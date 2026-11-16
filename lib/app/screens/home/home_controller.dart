import 'package:start3x_app/exports.dart';

class HomeController extends GetxController with BaseClass {
  var searchQuery = ''.obs;
  var selectedSortOption = 'Interaction Date'.obs;
  var selectedSortDirection = 'Newest to Oldest'.obs;
  var isLoading = false.obs;

  String clientPasskey = '';

  final RxList<LeadModel> leads = <LeadModel>[].obs;
  final RxMap<String, List<LeadResponseModel>> leadResponsesMap =
      <String, List<LeadResponseModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _extractPasskeyFromArguments();
    fetchLeads();
  }

  void _extractPasskeyFromArguments() {
    if (Get.arguments != null) {
      if (Get.arguments is Map && Get.arguments['passkey'] != null) {
        clientPasskey = Get.arguments['passkey'].toString();
      } else if (Get.arguments is ClientModel) {
        clientPasskey = (Get.arguments as ClientModel).passkey;
      } else if (Get.arguments is AccessClientModel) {
        clientPasskey = (Get.arguments as AccessClientModel).id;
      } else if (Get.arguments is String) {
        clientPasskey = Get.arguments as String;
      }
    }

    if (clientPasskey.isEmpty) {
      clientPasskey = storage.read('clientPasskey')?.toString() ?? '';
    }

    if (clientPasskey.isEmpty) {
      final userData = getUserData();
      clientPasskey = userData.passkey ??
          storage.read(LocalKeys.userData)?['passkey'] ??
          '';
    }

    if (clientPasskey.isNotEmpty) {
      storage.write('clientPasskey', clientPasskey);
    }
  }

  Future<void> fetchLeads() async {
    if (clientPasskey.isEmpty) {
      _extractPasskeyFromArguments();
    }

    if (clientPasskey.isEmpty) {
      leads.clear();
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      var res = await httpRequest(
        REQUEST.get,
        "$getLeadsApiEndPoint?passkey=$clientPasskey",
        {},
      );

      // Also fetch all responses for this passkey to track accurate interaction dates and uncontacted status
      var respRes = await httpRequest(
        REQUEST.get,
        "$getResponsesApiEndPoint?passkey=$clientPasskey",
        {},
      );

      if (respRes != null &&
          respRes["success"] == true &&
          respRes["data"] != null) {
        List dataList = respRes["data"];
        final Map<String, List<LeadResponseModel>> map = {};
        for (var item in dataList) {
          final resp = LeadResponseModel.fromJson(item);
          if (resp.leadId.isNotEmpty) {
            map.putIfAbsent(resp.leadId, () => []).add(resp);
          }
        }
        leadResponsesMap.value = map;
      }

      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        if (dataList.isNotEmpty) {
          leads.value =
              dataList.map((item) => LeadModel.fromJson(item)).toList();

          // Auto-check for past due leads on init
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkPastDueLeads();
            DealClosedPromptHelper.checkAndPromptDealClosed();
          });
        } else {
          leads.clear();
        }
      } else {
        leads.clear();
      }
    } catch (e) {
      // Keep existing leads on network glitch
    } finally {
      isLoading.value = false;
    }
  }

  DateTime? parseLeadDateTime(String text) {
    if (text.isEmpty) return null;

    final regex = RegExp(
        r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})(?:\s+(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)?)?');
    final match = regex.firstMatch(text);
    if (match != null) {
      int day = int.parse(match.group(1)!);
      int month = int.parse(match.group(2)!);
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

      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        return DateTime(year, month, day, hour, minute);
      }
    }

    try {
      return DateTime.parse(text).toLocal();
    } catch (_) {}

    return null;
  }

  void _checkPastDueLeads() {
    final now = DateTime.now();
    for (var lead in leads) {
      final dateStr = lead.scheduledDate;
      if (dateStr.isEmpty) continue;
      final dt = parseLeadDateTime(dateStr);
      if (dt != null && dt.isBefore(now) && (lead.isCompleted == false)) {
        Get.toNamed(
          AppRoutes.callingScreen,
          arguments: {
            'lead': lead,
            'isPastDue': true,
            'pastDueDate': dateStr,
          },
        );
        break; // Open first past due lead
      }
    }
  }

  Future<void> refreshLeads() async {
    await fetchLeads();
  }

  // --- Filter Count Getters ---
  int get uncontactedCount => leads.where((l) => _isUncontactedLead(l)).length;
  int get missedCount => leads.where((l) => _isMissedLead(l)).length;

  void toggleSortDirection() {
    selectedSortDirection.value =
        selectedSortDirection.value == 'Newest to Oldest'
            ? 'Oldest to Newest'
            : 'Newest to Oldest';
  }

  bool _isUncontactedLead(LeadModel lead) {
    // 1. If lead has any logged call responses, it is already contacted
    final responses = leadResponsesMap[lead.id];
    if (responses != null && responses.isNotEmpty) {
      return false;
    }

    // 2. If status or isCompleted indicates an interaction already occurred
    if (lead.isCompleted) return false;

    final status = lead.status.toLowerCase();
    if (status.contains('done') ||
        status.contains('callback') ||
        status.contains('meeting') ||
        status.contains('deal') ||
        status.contains('conversion')) {
      return false;
    }

    return true;
  }

  bool _isMissedLead(LeadModel lead) {
    // 1. Check if status explicitly says missed
    final status = lead.status.toLowerCase();
    if (status.contains('missed')) return true;

    // 2. Check if latest response was missed
    final responses = leadResponsesMap[lead.id];
    if (responses != null && responses.isNotEmpty) {
      if (responses.first.isMissed) return true;
    }

    // 3. Check if scheduled date was in the past and task is not completed
    if (!lead.isCompleted && lead.scheduledDate.isNotEmpty) {
      final dt = parseLeadDateTime(lead.scheduledDate);
      if (dt != null && dt.isBefore(DateTime.now())) {
        return true;
      }
    }

    return false;
  }

  DateTime _getLeadInteractionDate(LeadModel lead) {
    // 1. Check if there are responses
    final responses = leadResponsesMap[lead.id];
    if (responses != null && responses.isNotEmpty) {
      final latest = responses.first;
      final dt = DateTime.tryParse(latest.createdAt) ??
          parseLeadDateTime(latest.createdAt) ??
          parseLeadDateTime(latest.scheduledDate ?? '');
      if (dt != null) return dt;
    }

    // 2. Check lead's scheduledDate
    if (lead.scheduledDate.isNotEmpty) {
      final dt = parseLeadDateTime(lead.scheduledDate);
      if (dt != null) return dt;
    }

    // 3. Fallback to createdAt
    if (lead.createdAt.isNotEmpty) {
      final dt = DateTime.tryParse(lead.createdAt) ??
          parseLeadDateTime(lead.createdAt);
      if (dt != null) return dt;
    }

    // 4. Default by rank number
    final rankNum = int.tryParse(lead.rank.replaceAll(RegExp(r'\D'), '')) ?? 0;
    return DateTime(2020).add(Duration(days: rankNum));
  }

  DateTime _getLeadUploadDate(LeadModel lead) {
    if (lead.createdAt.isNotEmpty) {
      final dt = DateTime.tryParse(lead.createdAt) ??
          parseLeadDateTime(lead.createdAt);
      if (dt != null) return dt;
    }
    final rankNum = int.tryParse(lead.rank.replaceAll(RegExp(r'\D'), '')) ?? 0;
    return DateTime(2020).add(Duration(days: rankNum));
  }

  List<LeadModel> get filteredLeads {
    List<LeadModel> result = leads.toList();

    // 1. Search Query Filter across name, location, rank, phone numbers, KW, bill
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      result = result.where((lead) {
        return lead.name.toLowerCase().contains(q) ||
            lead.location.toLowerCase().contains(q) ||
            lead.rank.toLowerCase().contains(q) ||
            lead.phoneNumber.toLowerCase().contains(q) ||
            lead.altPhoneNumber.toLowerCase().contains(q) ||
            lead.kw.toLowerCase().contains(q) ||
            lead.electricityBill.toLowerCase().contains(q);
      }).toList();
    }

    final isNewest = selectedSortDirection.value == 'Newest to Oldest';
    final opt = selectedSortOption.value;

    // 2. Filter / Sort by Selected Option
    if (opt == 'Uncontacted Leads') {
      result = result.where((lead) => _isUncontactedLead(lead)).toList();
      result.sort((a, b) {
        final dtA = _getLeadUploadDate(a);
        final dtB = _getLeadUploadDate(b);
        return isNewest ? dtB.compareTo(dtA) : dtA.compareTo(dtB);
      });
    } else if (opt == 'Missed Tasks') {
      result = result.where((lead) => _isMissedLead(lead)).toList();
      result.sort((a, b) {
        final dtA = _getLeadInteractionDate(a);
        final dtB = _getLeadInteractionDate(b);
        return isNewest ? dtB.compareTo(dtA) : dtA.compareTo(dtB);
      });
    } else if (opt == 'Upload Date') {
      result.sort((a, b) {
        final dtA = _getLeadUploadDate(a);
        final dtB = _getLeadUploadDate(b);
        return isNewest ? dtB.compareTo(dtA) : dtA.compareTo(dtB);
      });
    } else if (opt == 'Interaction Date') {
      result.sort((a, b) {
        final dtA = _getLeadInteractionDate(a);
        final dtB = _getLeadInteractionDate(b);
        return isNewest ? dtB.compareTo(dtA) : dtA.compareTo(dtB);
      });
    } else {
      // Default: Interaction Date
      result.sort((a, b) {
        final dtA = _getLeadInteractionDate(a);
        final dtB = _getLeadInteractionDate(b);
        return isNewest ? dtB.compareTo(dtA) : dtA.compareTo(dtB);
      });
    }

    return result;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void showSortBottomSheet(BuildContext context) {
    final tempOption = selectedSortOption.value.obs;
    final tempDirection = selectedSortDirection.value.obs;

    final sortOptions = [
      'Upload Date',
      'Interaction Date',
      'Uncontacted Leads',
      'Missed Tasks',
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
              // Top Action Row: Cancel & Apply
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      selectedSortOption.value = tempOption.value;
                      selectedSortDirection.value = tempDirection.value;
                      Get.back();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Subtitle & Title
              const Text(
                'Organize Contacts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Organise as needed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 24),

              // Options Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Column(
                  children: List.generate(sortOptions.length, (index) {
                    final option = sortOptions[index];
                    final isLast = index == sortOptions.length - 1;

                    return Obx(() {
                      final isSelected = tempOption.value == option;
                      final directionText = tempDirection.value;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (isSelected) {
                                tempDirection.value =
                                    tempDirection.value == 'Newest to Oldest'
                                        ? 'Oldest to Newest'
                                        : 'Newest to Oldest';
                              } else {
                                tempOption.value = option;
                                tempDirection.value = 'Newest to Oldest';
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 16),
                              child: isSelected
                                  ? Row(
                                      children: [
                                        const Icon(
                                          Icons.swap_vert_rounded,
                                          color: AppColors.primaryBlue,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 14),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              option,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              directionText,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.shade200,
                            ),
                        ],
                      );
                    });
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
