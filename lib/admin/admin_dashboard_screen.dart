import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:start3x_app/widgets/responsive_layout.dart';
import 'package:start3x_app/exports.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientManagementController(), permanent: true);
    final bool isWide = kIsWeb && MediaQuery.of(context).size.width >= Breakpoints.mobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // --- Modern Web App Bar ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isWide ? 20 : 12,
                horizontal: isWide ? 40 : 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppImages.logo,
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Admin Portal',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (isWide)
                                const Text(
                                  'Manage clients, licenses & global access control',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            Get.toNamed(AppRoutes.notificationsScreen),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppColors.primaryBlue
                                  .withValues(alpha: 0.3)),
                          minimumSize: Size(isWide ? 44 : 40, isWide ? 42 : 40),
                          padding: EdgeInsets.all(isWide ? 10 : 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      isWide
                          ? OutlinedButton.icon(
                              onPressed: controller.logout,
                              icon: const Icon(Icons.logout_rounded,
                                  size: 18, color: Colors.red),
                              label: const Text(
                                'Sign Out',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.red.withValues(alpha: 0.3)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: controller.logout,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.red.withValues(alpha: 0.3)),
                                minimumSize: const Size(40, 40),
                                padding: const EdgeInsets.all(8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Icon(Icons.logout_rounded,
                                  size: 18, color: Colors.red),
                            ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Body Canvas ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 14,
                  vertical: isWide ? 36 : 18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview & Controls',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select an administrative workflow to manage your client accounts.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Cards (Grid on web/desktop, column on mobile)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 600) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildModernDashboardCard(
                                      icon: Icons.groups_rounded,
                                      accentColor: const Color(0xFF007AFF),
                                      title: 'My Clientele',
                                      description:
                                          'Explore registered clients, assign leads, review live status, and drill down into details.',
                                      badgeText: 'Live Accounts',
                                      onTap: controller.onTapMyClientele,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _buildModernDashboardCard(
                                      icon: Icons.verified_user_rounded,
                                      accentColor: const Color(0xFF10B981),
                                      title: 'Access Control',
                                      description:
                                          'Issue and revoke client passkeys, grant permissions, and configure access limits.',
                                      badgeText: 'Security & Auth',
                                      onTap: controller.onTapAccessControl,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _buildModernDashboardCard(
                                  icon: Icons.groups_rounded,
                                  accentColor: const Color(0xFF007AFF),
                                  title: 'My Clientele',
                                  description:
                                      'Explore registered clients, assign leads, and drill down into details.',
                                  badgeText: 'Live Accounts',
                                  onTap: controller.onTapMyClientele,
                                ),
                                const SizedBox(height: 12),
                                _buildModernDashboardCard(
                                  icon: Icons.verified_user_rounded,
                                  accentColor: const Color(0xFF10B981),
                                  title: 'Access Control',
                                  description:
                                      'Issue and revoke client passkeys and configure access limits.',
                                  badgeText: 'Security & Auth',
                                  onTap: controller.onTapAccessControl,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDashboardCard({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String description,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Open section',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: accentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
