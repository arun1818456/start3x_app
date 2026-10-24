import 'package:flutter/services.dart';
import 'package:start3x_app/admin/models/access_model.dart';
import 'package:start3x_app/exports.dart';

class AccessControlController extends GetxController with BaseClass {
  var generatedPasskey = '000000000000'.obs;
  var searchQuery = ''.obs;

  RxList<AccessClientModel> clients = <AccessClientModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPasskeys();
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
    try {
      var res = await httpRequest(REQUEST.get, listPasskeysApiEndPoint, {});
      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        clients.value = dataList
            .map((item) => AccessClientModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      // Keep existing list on error
    }
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
        clients.add(newClient);
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

  Future<void> removeClient(AccessClientModel client) async {
    clients.remove(client);

    try {
      await httpRequest(
        REQUEST.delete,
        "$deletePasskeyApiEndPoint${client.id}",
        {},
      );
    } catch (e) {
      // Ignored
    }

    showMySnackBar(
      'Client ${client.rank} removed from access control',
      alert: true,
    );
  }
}
