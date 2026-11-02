import 'package:start3x_app/exports.dart';

class InsightsController extends GetxController with BaseClass {
  var isLoading = false.obs;
  var selectedFilter = 'Select by date'.obs;

  final RxList<InsightItemModel> insightItems = <InsightItemModel>[
    InsightItemModel(title: 'Callback Missed', count: '00'),
    InsightItemModel(title: 'Callback Done', count: '00'),
    InsightItemModel(title: 'Meetings Missed', count: '00'),
    InsightItemModel(title: 'Meetings Done', count: '00'),
    InsightItemModel(title: 'Conversions', count: '00'),
  ].obs;

  final folderLeads = <LeadModel>[].obs;
  var isFolderLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInsightsFromApi();
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
      String query = passkeyVal.isNotEmpty ? "passkey=$passkeyVal" : "";

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

      String query = "passkey=$passkeyVal&category=$categoryKey";

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

      // Fallback: fetch leads and responses and filter locally
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

      final Set<String> matchedLeadIds = {};
      for (var resp in responses) {
        final outcome = resp.outcome.toLowerCase();
        final text = resp.text.toLowerCase();
        bool isMatch = false;

        if (categoryKey == 'meetings_done') {
          isMatch = resp.isDone && (outcome.contains('meeting') || text.contains('completed'));
        } else if (categoryKey == 'meetings_missed') {
          isMatch = resp.isMissed && (outcome.contains('meeting') || text.contains('missed'));
        } else if (categoryKey == 'callback_done') {
          isMatch = resp.isDone && outcome.contains('callback');
        } else if (categoryKey == 'callback_missed') {
          isMatch = resp.isMissed && outcome.contains('callback');
        } else if (categoryKey == 'task_done') {
          isMatch = resp.isDone;
        }

        if (isMatch && resp.leadId.isNotEmpty) {
          matchedLeadIds.add(resp.leadId);
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
    int cbMissed = 0;
    int cbDone = 0;
    int mtgMissed = 0;
    int mtgDone = 0;
    int conversions = 0;

    for (var resp in responses) {
      final outcome = resp.outcome.toLowerCase();
      if (resp.isDone) {
        if (outcome.contains('callback')) {
          cbDone++;
        } else if (outcome.contains('meeting')) {
          mtgDone++;
        } else {
          conversions++;
        }
      } else if (resp.isMissed) {
        if (outcome.contains('callback')) {
          cbMissed++;
        } else if (outcome.contains('meeting')) {
          mtgMissed++;
        } else {
          cbMissed++;
        }
      } else {
        if (outcome.contains('callback')) {
          cbDone++;
        } else if (outcome.contains('meeting')) {
          mtgDone++;
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

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    fetchInsightsFromApi();
  }
}
