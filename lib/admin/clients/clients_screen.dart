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
                    final list = controller.filteredClients;
                    if (list.isEmpty) {
                      return const Center(
                        child: Text(
                          'No clients found',
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
                        return _buildClientCard(list[index]);
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

  Widget _buildClientCard(ClientModel client) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const ClientDetailScreen(), arguments: client);
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
                client.rank,
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

            // Name and Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.location,
                    style: AppTextStyles.cardSubtitle,
                  ),
                ],
              ),
            ),

            // Company and Passkey
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  client.company,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  client.passkey,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
