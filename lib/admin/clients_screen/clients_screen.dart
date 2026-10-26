import 'package:start3x_app/exports.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientsController());

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              // --- Top Header Bar ---
              _buildTopHeader(context, controller),
              const SizedBox(height: 20),

              // --- Search Bar ---
              _buildSearchBar(controller),
              const SizedBox(height: 20),

              // --- Clients Cards List ---
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

                    final List<AccessClientModel> list = controller.filteredClients;
                    if (list.isEmpty) {
                      return const Center(
                        child: Text(
                          'No clients_screen found',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _buildClientItemCard(list[index]);
                      },
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

  Widget _buildTopHeader(BuildContext context, ClientsController controller) {
    return Row(
      children: [
        // Back Button
        GestureDetector(
          onTap: () => Get.back(),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 22,
              color: AppColors.textDark,
            ),
          ),
        ),

        // Centered Clients Title
        const Expanded(
          child: Text(
            'Clients',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),

        // Sorted by Button
        GestureDetector(
          onTap: () => controller.showSortBottomSheet(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sorted by',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
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

  Widget _buildSearchBar(ClientsController controller) {
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
          hintText: 'Search',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.textGrey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildClientItemCard(AccessClientModel item) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const ClientDetailScreen(), arguments: item);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 36,
              child: Text(
                item.rank,
                style: AppTextStyles.rankText,
              ),
            ),

            // Divider
            Container(
              height: 38,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: Colors.white24,
            ),

            // Name & Passkey Key ID
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Key: ${item.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardSubtitle,
                  ),
                  if (item.createdAt.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.createdAt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.isActive.value
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.isActive.value ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: item.isActive.value
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
