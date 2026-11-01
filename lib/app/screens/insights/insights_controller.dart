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
      final List<LeadModel> leadList = homeCtrl.leads;

      int cbMissed = 0;
      int cbDone = 0;
      int mtgMissed = 0;
      int mtgDone = 0;
      int conversions = 0;

      for (final LeadModel item in leadList) {
        final String status = item.status.toLowerCase();
        if (status.contains('callback')) {
          if (status.contains('missed')) {
            cbMissed++;
          } else {
            cbDone++;
          }
        } else if (status.contains('meeting')) {
          if (status.contains('missed')) {
            mtgMissed++;
          } else {
            mtgDone++;
          }
        } else if (status.contains('conversion') || status.contains('converted')) {
          conversions++;
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
