import 'package:start3x_app/exports.dart';

class InsightsController extends GetxController {
  var selectedFilter = 'Select by date'.obs;

  final RxList<InsightItemModel> insightItems = <InsightItemModel>[
    InsightItemModel(title: 'Callback Missed', count: '00'),
    InsightItemModel(title: 'Meetings Missed', count: '00'),
    InsightItemModel(title: 'Meetings Done', count: '00'),
    InsightItemModel(title: 'Conversions', count: '00'),
  ].obs;

  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }
}
