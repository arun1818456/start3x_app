import 'package:start3x_app/exports.dart';

class TaskController extends GetxController {
  var searchQuery = ''.obs;
  var selectedSort = 'Sorted by'.obs;

  final RxList<ToDoItemModel> todayTasks = <ToDoItemModel>[
    ToDoItemModel(
      rank: '#3',
      name: 'Lehraj mehra',
      location: 'chandigarh',
      status: 'To-Do:',
      date: 'October 23, 2026',
      time: '11:30 Am',
      reminderTime: '11:00',
    ),
    ToDoItemModel(
      rank: '#5',
      name: 'Lehraj mehra',
      location: 'chandigarh',
      status: 'To-Do:',
      date: 'October 23, 2026',
      time: '11:30 Am',
      reminderTime: '11:00',
    ),
    ToDoItemModel(
      rank: '#2',
      name: 'Lehraj mehra',
      location: 'chandigarh',
      status: 'To-Do:',
      date: 'October 23, 2026',
      time: '11:30 Am',
      reminderTime: '11:00',
    ),
  ].obs;

  final RxList<ToDoItemModel> tomorrowTasks = <ToDoItemModel>[
    ToDoItemModel(
      rank: '#1',
      name: 'Lehraj mehra',
      location: 'chandigarh',
      status: 'To-Do:',
      date: 'October 23, 2026',
      time: '11:30 Am',
      reminderTime: '11:00',
    ),
    ToDoItemModel(
      rank: '#6',
      name: 'Lehraj mehra',
      location: 'chandigarh',
      status: 'To-Do:',
      date: 'October 23, 2026',
      time: '11:30 Am',
      reminderTime: '11:00',
    ),
  ].obs;

  List<ToDoItemModel> filterTasks(List<ToDoItemModel> list) {
    if (searchQuery.value.isEmpty) {
      return list;
    }
    return list
        .where((item) =>
            item.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            item.location
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }
}
