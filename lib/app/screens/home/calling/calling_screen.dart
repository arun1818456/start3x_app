import 'package:start3x_app/exports.dart';

class CallingScreen extends StatelessWidget {
  const CallingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CallingController());
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        children: [
          // Top Header
          _buildTopHeader(context, controller),

          // Dynamic Responses Area
          Expanded(
            child: Obx(
              () {
                final responseList = controller.lead.responses.toList();
                if (responseList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No lead responses',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 20.0),
                  child: Column(
                    children: List.generate(
                      responseList.length,
                      (index) => _buildResponseCard(
                          controller, responseList[index], index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, CallingController controller) {
    return Container(
      width: double.infinity,
      color: AppColors.darkCardBg,
      padding: const EdgeInsets.only(top: 44, bottom: 24, left: 18, right: 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.whiteColor,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.blackColor,
                    size: 18,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.whiteColor,
                  size: 28,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (Get.isSnackbarOpen) return;
                  Get.snackbar('Option', value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Edit Lead', child: Text('Edit Lead')),
                  const PopupMenuItem(value: 'Block Lead', child: Text('Block Lead')),
                  const PopupMenuItem(value: 'Share Lead', child: Text('Share Lead')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.lead.name,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.phone,
                bgColor: AppColors.primaryBlue,
                label: 'Call',
                onTap: () => controller.makePhoneCall(),
              ),
              _buildActionButton(
                icon: Icons.chat_bubble_rounded,
                bgColor: const Color(0xFF25D366),
                label: 'Whatsapp',
                onTap: () => controller.openWhatsApp(),
              ),
              _buildActionButton(
                icon: Icons.add_call,
                bgColor: AppColors.primaryBlue,
                label: 'Alt Num',
                onTap: () => controller.makeAltCall(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: bgColor,
            child: Icon(
              icon,
              color: AppColors.whiteColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseCard(
      CallingController controller, LeadResponseModel resp, int index) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                resp.responseNumber,
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => controller.showEditResponseBottomSheet(index, resp),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        color: AppColors.whiteColor,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (resp.meetingScheduled != null && resp.meetingScheduled!.isNotEmpty) ...[
            _buildDetailRow('Meeting Scheduled: ', resp.meetingScheduled!),
            const SizedBox(height: 4),
          ],
          if (resp.callback != null && resp.callback!.isNotEmpty) ...[
            _buildDetailRow('Callback: ', resp.callback!),
            const SizedBox(height: 4),
          ],
          _buildDetailRow('Outcome: ', resp.outcome),
          const SizedBox(height: 4),
          _buildDetailRow('Text: ', resp.text),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Date of this call: ',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: resp.callDate,
                    style: const TextStyle(
                      color: Color(0xFFFFCC00),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Color(0xFFFFCC00),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
