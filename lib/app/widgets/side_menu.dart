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

    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        final clientObj = Get.arguments['client'];
        if (clientObj != null) {
          if (clientObj is ClientModel) {
            if (clientObj.name.isNotEmpty) displayName = clientObj.name;
            if (clientObj.passkey.isNotEmpty) {
              displaySubtitle = 'Passkey: ${clientObj.passkey}';
            }
          } else if (clientObj is AccessClientModel) {
            if (clientObj.name.isNotEmpty) displayName = clientObj.name;
            displaySubtitle = 'Passkey: ${clientObj.id}';
          }
        } else if (Get.arguments['passkey'] != null) {
          displaySubtitle = 'Passkey: ${Get.arguments['passkey']}';
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
                    icon: Icons.assignment_rounded,
                    title: "To-Do List",
                    onTap: () {
                      Get.back();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.forum_rounded,
                    title: 'Group Chat',
                    onTap: () {
                      Get.back();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Insights',
                    onTap: () {
                      Get.back();
                    },
                  ),
                  const Divider(indent: 20, endIndent: 20),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    onTap: () {
                      Get.back();
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
