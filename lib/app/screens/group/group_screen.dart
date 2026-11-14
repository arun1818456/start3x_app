import 'package:start3x_app/exports.dart';

class GroupScreen extends StatelessWidget {
  final bool? showBackButton;
  const GroupScreen({super.key, this.showBackButton});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupController());
    final bool canBack = (showBackButton == true) ||
        (Get.arguments is Map && Get.arguments['showBackButton'] == true);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // --- Header ---
            _buildHeader(controller, canBack),

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 12.0),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatBubble(controller, controller.messages[index]);
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
                    Text(
                      '${controller.typingUser.value} is typing...',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // --- Bottom WhatsApp Style Input Bar ---
            _buildWhatsAppInputBar(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(GroupController controller, bool canBack) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      padding: EdgeInsets.only(
        top: 48,
        bottom: 14,
        left: canBack ? 12 : 16,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (canBack) ...[
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.whiteColor,
                    size: 20,
                  ),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
              ],
              const Icon(
                Icons.forum_rounded,
                color: AppColors.whiteColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Group Chat',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Obx(() {
                        final isConnected = controller.socketController.isSocketConnected.value;
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isConnected ? const Color(0xFF4ADE80) : Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                      Obx(() {
                        final isConnected = controller.socketController.isSocketConnected.value;
                        return Text(
                          isConnected ? 'Live Connected' : 'Connecting...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ],
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

  Widget _buildChatBubble(GroupController controller, GroupMessageModel item) {
    final bool isMe = item.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 6,
          left: isMe ? 50 : 0,
          right: isMe ? 0 : 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryBlue : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 3),
            bottomRight: Radius.circular(isMe ? 3 : 16),
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
                  Text(
                    item.senderName,
                    style: TextStyle(
                      color: item.senderName.toLowerCase() == 'admin'
                          ? Colors.orange.shade800
                          : item.messageType == 'welcome'
                              ? Colors.purple.shade700
                              : AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
            ],

            // Message Text
            Text(
              item.messageText,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textDark,
                fontSize: 14.5,
                height: 1.35,
              ),
            ),

            // Optional Flagged Lead Card
            if (item.flaggedLead != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => controller.openLeadDetails(item.flaggedLead!),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        child: Text(
                          '${item.flaggedLead!.rank} ${item.flaggedLead!.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: isMe ? Colors.white70 : AppColors.textGrey,
                        size: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppInputBar(GroupController controller) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Text Input Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
      ),
    );
  }
}
