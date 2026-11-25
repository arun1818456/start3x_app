import 'package:start3x_app/exports.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetailController extends GetxController with BaseClass {
  late ClientModel client;

  // Form Controllers for Assign Lead
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final kwController = TextEditingController();
  final electricityBillController = TextEditingController();
  final textController = TextEditingController();

  var selectedDateTime = 'Select date & Time'.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is ClientModel) {
        client = Get.arguments as ClientModel;
      } else if (Get.arguments is AccessClientModel) {
        final accessClient = Get.arguments as AccessClientModel;
        client = ClientModel(
          rank: accessClient.rank,
          name: accessClient.name,
          location: accessClient.location,
          company: accessClient.company.isNotEmpty ? accessClient.company : accessClient.name,
          passkey: accessClient.id,
          phone: accessClient.phone,
        );
      }
    } else {
      client = ClientModel(
        rank: '',
        name: '',
        location: '',
        company: '',
        passkey: '',
      );
    }
  }

  void navigateToProfile() {
    Get.to(
      () => BottomBar(),
      arguments: {
        'passkey': client.passkey,
        'client': client,
      },
    );
  }

  void editClient() {
    Get.toNamed(
      AppRoutes.clientSetupScreen,
      arguments: {
        'fromMenu': true,
        'passkey': client.passkey,
        'client': client,
      },
    );
  }

  Future<void> makePhoneCall([String? number]) async {
    final phone = (number != null && number.isNotEmpty) ? number : client.phone;
    if (phone.isEmpty) {
      showMySnackBar('No phone number available for ${client.name}', alert: true);
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      showMySnackBar('Could not launch dialer for $cleanPhone', error: true);
    }
  }

  Future<void> openWhatsApp([String? number]) async {
    final phone = (number != null && number.isNotEmpty) ? number : client.phone;
    if (phone.isEmpty) {
      showMySnackBar('No phone number available for ${client.name}', alert: true);
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      showMySnackBar('Could not open WhatsApp for $cleanPhone', error: true);
    }
  }

  Future<void> makeAltCall() async {
    final alt = client.altPhone.isNotEmpty ? client.altPhone : client.phone;
    await makePhoneCall(alt);
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
            .toString()
            .padLeft(2, '0');
    final String minute = pickedTime.minute.toString().padLeft(2, '0');
    final String period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final String day = pickedDate.day.toString().padLeft(2, '0');
    final String month = pickedDate.month.toString().padLeft(2, '0');
    final String year = pickedDate.year.toString();

    selectedDateTime.value = '$day/$month/$year $hour:$minute $period';
  }

  Future<void> submitAssignLead() async {
    final leadName = nameController.text.trim();
    if (leadName.isEmpty) {
      showMySnackBar('Please enter Name', alert: true);
      return;
    }

    final phoneVal = phoneController.text.trim();
    final addressText = addressController.text.trim();
    final locationVal = addressText.isNotEmpty ? addressText : client.location;

    try {
      showCircularLoader();
      var res = await httpRequest(
        REQUEST.post,
        createLeadApiEndPoint,
        {
          "passkey": client.passkey,
          "name": leadName,
          "phoneNumber": phoneVal,
          "location": locationVal,
          "kw": kwController.text.trim(),
          "electricityBill": electricityBillController.text.trim(),
          "textNote": textController.text.trim(),
          "scheduledDate": selectedDateTime.value != 'Select date & Time'
              ? selectedDateTime.value
              : '',
        },
        token: getUserData().token ?? "",
      );
      hideCircularLoader();
      showMySnackBar(
        res["message"] ?? 'Lead assigned successfully!',
        success: true,
      );

      // Clear form after submission
      nameController.clear();
      phoneController.clear();
      addressController.clear();
      kwController.clear();
      electricityBillController.clear();
      textController.clear();
      selectedDateTime.value = 'Select date & Time';
    } catch (e) {
      hideCircularLoader();
      showMySnackBar(
        e.toString(),
        error: true,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    kwController.dispose();
    electricityBillController.dispose();
    textController.dispose();
    super.onClose();
  }
}
