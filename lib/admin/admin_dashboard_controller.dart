import 'package:start3x_app/exports.dart';

class AdminDashboardController extends GetxController with BaseClass {
  void onTapMyClientele() {
    Get.to(() => const ClientsScreen());
  }

  void onTapAccessControl() {
    Get.to(() => const AccessControlScreen());
  }

  void logout() {
    CommonDialogs().showCustomDialog(
      Get.context!,
      title: "Logout Confirmation",
      description:
          "Are you sure you want to logout? All local storage data will be cleared.",
      yesButtonText: "Logout",
      noButtonText: "Cancel",
      onTapYes: () async {
        await storage.erase();
        Get.offAllNamed(AppRoutes.loginScreen);
        showMySnackBar("Logged out successfully", success: true);
      },
    );
  }
}
