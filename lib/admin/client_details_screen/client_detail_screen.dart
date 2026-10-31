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

          // --- Assign Lead Main Body (Fixed Screen Content) ---
          Expanded(
            child: _buildAssignLeadView(context, controller),
          ),
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
          // Top Navigation Row with Back Button, Title & 3-Dots Menu
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

              // Title and Passkey info
              Expanded(
                child: Column(
                  children: [
                    Text(
                      controller.client.name.isNotEmpty
                          ? controller.client.name
                          : 'Client Details',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (controller.client.passkey.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Passkey: ${controller.client.passkey}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Three-Dots Popup Menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.whiteColor,
                  size: 26,
                ),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'View Profile') {
                    controller.navigateToProfile();
                  } else {
                    controller.showMySnackBar('Option: $value', alert: true);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'View Profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_rounded,
                            color: AppColors.primaryBlue, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'View Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'Edit Client',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded,
                            color: AppColors.textDark, size: 20),
                        SizedBox(width: 10),
                        Text('Edit Client', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Block Client',
                    child: Row(
                      children: [
                        Icon(Icons.block_rounded, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Text('Block Client',
                            style: TextStyle(fontSize: 14, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Action Buttons: Call | Whatsapp | Alt Num
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.phone_rounded,
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
            radius: 22,
            backgroundColor: bgColor,
            child: Icon(
              icon,
              color: AppColors.whiteColor,
              size: 20,
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Header Title
            const Text(
              'Assign New Lead',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fill in the lead details to assign to this client',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            // Lead Name Field
            _buildFieldLabel('Lead Name'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.nameController,
              hintText: 'Enter lead name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),

            // Phone Number Field
            _buildFieldLabel('Phone Number'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.phoneController,
              hintText: 'Enter phone number',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Address Field
            _buildFieldLabel('Address / Location'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.addressController,
              hintText: 'Enter address / location',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            // KW Field
            _buildFieldLabel('KW (System Size)'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.kwController,
              hintText: 'Enter KW capacity',
              icon: Icons.electric_bolt_rounded,
            ),
            const SizedBox(height: 16),

            // Electricity Bill Field
            _buildFieldLabel('Electricity Bill (Monthly)'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.electricityBillController,
              hintText: 'Enter bill amount',
              icon: Icons.receipt_long_rounded,
            ),
            const SizedBox(height: 16),

            // Select Date & Time Picker
            _buildFieldLabel('Schedule Date & Time'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => controller.selectDateTime(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF05161C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.selectedDateTime.value,
                          style: TextStyle(
                            color: controller.selectedDateTime.value ==
                                    'Select date & Time'
                                ? Colors.white38
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.white54,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text Note Field
            _buildFieldLabel('Notes / Remarks'),
            const SizedBox(height: 6),
            _buildDarkTextField(
              controller: controller.textController,
              hintText: 'Enter additional text note...',
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.submitAssignLead,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Assign Lead',
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
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF05161C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.primaryBlue, size: 20),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ),
    );
  }
}
