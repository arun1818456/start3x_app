import 'package:start3x_app/exports.dart';

class SideMenuBar extends StatelessWidget with BaseClass {
  SideMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = getUserData();
    String displayName =
        (user.name != null && user.name!.trim().isNotEmpty)
            ? user.name!.trim()
            : 'User';
    String displaySubtitle =
        (user.email != null && user.email!.trim().isNotEmpty)
            ? user.email!.trim()
            : (user.passkey != null && user.passkey!.trim().isNotEmpty
                ? 'Passkey: ${user.passkey}'
                : '');

    String activePasskey = '';
    dynamic activeClientObj;

    // Resolve active client/passkey if Admin is viewing a client
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        if (Get.arguments['client'] != null) {
          activeClientObj = Get.arguments['client'];
          if (activeClientObj is ClientModel) {
            if (activeClientObj.name.isNotEmpty) displayName = activeClientObj.name;
            activePasskey = activeClientObj.passkey;
            if (activePasskey.isNotEmpty) displaySubtitle = 'Passkey: $activePasskey';
          } else if (activeClientObj is AccessClientModel) {
            if (activeClientObj.name.isNotEmpty) displayName = activeClientObj.name;
            activePasskey = activeClientObj.id;
            if (activePasskey.isNotEmpty) displaySubtitle = 'Passkey: $activePasskey';
          }
        }
        if (activePasskey.isEmpty && Get.arguments['passkey'] != null) {
          activePasskey = Get.arguments['passkey'].toString();
          displaySubtitle = 'Passkey: $activePasskey';
        }
      } else if (Get.arguments is ClientModel) {
        activeClientObj = Get.arguments as ClientModel;
        displayName = (Get.arguments as ClientModel).name;
        activePasskey = (Get.arguments as ClientModel).passkey;
        displaySubtitle = 'Passkey: $activePasskey';
      } else if (Get.arguments is AccessClientModel) {
        activeClientObj = Get.arguments as AccessClientModel;
        displayName = (Get.arguments as AccessClientModel).name;
        activePasskey = (Get.arguments as AccessClientModel).id;
        displaySubtitle = 'Passkey: $activePasskey';
      } else if (Get.arguments is String) {
        activePasskey = Get.arguments as String;
        displaySubtitle = 'Passkey: $activePasskey';
      }
    }

    if (activePasskey.isEmpty && Get.isRegistered<HomeController>()) {
      activePasskey = Get.find<HomeController>().clientPasskey;
    }

    if (activePasskey.isEmpty) {
      activePasskey = storage.read('clientPasskey')?.toString() ?? '';
    }

    if (activePasskey.isEmpty) {
      activePasskey = user.passkey ?? '';
    }

    // If Admin is viewing a client screen but client object was not in arguments, try fetching from storage
    if (user.role == 'admin' && activePasskey.isNotEmpty && activePasskey != user.passkey) {
      displaySubtitle = 'Passkey: $activePasskey';
      final storedInfo = storage.read('clientInfo_$activePasskey');
      if (storedInfo != null && storedInfo is Map) {
        final compName = storedInfo['companyName'] ?? storedInfo['name'] ?? storedInfo['legalName'];
        if (compName != null && compName.toString().isNotEmpty) {
          displayName = compName.toString();
        }
      }
    } else if (user.role != 'admin') {
      final storedInfo = storage.read('clientInfo') ?? storage.read('savedClientSetup');
      if (storedInfo != null && storedInfo is Map) {
        final compName = storedInfo['companyName'] ?? storedInfo['name'] ?? storedInfo['legalName'];
        if (compName != null && compName.toString().isNotEmpty) {
          displayName = compName.toString();
        }
      }
    }

    return Drawer(
      backgroundColor: AppColors.whiteColor,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // --- Drawer Header with Profile Photo & Name ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
              ),
              child: Row(
                children: [
                  // Profile Photo / CircleAvatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (displaySubtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            displaySubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Menu Items ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildMenuItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    onTap: () {
                      Get.back();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.business_rounded,
                    title: 'Business Details',
                    onTap: () {
                      Get.back();
                      Get.toNamed(
                        AppRoutes.clientSetupScreen,
                        arguments: {
                          'fromMenu': true,
                          'passkey': activePasskey,
                          'client': activeClientObj,
                        },
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.groups_rounded,
                    title: 'Team',
                    onTap: () {
                      Get.back();
                      Get.toNamed(
                        AppRoutes.teamScreen,
                        arguments: {
                          'passkey': activePasskey,
                          'client': activeClientObj,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // --- Logout Tile ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                tileColor: Colors.red.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Get.back();
                  CommonDialogs().showCustomDialog(
                    Get.context!,
                    title: "Logout Confirmation",
                    description:
                        "Are you sure you want to logout? All local storage data will be cleared.",
                    yesButtonText: "Logout",
                    noButtonText: "Cancel",
                    onTapYes: () async {
                      if (Get.isRegistered<MySocketController>()) {
                        Get.find<MySocketController>().disconnectSocket();
                      }
                      await storage.erase();
                      Get.offAllNamed(AppRoutes.loginScreen);
                      showMySnackBar("Logged out successfully", success: true);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryBlue,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 2,
      ),
      onTap: onTap,
    );
  }
}
