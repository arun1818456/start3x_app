import 'package:start3x_app/exports.dart';

class AccessControlScreen extends StatelessWidget {
  const AccessControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccessControlController());

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Header Bar ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: Colors.grey.shade100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textDark,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Access Control',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchPasskeys();
                },
                color: AppColors.primaryBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // --- Search Bar ---
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          onChanged: controller.updateSearch,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.search,
                                color: AppColors.textDark, size: 20),
                            hintText: 'Search',
                            hintStyle: TextStyle(
                                fontSize: 14, color: AppColors.textGrey),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- Clients Count Box ---
                      Container(
                        width: 135,
                        height: 135,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(
                              () => Text(
                                '${controller.clients.length}',
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const Text(
                              'Clients',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- Generated Passkey Display Pill ---
                      GestureDetector(
                        onTap: controller.copyPasskeyToClipboard,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Obx(
                              () => Text(
                                controller.generatedPasskey.value,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // --- Click to Generate Passkey Button ---
                      GestureDetector(
                        onTap: controller.generatePasskey,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Center(
                            child: Text(
                              'Click to Generate Passkey',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // --- Clients Cards List ---
                      Obx(
                        () {
                          if (controller.isLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            );
                          }

                          final clientList = controller.filteredClients;
                          if (clientList.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No clients found',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 15,
                                ),
                              ),
                            );
                          }

                        return Column(
                          children: List.generate(clientList.length, (index) {
                            final item = clientList[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Rank Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.rank,
                                      style: const TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // User Name, Passkey ID & CreatedAt
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Key: ${item.id}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textGrey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (item.createdAt.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Created: ${item.createdAt}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textGrey,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),

                                  // Copy Passkey Icon
                                  GestureDetector(
                                    onTap: () => controller
                                        .copySpecificPasskey(item.id),
                                    behavior: HitTestBehavior.opaque,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Icon(
                                        Icons.copy_rounded,
                                        size: 18,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),

                                  // Active/Inactive Toggle Switch (Smaller size)
                                  Transform.scale(
                                    scale: 0.75,
                                    child: Obx(
                                      () => Switch(
                                        value: item.isActive.value,
                                        activeTrackColor: AppColors.primaryBlue,
                                        onChanged: (val) =>
                                            controller.togglePasskey(item, val),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
