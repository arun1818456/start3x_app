import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:start3x_app/widgets/responsive_layout.dart';
import 'package:start3x_app/exports.dart';

class BottomBar extends StatelessWidget with BaseClass {
  BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = getUserData();
    final bool isAdmin = user.role == 'admin';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (isAdmin) {
          Get.offAll(() => const AdminDashboardScreen());
        } else {
          CommonDialogs().showCustomDialog(
            context,
            title: "Exit App",
            description: "Are you sure you want to exit the app?",
            yesButtonText: "Exit",
            noButtonText: "Cancel",
            onTapYes: () {
              if (!kIsWeb) SystemNavigator.pop();
            },
          );
        }
      },
      child: GetBuilder<BottomController>(
        init: BottomController(),
        builder: (controller) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool useRail =
                  kIsWeb && constraints.maxWidth >= Breakpoints.mobile;

              if (useRail) {
                return _buildWebLayout(controller, constraints);
              }
              return _buildMobileLayout(controller);
            },
          );
        },
      ),
    );
  }

  /// Web layout: NavigationRail on the left + content area
  Widget _buildWebLayout(
      BottomController controller, BoxConstraints constraints) {
    final bool isDesktop = constraints.maxWidth >= Breakpoints.tablet;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Row(
        children: [
          // Side Navigation Rail
          NavigationRail(
            backgroundColor: AppColors.primaryBlue,
            selectedIndex: controller.selectedIndex,
            onDestinationSelected: (index) => controller.onItemTapped(index),
            extended: isDesktop,
            minExtendedWidth: 200,
            minWidth: 72,
            labelType: isDesktop
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedIconTheme:
                IconThemeData(color: Colors.white.withValues(alpha: 0.6)),
            indicatorColor: Colors.white.withValues(alpha: 0.2),
            leading: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: isDesktop ? 16 : 8,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      AppImages.logo,
                      height: isDesktop ? 40 : 30,
                      width: isDesktop ? 40 : 30,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primaryBlue,
                        size: 28,
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "Start3x",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.3),
                    thickness: 1,
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment_rounded),
                label: Text('To-Do'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.forum_outlined),
                selectedIcon: Icon(Icons.forum_rounded),
                label: Text('Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_rounded),
                selectedIcon: Icon(Icons.bar_chart_rounded),
                label: Text('Insights'),
              ),
            ],
          ),

          // Vertical divider
          Container(
            width: 1,
            color: Colors.grey.shade200,
          ),

          // Content area
          Expanded(
            child: IndexedStack(
              index: controller.selectedIndex,
              children: controller.pages,
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile layout: original bottom navigation bar
  Widget _buildMobileLayout(BottomController controller) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: IndexedStack(
        index: controller.selectedIndex,
        children: controller.pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: _buildFloatingBottomNav(controller),
      ),
    );
  }

  Widget _buildFloatingBottomNav(BottomController controller) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
            controller: controller,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment_rounded,
            label: 'To-Do',
            controller: controller,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.forum_outlined,
            selectedIcon: Icons.forum_rounded,
            label: 'Chat',
            controller: controller,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.bar_chart_rounded,
            selectedIcon: Icons.bar_chart_rounded,
            label: 'Insights',
            controller: controller,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required BottomController controller,
  }) {
    final bool isSelected = controller.selectedIndex == index;
    return GestureDetector(
      onTap: () => controller.onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
