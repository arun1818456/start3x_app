import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:start3x_app/app/constants/colors.dart';
import 'package:start3x_app/app/constants/image_constants.dart';
import 'package:start3x_app/app/screens/splash/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildBody(),
        );
      },
    );
  }

  /// Builds the body of the Splash Screen.
  Widget _buildBody() {
    return SizedBox(
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            AppImages.splashLogo,
            height: 250,
            width: 250,
          ),
          const Spacer(),
          const LinearProgressIndicator(
            color: AppColors.primaryBlue,
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}
