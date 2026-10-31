import 'package:flutter/services.dart';
import 'package:start3x_app/exports.dart';

class AccessControlController extends GetxController with BaseClass {
  var generatedPasskey = '000000000000'.obs;
  var searchQuery = ''.obs;
  RxList<AccessClientModel> get clients => clientManagement.clients;
  RxBool get isLoading => clientManagement.isLoading;

  ClientManagementController get clientManagement {
    if (!Get.isRegistered<ClientManagementController>()) {
      return Get.put(ClientManagementController(), permanent: true);
    }
    return Get.find<ClientManagementController>();
  }



  @override
  void onInit() {
    super.onInit();
    clientManagement.fetchPasskeys();
  }

  List<AccessClientModel> get filteredClients {
    if (searchQuery.value.trim().isEmpty) {
      return clients;
    }
    final q = searchQuery.value.toLowerCase().trim();
    return clients.where((c) {
      return c.rank.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.id.toLowerCase().contains(q);
    }).toList();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  Future<void> fetchPasskeys() async {
    await clientManagement.fetchPasskeys(force: true);
  }

  Future<void> generatePasskey() async {
    try {
      showCircularLoader();
      var res = await httpRequest(
        REQUEST.post,
        generatePasskeyApiEndPoint,
        {},
        token: getUserData().token ?? "",
      );
      hideCircularLoader();

      if (res != null && res["success"] == true && res["data"] != null) {
        final newClient = AccessClientModel.fromJson(res["data"]);
        generatedPasskey.value = newClient.id; // Backend generated Passkey ID
        clientManagement.addClient(newClient);
        showMySnackBar('New Passkey: ${newClient.id}', success: true);
      } else {
        showMySnackBar(
          res?["message"] ?? 'Failed to generate passkey',
          alert: true,
        );
      }
    } catch (e) {
      hideCircularLoader();
      showMySnackBar(e.toString(), error: true);
    }
  }

  void copyPasskeyToClipboard() {
    if (generatedPasskey.value != '000000000000') {
      Clipboard.setData(ClipboardData(text: generatedPasskey.value));
      showMySnackBar('Passkey copied to clipboard!', success: true);
    }
  }

  void copySpecificPasskey(String passkey) {
    if (passkey.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: passkey));
      showMySnackBar('Passkey copied: $passkey', success: true);
    }
  }

  Future<void> togglePasskey(AccessClientModel client, bool value) async {
    if(Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    client.isActive.value = value;
    try {
      var res = await httpRequest(
        REQUEST.put,
        "$togglePasskeyApiEndPoint${client.id}",
        {"isActive": value},
      );
      if (res != null && res["success"] == true) {
        showMySnackBar(
          'Passkey ${value ? "Activated" : "Deactivated"}',
          success: value,
          alert: !value,
        );
      }
    } catch (e) {
      // Fallback revert if network fails
      client.isActive.value = !value;
      showMySnackBar('Failed to update status', error: true);
    }
  }
}
