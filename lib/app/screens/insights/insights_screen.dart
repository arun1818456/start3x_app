import 'package:start3x_app/exports.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InsightsController());
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Insights',
                style: AppTextStyles.headerTitle,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: _buildFilterButton(context, controller),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => controller.fetchInsightsFromApi(),
                      child: ListView.separated(
                        itemCount: controller.insightItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _buildInsightCard(controller.insightItems[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(
      BuildContext context, InsightsController controller) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        controller.updateFilter(value);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'Today',
            child: Text('Today'),
          ),
          const PopupMenuItem<String>(
            value: 'Yesterday',
            child: Text('Yesterday'),
          ),
          const PopupMenuItem<String>(
            value: 'Last 7 Days',
            child: Text('Last 7 Days'),
          ),
          const PopupMenuItem<String>(
            value: 'Last Month',
            child: Text('Last Month'),
          ),
          const PopupMenuItem<String>(
            value: 'Select by date',
            child: Text('Select by date'),
          ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Text(
                controller.selectedFilter.value,
                style: AppTextStyles.buttonText,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.tune_rounded,
              size: 15,
              color: AppColors.textDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(InsightItemModel item) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => InsightFolderScreen(
            title: item.title,
            folderType: item.title,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.folder_open_rounded,
              color: AppColors.whiteColor,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              item.count,
              style: const TextStyle(
                color: AppColors.whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
