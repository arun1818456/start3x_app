import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:start3x_app/constants/local_keys.dart';
import 'package:start3x_app/app/models/user_model.dart';
import 'package:start3x_app/widgets/full_screen_loader.dart';

mixin BaseClass {
  final GetStorage storage = GetStorage();

  UserDataModel getUserData() {
    if (storage.hasData(LocalKeys.userData)) {
      return UserDataModel.fromJson(storage.read(LocalKeys.userData));
    } else {
      return UserDataModel();
    }
  }

  bool isLoggedIn() {
    return storage.hasData(LocalKeys.userData);
  }

  void keyBoardOff() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  Future<String> getDeviceToken() async {
    try {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String? token = await FirebaseMessaging.instance.getToken();
        debugPrint("🔥 FCM Device Token: $token");
        if (token != null && token.isNotEmpty) {
          storage.write(LocalKeys.fcmToken, token);
        }
        return token ?? "";
      } else {
        debugPrint("Notification permission denied");
        return "";
      }
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
      return "";
    }
  }

  void showCircularLoader({String message = "Please wait"}) {
    Get.dialog(LoadingDialog(message: message), barrierDismissible: false);
  }

  void hideCircularLoader() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  void showMySnackBar(
    String message, {
    bool error = false,
    int? second = 2,
    bool success = false,
    bool alert = false,
  }) {
    final context = Get.context;
    final bool isWide = context != null && MediaQuery.of(context).size.width >= 600;
    final double screenWidth = context != null ? MediaQuery.of(context).size.width : 400;

    // Toast width for web/desktop vs mobile
    final double toastWidth = isWide ? 400.0 : (screenWidth - 32);
    final double horizontalMargin = isWide ? (screenWidth - toastWidth) / 2 : 16.0;

    final Color bgColor = success
        ? const Color(0xFF16A34A)
        : alert
            ? const Color(0xFFEA580C)
            : const Color(0xFFDC2626);

    final IconData icon = success
        ? Icons.check_circle_rounded
        : alert
            ? Icons.warning_amber_rounded
            : Icons.error_outline_rounded;

    Get.showSnackbar(
      GetSnackBar(
        messageText: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: Duration(seconds: second ?? 3),
        margin: EdgeInsets.only(
          left: horizontalMargin,
          right: horizontalMargin,
          top: isWide ? 20 : 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 12,
        snackPosition: SnackPosition.TOP,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
  String getFormattedCurrentDateTime() {
    final now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String year = now.year.toString();
    final String hour = (now.hour % 12 == 0 ? 12 : now.hour % 12)
        .toString()
        .padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    final String period = now.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year $hour:$minute $period';
  }
}
