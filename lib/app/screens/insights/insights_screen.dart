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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: _buildFilterButton(context, controller),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    itemCount: controller.insightItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildInsightCard(controller.insightItems[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, InsightsController controller) {
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
              size: 16,
              color: AppColors.textDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(InsightItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.folder_open_rounded,
            color: AppColors.whiteColor,
            size: 44,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                color: AppColors.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            item.count,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
