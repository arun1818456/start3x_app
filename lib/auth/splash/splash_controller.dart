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
    _timer = Timer(const Duration(seconds: 3), () {
      if (isLoggedIn()) {
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
}
