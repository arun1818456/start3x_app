import 'package:start3x_app/exports.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientManagementController(), permanent: true);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Bar ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    onPressed: controller.logout,
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            // --- Body Content ---
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    // Card 1: My clientele
                    _buildDashboardCard(
                      icon: const Icon(
                        Icons.groups_rounded,
                        color: AppColors.primaryBlue,
                        size: 46,
                      ),
                      title: 'My clientele',
                      onTap: controller.onTapMyClientele,
                    ),

                    const SizedBox(height: 24),

                    // Card 2: Access Control
                    _buildDashboardCard(
                      icon: const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.primaryBlue,
                        size: 46,
                      ),
                      title: 'Access Control',
                      onTap: controller.onTapAccessControl,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Left Icon Area
            SizedBox(
              width: 100,
              child: Center(child: icon),
            ),

            // Vertical Divider
            Container(
              width: 1,
              height: 60,
              color: Colors.black12,
            ),

            // Right Title Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
