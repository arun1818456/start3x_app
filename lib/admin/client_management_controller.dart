import 'package:start3x_app/exports.dart';

class ClientManagementController extends GetxController with BaseClass {

  RxList<AccessClientModel> clients = <AccessClientModel>[].obs;
  var isLoading = false.obs;
  var isFetched = false;

  @override
  void onInit() {
    super.onInit();
    fetchPasskeys();
  }

  // --- Fetch & Manage Clients Data ---
  Future<void> fetchPasskeys({bool force = false}) async {
    if (isFetched && !force) return;

    try {
      isLoading.value = true;
      var res = await httpRequest(REQUEST.get, listPasskeysApiEndPoint, {});
      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        clients.value = dataList
            .map((item) => AccessClientModel.fromJson(item))
            .toList();
        isFetched = true;
      }
    } catch (e) {
      // Keep existing list on error
    } finally {
      isLoading.value = false;
    }
  }

  void addClient(AccessClientModel newClient) {
    clients.add(newClient);
  }

  // --- Dashboard Navigation & Actions ---
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
        if (Get.isRegistered<ClientManagementController>()) {
          Get.delete<ClientManagementController>(force: true);
        }
        Get.offAllNamed(AppRoutes.loginScreen);
        showMySnackBar("Logged out successfully", success: true);
      },
    );
  }
}
