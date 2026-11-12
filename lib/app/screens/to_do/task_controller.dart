import 'package:start3x_app/exports.dart';

class TaskController extends GetxController with BaseClass {
  var searchQuery = ''.obs;
  var selectedSort = 'Time (Earliest first)'.obs;
  var isLoading = false.obs;

  final RxList<ToDoItemModel> todayTasks = <ToDoItemModel>[].obs;
  final RxList<ToDoItemModel> tomorrowTasks = <ToDoItemModel>[].obs;
  final RxList<ToDoItemModel> otherTasks = <ToDoItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasksFromLeads();
  }

  String resolvePasskey() {
    String passkey = '';

    // 1. From Get.arguments (when Admin navigates to a specific client)
    if (Get.arguments != null) {
      if (Get.arguments is Map && Get.arguments['passkey'] != null) {
        passkey = Get.arguments['passkey'].toString();
      } else if (Get.arguments is ClientModel) {
        passkey = (Get.arguments as ClientModel).passkey;
      } else if (Get.arguments is AccessClientModel) {
        passkey = (Get.arguments as AccessClientModel).id;
      } else if (Get.arguments is String) {
        passkey = Get.arguments as String;
      }
    }

    // 2. From HomeController if available
    if (passkey.isEmpty && Get.isRegistered<HomeController>()) {
      final homePasskey = Get.find<HomeController>().clientPasskey;
      if (homePasskey.isNotEmpty) passkey = homePasskey;
    }

    // 3. From storage cache
    if (passkey.isEmpty) {
      passkey = storage.read('clientPasskey')?.toString() ?? '';
    }

    // 4. From logged in user profile
    if (passkey.isEmpty) {
      final userData = getUserData();
      passkey = userData.passkey ?? '';
    }

    return passkey;
  }

  void loadTasksFromLeads() {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      if (homeController.leads.isNotEmpty) {
        populateTasks(homeController.leads);
      } else {
        fetchTasksFromApi();
      }
      ever(homeController.leads, (List<LeadModel> leadsList) {
        populateTasks(leadsList);
      });
    } else {
      fetchTasksFromApi();
    }
  }

  Future<void> fetchTasksFromApi() async {
    final passkey = resolvePasskey();
    if (passkey.isEmpty) return;

    try {
      isLoading.value = true;
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
    } finally {
      isLoading.value = false;
    }
  }

  DateTime? parseLeadDateTime(String text) {
    if (text.isEmpty) return null;

    final regex = RegExp(
      r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})(?:\s+(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)?)?',
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      int d1 = int.parse(match.group(1)!);
      int d2 = int.parse(match.group(2)!);
      int year = int.parse(match.group(3)!);

      int hour = 0;
      int minute = 0;
      if (match.group(4) != null && match.group(5) != null) {
        hour = int.parse(match.group(4)!);
        minute = int.parse(match.group(5)!);
        final period = match.group(6)?.toUpperCase();
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }

      // Format is DD/MM/YYYY: d1 is Day, d2 is Month
      if (d2 >= 1 && d2 <= 12 && d1 >= 1 && d1 <= 31) {
        return DateTime(year, d2, d1, hour, minute);
      } else if (d1 >= 1 && d1 <= 12 && d2 >= 1 && d2 <= 31) {
        return DateTime(year, d1, d2, hour, minute);
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
      // Exclude completed tasks from active To-Do list
      if (lead.isCompleted || lead.status.toLowerCase().startsWith('done')) {
        continue;
      }

      String dateStr = lead.scheduledDate.isNotEmpty
          ? lead.scheduledDate
          : lead.createdAt;
      String statusStr = lead.status.isNotEmpty ? lead.status : 'To-do:';
      String timeStr = '11:30 AM';
      String reminderStr = 'At task due time';

      final timeMatch =
          RegExp(r'\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)').firstMatch(dateStr);
      if (timeMatch != null) {
        timeStr = timeMatch.group(0)!;
      }

      final parsed = parseLeadDateTime(dateStr);

      String displayDate = dateStr;
      if (parsed != null) {
        String day = parsed.day.toString().padLeft(2, '0');
        String month = parsed.month.toString().padLeft(2, '0');
        displayDate = '$day/$month/${parsed.year}';
      }

      // Check if task is overdue (scheduled before today)
      bool isOverdue = false;
      if (parsed != null) {
        final taskDayOnly = DateTime(parsed.year, parsed.month, parsed.day);
        if (taskDayOnly.isBefore(todayDate)) {
          isOverdue = true;
        }
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
        dateTime: parsed,
        isOverdue: isOverdue,
      );

      if (parsed == null) {
        // Fallback: if status says to-do or missed, place in today
        if (statusStr.toLowerCase().contains('to-do') ||
            statusStr.toLowerCase().contains('missed')) {
          today.add(todoItem);
        } else {
          other.add(todoItem);
        }
      } else if (isOverdue || _isSameDay(parsed, todayDate)) {
        // Overdue tasks and Today's tasks belong in Today's actionable bucket!
        today.add(todoItem);
      } else if (_isSameDay(parsed, tomorrowDate)) {
        tomorrow.add(todoItem);
      } else if (parsed.isAfter(tomorrowDate)) {
        other.add(todoItem);
      } else {
        today.add(todoItem);
      }
    }

    _applySorting(today);
    _applySorting(tomorrow);
    _applySorting(other);

    todayTasks.value = today;
    tomorrowTasks.value = tomorrow;
    otherTasks.value = other;
  }

  void _applySorting(List<ToDoItemModel> list) {
    if (selectedSort.value.contains('Earliest')) {
      list.sort((a, b) {
        // Put overdue tasks first
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;

        if (a.dateTime == null && b.dateTime == null) return 0;
        if (a.dateTime == null) return 1;
        if (b.dateTime == null) return -1;
        return a.dateTime!.compareTo(b.dateTime!);
      });
    } else if (selectedSort.value.contains('Latest')) {
      list.sort((a, b) {
        if (a.dateTime == null && b.dateTime == null) return 0;
        if (a.dateTime == null) return 1;
        if (b.dateTime == null) return -1;
        return b.dateTime!.compareTo(a.dateTime!);
      });
    } else if (selectedSort.value.contains('Rank')) {
      list.sort((a, b) {
        int rA = int.tryParse(a.rank.replaceAll(RegExp(r'\D'), '')) ?? 999;
        int rB = int.tryParse(b.rank.replaceAll(RegExp(r'\D'), '')) ?? 999;
        return rA.compareTo(rB);
      });
    } else if (selectedSort.value.contains('Name')) {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
  }

  void setSortOption(String option) {
    selectedSort.value = option;
    if (Get.isRegistered<HomeController>()) {
      populateTasks(Get.find<HomeController>().leads);
    } else {
      fetchTasksFromApi();
    }
  }

  void showSortBottomSheet(BuildContext context) {
    final options = [
      'Time (Earliest first)',
      'Time (Latest first)',
      'Rank (#1 to #99)',
      'Name (A to Z)',
    ];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort Tasks By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 10),
              ...options.map((opt) {
                return Obx(() {
                  final isSelected = selectedSort.value == opt;
                  return InkWell(
                    onTap: () {
                      setSortOption(opt);
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            opt,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.textDark,
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
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  List<ToDoItemModel> filterTasks(List<ToDoItemModel> list) {
    if (searchQuery.value.trim().isEmpty) {
      return list;
    }
    final q = searchQuery.value.toLowerCase().trim();
    return list.where((item) {
      return item.name.toLowerCase().contains(q) ||
          item.location.toLowerCase().contains(q) ||
          item.rank.toLowerCase().contains(q) ||
          item.status.toLowerCase().contains(q);
    }).toList();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }
}
