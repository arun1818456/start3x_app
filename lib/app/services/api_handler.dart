import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:start3x_app/app/constants/api_constant.dart';
import 'package:start3x_app/app/routes/routes.dart';
import 'package:start3x_app/app/services/app_exception.dart';
import 'package:start3x_app/app/widgets/common_dialogs.dart';

enum REQUEST { get, post, put, patch, delete }

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

Future<dynamic> httpRequest(
  REQUEST requestType,
  String url,
  dynamic data, {
  String token = "",
}) async {
  dynamic responseJson;
  data = jsonEncode(data);
  dynamic value;
  if (kDebugMode) {
    log(
      "$requestType ${data != "{}" ? "DataSend:- $data" : ""} Token:- ${token.isNotEmpty} \n Url 👉 ${getUrl(url)}",
    );
  }

  try {
    final result = await InternetAddress.lookup('google.com');

    if (result.isEmpty || result[0].rawAddress.isEmpty) {
      _showNoInternetDialog();
      throw FetchDataException("No Internet Connection");
    }
  } on SocketException {
    _showNoInternetDialog();
    throw FetchDataException("No Internet Connection");
  }

  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      switch (requestType) {
        case REQUEST.get:
          value = await http.get(
            getUrl(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          );
          break;
        case REQUEST.post:
          value = await http.post(
            getUrl(url),
            headers: token.isEmpty
                ? {"Content-Type": "application/json"}
                : {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
            body: data,
          );
          break;
        case REQUEST.put:
          value = await http.put(
            getUrl(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: data,
          );
          break;
        case REQUEST.patch:
          value = await http.patch(
            getUrl(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: data,
          );
          break;
        case REQUEST.delete:
          value = await http.delete(
            getUrl(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: data,
          );
          break;
      }
    }
    if (kDebugMode) {
      final decoded = safeDecode(value.body);
      final prettyString = const JsonEncoder.withIndent('  ').convert(decoded);
      log("Response 👉 ${value.statusCode} $prettyString");
    }
    if (value.statusCode == 401 &&
        (jsonDecode(value.body)["message"].toString() ==
                "Please authenticate" ||
            jsonDecode(value.body)["message"].toString() == "Invalid token")) {
      showAuthDialog(
        title: "Session Expired",
        description: "Your session has expired. Please login again.",
      );
      return {};
    } else if (value.statusCode == 404 &&
        jsonDecode(value.body)["message"].toString() == "User not found") {
      showAuthDialog(
        title: "User Not Found",
        description: "Please Contact Admin",
      );
      return {};
    } else {
      responseJson = returnResponse(value);
    }
  } on SocketException catch (_) {
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
    throw FetchDataException("No Internet Connection");
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

void showAuthDialog({required String title, required String description}) {
  if (Get.isDialogOpen == true) return;

  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () async {
            await GetStorage().erase();
            Get.back();
            Get.toNamed(AppRoutes.loginScreen);
          },
          child: const Text("OK"),
        ),
      ],
    ),
    barrierDismissible: false,
  );
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
