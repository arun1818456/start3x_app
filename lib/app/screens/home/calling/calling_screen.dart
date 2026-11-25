import 'package:start3x_app/exports.dart';

class CallingScreen extends StatelessWidget {
  const CallingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CallingController());

    return Obx(
      () => PopScope(
        canPop: !controller.isPastDueAlertActive.value,
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SafeArea(
            top: false,
            child: Column(
            children: [
              // --- Top Start3X Past Due Alert Banner ---
              if (controller.isPastDueAlertActive.value)
                _buildStart3xAlertBanner(context, controller),

              // --- Top Header Bar ---
              _buildTopHeader(context, controller),

              // --- Responses Section Header & List ---
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoadingResponses.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      );
                    }

                    final responseList = controller.responses;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title Row
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 12, bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Call Responses',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${responseList.length} Total',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Responses List or Empty View
                        Expanded(
                          child: responseList.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phonelink_ring_rounded,
                                        size: 42,
                                        color: AppColors.textGrey,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'No call responses recorded yet',
                                        style: TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0, vertical: 8.0),
                                  itemCount: responseList.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    return _buildResponseCard(
                                      controller,
                                      responseList[index],
                                      index,
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStart3xAlertBanner(
      BuildContext context, CallingController controller) {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          children: [
            // Logo Image / Text
            Image.asset(
              AppImages.logo,
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'START3X',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBlue,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Icon(Icons.north_east_rounded,
                      color: AppColors.primaryBlue, size: 22),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Message Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text(
                    'You had a task scheduled for this lead: ${controller.pastDueDateStr.isNotEmpty ? controller.pastDueDateStr : controller.lead.scheduledDate}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Has it been completed?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Please select the correct option to keep the data up to date.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            const Divider(height: 1, color: Color(0xFFE0E0E0)),

            // Row with 3 equal width buttons: YES | NO | Ask group
            IntrinsicHeight(
              child: Row(
                children: [
                  // YES Button
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.onYesTap();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: const Text(
                          'YES',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                      width: 1, thickness: 1, color: Color(0xFFE0E0E0)),

                  // NO Button
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.onNoTap();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: const Text(
                          'NO',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                      width: 1, thickness: 1, color: Color(0xFFE0E0E0)),

                  // Ask group Button
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.shareLeadToChat();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: const Text(
                          'Ask group',
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, CallingController controller) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkCardBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 42, bottom: 12, left: 14, right: 14),
      child: Column(
        children: [
          // Top Navigation Row
          Row(
            children: [
              // Back Button (Hidden if alert active to prevent back navigation)
              Obx(() {
                if (controller.isPastDueAlertActive.value) {
                  return const SizedBox(width: 34);
                }
                return GestureDetector(
                  onTap: () => Get.back(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.whiteColor,
                      size: 16,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 10),

              // Title Name & Location
              Expanded(
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.lead.name.isNotEmpty
                            ? controller.lead.name
                            : 'Lead Name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (controller.lead.location.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white70,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                controller.lead.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Dropdown Details Toggle Button (ALWAYS VISIBLE!)
              Obx(
                () => GestureDetector(
                  onTap: () => controller.showDetails.toggle(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: controller.showDetails.value
                          ? AppColors.primaryBlue
                          : Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.showDetails.value
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.whiteColor,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Three Dots Popup Menu (Hidden if alert active)
              Obx(() {
                if (controller.isPastDueAlertActive.value) {
                  return const SizedBox.shrink();
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 6),
                    PopupMenuButton<String>(
                      icon: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.whiteColor,
                          size: 20,
                        ),
                      ),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (value) {
                        if (value == 'Details') {
                          controller.showDetails.toggle();
                        } else if (value == 'Edit Lead') {
                          controller.openEditLeadDialog(context);
                        } else if (value == 'Share Lead') {
                          controller.shareLeadToChat();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'Details',
                          child: Row(
                            children: [
                              Icon(
                                controller.showDetails.value
                                    ? Icons.visibility_off_rounded
                                    : Icons.info_outline_rounded,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                controller.showDetails.value
                                    ? 'Hide Details'
                                    : 'Details',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Edit Lead',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded,
                                  color: AppColors.textDark, size: 20),
                              SizedBox(width: 10),
                              Text('Edit Lead', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Share Lead',
                          child: Row(
                            children: [
                              Icon(Icons.share_rounded,
                                  color: AppColors.primaryBlue, size: 20),
                              SizedBox(width: 10),
                              Text('Share Lead', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

          // Quick Actions Row (Call, WhatsApp, Alt Call)
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
                label: 'WhatsApp',
                onTap: () => controller.openWhatsApp(),
              ),
              _buildActionButton(
                icon: Icons.add_call,
                bgColor: Colors.white.withValues(alpha: 0.15),
                label: 'Alt Call',
                onTap: () => controller.makeAltCall(),
              ),
            ],
          ),

          // Expandable / Collapsible Lead Details Section
          Obx(
            () {
              if (!controller.showDetails.value) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),

                  // Lead Initials & Company Info
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.primaryBlue.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            controller.lead.name.isNotEmpty
                                ? controller.lead.name[0].toUpperCase()
                                : 'L',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.lead.name.isNotEmpty
                                  ? controller.lead.name
                                  : 'Lead Name',
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (controller.lead.location.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      controller.lead.location,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (controller.lead.kw.isNotEmpty ||
                      controller.lead.electricityBill.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          if (controller.lead.kw.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    color: Color(0xFFFFCC00), size: 16),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'KW: ${controller.lead.kw}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (controller.lead.electricityBill.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.receipt_long_rounded,
                                    color: Color(0xFFFFCC00), size: 16),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Bill: ${controller.lead.electricityBill}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.whiteColor,
              size: 19,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 11.5,
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
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Green Banner for isDone or Red Banner for isMissed
            if (resp.isDone)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                color: const Color(0xFF00C853),
                child: const Text(
                  'This task has been completed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (resp.isMissed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                color: const Color(0xFFFF1744),
                child: const Text(
                  'This task has been Missed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Response # & Edit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          resp.responseNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            controller.showEditResponseBottomSheet(index, resp),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: AppColors.whiteColor,
                                size: 13.5,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Caller Detail Tile (if available)
                  if (resp.userName != null &&
                      resp.userName!.trim().isNotEmpty) ...[
                    _buildDetailTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Called By: ',
                      value: resp.userName!,
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Meeting or Callback Details
                  if (resp.scheduledDate != null &&
                      resp.scheduledDate!.isNotEmpty) ...[
                    _buildDetailTile(
                      icon: Icons.event_available_rounded,
                      label: 'Meeting Scheduled: ',
                      value: resp.scheduledDate!,
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (resp.callback != null && resp.callback!.isNotEmpty) ...[
                    _buildDetailTile(
                      icon: Icons.phone_callback_rounded,
                      label: 'Callback: ',
                      value: resp.callback!,
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Outcome
                  _buildDetailTile(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Outcome: ',
                    value: resp.outcome,
                  ),

                  const SizedBox(height: 6),

                  // Response Text
                  if (resp.text.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        resp.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Call Date Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (resp.userName != null &&
                          resp.userName!.trim().isNotEmpty)
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_circle_outlined,
                                color: Colors.white70,
                                size: 15,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  resp.userName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          preferBelow: false,
                          showDuration: const Duration(seconds: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.darkCardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          textStyle: const TextStyle(
                            color: Color(0xFFFFCC00),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          message: _formatFullCallDateTime(resp),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: Color(0xFFFFCC00),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Call Date: ',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: resp.createdAt,
                                        style: const TextStyle(
                                          color: Color(0xFFFFCC00),
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullCallDateTime(LeadResponseModel resp) {
    final raw = resp.rawCreatedAt?.trim() ?? '';
    if (raw.isNotEmpty) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        final dt = parsed.toLocal();
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        final day = dt.day.toString().padLeft(2, '0');
        final month = months[dt.month - 1];
        final year = dt.year.toString();
        final hour = (dt.hour % 12 == 0 ? 12 : dt.hour % 12)
            .toString()
            .padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        final second = dt.second.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        return '$day $month $year, $hour:$minute:$second $period';
      }
    }
    if (resp.createdAt.trim().isNotEmpty) {
      return resp.createdAt.trim();
    }
    return 'N/A';
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFFCC00), size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Color(0xFFFFCC00),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
