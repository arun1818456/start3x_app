import 'package:start3x_app/exports.dart';

class CallResponseController extends GetxController with BaseClass {
  late LeadModel lead;
  var selectedOutcomeIndex = (-1).obs; // Initially nothing is selected (-1)

  final List<String> outcomes = [
    'Got a callback',
    'Got a meeting',
    "Didn't pick up",
    'He picked up, but no result',
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is LeadModel) {
      lead = Get.arguments as LeadModel;
    } else {
      lead = LeadModel(
        rank: '#3',
        name: 'Vikram Singh',
        location: 'chandigarh',
        status: 'To-Do:',
        date: 'October 23, 2026',
      );
    }
  }

  void onSelectOption(int index) {
    selectedOutcomeIndex.value = index;
  }

  void onSaveOutcome() {
    if (selectedOutcomeIndex.value == -1) {
      showMySnackBar(
        'Select an outcome for this call to proceed',
        alert: true,
      );
      return;
    }

    final selectedOutcome = outcomes[selectedOutcomeIndex.value];
    Get.toNamed(
      AppRoutes.addCallData,
      arguments: {
        'lead': lead,
        'outcome': selectedOutcome,
      },
    );
  }
}
