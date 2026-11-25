import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:start3x_app/widgets/responsive_layout.dart';
import 'package:start3x_app/exports.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientsController());
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
                  // --- Header ---
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 28.0 : 14.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: _buildTopHeader(context, controller, isWide),
                  ),

                  // --- Filter & Search Controls ---
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 28.0 : 14.0,
                      vertical: 10.0,
                    ),
                    child: _buildSearchBar(controller),
                  ),

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
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people_outline_rounded,
                                    size: 54, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                  'No clients found',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Grid layout on desktop, list on mobile
                        if (isWide) {
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28.0,
                              vertical: 10.0,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.8,
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return _buildClientItemCard(list[index]);
                            },
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 8.0,
                          ),
                          itemCount: list.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 9),
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
        ),
      ),
    );
  }

  Widget _buildTopHeader(
      BuildContext context, ClientsController controller, bool isWide) {
    return Row(
      children: [
        // Back Button
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textDark,
          ),
          tooltip: 'Back to Dashboard',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),

        // Title
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Clientele',
                style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Browse accounts & view lead distribution',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ClientsController controller) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        onChanged: controller.updateSearch,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          icon: Icon(Icons.search_rounded, color: AppColors.primaryBlue, size: 19),
          hintText: 'Search by client name, passkey...',
          hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textGrey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildClientItemCard(AccessClientModel item) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Get.to(() => const ClientDetailScreen(), arguments: item);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.darkCardBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 26, maxWidth: 44),
                child: Text(
                  item.rank,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rankText,
                ),
              ),

              // Divider
              Container(
                height: 32,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white24,
              ),

              // Name & Passkey Key ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                          fontSize: 10.5,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.isActive.value
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.isActive.value ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
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
      ),
    );
  }
}
