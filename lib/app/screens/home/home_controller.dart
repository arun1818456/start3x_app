import 'package:start3x_app/exports.dart';

class HomeController extends GetxController with BaseClass {
  var searchQuery = ''.obs;
  var selectedSortOption = 'Interaction Date'.obs;
  var selectedSortDirection = 'Newest to Oldest'.obs;
  var isLoading = false.obs;

  String clientPasskey = '';

  final RxList<LeadModel> leads = <LeadModel>[].obs;

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
      final userData = getUserData();
      clientPasskey = userData.passkey ??
          storage.read(LocalKeys.userData)?['passkey'] ??
          '';
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

      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        if (dataList.isNotEmpty) {
          leads.value =
              dataList.map((item) => LeadModel.fromJson(item)).toList();
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

  Future<void> refreshLeads() async {
    await fetchLeads();
  }

  List<LeadModel> get filteredLeads {
    List<LeadModel> result = leads.toList();

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result
          .where((lead) =>
              lead.name.toLowerCase().contains(q) ||
              lead.location.toLowerCase().contains(q) ||
              lead.company.toLowerCase().contains(q))
          .toList();
    }

    if (selectedSortOption.value == 'Upload Date') {
      result.sort((a, b) => selectedSortDirection.value == 'Newest to Oldest'
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date));
    } else if (selectedSortOption.value == 'Interaction Date') {
      result.sort((a, b) => selectedSortDirection.value == 'Newest to Oldest'
          ? a.rank.compareTo(b.rank)
          : b.rank.compareTo(a.rank));
    } else if (selectedSortOption.value == 'Uncontacted Leads') {
      result.sort((a, b) => a.status.toLowerCase().contains('to-do') ? -1 : 1);
    } else if (selectedSortOption.value == 'Missed Tasks') {
      result.sort((a, b) => a.status.toLowerCase().contains('missed') ? -1 : 1);
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
