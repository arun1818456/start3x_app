import 'package:start3x_app/exports.dart';

class FinalScreenController extends GetxController {
  final textController = TextEditingController();
  late LeadModel lead;
  String selectedOutcome = 'Got a meeting';
  var selectedDateTime = RxnString();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      lead = args['lead'] as LeadModel? ??
          LeadModel(
            rank: '#3',
            name: 'Vikram Singh',
            location: 'chandigarh',
            status: 'To-Do:',
            date: 'October 23, 2026',
          );
      selectedOutcome = args['outcome']?.toString() ?? 'Got a meeting';
      selectedDateTime.value = args['dateTime']?.toString();
    } else {
      lead = LeadModel(
        rank: '#3',
        name: 'Vikram Singh',
        location: 'chandigarh',
        status: 'To-Do:',
        date: 'October 23, 2026',
      );
    }

    // Auto trigger date & time picker on init for callback/meeting if not set
    if ((selectedOutcome == 'Got a callback' || selectedOutcome == 'Got a meeting') &&
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

    final String hour = (pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod)
        .toString();
    final String minute = pickedTime.minute.toString().padLeft(2, '0');
    final String period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final String month = combined.month.toString().padLeft(2, '0');
    final String day = combined.day.toString().padLeft(2, '0');
    final String year = combined.year.toString();

    selectedDateTime.value = '$hour:$minute $period, $month/$day/$year';
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

  void saveResponse() {
    final noteText = textController.text.trim();
    final dt = selectedDateTime.value;
    final newResponse = LeadResponseModel(
      responseNumber: 'Response #${lead.responses.length + 1}',
      outcome: selectedOutcome,
      meetingScheduled: selectedOutcome == 'Got a meeting' ? dt : null,
      callback: selectedOutcome == 'Got a callback' ? dt : null,
      text: noteText.isEmpty ? 'Unhe sirf hybrid chahiye' : noteText,
      callDate: _getFormattedCurrentDateTime(),
    );

    lead.responses.insert(0, newResponse);

    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'Saved Successfully',
      'Response added for ${lead.name}',
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.until((route) => route.settings.name == AppRoutes.callingScreen || route.isFirst);
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
