import 'package:start3x_app/exports.dart';

class ToDoScreen extends StatelessWidget {
  const ToDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaskController());
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Column(
            children: [
              _buildTopHeader(context, controller),
              const SizedBox(height: 16),
              _buildSearchBar(controller),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchTasksFromApi,
                  color: AppColors.primaryBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Today's To-Do Section ---
                        Obx(() {
                          final count = controller.todayTasks.length;
                          return Row(
                            children: [
                              Text(
                                "Today's To-Do List",
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),
                        const SizedBox(height: 10),
                        Obx(
                          () {
                            final todayList =
                                controller.filterTasks(controller.todayTasks);
                            if (todayList.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'No tasks for today',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: todayList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildTaskCard(todayList[index]);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 22),

                        // --- Tomorrow's To-Do Section ---
                        Obx(() {
                          final count = controller.tomorrowTasks.length;
                          return Row(
                            children: [
                              Text(
                                "Tomorrow's To-Do List",
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),
                        const SizedBox(height: 10),
                        Obx(
                          () {
                            final tomorrowList =
                                controller.filterTasks(controller.tomorrowTasks);
                            if (tomorrowList.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'No tasks for tomorrow',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tomorrowList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildTaskCard(tomorrowList[index]);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 22),

                        // --- Other Dates To-Do Section ---
                        Obx(() {
                          final count = controller.otherTasks.length;
                          return Row(
                            children: [
                              Text(
                                "Other Dates To-Do List",
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),
                        const SizedBox(height: 10),
                        Obx(
                          () {
                            final otherList =
                                controller.filterTasks(controller.otherTasks);
                            if (otherList.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'No tasks for other dates',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: otherList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildTaskCard(otherList[index]);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, TaskController controller) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Align(
          alignment: Alignment.center,
          child: Text(
            'To-do',
            style: AppTextStyles.headerTitle,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
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
                    String sortLabel = controller.selectedSort.value;
                    if (sortLabel.contains('Earliest')) sortLabel = 'Earliest';
                    if (sortLabel.contains('Latest')) sortLabel = 'Latest';
                    if (sortLabel.contains('Rank')) sortLabel = 'Rank';
                    if (sortLabel.contains('Name')) sortLabel = 'Name';
                    return Text(
                      sortLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
        ),
      ],
    );
  }

  Widget _buildSearchBar(TaskController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        onChanged: controller.updateSearch,
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: AppColors.textDark, size: 22),
          hintText: 'Search tasks by name, location, rank...',
          hintStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTaskCard(ToDoItemModel item) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.callingScreen, arguments: item.lead);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Rank Number
            SizedBox(
              width: 32,
              child: Text(
                item.rank,
                style: AppTextStyles.rankText,
              ),
            ),
            Container(
              height: 38,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: Colors.white24,
            ),

            // Lead Name & Location
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
                    item.location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardSubtitle,
                  ),
                ],
              ),
            ),

            // Status, Date, Time & Reminder
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.isOverdue) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                Text(
                  item.status,
                  style: TextStyle(
                    color: item.isOverdue
                        ? Colors.red.shade300
                        : item.status.toLowerCase().contains('meeting')
                            ? const Color(0xFF60A5FA)
                            : item.status.toLowerCase().contains('callback')
                                ? const Color(0xFFFFCC00)
                                : AppColors.whiteColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.date,
                  style: const TextStyle(
                    color: Color(0xFFFFCC00),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.time,
                  style: const TextStyle(
                    color: Color(0xFFFFCC00),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Reminder: ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                        ),
                      ),
                      TextSpan(
                        text: item.reminderTime,
                        style: const TextStyle(
                          color: Color(0xFFFFCC00),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
