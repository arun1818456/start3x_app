import 'package:start3x_app/exports.dart';

class SideMenuBar extends StatelessWidget {
  const SideMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
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
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(
                      Icons.person,
                      size: 36,
                      color: AppColors.darkCardBg,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name & Subtitle
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lehraj Mehra',
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'lehraj@gmail.com',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
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
                  Get.snackbar('Logout', 'User logged out successfully');
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
