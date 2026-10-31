import 'package:start3x_app/exports.dart';

class InsightsController extends GetxController {
  var selectedFilter = 'Select by date'.obs;

  final RxList<InsightItemModel> insightItems = <InsightItemModel>[
    InsightItemModel(title: 'Callback Missed', count: '00'),
    InsightItemModel(title: 'Callback Done', count: '00'),
    InsightItemModel(title: 'Meetings Missed', count: '00'),
    InsightItemModel(title: 'Meetings Done', count: '00'),
    InsightItemModel(title: 'Conversions', count: '00'),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    calculateInsights();
  }

  void calculateInsights() {
    if (Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      final leads = homeCtrl.leads;

      int cbMissed = 0;
      int cbDone = 0;
      int mtgMissed = 0;
      int mtgDone = 0;
      int conversions = 0;

      for (var lead in leads) {
        final status = lead.status.toLowerCase();
        for (var resp in lead.responses) {
          final outcome = resp.outcome.toLowerCase();
          if (outcome.contains('callback')) {
            cbDone++;
          }
          if (outcome.contains('meeting')) {
            mtgDone++;
          }
          if (outcome.contains('conversion') || outcome.contains('converted')) {
            conversions++;
          }
        }

        if (status.contains('missed')) {
          if (status.contains('callback')) cbMissed++;
          if (status.contains('meeting')) mtgMissed++;
        }
      }

      insightItems.value = [
        InsightItemModel(
            title: 'Callback Missed',
            count: cbMissed.toString().padLeft(2, '0')),
        InsightItemModel(
            title: 'Callback Done',
            count: cbDone.toString().padLeft(2, '0')),
        InsightItemModel(
            title: 'Meetings Missed',
            count: mtgMissed.toString().padLeft(2, '0')),
        InsightItemModel(
            title: 'Meetings Done',
            count: mtgDone.toString().padLeft(2, '0')),
        InsightItemModel(
            title: 'Conversions',
            count: conversions.toString().padLeft(2, '0')),
      ];
    }
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    calculateInsights();
  }
}
