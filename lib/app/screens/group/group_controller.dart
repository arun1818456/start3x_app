import 'dart:async';
import 'package:flutter/services.dart';
import 'package:start3x_app/exports.dart';

class GroupController extends GetxController with BaseClass {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  var isLoading = false.obs;
  var isSending = false.obs;

  // Typing indicator
  var isTyping = false.obs;
  var typingUser = ''.obs;
  Timer? _typingDebounce;
  Timer? _incomingTypingTimer;

  final RxList<GroupMessageModel> messages = <GroupMessageModel>[].obs;
  final RxSet<String> selectedMessageIds = <String>{}.obs;

  bool get isSelectionMode => selectedMessageIds.isNotEmpty;

  // Flag leads selection
  final RxList<LeadModel> availableLeads = <LeadModel>[].obs;
  final RxList<LeadModel> selectedLeads = <LeadModel>[].obs;
  final RxBool isLoadingLeads = false.obs;
  final RxString leadSearchQuery = ''.obs;

  final GroupMessageModel systemWelcomeMessage = GroupMessageModel(
    id: 'welcome_system_msg',
    senderName: 'Start3X Bot',
    messageText: 'Welcome to Start3X Group Chat! 👋 Connect & chat with your team in real time.',
    messageType: 'welcome',
    createdAt: 'System',
    isMe: false,
  );

  MySocketController get socketController {
    if (!Get.isRegistered<MySocketController>()) {
      return Get.put(MySocketController(), permanent: true);
    }
    return Get.find<MySocketController>();
  }

  /// Resolve target passkey (supports Admin opening any Client profile)
  String resolvePasskey() {
    String passkey = '';

    // 1. From Get.arguments (when Admin navigates to a specific client)
    if (Get.arguments != null) {
      if (Get.arguments is Map && Get.arguments['passkey'] != null) {
        passkey = Get.arguments['passkey'].toString();
      } else if (Get.arguments is ClientModel) {
        passkey = (Get.arguments as ClientModel).passkey;
      } else if (Get.arguments is AccessClientModel) {
        passkey = (Get.arguments as AccessClientModel).id;
      } else if (Get.arguments is String) {
        passkey = Get.arguments as String;
      }
    }

    // 2. From HomeController if already loaded for this client
    if (passkey.isEmpty && Get.isRegistered<HomeController>()) {
      final homePasskey = Get.find<HomeController>().clientPasskey;
      if (homePasskey.isNotEmpty) passkey = homePasskey;
    }

    // 3. From storage cache
    if (passkey.isEmpty) {
      passkey = storage.read('clientPasskey')?.toString() ?? '';
    }

    // 4. From logged in user profile (for regular clients)
    if (passkey.isEmpty) {
      final userData = getUserData();
      passkey = userData.passkey ?? '';
    }

    return passkey;
  }

  /// Resolve sender name: Admin always sends as "Admin", User sends with their Name
  String resolveSenderName() {
    final user = getUserData();
    if (user.role == 'admin') {
      return 'Admin';
    }
    return (user.name != null && user.name!.trim().isNotEmpty)
        ? user.name!.trim()
        : 'User';
  }

