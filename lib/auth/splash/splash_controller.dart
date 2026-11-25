import 'dart:async';
import 'package:start3x_app/exports.dart';

class SplashController extends GetxController with BaseClass {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _navigateToNextScreen() {
    _timer = Timer(const Duration(seconds: 2), () async {
      if (isLoggedIn()) {
        final bool sessionValid = await _verifyActiveSession();
        if (!sessionValid) return;

        _syncDeviceToken();
        UserDataModel userData = getUserData();
        if (userData.role == "admin") {
          Get.offAllNamed(AppRoutes.adminDashboardScreen);
        } else {
          if (userData.isSetupComplete ?? false) {
            Get.offAllNamed(AppRoutes.mainScreen);
          } else {
            Get.offAllNamed(AppRoutes.clientSetupScreen);
          }
        }
      } else {
        Get.offAllNamed(AppRoutes.loginScreen);
      }
    });
  }

  Future<bool> _verifyActiveSession() async {
    try {
      final jwt = getUserData().token ?? "";
      if (jwt.isEmpty) return true;

      final res = await httpRequest(
        REQUEST.get,
        userDetailsApiEndPoint,
        {},
        token: jwt,
      );
      if (res == null || (res is Map && res.isEmpty)) {
        // 401 handler already triggered forceLogoutToLogin
        return false;
      }
      return true;
    } catch (_) {
      // Allow offline fallback if network temporarily unreachable
      return true;
    }
  }

  void _syncDeviceToken() async {
    try {
      final token = await getDeviceToken();
      final jwt = getUserData().token ?? "";
      if (token.isNotEmpty && jwt.isNotEmpty) {
        await httpRequest(
          REQUEST.put,
          updateDeviceTokenApiEndPoint,
          {"deviceToken": token},
          token: jwt,
        );
      }
    } catch (e) {
      debugPrint("Device token sync error: $e");
    }
  }
}
