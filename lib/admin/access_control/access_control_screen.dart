import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:start3x_app/widgets/responsive_layout.dart';
import 'package:start3x_app/exports.dart';

class AccessControlScreen extends StatelessWidget {
  const AccessControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccessControlController());
    final bool isWide = kIsWeb && MediaQuery.of(context).size.width >= Breakpoints.mobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // --- Header Bar ---
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: isWide ? 28 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textDark,
                            size: 20,
                          ),
                          tooltip: 'Back to Dashboard',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Access Control',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Generate passkeys, authorize users & revoke credentials',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
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
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 28 : 20,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Web 2-Column Banner or Mobile Stack
                            if (isWide) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Stat Card
                                  _buildCounterCard(controller),
                                  const SizedBox(width: 24),

                                  // Right Passkey Generator Card
                                  Expanded(
                                    child: _buildPasskeyGeneratorCard(controller),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Center(child: _buildCounterCard(controller)),
                              const SizedBox(height: 20),
                              _buildPasskeyGeneratorCard(controller),
                            ],

                            const SizedBox(height: 28),

                            // Search bar
                            Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: TextField(
                                onChanged: controller.updateSearch,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.search_rounded,
                                      color: AppColors.primaryBlue, size: 20),
                                  hintText: 'Search clients by name, key...',
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: AppColors.textGrey),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              'Authorized Clients & Passkeys',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 12),

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
                                    padding: EdgeInsets.symmetric(vertical: 30),
                                    child: Center(
                                      child: Text(
                                        'No matching passkeys found',
                                        style: TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  children: List.generate(clientList.length,
                                      (index) {
                                    final item = clientList[index];
                                    return _buildPasskeyTile(
                                        context, controller, item);
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
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard(AccessControlController controller) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => Text(
              '${controller.clients.length}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Active Passkeys',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasskeyGeneratorCard(AccessControlController controller) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Display Pill
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: controller.copyPasskeyToClipboard,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.key_rounded,
                        size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Obx(
                      () => Text(
                        controller.generatedPasskey.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.copy_rounded,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Click to Generate Passkey Button
          ElevatedButton.icon(
            onPressed: controller.generatePasskey,
            icon: const Icon(Icons.add_circle_outline_rounded,
                size: 18, color: Colors.white),
            label: const Text(
              'Generate New Passkey',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasskeyTile(BuildContext context,
      AccessControlController controller, AccessClientModel item) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.showPasskeyUsersDialog(context, item),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.rank,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // User Name, Passkey ID & CreatedAt
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Passkey: ${item.id}',
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
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Copy Passkey Icon
              IconButton(
                onPressed: () => controller.copySpecificPasskey(item.id),
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                tooltip: 'Copy Key',
              ),

              // Active/Inactive Toggle Switch
              Transform.scale(
                scale: 0.8,
                child: Obx(
                  () => Switch(
                    value: item.isActive.value,
                    activeTrackColor: AppColors.primaryBlue,
                    onChanged: (val) => controller.togglePasskey(item, val),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