  void checkIncomingArguments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null && Get.arguments is Map) {
        final args = Get.arguments as Map;
        if (args['initialFlaggedLead'] != null &&
            args['initialFlaggedLead'] is LeadModel) {
          final LeadModel incomingLead = args['initialFlaggedLead'] as LeadModel;
          final exists = selectedLeads.any((l) =>
              (incomingLead.id.isNotEmpty && l.id == incomingLead.id) ||
              (incomingLead.rank.isNotEmpty && l.rank == incomingLead.rank));
          if (!exists) {
            selectedLeads.add(incomingLead);
          }
          final String? passkeyArg = args['passkey']?.toString();
          if (passkeyArg != null && passkeyArg.isNotEmpty) {
            socketController.joinChat(targetPasskey: passkeyArg);
          }
          args.remove('initialFlaggedLead');
        }
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    final currentPasskey = resolvePasskey();

    // Ensure socket is initialized and joined the correct client room
    socketController.initializeSocket();
    if (currentPasskey.isNotEmpty) {
      socketController.joinChat(targetPasskey: currentPasskey);
    }

    checkIncomingArguments();

    fetchChatMessagesFromApi();
    fetchAvailableLeads();

    // Listen to text changes for typing indicator
    messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = messageController.text;
    final currentPasskey = resolvePasskey();
    if (text.isNotEmpty) {
      if (_typingDebounce?.isActive ?? false) _typingDebounce?.cancel();
      socketController.sendTypingStatus(true, passkey: currentPasskey);
      _typingDebounce = Timer(const Duration(seconds: 2), () {
        socketController.sendTypingStatus(false, passkey: currentPasskey);
      });
    } else {
      socketController.sendTypingStatus(false, passkey: currentPasskey);
    }
  }

  Future<void> fetchChatMessagesFromApi() async {
    try {
      isLoading.value = true;
      final passkey = resolvePasskey();
      if (passkey.isNotEmpty) {
        socketController.joinChat(targetPasskey: passkey);
      }
      final user = getUserData();
      final currentUserName = resolveSenderName();
      final bool isAdmin = user.role?.toLowerCase() == 'admin';
      final currentUserId = user.id ?? '';
      String query = passkey.isNotEmpty ? "?passkey=$passkey" : "";

      var res = await httpRequest(
        REQUEST.get,
        "$getChatMessagesApiEndPoint$query",
        {},
      );

      List<GroupMessageModel> list = [systemWelcomeMessage];

      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        List<GroupMessageModel> fetched = dataList
            .map((item) => GroupMessageModel.fromJson(
                  item,
                  currentUserName: currentUserName,
                  isCurrentUserAdmin: isAdmin,
                  currentUserId: currentUserId,
                ))
            .toList();
        list.addAll(fetched);
      }

      messages.value = list;
      scrollToBottom();
    } catch (e) {
      if (messages.isEmpty) {
        messages.value = [systemWelcomeMessage];
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all available leads for flagging/attaching
  Future<void> fetchAvailableLeads({bool force = false}) async {
    if (!force && availableLeads.isNotEmpty) return;

    if (Get.isRegistered<HomeController>()) {
      final homeLeads = Get.find<HomeController>().leads;
      if (homeLeads.isNotEmpty) {
        availableLeads.value = homeLeads;
        return;
      }
    }

    try {
      isLoadingLeads.value = true;
      final passkey = resolvePasskey();
      if (passkey.isNotEmpty) {
        var res = await httpRequest(
          REQUEST.get,
          "$getLeadsApiEndPoint?passkey=$passkey",
          {},
        );
        if (res != null && res["success"] == true && res["data"] != null) {
          List dataList = res["data"];
          availableLeads.value =
              dataList.map((item) => LeadModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching leads for chat: $e");
    } finally {
      isLoadingLeads.value = false;
    }
  }

  List<LeadModel> get filteredAvailableLeads {
    final query = leadSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return availableLeads;
    return availableLeads.where((lead) {
      return lead.name.toLowerCase().contains(query) ||
          lead.rank.toLowerCase().contains(query) ||
          lead.location.toLowerCase().contains(query) ||
          lead.phoneNumber.toLowerCase().contains(query);
    }).toList();
  }

  void toggleLeadSelection(LeadModel lead) {
    final index = selectedLeads.indexWhere(
        (l) => (lead.id.isNotEmpty && l.id == lead.id) || l.rank == lead.rank);
    if (index != -1) {
      selectedLeads.removeAt(index);
    } else {
      selectedLeads.add(lead);
    }
  }

  bool isLeadSelected(LeadModel lead) {
    return selectedLeads.any(
        (l) => (lead.id.isNotEmpty && l.id == lead.id) || l.rank == lead.rank);
  }

  void removeSelectedLead(LeadModel lead) {
    selectedLeads.removeWhere(
        (l) => (lead.id.isNotEmpty && l.id == lead.id) || l.rank == lead.rank);
  }

  void clearSelectedLeads() {
    selectedLeads.clear();
  }

  void openFlagLeadPicker(BuildContext context) {
    fetchAvailableLeads(force: availableLeads.isEmpty);
    leadSearchQuery.value = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildLeadPickerSheet(ctx),
    );
  }

  Widget _buildLeadPickerSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Flag Leads',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Obx(() {
                          final count = selectedLeads.length;
                          return Text(
                            count == 0
                                ? 'Select one or more leads'
                                : '$count lead(s) selected',
                            style: TextStyle(
                              fontSize: 12,
                              color: count == 0
                                  ? AppColors.textGrey
                                  : AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                Obx(() {
                  final allSelected = availableLeads.isNotEmpty &&
                      selectedLeads.length == availableLeads.length;
                  return TextButton(
                    onPressed: () {
                      if (allSelected) {
                        selectedLeads.clear();
                      } else {
                        selectedLeads.assignAll(availableLeads);
                      }
                    },
                    child: Text(
                      allSelected ? 'Deselect All' : 'Select All',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => leadSearchQuery.value = val,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search by name, rank, phone or city...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textGrey),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 16),

          // Leads List
          Expanded(
            child: Obx(() {
              if (isLoadingLeads.value && availableLeads.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                );
              }

              final list = filteredAvailableLeads;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_search_rounded,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        availableLeads.isEmpty
                            ? 'No leads available'
                            : 'No leads matching search',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: list.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final lead = list[index];
                  return Obx(() {
                    final isSelected = isLeadSelected(lead);
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: Checkbox(
                        value: isSelected,
                        activeColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (_) => toggleLeadSelection(lead),
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lead.rank,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lead.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          [
                            if (lead.phoneNumber.isNotEmpty) lead.phoneNumber,
                            if (lead.location.isNotEmpty) lead.location,
                          ].join(' • '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: () => toggleLeadSelection(lead),
                    );
                  });
                },
              );
            }),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Obx(() {
                    final count = selectedLeads.length;
                    return Text(
                      count == 0 ? 'Done' : 'Attach $count Lead(s)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle incoming real-time socket message
  void onSocketMessageReceived(Map<String, dynamic> data) {
    try {
      final user = getUserData();
      final currentUserName = resolveSenderName();
      final bool isAdmin = user.role?.toLowerCase() == 'admin';
      final currentUserId = user.id ?? '';

      final newMsg = GroupMessageModel.fromJson(
        data,
        currentUserName: currentUserName,
        isCurrentUserAdmin: isAdmin,
        currentUserId: currentUserId,
      );

      // Check if message already exists by id
      if (newMsg.id.isNotEmpty) {
        final existingIndex = messages.indexWhere((m) => m.id == newMsg.id);
        if (existingIndex != -1) {
          messages[existingIndex] = newMsg;
          return;
        }
      }

      // Check if there is an optimistic pending message from me with the same text
      if (newMsg.isMe) {
        final pendingIndex = messages.lastIndexWhere(
          (m) => m.isMe && m.id.isEmpty && m.messageText == newMsg.messageText,
        );
        if (pendingIndex != -1) {
          messages[pendingIndex] = newMsg;
          scrollToBottom();
          return;
        }
      }

      // Also check any unsaved optimistic message with same text & sender
      final optimisticIdx = messages.lastIndexWhere(
        (m) => m.id.isEmpty && m.messageText == newMsg.messageText && m.senderName == newMsg.senderName,
      );
      if (optimisticIdx != -1) {
        messages[optimisticIdx] = newMsg;
        scrollToBottom();
        return;
      }

      // Append new incoming message
      messages.add(newMsg);
      scrollToBottom();
    } catch (e) {
      debugPrint("Error processing socket message: $e");
    }
  }

  /// Handle real-time message deletion broadcast from server
  void onSocketMessageDeleted(Map<String, dynamic> data) {
    try {
      final deletedId = data['messageId']?.toString() ?? data['_id']?.toString() ?? '';
      if (deletedId.isEmpty) return;

      final eventPasskey = data['passkey']?.toString() ?? '';
      final currentPasskey = resolvePasskey();
      if (eventPasskey.isNotEmpty &&
          currentPasskey.isNotEmpty &&
          eventPasskey != currentPasskey) {
        return;
      }

      messages.removeWhere((m) => m.id == deletedId);
      selectedMessageIds.remove(deletedId);
    } catch (e) {
      debugPrint("Error processing socket message deletion: $e");
    }
  }

  /// Handle real-time batch message deletion broadcast from server
  void onSocketMessagesDeleted(Map<String, dynamic> data) {
    try {
      final rawIds = data['messageIds'];
      if (rawIds is! List || rawIds.isEmpty) return;

      final eventPasskey = data['passkey']?.toString() ?? '';
      final currentPasskey = resolvePasskey();
      if (eventPasskey.isNotEmpty &&
          currentPasskey.isNotEmpty &&
          eventPasskey != currentPasskey) {
        return;
      }

      final idSet = rawIds
          .map((e) => e?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      if (idSet.isEmpty) return;

      messages.removeWhere((m) => idSet.contains(m.id));
      selectedMessageIds.removeAll(idSet);
    } catch (e) {
      debugPrint("Error processing socket batch message deletion: $e");
    }
  }

  /// Handle incoming typing indicator
  void onUserTyping(Map<String, dynamic> data) {
    final name = data["userName"]?.toString() ?? 'Someone';
    final bool typing = data["isTyping"] == true;

    final myName = resolveSenderName();
    // Ignore my own typing events
    if (myName.toLowerCase() == name.toLowerCase()) {
      return;
    }

    if (typing) {
      typingUser.value = name;
      isTyping.value = true;
      _incomingTypingTimer?.cancel();
      _incomingTypingTimer = Timer(const Duration(seconds: 3), () {
        isTyping.value = false;
        typingUser.value = '';
      });
    } else {
      isTyping.value = false;
      typingUser.value = '';
      _incomingTypingTimer?.cancel();
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final leadsToSend = List<LeadModel>.from(selectedLeads);

    if (text.isEmpty && leadsToSend.isEmpty) return;

    final user = getUserData();
    final passkey = resolvePasskey();
    final sender = resolveSenderName();

    final messageToSend = text.isNotEmpty
        ? text
        : (leadsToSend.length == 1
            ? '🚩 Flagged lead: ${leadsToSend.first.rank} ${leadsToSend.first.name}'
            : '🚩 ${leadsToSend.length} Flagged leads shared');

    messageController.clear();
    selectedLeads.clear();
    socketController.sendTypingStatus(false, passkey: passkey);

    // Optimistically add message locally (WhatsApp style)
    final localMsg = GroupMessageModel(
      senderId: user.id ?? '',
      senderName: sender,
      messageText: messageToSend,
      messageType: leadsToSend.isNotEmpty ? 'flagged_lead' : 'text',
      flaggedLead: leadsToSend.isNotEmpty ? leadsToSend.first : null,
      flaggedLeads: leadsToSend,
      createdAt: 'Now',
      isMe: true,
    );
    messages.add(localMsg);
    scrollToBottom();

    final leadIds = leadsToSend
        .map((e) => e.id)
        .where((id) => id.isNotEmpty)
        .toList();

    // 1. Try sending via Socket if connected (Instant real-time!)
    if (socketController.isSocketConnected.value) {
      socketController.sendChatMessage(
        messageText: messageToSend,
        messageType: leadsToSend.isNotEmpty ? 'flagged_lead' : 'text',
        passkey: passkey,
        leadIds: leadIds.isNotEmpty ? leadIds : null,
      );
    } else {
      // 2. Fallback to HTTP POST if socket is disconnected/reconnecting
      try {
        isSending.value = true;
        Map<String, dynamic> body = {
          "passkey": passkey,
          "senderId": user.id ?? "",
          "senderName": sender,
          "messageText": messageToSend,
          "messageType": leadsToSend.isNotEmpty ? "flagged_lead" : "text",
          if (leadIds.isNotEmpty) "leadIds": leadIds,
        };

        var res = await httpRequest(
          REQUEST.post,
          sendChatMessageApiEndPoint,
          body,
          token: user.token ?? "",
        );

        if (res != null && res["success"] == true && res["data"] != null) {
          final serverMsg = GroupMessageModel.fromJson(
            res["data"],
            currentUserName: sender,
            isCurrentUserAdmin: user.role?.toLowerCase() == 'admin',
            currentUserId: user.id ?? '',
          );
          final lastIdx = messages.length - 1;
          if (lastIdx >= 0 && messages[lastIdx].id.isEmpty) {
            messages[lastIdx] = serverMsg;
          }
        }
      } catch (e) {
        // Keep optimistic local message
      } finally {
        isSending.value = false;
        scrollToBottom();
      }
    }
  }

  bool get isCurrentUserAdmin =>
      getUserData().role?.toLowerCase() == 'admin';

  bool canDeleteMessage(GroupMessageModel item) {
    if (item.id.isEmpty ||
        item.id == systemWelcomeMessage.id ||
        item.messageType == 'welcome') {
      return false;
    }
    return item.isMe || isCurrentUserAdmin;
  }

  bool isMessageSelected(GroupMessageModel item) =>
      item.id.isNotEmpty && selectedMessageIds.contains(item.id);

  void onMessageLongPress(GroupMessageModel item) {
    if (!canDeleteMessage(item)) return;
    HapticFeedback.mediumImpact();
    if (selectedMessageIds.contains(item.id)) {
      selectedMessageIds.remove(item.id);
    } else {
      selectedMessageIds.add(item.id);
    }
  }

  void onMessageTap(GroupMessageModel item) {
    if (!isSelectionMode || !canDeleteMessage(item)) return;
    HapticFeedback.selectionClick();
    if (selectedMessageIds.contains(item.id)) {
      selectedMessageIds.remove(item.id);
    } else {
      selectedMessageIds.add(item.id);
    }
  }

  void clearMessageSelection() {
    selectedMessageIds.clear();
  }

  void selectAllDeletableMessages() {
    final deletableIds = messages
        .where((m) => canDeleteMessage(m))
        .map((m) => m.id)
        .toList();
    if (deletableIds.isEmpty) return;
    final allSelected =
        deletableIds.every((id) => selectedMessageIds.contains(id));
    if (allSelected) {
      selectedMessageIds.clear();
    } else {
      selectedMessageIds.addAll(deletableIds);
    }
  }

  /// Confirm before deleting selected message(s) (own messages, or any for Admin)
  void confirmDeleteSelectedMessages(BuildContext context) {
    final count = selectedMessageIds.length;
    if (count == 0) return;
    HapticFeedback.mediumImpact();
    CommonDialogs().showCustomDialog(
      context,
      title: count == 1 ? "Delete Message" : "Delete $count Messages",
      description: count == 1
          ? "Delete this message for everyone?"
          : "Delete $count selected messages for everyone?",
      yesButtonText: "Delete",
      noButtonText: "Cancel",
      onTapYes: () => deleteSelectedMessages(),
    );
  }

  /// Confirm before deleting a single message
  void confirmDeleteMessage(BuildContext context, GroupMessageModel item) {
    if (!canDeleteMessage(item)) return;
    HapticFeedback.mediumImpact();
    CommonDialogs().showCustomDialog(
      context,
      title: "Delete Message",
      description: "Delete this message for everyone?",
      yesButtonText: "Delete",
      noButtonText: "Cancel",
      onTapYes: () => deleteMessage(item),
    );
  }

  /// Delete selected messages from DB and broadcast removal to everyone
  Future<void> deleteSelectedMessages() async {
    final idsToDelete = selectedMessageIds
        .where((id) => id.isNotEmpty)
        .toList();
    if (idsToDelete.isEmpty) return;

    final idSet = idsToDelete.toSet();
    final List<({int index, GroupMessageModel msg})> backup = [];
    for (int i = 0; i < messages.length; i++) {
      if (idSet.contains(messages[i].id) && canDeleteMessage(messages[i])) {
        backup.add((index: i, msg: messages[i]));
      }
    }
    if (backup.isEmpty) {
      selectedMessageIds.clear();
      return;
    }

    final targetIds = backup.map((b) => b.msg.id).toList();
    selectedMessageIds.clear();
    messages.removeWhere((m) => targetIds.contains(m.id));

    try {
      final user = getUserData();
      dynamic res;
      if (targetIds.length == 1) {
        res = await httpRequest(
          REQUEST.delete,
          "$deleteChatMessageApiEndPoint${targetIds.first}",
          {},
          token: user.token ?? "",
        );
      } else {
        res = await httpRequest(
          REQUEST.post,
          deleteMultipleChatMessagesApiEndPoint,
          {"messageIds": targetIds},
          token: user.token ?? "",
        );
      }

      if (res == null || res["success"] != true) {
        _restoreBackupMessages(backup);
        showMySnackBar(
          res?["message"]?.toString() ?? "Could not delete messages",
          alert: true,
        );
      }
    } catch (e) {
      _restoreBackupMessages(backup);
      showMySnackBar(
        e.toString().isNotEmpty ? e.toString() : "Failed to delete messages",
        alert: true,
      );
    }
  }

  void _restoreBackupMessages(
      List<({int index, GroupMessageModel msg})> backup) {
    for (final entry in backup) {
      if (!messages.any((m) => m.id == entry.msg.id)) {
        final safeIdx =
            entry.index <= messages.length ? entry.index : messages.length;
        messages.insert(safeIdx, entry.msg);
      }
    }
  }

  /// Delete single message from DB and broadcast removal to everyone
  Future<void> deleteMessage(GroupMessageModel item) async {
    if (!canDeleteMessage(item)) return;

    final removedIndex = messages.indexWhere((m) => m.id == item.id);
    if (removedIndex == -1) return;

    selectedMessageIds.remove(item.id);
    messages.removeAt(removedIndex);

    try {
      final user = getUserData();
      final res = await httpRequest(
        REQUEST.delete,
        "$deleteChatMessageApiEndPoint${item.id}",
        {},
        token: user.token ?? "",
      );

      if (res == null || res["success"] != true) {
        if (!messages.any((m) => m.id == item.id)) {
          final safeIdx =
              removedIndex <= messages.length ? removedIndex : messages.length;
          messages.insert(safeIdx, item);
        }
        showMySnackBar(
          res?["message"]?.toString() ?? "Could not delete message",
          alert: true,
        );
      }
    } catch (e) {
      if (!messages.any((m) => m.id == item.id)) {
        final safeIdx =
            removedIndex <= messages.length ? removedIndex : messages.length;
        messages.insert(safeIdx, item);
      }
      showMySnackBar(
        e.toString().isNotEmpty ? e.toString() : "Failed to delete message",
        alert: true,
      );
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void openLeadDetails(LeadModel lead) {
    Get.toNamed(AppRoutes.callingScreen, arguments: lead);
  }

  @override
  void onClose() {
    messageController.removeListener(_onTextChanged);
    _typingDebounce?.cancel();
    _incomingTypingTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
