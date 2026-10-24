import 'package:start3x_app/exports.dart';

class GroupController extends GetxController {
  final nameController = TextEditingController(text: 'Your Name');
  final messageController = TextEditingController();
  final leadNumController = TextEditingController();

  var showComposeBox = true.obs;

  final RxList<GroupMessageModel> messages = <GroupMessageModel>[
    GroupMessageModel(
      senderName: 'Arun',
      messageText:
          'Mene ise call kar liya hai kal meeting hai... please check ajay ji',
      flaggedLead: LeadModel(
        rank: '#1',
        name: 'Sahil kashyap',
        location: 'chandigarh',
        status: 'Missed:',
        date: 'October 23, 2026',
      ),
    ),
  ].obs;

  void toggleComposeBox() {
    showComposeBox.value = !showComposeBox.value;
  }

  void postMessage() {
    if (Get.isSnackbarOpen) return;
    if (messageController.text.trim().isEmpty) {
      Get.snackbar(
        'Empty Message',
        'Please enter text before posting',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    LeadModel? flagged;
    if (leadNumController.text.trim().isNotEmpty) {
      flagged = LeadModel(
        rank: '#${leadNumController.text.trim()}',
        name: 'Sahil kashyap',
        location: 'chandigarh',
        status: 'Missed:',
        date: 'October 23, 2026',
      );
    }

    messages.add(
      GroupMessageModel(
        senderName: nameController.text.trim().isEmpty
            ? 'Your Name'
            : nameController.text.trim(),
        messageText: messageController.text.trim(),
        flaggedLead: flagged,
      ),
    );

    messageController.clear();
    leadNumController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    messageController.dispose();
    leadNumController.dispose();
    super.onClose();
  }
}
