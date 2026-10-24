import 'package:start3x_app/exports.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientDetailController());

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        children: [
          // --- Top Header ---
          _buildTopHeader(context, controller),

          // --- Dynamic Body Content based on Tab ---
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildAssignLeadView(context, controller);
              } else {
                return const BottomBar(); // User's full app access
              }
            }),
          ),

          // --- Bottom Tab Navigation Bar (Assign Lead | Profile) ---
          _buildBottomTabBar(controller),
        ],
      ),
    );
  }

  Widget _buildTopHeader(
      BuildContext context, ClientDetailController controller) {
    return Container(
      width: double.infinity,
      color: AppColors.darkCardBg,
      padding: const EdgeInsets.only(top: 44, bottom: 20, left: 18, right: 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.opaque,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.whiteColor,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.blackColor,
                    size: 16,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.whiteColor,
                  size: 26,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  Get.snackbar('Option', value,
                      snackPosition: SnackPosition.BOTTOM);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'Edit Client', child: Text('Edit Client')),
                  const PopupMenuItem(
                      value: 'Block Client', child: Text('Block Client')),
                ],
              ),
            ],
          ),
          Text(
            controller.client.company,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            controller.client.name,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            controller.client.passkey,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
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
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: bgColor,
            child: Icon(
              icon,
              color: AppColors.whiteColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
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

  Widget _buildAssignLeadView(
      BuildContext context, ClientDetailController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(0),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            _buildFieldLabel('Name'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.nameController,
              hintText: 'Enter name',
            ),
            const SizedBox(height: 16),

            // KW Field
            _buildFieldLabel('KW'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.kwController,
              hintText: 'Enter KW',
            ),
            const SizedBox(height: 16),

            // Electricity Bill Field
            _buildFieldLabel('Electricity Bill'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.electricityBillController,
              hintText: 'Enter electricity bill',
            ),
            const SizedBox(height: 16),

            // Select Date & Time Picker
            GestureDetector(
              onTap: () => controller.selectDateTime(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF05161C),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => Text(
                        controller.selectedDateTime.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text Field
            _buildFieldLabel('Text'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.textController,
              hintText: 'Enter text',
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: controller.submitAssignLead,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF05161C),
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBottomTabBar(ClientDetailController controller) {
    return Obx(
      () => Container(
        height: 56,
        color: AppColors.primaryBlue,
        child: Row(
          children: [
            // Tab 1: Assign Lead
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = 0,
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Text(
                    'Assign Lead',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: controller.selectedTab.value == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Colors.white,
                      decoration: controller.selectedTab.value == 0
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),

            // Divider Line
            Container(
              width: 1,
              height: 30,
              color: Colors.white30,
            ),

            // Tab 2: Profile
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = 1,
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: controller.selectedTab.value == 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Colors.white,
                      decoration: controller.selectedTab.value == 1
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
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
