import 'package:start3x_app/exports.dart';

class TeamController extends GetxController with BaseClass {
  var isLoading = false.obs;
  final RxList<UserDataModel> teamMembers = <UserDataModel>[].obs;
  final RxList<UserDataModel> filteredMembers = <UserDataModel>[].obs;
  final searchController = TextEditingController();
  final RxString passkey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    passkey.value = resolvePasskey();
    fetchTeamMembers();
  }

  String resolvePasskey() {
    String passkeyVal = '';
    if (Get.arguments != null) {
      if (Get.arguments is Map && Get.arguments['passkey'] != null) {
        passkeyVal = Get.arguments['passkey'].toString();
      } else if (Get.arguments is ClientModel) {
        passkeyVal = (Get.arguments as ClientModel).passkey;
      } else if (Get.arguments is AccessClientModel) {
        passkeyVal = (Get.arguments as AccessClientModel).id;
      } else if (Get.arguments is String) {
        passkeyVal = Get.arguments as String;
      }
    }

    if (passkeyVal.isEmpty && Get.isRegistered<HomeController>()) {
      final homePasskey = Get.find<HomeController>().clientPasskey;
      if (homePasskey.isNotEmpty) passkeyVal = homePasskey;
    }

    if (passkeyVal.isEmpty) {
      passkeyVal = storage.read('clientPasskey')?.toString() ?? '';
    }

    if (passkeyVal.isEmpty) {
      final userData = getUserData();
      passkeyVal = userData.passkey ??
          storage.read(LocalKeys.userData)?['passkey']?.toString() ??
          '';
    }

    return passkeyVal;
  }

  Future<void> fetchTeamMembers() async {
    if (passkey.value.isEmpty) {
      passkey.value = resolvePasskey();
    }

    if (passkey.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMySnackBar('Passkey not found', alert: true);
      });
      return;
    }

    try {
      isLoading.value = true;
      var res = await httpRequest(
        REQUEST.get,
        "$getPasskeyUsersApiEndPoint${passkey.value}",
        {},
      );
      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        final list =
            dataList.map((item) => UserDataModel.fromJson(item)).toList();
        teamMembers.value = list;
        filterMembers(searchController.text);
      } else {
        teamMembers.clear();
        filteredMembers.clear();
      }
    } catch (e) {
      debugPrint("Error fetching team members: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMySnackBar("Failed to load team members", error: true);
      });
    } finally {
      isLoading.value = false;
    }
  }

  void filterMembers(String query) {
    if (query.trim().isEmpty) {
      filteredMembers.value = List.from(teamMembers);
    } else {
      final q = query.toLowerCase().trim();
      filteredMembers.value = teamMembers.where((user) {
        final nameMatches = (user.name ?? '').toLowerCase().contains(q);
        final emailMatches = (user.email ?? '').toLowerCase().contains(q);
        final roleMatches = (user.role ?? '').toLowerCase().contains(q);
        return nameMatches || emailMatches || roleMatches;
      }).toList();
    }
  }

  String formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      return '$day/$month/$year';
    } catch (_) {
      return raw;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
