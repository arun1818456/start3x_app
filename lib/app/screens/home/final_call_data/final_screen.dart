import 'package:start3x_app/exports.dart';

class FinalScreen extends StatelessWidget {
  const FinalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FinalScreenController());
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Action Bar (Cancel | Save)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.saveResponse,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),

            // Main Body Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text Response Box with Lead Name & Block Option
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: controller.textController,
                              maxLines: 4,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 14,
                                height: 1.35,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Write the last response to help with the\nnext call..',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13.5,
                                  height: 1.35,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE0E0E0)),
                            const SizedBox(height: 8),
                            Text(
                              controller.lead.name.isNotEmpty
                                  ? controller.lead.name
                                  : 'Lead Name',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Select follow-up date Card (If Got a callback or Got a meeting)
                      if (controller.selectedOutcome == 'Got a callback' ||
                          controller.selectedOutcome == 'Got a meeting') ...[
                        Obx(() {
                          final dt = controller.selectedDateTime.value;
                          return GestureDetector(
                            onTap: controller.pickDateTime,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.textDark,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      dt != null && dt.isNotEmpty
                                          ? '${controller.selectedOutcome}: $dt'
                                          : 'Select follow-up date',
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: Colors.grey,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],

                      // Select Reminder Tile Card
                      Obx(() {
                        final reminderVal = controller.selectedReminder.value;
                        return GestureDetector(
                          onTap: () =>
                              controller.showReminderBottomSheet(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.notifications_active_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Select Reminder',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        reminderVal,
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.grey,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
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
