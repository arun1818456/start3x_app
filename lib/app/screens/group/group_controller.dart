import 'package:start3x_app/exports.dart';

class GroupController extends GetxController with BaseClass {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  var isLoading = false.obs;
  var isSending = false.obs;

  final RxList<GroupMessageModel> messages = <GroupMessageModel>[].obs;

  final GroupMessageModel systemWelcomeMessage = GroupMessageModel(
    id: 'welcome_system_msg',
    senderName: 'Start3X Bot',
    messageText: 'Welcome to Start3X Group Chat! 👋 Connect & chat with your team.',
    messageType: 'welcome',
    createdAt: 'System',
    isMe: false,
  );

  @override
  void onInit() {
    super.onInit();
    fetchChatMessagesFromApi();
  }

  Future<void> fetchChatMessagesFromApi() async {
    try {
      isLoading.value = true;
      final userData = getUserData();
      final passkey = userData.passkey ?? '';
      final currentUserName = userData.name ?? '';
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

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final user = getUserData();
    final passkey = user.passkey ?? 'default';
    final userName = user.name;
    final String sender = (userName != null && userName.isNotEmpty)
        ? userName
        : 'Me';

    messageController.clear();

    Map<String, dynamic> body = {
      "passkey": passkey,
      "senderName": sender,
      "messageText": text,
      "messageType": "text",
    };

    try {
      isSending.value = true;

      // Add local message immediately for instant UI response (WhatsApp style)
      final localMsg = GroupMessageModel(
        senderName: sender,
        messageText: text,
        messageType: 'text',
        createdAt: 'Now',
        isMe: true,
      );
      messages.add(localMsg);
      scrollToBottom();

      var res = await httpRequest(
        REQUEST.post,
        sendChatMessageApiEndPoint,
        body,
      );

      if (res != null && res["success"] == true && res["data"] != null) {
        // Replace last item with parsed server response if needed
        final serverMsg = GroupMessageModel.fromJson(
          res["data"],
          currentUserName: sender,
        );
        messages[messages.length - 1] = serverMsg;
      }
    } catch (e) {
      // Keep local message on UI
    } finally {
      isSending.value = false;
      scrollToBottom();
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
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
