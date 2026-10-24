import 'package:start3x_app/exports.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetailController extends GetxController {
  late ClientModel client;

  var selectedTab = 0.obs; // 0: Assign Lead, 1: Profile

  // Form Controllers for Assign Lead
  final nameController = TextEditingController();
  final kwController = TextEditingController();
  final electricityBillController = TextEditingController();
  final textController = TextEditingController();

  var selectedDateTime = 'Select date & Time'.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is ClientModel) {
      client = Get.arguments as ClientModel;
    } else {
      client = ClientModel(
        rank: '#3',
        name: 'Ramananda',
        location: 'chandigarh',
        company: 'Sunrays',
        passkey: '8dffbe67y3b',
      );
    }
  }

  Future<void> makePhoneCall([String? number]) async {
    final phone = number ?? client.phone;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not launch dialer for $cleanPhone');
    }
  }

  Future<void> openWhatsApp([String? number]) async {
    final phone = number ?? client.phone;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open WhatsApp for $cleanPhone');
    }
  }

  Future<void> makeAltCall() async {
    await makePhoneCall(client.altPhone);
  }

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final String hour =
        (pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod)
            .toString();
    final String minute = pickedTime.minute.toString().padLeft(2, '0');
    final String period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final String month = pickedDate.month.toString().padLeft(2, '0');
    final String day = pickedDate.day.toString().padLeft(2, '0');
    final String year = pickedDate.year.toString();

    selectedDateTime.value = '$month/$day/$year $hour:$minute $period';
  }

  void submitAssignLead() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Alert', 'Please enter Name',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.snackbar(
      'Success',
      'Lead assigned to ${client.name} successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Clear form after submission
    nameController.clear();
    kwController.clear();
    electricityBillController.clear();
    textController.clear();
    selectedDateTime.value = 'Select date & Time';
  }
}
