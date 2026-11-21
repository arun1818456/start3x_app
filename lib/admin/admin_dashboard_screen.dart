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
                vertical: isWide ? 20 : 14,
                horizontal: isWide ? 40 : 20,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
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
                          height: 38,
                          width: 38,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: AppColors.primaryBlue,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Portal',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (isWide)
                            const Text(
                              'Manage clients, licenses & global access control',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textGrey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.logout,
                    icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                    label: Text(
                      isWide ? 'Sign Out' : '',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 16 : 8,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Body Canvas ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 20,
                  vertical: 36,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select an administrative workflow to manage your client accounts.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 28),

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
                                const SizedBox(height: 18),
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
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textGrey,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Open section',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
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
