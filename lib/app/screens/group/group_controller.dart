import 'dart:async';
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

  @override
  void onInit() {
    super.onInit();
    final currentPasskey = resolvePasskey();

    // Ensure socket is initialized and joined the correct client room
    socketController.initializeSocket();
    if (currentPasskey.isNotEmpty) {
      socketController.joinChat(targetPasskey: currentPasskey);
    }

    fetchChatMessagesFromApi();

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
    if (text.isEmpty) return;

    final user = getUserData();
    final passkey = resolvePasskey();
    final sender = resolveSenderName();

    messageController.clear();
    socketController.sendTypingStatus(false, passkey: passkey);

    // Optimistically add message locally (WhatsApp style)
    final localMsg = GroupMessageModel(
      senderId: user.id ?? '',
      senderName: sender,
      messageText: text,
      messageType: 'text',
      createdAt: 'Now',
      isMe: true,
    );
    messages.add(localMsg);
    scrollToBottom();

    // 1. Try sending via Socket if connected (Instant real-time!)
    if (socketController.isSocketConnected.value) {
      socketController.sendChatMessage(
        messageText: text,
        messageType: 'text',
        passkey: passkey,
      );
    } else {
      // 2. Fallback to HTTP POST if socket is disconnected/reconnecting
      try {
        isSending.value = true;
        Map<String, dynamic> body = {
          "passkey": passkey,
          "senderName": sender,
          "messageText": text,
          "messageType": "text",
        };

        var res = await httpRequest(
          REQUEST.post,
          sendChatMessageApiEndPoint,
          body,
        );

        if (res != null && res["success"] == true && res["data"] != null) {
          final serverMsg = GroupMessageModel.fromJson(
            res["data"],
            currentUserName: sender,
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
    messageController.dispose();
    scrollController.dispose();
    _typingDebounce?.cancel();
    _incomingTypingTimer?.cancel();
    super.onClose();
  }
}
