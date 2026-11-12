import 'package:start3x_app/exports.dart';

class InsightsController extends GetxController with BaseClass {
  var isLoading = false.obs;
  var selectedFilter = 'Today'.obs;
  DateTime? customStartDate;
  DateTime? customEndDate;

  final RxList<InsightItemModel> insightItems = <InsightItemModel>[
    InsightItemModel(title: 'Callback Missed', count: '00'),
    InsightItemModel(title: 'Callback Done', count: '00'),
    InsightItemModel(title: 'Meetings Missed', count: '00'),
    InsightItemModel(title: 'Meetings Done', count: '00'),
    InsightItemModel(title: 'Conversions / Tasks Done', count: '00'),
  ].obs;

  final folderLeads = <LeadModel>[].obs;
  var isFolderLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInsightsFromApi();
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _buildDateQueryString() {
    if (selectedFilter.value == 'All Time') return "";

    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (selectedFilter.value == 'Today') {
      start = now;
      end = now;
    } else if (selectedFilter.value == 'Yesterday') {
      final y = now.subtract(const Duration(days: 1));
      start = y;
      end = y;
    } else if (selectedFilter.value == 'Last 7 Days') {
      start = now.subtract(const Duration(days: 6));
      end = now;
    } else if (selectedFilter.value == 'Last Month') {
      start = DateTime(now.year, now.month - 1, 1);
      end = DateTime(now.year, now.month, 0);
    } else if (customStartDate != null && customEndDate != null) {
      start = customStartDate;
      end = customEndDate;
    }

    if (start != null && end != null) {
      return "&startDate=${_formatDate(start)}&endDate=${_formatDate(end)}";
    }
    return "";
  }

