import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:start3x_app/admin/client_management_controller.dart';
import 'package:start3x_app/constants/api_constant.dart';
import 'package:start3x_app/constants/local_keys.dart';
import 'package:start3x_app/routes/routes.dart';
import 'package:start3x_app/services/app_exception.dart';
import 'package:start3x_app/services/socket_controller.dart';
import 'package:start3x_app/widgets/common_dialogs.dart';

enum REQUEST { get, post, put, patch, delete }

bool _isHandlingAuthLogout = false;

Uri getUrl(String methodName) {
  if (methodName.contains("http")) {
    return Uri.parse(methodName);
  } else {
    return Uri.parse(baseUrl + methodName);
  }
}

dynamic safeDecode(String body) {
  try {
    return jsonDecode(body);
  } catch (e) {
    debugPrint("Failed to decode JSON: $e");
    throw FetchDataException("Invalid JSON response from server.");
  }
}

String _resolveStoredToken(String url, String explicitToken) {
  if (explicitToken.isNotEmpty) return explicitToken;
  if (url.contains("http")) return "";
  if (url.contains(loginApiEndPoint) ||
      url.contains(signUpApiEndPoint) ||
      url.contains(googleLoginApiEndPoint)) {
    return "";
  }
  try {
    final uData = GetStorage().read(LocalKeys.userData);
    return uData?['token']?.toString() ?? "";
  } catch (_) {
    return "";
  }
}

Future<dynamic> httpRequest(
  REQUEST requestType,
  String url,
  dynamic data, {
  String token = "",
}) async {
  dynamic responseJson;
  data = jsonEncode(data);
  dynamic value;
  final resolvedToken = _resolveStoredToken(url, token);

  if (kDebugMode) {
    log(
      "$requestType ${data != "{}" ? "DataSend:- $data" : ""} Token:- ${resolvedToken.isNotEmpty} \n Url \u{1F449} ${getUrl(url)}",
    );
  }

  final Map<String, String> authHeaders = resolvedToken.isEmpty
      ? {"Content-Type": "application/json"}
      : {
          "Content-Type": "application/json",
          "Authorization": "Bearer $resolvedToken",
        };

  try {
    switch (requestType) {
      case REQUEST.get:
        value = await http.get(getUrl(url), headers: authHeaders);
        break;
      case REQUEST.post:
        value = await http.post(getUrl(url), headers: authHeaders, body: data);
        break;
      case REQUEST.put:
        value = await http.put(getUrl(url), headers: authHeaders, body: data);
        break;
      case REQUEST.patch:
        value = await http.patch(getUrl(url), headers: authHeaders, body: data);
        break;
      case REQUEST.delete:
        value = await http.delete(getUrl(url), headers: authHeaders, body: data);
        break;
    }

    if (kDebugMode) {
      final decoded = safeDecode(value.body);
      final prettyString = const JsonEncoder.withIndent('  ').convert(decoded);
      log("Response \u{1F449} ${value.statusCode} $prettyString");
    }

    if (value.statusCode == 401) {
      final decoded = jsonDecode(value.body);
      final msg = decoded["message"]?.toString() ?? "Session expired";
      final bool isSessionExpired = decoded["sessionExpired"] == true ||
          msg == "Please authenticate" ||
          msg == "Invalid token" ||
          msg.toLowerCase().contains("another device");
      if (isSessionExpired) {
        forceLogoutToLogin(
          title: "Session Expired",
          description: decoded["sessionExpired"] == true
              ? msg
              : "Your session has expired. Please login again.",
        );
        return {};
      }
    } else if (value.statusCode == 404 &&
        jsonDecode(value.body)["message"].toString() == "User not found") {
      forceLogoutToLogin(
        title: "User Not Found",
        description: "Please Contact Admin",
      );
      return {};
    }

    responseJson = returnResponse(value);
  } on http.ClientException catch (_) {
    // Works on both web and mobile (replaces SocketException + InternetAddress)
    _showNoInternetDialog();
    throw FetchDataException("No Internet Connection");
  } catch (e) {
    if (e is AppException) rethrow;
    if (Get.context != null) {
      CommonDialogs().showCustomDialog(
        Get.context!,
        title: "Server Error",
        description: "Please update the app \nor try after some time",
        yesButtonText: "OK",
        noButtonText: "",
        onTapYes: () {},
      );
    }
    throw FetchDataException("Network error: $e");
  }
  return responseJson;
}

@visibleForTesting
dynamic returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      return jsonDecode(response.body);
    case 201:
      return jsonDecode(response.body);
    case 204:
      return {};
    case 400:
      throw BadRequestException(getMessage(response));
    case 401:
      throw BadRequestException(getMessage(response));
    case 403:
      throw UnauthorisedException(getMessage(response));
    case 500:
      throw UnauthorisedException(getMessage(response));
    case 404:
      throw BadRequestException(getMessage(response));
    case 406:
      throw BadRequestException(getMessage(response));

    default:
      throw FetchDataException(
        'Error occurred while communication with server with status code : ${response.statusCode}',
      );
  }
}

Future<void> forceLogoutToLogin({
  required String title,
  required String description,
}) async {
  if (_isHandlingAuthLogout) return;
  _isHandlingAuthLogout = true;

  try {
    if (Get.isRegistered<MySocketController>()) {
      Get.find<MySocketController>().disconnectSocket();
    }
    await GetStorage().erase();
    if (Get.isRegistered<ClientManagementController>()) {
      Get.delete<ClientManagementController>(force: true);
    }
  } catch (_) {}

  if (Get.currentRoute != AppRoutes.loginScreen) {
    Get.offAllNamed(AppRoutes.loginScreen);
  }

  Future.delayed(const Duration(milliseconds: 150), () {
    if (Get.context != null && Get.isDialogOpen != true) {
      Get.dialog(
        AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                if (Get.isDialogOpen == true) Get.back();
              },
              child: const Text("OK"),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
    _isHandlingAuthLogout = false;
  });
}

void showAuthDialog({required String title, required String description}) {
  forceLogoutToLogin(title: title, description: description);
}

String getMessage(http.Response response) {
  try {
    dynamic responseJson = jsonDecode(response.body);
    String? msg = responseJson['message'];
    if (msg != null) {
      return msg.contains("HandshakeException") ? "no_internet" : msg;
    } else {
      return "Please Refresh Page Network Problem";
    }
  } catch (e) {
    return "Please Refresh Page Network Problem";
  }
}

void _showNoInternetDialog() {
  if (Get.isDialogOpen == true) return;

  if (Get.context != null) {
    CommonDialogs().showCustomDialog(
      Get.context!,
      title: "No Internet Connection",
      description: "Please check your internet connection.",
      yesButtonText: "OK",
      noButtonText: "",
      onTapYes: () {},
    );
  }
}
