import 'package:start3x_app/exports.dart';

class TaskController extends GetxController with BaseClass {
  var searchQuery = ''.obs;
  var selectedSort = 'Sorted by'.obs;

  final RxList<ToDoItemModel> todayTasks = <ToDoItemModel>[].obs;
  final RxList<ToDoItemModel> tomorrowTasks = <ToDoItemModel>[].obs;
  final RxList<ToDoItemModel> otherTasks = <ToDoItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasksFromLeads();
  }

  void loadTasksFromLeads() {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      populateTasks(homeController.leads);
      ever(homeController.leads, (List<LeadModel> leadsList) {
        populateTasks(leadsList);
      });
    } else {
      fetchTasksFromApi();
    }
  }

  Future<void> fetchTasksFromApi() async {
    String passkey = '';
    if (Get.isRegistered<HomeController>()) {
      passkey = Get.find<HomeController>().clientPasskey;
    }

    if (passkey.isEmpty && Get.arguments != null) {
      if (Get.arguments is Map && Get.arguments['passkey'] != null) {
        passkey = Get.arguments['passkey'].toString();
      } else if (Get.arguments is String) {
        passkey = Get.arguments as String;
      }
    }

    if (passkey.isEmpty) {
      final userData = getUserData();
      passkey = userData.passkey ??
          storage.read(LocalKeys.userData)?['passkey'] ??
          '';
    }

    if (passkey.isEmpty) return;

    try {
      var res = await httpRequest(
        REQUEST.get,
        "$getLeadsApiEndPoint?passkey=$passkey",
        {},
      );
      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        List<LeadModel> leads =
            dataList.map((item) => LeadModel.fromJson(item)).toList();
        populateTasks(leads);
      }
    } catch (e) {
      // Keep existing
    }
  }

  DateTime? _parseDateString(String text) {
    if (text.isEmpty) return null;

    final regex = RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})');
    final match = regex.firstMatch(text);
    if (match != null) {
      int d1 = int.parse(match.group(1)!);
      int d2 = int.parse(match.group(2)!);
      int year = int.parse(match.group(3)!);

      // Primary DD/MM/YYYY format: d1 is Day, d2 is Month
      if (d2 >= 1 && d2 <= 12 && d1 >= 1 && d1 <= 31) {
        return DateTime(year, d2, d1);
      } else if (d1 >= 1 && d1 <= 12 && d2 >= 1 && d2 <= 31) {
        return DateTime(year, d1, d2);
      }
    }

    try {
      return DateTime.parse(text).toLocal();
    } catch (_) {}

    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void populateTasks(List<LeadModel> leads) {
    List<ToDoItemModel> today = [];
    List<ToDoItemModel> tomorrow = [];
    List<ToDoItemModel> other = [];

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final tomorrowDate = todayDate.add(const Duration(days: 1));

    for (var lead in leads) {
      String dateStr = lead.scheduledDate;
      String statusStr = lead.status;
      String timeStr = '11:30 AM';
      String reminderStr = 'At task due time';

      final timeMatch =
          RegExp(r'\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)').firstMatch(dateStr);
      if (timeMatch != null) {
        timeStr = timeMatch.group(0)!;
      }

      final parsed = _parseDateString(dateStr);

      String displayDate = dateStr;
      if (parsed != null) {
        String day = parsed.day.toString().padLeft(2, '0');
        String month = parsed.month.toString().padLeft(2, '0');
        displayDate = '$day/$month/${parsed.year}';
      }

      final todoItem = ToDoItemModel(
        lead: lead,
        rank: lead.rank,
        name: lead.name,
        location: lead.location,
        status: statusStr,
        date: displayDate,
        time: timeStr,
        reminderTime: reminderStr,
      );

      if (parsed == null) {
        if (lead.status.toLowerCase().contains('to-do') ||
            lead.status.toLowerCase().contains('missed')) {
          today.add(todoItem);
        } else {
          tomorrow.add(todoItem);
        }
      } else if (_isSameDay(parsed, todayDate)) {
        today.add(todoItem);
      } else if (_isSameDay(parsed, tomorrowDate)) {
        tomorrow.add(todoItem);
      } else {
        other.add(todoItem);
      }
    }

    todayTasks.value = today;
    tomorrowTasks.value = tomorrow;
    otherTasks.value = other;
  }

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