  String _resolvePasskey() {
    String passkey = '';

    // 1. Try from HomeController if registered
    if (Get.isRegistered<HomeController>()) {
      passkey = Get.find<HomeController>().clientPasskey;
    }

    // 2. Try from Get.arguments if passed
    if (passkey.isEmpty && Get.arguments != null) {
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

    // 3. Try from storage ('clientPasskey')
    if (passkey.isEmpty) {
      passkey = storage.read('clientPasskey')?.toString() ?? '';
    }

    // 4. Try from logged in user data
    if (passkey.isEmpty) {
      final userData = getUserData();
      passkey = userData.passkey ??
          storage.read(LocalKeys.userData)?['passkey'] ??
          '';
    }

    return passkey;
  }

  Future<void> fetchInsightsFromApi() async {
    try {
      isLoading.value = true;
      final String passkeyVal = _resolvePasskey();
      final String dateQuery = _buildDateQueryString();
      String query = passkeyVal.isNotEmpty
          ? "passkey=$passkeyVal$dateQuery"
          : (dateQuery.startsWith('&') ? dateQuery.substring(1) : dateQuery);

      var res = await httpRequest(
        REQUEST.get,
        "$getInsightsSummaryApiEndPoint?$query",
        {},
      );

      if (res != null && res["success"] == true && res["data"] != null) {
        final data = res["data"];
        if (data is Map<String, dynamic>) {
          int cbMissed = int.tryParse(data['callbackMissed']?.toString() ?? '0') ?? 0;
          int cbDone = int.tryParse(data['callbackDone']?.toString() ?? '0') ?? 0;
          int mtgMissed = int.tryParse(data['meetingsMissed']?.toString() ?? '0') ?? 0;
          int mtgDone = int.tryParse(data['meetingsDone']?.toString() ?? '0') ?? 0;
          int taskDone = int.tryParse(data['taskDone']?.toString() ?? data['conversions']?.toString() ?? '0') ?? 0;

          insightItems.value = [
            InsightItemModel(title: 'Callback Missed', count: cbMissed.toString().padLeft(2, '0')),
            InsightItemModel(title: 'Callback Done', count: cbDone.toString().padLeft(2, '0')),
            InsightItemModel(title: 'Meetings Missed', count: mtgMissed.toString().padLeft(2, '0')),
            InsightItemModel(title: 'Meetings Done', count: mtgDone.toString().padLeft(2, '0')),
            InsightItemModel(title: 'Conversions / Tasks Done', count: taskDone.toString().padLeft(2, '0')),
          ];
          return;
        }
      }

      // Fallback to fetching responses if summary endpoint isn't populated yet
      var respRes = await httpRequest(
        REQUEST.get,
        "$getResponsesApiEndPoint?$query",
        {},
      );

      if (respRes != null && respRes["success"] == true && respRes["data"] != null) {
        List dataList = respRes["data"];
        final List<LeadResponseModel> responses = dataList
            .map((item) => LeadResponseModel.fromJson(item))
            .toList();
        _processResponses(responses);
      } else {
        _processResponsesFromLocalLeads();
      }
    } catch (e) {
      _processResponsesFromLocalLeads();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFolderLeads(String folderType) async {
    try {
      isFolderLoading.value = true;
      final String passkeyVal = _resolvePasskey();

      String categoryKey = 'meetings_done';
      final String typeLower = folderType.toLowerCase();
      if (typeLower.contains('meeting done') || typeLower.contains('meetings done')) {
        categoryKey = 'meetings_done';
      } else if (typeLower.contains('meeting missed') || typeLower.contains('meetings missed')) {
        categoryKey = 'meetings_missed';
      } else if (typeLower.contains('callback done')) {
        categoryKey = 'callback_done';
      } else if (typeLower.contains('callback missed')) {
        categoryKey = 'callback_missed';
      } else if (typeLower.contains('conversion') || typeLower.contains('tasks done')) {
        categoryKey = 'task_done';
      }

      final String dateQuery = _buildDateQueryString();
      String query = "passkey=$passkeyVal&category=$categoryKey$dateQuery";

      var res = await httpRequest(
        REQUEST.get,
        "$getInsightFolderLeadsApiEndPoint?$query",
        {},
      );

      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        final List<LeadModel> populatedLeads = dataList
            .map((item) => LeadModel.fromJson(item))
            .toList();
        folderLeads.value = populatedLeads;
        return;
      }

      // Fallback: fetch leads and responses and filter locally based strictly on LATEST response
      List<LeadModel> allLeads = [];
      if (Get.isRegistered<HomeController>()) {
        allLeads = Get.find<HomeController>().leads.toList();
      }

      var leadRes = await httpRequest(
        REQUEST.get,
        "$getLeadsApiEndPoint?passkey=$passkeyVal",
        {},
      );

      if (leadRes != null && leadRes["success"] == true && leadRes["data"] != null) {
        List dataList = leadRes["data"];
        allLeads = dataList.map((item) => LeadModel.fromJson(item)).toList();
      }

      var respRes = await httpRequest(
        REQUEST.get,
        "$getResponsesApiEndPoint?$query",
        {},
      );

      List<LeadResponseModel> responses = [];
      if (respRes != null && respRes["success"] == true && respRes["data"] != null) {
        List dataList = respRes["data"];
        responses = dataList.map((item) => LeadResponseModel.fromJson(item)).toList();
      }

      // Keep ONLY the single latest response for each lead!
      final Map<String, LeadResponseModel> latestMap = {};
      for (var resp in responses) {
        if (resp.leadId.isEmpty) continue;
        if (!latestMap.containsKey(resp.leadId)) {
          latestMap[resp.leadId] = resp;
        }
      }

      final Set<String> matchedLeadIds = {};
      for (var entry in latestMap.entries) {
        final resp = entry.value;
        final outcome = resp.outcome.toLowerCase();
        bool isMatch = false;

        if (categoryKey == 'meetings_done') {
          isMatch = resp.isDone && outcome.contains('meeting');
        } else if (categoryKey == 'meetings_missed') {
          isMatch = resp.isMissed && outcome.contains('meeting');
        } else if (categoryKey == 'callback_done') {
          isMatch = resp.isDone && outcome.contains('callback');
        } else if (categoryKey == 'callback_missed') {
          isMatch = resp.isMissed && outcome.contains('callback');
        } else if (categoryKey == 'task_done') {
          isMatch = resp.isDone && !outcome.contains('meeting') && !outcome.contains('callback');
        }

        if (isMatch) {
          matchedLeadIds.add(entry.key);
        }
      }

      final List<LeadModel> populated = [];
      for (var lead in allLeads) {
        if (matchedLeadIds.contains(lead.id)) {
          populated.add(lead);
        }
      }

      folderLeads.value = populated;
    } catch (e) {
      folderLeads.clear();
    } finally {
      isFolderLoading.value = false;
    }
  }

  void _processResponsesFromLocalLeads() {
    if (Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      final leadList = homeCtrl.leads;

      int cbMissed = 0;
      int cbDone = 0;
      int mtgMissed = 0;
      int mtgDone = 0;
      int conversions = 0;

      for (final lead in leadList) {
        final status = lead.status.toLowerCase();
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
        } else if (status.contains('conversion') ||
            status.contains('converted')) {
          conversions++;
        }
      }

      insightItems.value = [
        InsightItemModel(title: 'Callback Missed', count: cbMissed.toString().padLeft(2, '0')),
        InsightItemModel(title: 'Callback Done', count: cbDone.toString().padLeft(2, '0')),
        InsightItemModel(title: 'Meetings Missed', count: mtgMissed.toString().padLeft(2, '0')),
        InsightItemModel(title: 'Meetings Done', count: mtgDone.toString().padLeft(2, '0')),
        InsightItemModel(title: 'Conversions / Tasks Done', count: conversions.toString().padLeft(2, '0')),
      ];
    }
  }

  void _processResponses(List<LeadResponseModel> responses) {
    // Keep ONLY the single latest response for each lead!
    final Map<String, LeadResponseModel> latestMap = {};
    for (var resp in responses) {
      if (resp.leadId.isEmpty) continue;
      if (!latestMap.containsKey(resp.leadId)) {
        latestMap[resp.leadId] = resp;
      }
    }

    int cbMissed = 0;
    int cbDone = 0;
    int mtgMissed = 0;
    int mtgDone = 0;
    int conversions = 0;

    for (var resp in latestMap.values) {
      final outcome = resp.outcome.toLowerCase();
      if (resp.isDone) {
        if (outcome.contains('meeting')) {
          mtgDone++;
        } else if (outcome.contains('callback')) {
          cbDone++;
        } else {
          conversions++;
        }
      } else if (resp.isMissed) {
        if (outcome.contains('meeting')) {
          mtgMissed++;
        } else if (outcome.contains('callback')) {
          cbMissed++;
        } else {
          cbMissed++;
        }
      }
    }

    insightItems.value = [
      InsightItemModel(title: 'Callback Missed', count: cbMissed.toString().padLeft(2, '0')),
      InsightItemModel(title: 'Callback Done', count: cbDone.toString().padLeft(2, '0')),
      InsightItemModel(title: 'Meetings Missed', count: mtgMissed.toString().padLeft(2, '0')),
      InsightItemModel(title: 'Meetings Done', count: mtgDone.toString().padLeft(2, '0')),
      InsightItemModel(title: 'Conversions / Tasks Done', count: conversions.toString().padLeft(2, '0')),
    ];
  }

  Future<void> pickCustomDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: customStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      customStartDate = picked;
      customEndDate = picked;
      final String formattedDate =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      selectedFilter.value = formattedDate;
      fetchInsightsFromApi();
    }
  }

  void updateFilter(String filter) {
    customStartDate = null;
    customEndDate = null;
    selectedFilter.value = filter;
    fetchInsightsFromApi();
  }
}
