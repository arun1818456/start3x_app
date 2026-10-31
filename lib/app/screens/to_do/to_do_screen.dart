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
              _buildTopHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(controller),
              const SizedBox(height: 20),
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
                        const Text(
                          "Today's To-Do List",
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                return _buildTaskCard(todayList[index]);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // --- Tomorrow's To-Do Section ---
                        const Text(
                          "Tomorrow's To-Do List",
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                return _buildTaskCard(tomorrowList[index]);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // --- Other Dates To-Do Section ---
                        const Text(
                          "Other Dates To-Do List",
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                  const SizedBox(height: 14),
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

  Widget _buildTopHeader() {
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
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sorted by',
                    style: AppTextStyles.buttonText,
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.tune_rounded,
                    size: 16,
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
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        onChanged: controller.updateSearch,
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: AppColors.textDark, size: 22),
          hintText: 'Search',
          hintStyle: AppTextStyles.searchHint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                item.rank,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.status,
                  style: const TextStyle(
                    color: AppColors.whiteColor,
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
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Task Reminder: ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      TextSpan(
                        text: item.reminderTime,
                        style: const TextStyle(
                          color: Color(0xFFFFCC00),
                          fontSize: 11,
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
