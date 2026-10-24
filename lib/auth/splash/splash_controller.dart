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
        final userData = storage.read(LocalKeys.userData);
        if (userData != null && userData['isAdmin'] == true) {
          Get.offAllNamed(AppRoutes.adminDashboardScreen);
        } else {
          Get.offAllNamed(AppRoutes.mainScreen);
        }
      } else {
        Get.offAllNamed(AppRoutes.loginScreen);
      }
    });
  }
}
