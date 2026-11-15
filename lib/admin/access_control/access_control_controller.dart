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

  // --- Fetch & Show Users Logged in with this Passkey ---
  var isLoadingUsers = false.obs;
  final RxList<UserDataModel> passkeyUsers = <UserDataModel>[].obs;

  Future<void> fetchUsersForPasskey(String passkey) async {
    try {
      isLoadingUsers.value = true;
      passkeyUsers.clear();
      var res = await httpRequest(
        REQUEST.get,
        "$getPasskeyUsersApiEndPoint$passkey",
        {},
      );
      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        passkeyUsers.value =
            dataList.map((item) => UserDataModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching passkey users: $e");
    } finally {
      isLoadingUsers.value = false;
    }
  }

  String formatUserDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final hour = (dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$day/$month/${dt.year} $hour:$minute $period';
    } catch (_) {
      return raw;
    }
  }

  void showPasskeyUsersDialog(BuildContext context, AccessClientModel client) {
    fetchUsersForPasskey(client.id);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
              maxWidth: 450,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          client.rank,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Key: ${client.id}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => copySpecificPasskey(client.id),
                                  child: const Icon(
                                    Icons.copy_rounded,
                                    size: 14,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textDark),
                        onPressed: () => Navigator.of(ctx).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Users List / Loading / Empty State
                Flexible(
                  child: Obx(() {
                    if (isLoadingUsers.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryBlue),
                            SizedBox(height: 12),
                            Text(
                              'Loading users...',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (passkeyUsers.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_off_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No users logged in with this passkey yet',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Users will appear here once they log in using this passkey.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Counter Strip
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          color: Colors.grey.shade100,
                          child: Text(
                            'Logged in Users (${passkeyUsers.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),

                        // List of Users
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            itemCount: passkeyUsers.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 12, color: Colors.black12),
                            itemBuilder: (context, index) {
                              final user = passkeyUsers[index];
                              final String initial = (user.name != null && user.name!.trim().isNotEmpty)
                                  ? user.name!.trim()[0].toUpperCase()
                                  : 'U';
                              final bool isSetup = user.isSetupComplete == true;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Profile Avatar
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                                      backgroundImage: (user.profileUrl != null && user.profileUrl!.isNotEmpty)
                                          ? NetworkImage(user.profileUrl!)
                                          : null,
                                      child: (user.profileUrl == null || user.profileUrl!.isEmpty)
                                          ? Text(
                                              initial,
                                              style: const TextStyle(
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),

                                    // User Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  user.name ?? 'Unknown User',
                                                  style: const TextStyle(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textDark,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: (user.role?.toLowerCase() == 'admin')
                                                      ? Colors.orange.shade100
                                                      : Colors.blue.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  (user.role ?? 'USER').toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: (user.role?.toLowerCase() == 'admin')
                                                        ? Colors.orange.shade900
                                                        : AppColors.primaryBlue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            user.email ?? '',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: AppColors.textGrey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                isSetup ? Icons.check_circle_rounded : Icons.pending_rounded,
                                                size: 13,
                                                color: isSetup ? Colors.green.shade700 : Colors.amber.shade800,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isSetup ? 'Setup Complete' : 'Setup Pending',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isSetup ? Colors.green.shade700 : Colors.amber.shade800,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (user.createdAt != null && user.createdAt!.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Text(
                                                  '•  ${formatUserDate(user.createdAt)}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textGrey,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                // Bottom Close Button
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
