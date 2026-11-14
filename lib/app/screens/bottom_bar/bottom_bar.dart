import 'package:flutter/services.dart';
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
              SystemNavigator.pop();
            },
          );
        }
      },
      child: GetBuilder<BottomController>(
        init: BottomController(),
        builder: (controller) {
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
        },
      ),
    );
  }

  Widget _buildFloatingBottomNav(BottomController controller) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12, top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
