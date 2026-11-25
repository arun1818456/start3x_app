import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:start3x_app/widgets/responsive_layout.dart';
import 'package:start3x_app/exports.dart';

class GroupScreen extends StatelessWidget {
  final bool? showBackButton;
  const GroupScreen({super.key, this.showBackButton});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkIncomingArguments();
    });
    final bool canBack = (showBackButton == true) ||
        (Get.arguments is Map && Get.arguments['showBackButton'] == true);
    final bool isWide = kIsWeb && MediaQuery.of(context).size.width >= Breakpoints.mobile;

    return Obx(() => PopScope(
      canPop: !controller.isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && controller.isSelectionMode) {
          controller.clearMessageSelection();
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
            child: Container(
              color: const Color(0xFFF4F6F9),
              child: Column(
          children: [
            // --- Header (Normal or Selection AppBar) ---
            Obx(() => controller.isSelectionMode
                ? _buildSelectionHeader(context, controller)
                : _buildHeader(controller, canBack)),

            // --- Chat Messages Area ---
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value && controller.messages.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatBubble(
                        context,
                        controller,
                        controller.messages[index],
                      );
                    },
                  );
                },
              ),
            ),

            // --- Real-time Typing Indicator ---
            Obx(() {
              if (!controller.isTyping.value) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: Colors.white,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${controller.typingUser.value} is typing...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // --- Bottom WhatsApp Style Input Bar with Flag Leads Option ---
            _buildWhatsAppInputBar(context, controller),
          ],
        ),
      ),
    ),
  ),
),
),
));
}

  Widget _buildSelectionHeader(BuildContext context, GroupController controller) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.only(
        top: 42,
        bottom: 10,
        left: 6,
        right: 8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: controller.clearMessageSelection,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.whiteColor,
              size: 22,
            ),
            tooltip: 'Cancel Selection',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${controller.selectedMessageIds.length} selected',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.whiteColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.selectAllDeletableMessages,
            icon: const Icon(
              Icons.select_all_rounded,
              color: AppColors.whiteColor,
              size: 22,
            ),
            tooltip: 'Select All',
          ),
          IconButton(
            onPressed: () => controller.confirmDeleteSelectedMessages(context),
            icon: const Icon(
              Icons.delete_rounded,
              color: AppColors.whiteColor,
              size: 22,
            ),
            tooltip: 'Delete Selected',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(GroupController controller, bool canBack) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      padding: EdgeInsets.only(
        top: 42,
        bottom: 10,
        left: canBack ? 10 : 14,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (canBack) ...[
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.whiteColor,
                      size: 18,
                    ),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 2),
                ],
                const Icon(
                  Icons.forum_rounded,
                  color: AppColors.whiteColor,
                  size: 21,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Group Chat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Obx(() {
                            final isConnected =
                                controller.socketController.isSocketConnected.value;
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: isConnected
                                    ? const Color(0xFF4ADE80)
                                    : Colors.orangeAccent,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                          Flexible(
                            child: Obx(() {
                              final isConnected =
                                  controller.socketController.isSocketConnected.value;
                              return Text(
                                isConnected ? 'Live Connected' : 'Connecting...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.fetchChatMessagesFromApi(),
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.whiteColor,
              size: 22,
            ),
            tooltip: 'Refresh Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
    BuildContext context,
    GroupController controller,
    GroupMessageModel item,
  ) {
    final bool isMe = item.isMe;
    final bool canDelete = controller.canDeleteMessage(item);

    return Obx(() {
      final bool isSelected = controller.isMessageSelected(item);
      final bool inSelectionMode = controller.isSelectionMode;

      return GestureDetector(
        onLongPress: canDelete ? () => controller.onMessageLongPress(item) : null,
        onTap: (inSelectionMode && canDelete)
            ? () => controller.onMessageTap(item)
            : null,
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: double.infinity,
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.14)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 1.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (inSelectionMode && canDelete) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
              Expanded(
                child: Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 2.5,
                      bottom: 4.5,
                      left: isMe ? 44 : 0,
                      right: isMe ? 0 : 44,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primaryBlue : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(isMe ? 14 : 3),
                        bottomRight: Radius.circular(isMe ? 3 : 14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sender Name (Only shown for incoming messages from others)
            if (!isMe) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      item.senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: item.senderName.toLowerCase() == 'admin'
                            ? Colors.orange.shade800
                            : item.messageType == 'welcome'
                                ? Colors.purple.shade700
                                : AppColors.primaryBlue,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (item.senderName.toLowerCase() == 'admin') ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
            ],

            // Message Text
            if (item.messageText.isNotEmpty)
              Text(
                item.messageText,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textDark,
                  fontSize: 13.5,
                  height: 1.3,
                ),
              ),

            // Flagged Lead Cards (Single or Multiple)
            if (item.flaggedLeads.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.flaggedLeads.map((lead) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      if (controller.isSelectionMode) {
                        controller.onMessageTap(item);
                      } else {
                        controller.openLeadDetails(lead);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isMe
                              ? Colors.white30
                              : AppColors.primaryBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_pin_rounded,
                            color: isMe ? Colors.white : AppColors.primaryBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${lead.rank} ${lead.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : AppColors.textDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (lead.location.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    lead.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isMe ? Colors.white70 : AppColors.textGrey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: isMe ? Colors.white70 : AppColors.textGrey,
                            size: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildWhatsAppInputBar(BuildContext context, GroupController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected Flagged Leads Chips Bar (if any selected)
            Obx(() {
              if (controller.selectedLeads.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color(0xFFF1F5F9),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      color: AppColors.primaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: controller.selectedLeads.map((lead) {
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${lead.rank} ${lead.name}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => controller.removeSelectedLead(lead),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.clearSelectedLeads,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Input Row: Flag Button + Text Input + Send Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  // Flag Lead Button with counter badge
                  GestureDetector(
                    onTap: () => controller.openFlagLeadPicker(context),
                    behavior: HitTestBehavior.opaque,
                    child: Obx(() {
                      final count = controller.selectedLeads.length;
                      final bool hasSelected = count > 0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: hasSelected
                                  ? AppColors.primaryBlue.withValues(alpha: 0.12)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: hasSelected
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Icon(
                              Icons.flag_rounded,
                              color: hasSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.textDark,
                              size: 20,
                            ),
                          ),
                          if (hasSelected)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '$count',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(width: 8),

                  // Text Input Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: controller.messageController,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => controller.sendMessage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send Button
                  GestureDetector(
                    onTap: () => controller.sendMessage(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
