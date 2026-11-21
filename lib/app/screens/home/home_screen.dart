import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:start3x_app/widgets/responsive_layout.dart';
import 'package:start3x_app/exports.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final bool isWide = kIsWeb && MediaQuery.of(context).size.width >= Breakpoints.mobile;

    return Scaffold(
      backgroundColor: isWide ? Colors.grey.shade50 : AppColors.whiteColor,
      drawer: isWide ? null : SideMenuBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
            child: Container(
              color: AppColors.whiteColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
            children: [
              // --- Top App Bar / Header ---
              _buildTopHeader(context, controller),
              const SizedBox(height: 14),

              // --- Search Bar ---
              _buildSearchBar(controller),
              const SizedBox(height: 12),

              // --- Quick Filter Chips Bar ---
              _buildFilterChips(controller),
              const SizedBox(height: 14),

              // --- Dynamic Cards List with Pull-to-Refresh ---
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshLeads,
                  color: AppColors.primaryBlue,
                  child: Obx(
                    () {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          ),
                        );
                      }

                      final leadsList = controller.filteredLeads;
                      if (leadsList.isEmpty) {
                        String emptyText = 'No leads assigned yet';
                        if (controller.searchQuery.value.trim().isNotEmpty) {
                          emptyText =
                              'No leads matching "${controller.searchQuery.value}"';
                        } else if (controller.selectedSortOption.value ==
                            'Uncontacted Leads') {
                          emptyText = 'No uncontacted leads found';
                        } else if (controller.selectedSortOption.value ==
                            'Missed Tasks') {
                          emptyText = 'No missed tasks found';
                        }

                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.filter_list_off_rounded,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    emptyText,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (controller.selectedSortOption.value ==
                                          'Uncontacted Leads' ||
                                      controller.selectedSortOption.value ==
                                          'Missed Tasks' ||
                                      controller.searchQuery.value
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    TextButton.icon(
                                      onPressed: () {
                                        controller.searchQuery.value = '';
                                        controller.selectedSortOption.value =
                                            'Interaction Date';
                                      },
                                      icon: const Icon(Icons.refresh_rounded,
                                          size: 18),
                                      label: const Text('Reset Filters'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: leadsList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return LeadCardWidget(lead: leadsList[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),
);
}

  Widget _buildTopHeader(BuildContext context, HomeController controller) {
    final user = controller.getUserData();
    final bool isAdmin = user.role == 'admin';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Back Button (if Admin) + Side Menu Drawer Icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAdmin) ...[
              GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Get.back();
                  } else {
                    Get.offAll(() => const AdminDashboardScreen());
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.menu_rounded,
                    size: 28,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Centered Home Title
        const Text(
          'Home',
          style: AppTextStyles.headerTitle,
        ),

        // Sorted by Pill Button
        GestureDetector(
          onTap: () => controller.showSortBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  String label = controller.selectedSortOption.value;
                  if (label == 'Uncontacted Leads') label = 'Uncontacted';
                  if (label == 'Missed Tasks') label = 'Missed';
                  return Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  );
                }),
                const SizedBox(width: 4),
                const Icon(
                  Icons.tune_rounded,
                  size: 15,
                  color: AppColors.textDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(HomeController controller) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        onChanged: controller.updateSearch,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: AppColors.textDark, size: 20),
          hintText: 'Search leads by name, location, rank...',
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textGrey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildFilterChips(HomeController controller) {
    final options = [
      {'label': 'All', 'value': 'All Leads'},
      {'label': 'Uncontacted', 'value': 'Uncontacted Leads'},
      {'label': 'Missed Tasks', 'value': 'Missed Tasks'},
      {'label': 'Interaction Date', 'value': 'Interaction Date'},
      {'label': 'Upload Date', 'value': 'Upload Date'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Obx(() {
        final current = controller.selectedSortOption.value;
        return Row(
          children: options.map((item) {
            final val = item['value']!;
            final label = item['label']!;
            final bool isSelected = (val == 'All Leads' &&
                    (current == 'Interaction Date' || current == 'All Leads')) ||
                current == val;

            // Get badge count if applicable
            String countSuffix = '';
            if (val == 'Uncontacted Leads') {
              countSuffix = ' (${controller.uncontactedCount})';
            } else if (val == 'Missed Tasks') {
              countSuffix = ' (${controller.missedCount})';
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  if (val == 'All Leads') {
                    controller.selectedSortOption.value = 'Interaction Date';
                  } else {
                    if (controller.selectedSortOption.value == val) {
                      controller.toggleSortDirection();
                    } else {
                      controller.selectedSortOption.value = val;
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primaryBlue : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$label$countSuffix',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      if (isSelected &&
                          (val == 'Upload Date' ||
                              val == 'Interaction Date')) ...[
                        const SizedBox(width: 4),
                        Icon(
                          controller.selectedSortDirection.value ==
                                  'Newest to Oldest'
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
