import 'package:start3x_app/exports.dart';

class TaskController extends GetxController with BaseClass {
  var searchQuery = ''.obs;
  var selectedSort = 'Sorted by'.obs;

  final RxList<ToDoItemModel> todayTasks = <ToDoItemModel>[].obs;
  final RxList<ToDoItemModel> tomorrowTasks = <ToDoItemModel>[].obs;

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

  void populateTasks(List<LeadModel> leads) {
    List<ToDoItemModel> today = [];
    List<ToDoItemModel> tomorrow = [];

    for (var lead in leads) {
      final todoItem = ToDoItemModel(
        rank: lead.rank,
        name: lead.name,
        location: lead.location,
        status: lead.status,
        date: lead.date,
        time: '11:30 AM',
        reminderTime: '11:00 AM',
      );

      if (lead.status.toLowerCase().contains('to-do') ||
          lead.status.toLowerCase().contains('missed')) {
        today.add(todoItem);
      } else {
        tomorrow.add(todoItem);
      }
    }

    todayTasks.value = today;
    tomorrowTasks.value = tomorrow;
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
