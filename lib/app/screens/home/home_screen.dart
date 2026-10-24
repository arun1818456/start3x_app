import 'package:start3x_app/exports.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      drawer:  SideMenuBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // --- Top App Bar / Header ---
              _buildTopHeader(context, controller),
              const SizedBox(height: 16),

              // --- Search Bar (Reduced Height) ---
              _buildSearchBar(controller),
              const SizedBox(height: 20),

              // --- Cards List ---
              Expanded(
                child: Obx(
                  () {
                    final leadsList = controller.filteredLeads;
                    return ListView.separated(
                      itemCount: leadsList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _buildLeadCard(leadsList[index]);
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

  Widget _buildTopHeader(BuildContext context, HomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Drawer Menu Icon
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
          hintText: 'Search',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.textGrey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildLeadCard(LeadModel lead) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.callingScreen, arguments: lead);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                lead.rank,
                style: AppTextStyles.rankText,
              ),
            ),
            Container(
              height: 36,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: Colors.white24,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lead.location,
                    style: AppTextStyles.cardSubtitle,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lead.status,
                  style: AppTextStyles.cardTagBold,
                ),
                const SizedBox(height: 2),
                Text(
                  lead.date,
                  style: AppTextStyles.cardTagLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
