import 'package:start3x_app/exports.dart';

class InsightFolderScreen extends StatelessWidget {
  final String title;
  final String folderType;

  const InsightFolderScreen({
    super.key,
    required this.title,
    required this.folderType,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InsightsController>()
        ? Get.find<InsightsController>()
        : Get.put(InsightsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFolderLeads(folderType);
    });

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isFolderLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    );
                  }

                  final folderLeads = controller.folderLeads;
                  if (folderLeads.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => controller.fetchFolderLeads(folderType),
                      color: AppColors.primaryBlue,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open_rounded,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No leads found in $title',
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchFolderLeads(folderType),
                    color: AppColors.primaryBlue,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: folderLeads.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final lead = folderLeads[index];
                        return LeadCardWidget(
                          lead: lead,
                          onTap: () {
                            Get.toNamed(AppRoutes.callingScreen, arguments: lead);
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
