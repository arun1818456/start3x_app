import 'package:start3x_app/exports.dart';

class AdminDashboardController extends GetxController with BaseClass {
  void onTapMyClientele() {
    Get.to(() => const ClientsScreen());
  }

  void onTapAccessControl() {
    Get.to(() => const AccessControlScreen());
  }

  void logout() {
    storage.remove(LocalKeys.userData);
    Get.offAllNamed(AppRoutes.loginScreen);
  }
}
