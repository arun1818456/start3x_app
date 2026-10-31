import 'package:start3x_app/exports.dart';

class FinalScreenController extends GetxController with BaseClass {
  final textController = TextEditingController();
  late LeadModel lead;
  String selectedOutcome = 'Got a meeting';
  var selectedDateTime = RxnString();
  var selectedReminder = 'At task due time'.obs;

  final List<String> reminderOptions = [
    'At task due time',
    '30 minutes before',
    '1 hour before',
    '1 day before',
    '1 week before',
    'Custom',
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      lead = args['lead'] as LeadModel? ??
          LeadModel(
            rank: '',
            name: '',
            location: '',
            status: '',
            date: '',
          );
      selectedOutcome = args['outcome']?.toString() ?? 'Got a meeting';
      selectedDateTime.value = args['dateTime']?.toString();
    } else {
      lead = LeadModel(
        rank: '',
        name: '',
        location: '',
        status: '',
        date: '',
      );
    }

    // Auto trigger date & time picker on init for callback/meeting if not set
    if ((selectedOutcome == 'Got a callback' ||
            selectedOutcome == 'Got a meeting') &&
        (selectedDateTime.value == null || selectedDateTime.value!.isEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pickDateTime();
      });
    }
  }

  Future<void> pickDateTime() async {
    final context = Get.context;
    if (context == null) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007AFF),
              surface: Colors.white,
              surfaceTint: Colors.transparent,
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
              primary: Color(0xFF007AFF),
              surface: Colors.white,
              surfaceTint: Colors.transparent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final DateTime combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final String hour =
        (pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod)
            .toString();
    final String minute = pickedTime.minute.toString().padLeft(2, '0');
    final String period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final String month = combined.month.toString().padLeft(2, '0');
    final String day = combined.day.toString().padLeft(2, '0');
    final String year = combined.year.toString();

    selectedDateTime.value = '$hour:$minute $period, $month/$day/$year';
  }

  void showReminderBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 20, bottom: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sheet Header Title matching screenshot
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Select Reminder',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 8),

              // Reminder Options
              Column(
                children: reminderOptions.map((option) {
                  return Obx(() {
                    final isSelected = selectedReminder.value == option ||
                        (option == 'Custom' &&
                            selectedReminder.value.startsWith('Custom'));

                    return InkWell(
                      onTap: () async {
                        if (option == 'Custom') {
                          final customTime =
                              await pickCustomReminderDateTime(context);
                          if (customTime != null && customTime.isNotEmpty) {
                            selectedReminder.value = 'Custom ($customTime)';
                          } else {
                            selectedReminder.value = 'Custom';
                          }
                        } else {
                          selectedReminder.value = option;
                        }
                        Get.back();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.textDark,
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<String?> pickCustomReminderDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return null;
    if (!context.mounted) return null;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return null;

    final String hour =
        (pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod)
            .toString();
    final String minute = pickedTime.minute.toString().padLeft(2, '0');
    final String period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final String month = pickedDate.month.toString().padLeft(2, '0');
    final String day = pickedDate.day.toString().padLeft(2, '0');

    return '$month/$day $hour:$minute $period';
  }

  String _getFormattedCurrentDateTime() {
    final now = DateTime.now();
    final int hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final String minute = now.minute.toString().padLeft(2, '0');
    final String period = now.hour >= 12 ? 'PM' : 'AM';
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    final String year = now.year.toString();

    return '$hour12:$minute $period, $month/$day/$year';
  }

  Future<void> saveResponse() async {
    final noteText = textController.text.trim();
    final dt = selectedDateTime.value;
    final formattedCallDate = _getFormattedCurrentDateTime();

    String passkeyVal = lead.passkey;
    if (passkeyVal.isEmpty) {
      final userData = getUserData();
      passkeyVal = userData.passkey ??
          storage.read(LocalKeys.userData)?['passkey'] ??
          '';
    }

    try {
      showCircularLoader();

      var responseRes = await httpRequest(
        REQUEST.post,
        createResponseApiEndPoint,
        {
          "passkey": passkeyVal,
          "leadId": lead.id,
          "phoneNumber": lead.phoneNumber,
          "outcome": selectedOutcome,
          "meetingScheduled": selectedOutcome == 'Got a meeting' ? dt : null,
          "callback": selectedOutcome == 'Got a callback' ? dt : null,
          "text": noteText.isEmpty ? 'Follow-up response' : noteText,
          "reminder": selectedReminder.value,
          "callDate": formattedCallDate,
        },
      );

      hideCircularLoader();

      if (responseRes != null &&
          responseRes["success"] == true &&
          responseRes["data"] != null) {
        final createdResponse =
            LeadResponseModel.fromJson(responseRes["data"]);
        lead.responses.insert(0, createdResponse);
      } else {
        final newResponse = LeadResponseModel(
          responseNumber: 'Response #${lead.responses.length + 1}',
          outcome: selectedOutcome,
          meetingScheduled: selectedOutcome == 'Got a meeting' ? dt : null,
          callback: selectedOutcome == 'Got a callback' ? dt : null,
          text: noteText.isEmpty ? 'Follow-up response' : noteText,
          reminder: selectedReminder.value,
          callDate: formattedCallDate,
        );
        lead.responses.insert(0, newResponse);
      }

      showMySnackBar('Response added for ${lead.name}', success: true);
    } catch (e) {
      hideCircularLoader();
      showMySnackBar('Saved response locally', success: true);
    }

    Get.until((route) =>
        route.settings.name == AppRoutes.callingScreen || route.isFirst);
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
