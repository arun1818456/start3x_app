import 'package:start3x_app/exports.dart';

class TeamController extends GetxController with BaseClass {
  var isLoading = false.obs;
  final RxList<UserDataModel> teamMembers = <UserDataModel>[].obs;
  final RxList<UserDataModel> filteredMembers = <UserDataModel>[].obs;
  final searchController = TextEditingController();
  final RxString passkey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    passkey.value = resolvePasskey();
    fetchTeamMembers();
  }

  String resolvePasskey() {
    String passkeyVal = '';
    if (Get.arguments != null) {
      if (Get.arguments is Map && Get.arguments['passkey'] != null) {
        passkeyVal = Get.arguments['passkey'].toString();
      } else if (Get.arguments is ClientModel) {
        passkeyVal = (Get.arguments as ClientModel).passkey;
      } else if (Get.arguments is AccessClientModel) {
        passkeyVal = (Get.arguments as AccessClientModel).id;
      } else if (Get.arguments is String) {
        passkeyVal = Get.arguments as String;
      }
    }

    if (passkeyVal.isEmpty && Get.isRegistered<HomeController>()) {
      final homePasskey = Get.find<HomeController>().clientPasskey;
      if (homePasskey.isNotEmpty) passkeyVal = homePasskey;
    }

    if (passkeyVal.isEmpty) {
      passkeyVal = storage.read('clientPasskey')?.toString() ?? '';
    }

    if (passkeyVal.isEmpty) {
      final userData = getUserData();
      passkeyVal = userData.passkey ??
          storage.read(LocalKeys.userData)?['passkey']?.toString() ??
          '';
    }

    return passkeyVal;
  }

  Future<void> fetchTeamMembers() async {
    if (passkey.value.isEmpty) {
      passkey.value = resolvePasskey();
    }

    if (passkey.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMySnackBar('Passkey not found', alert: true);
      });
      return;
    }

    try {
      isLoading.value = true;
      var res = await httpRequest(
        REQUEST.get,
        "$getPasskeyUsersApiEndPoint${passkey.value}",
        {},
      );
      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        final list =
            dataList.map((item) => UserDataModel.fromJson(item)).toList();
        teamMembers.value = list;
        filterMembers(searchController.text);
      } else {
        teamMembers.clear();
        filteredMembers.clear();
      }
    } catch (e) {
      debugPrint("Error fetching team members: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMySnackBar("Failed to load team members", error: true);
      });
    } finally {
      isLoading.value = false;
    }
  }

  void filterMembers(String query) {
    if (query.trim().isEmpty) {
      filteredMembers.value = List.from(teamMembers);
    } else {
      final q = query.toLowerCase().trim();
      filteredMembers.value = teamMembers.where((user) {
        final nameMatches = (user.name ?? '').toLowerCase().contains(q);
        final emailMatches = (user.email ?? '').toLowerCase().contains(q);
        final roleMatches = (user.role ?? '').toLowerCase().contains(q);
        return nameMatches || emailMatches || roleMatches;
      }).toList();
    }
  }

  String formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      return '$day/$month/$year';
    } catch (_) {
      return raw;
    }
  }

  // --- Member Progress Dialog Support ---
  final Rx<UserDataModel?> selectedMember = Rx<UserDataModel?>(null);
  final RxString progressFilter = 'Today'.obs; // Default 'Today'
  final RxBool isProgressLoading = false.obs;
  DateTime? customStartDate;
  DateTime? customEndDate;

  // Progress metrics
  final RxInt totalCalls = 0.obs;
  final RxInt meetingsDone = 0.obs;
  final RxInt meetingsMissed = 0.obs;
  final RxInt callbackDone = 0.obs;
  final RxInt callbackMissed = 0.obs;
  final RxInt conversions = 0.obs;
  final RxDouble conversionRate = 0.0.obs;

  String _formatApiDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _buildDateQuery() {
    if (progressFilter.value == 'All Time') return "";

    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (progressFilter.value == 'Today') {
      start = now;
      end = now;
    } else if (progressFilter.value == 'Yesterday') {
      final y = now.subtract(const Duration(days: 1));
      start = y;
      end = y;
    } else if (progressFilter.value == 'Last 7 Days') {
      start = now.subtract(const Duration(days: 6));
      end = now;
    } else if (progressFilter.value == 'Last Month') {
      start = DateTime(now.year, now.month - 1, 1);
      end = DateTime(now.year, now.month, 0);
    } else if (customStartDate != null && customEndDate != null) {
      start = customStartDate;
      end = customEndDate;
    }

    if (start != null && end != null) {
      return "&startDate=${_formatApiDate(start)}&endDate=${_formatApiDate(end)}";
    }
    return "";
  }

  bool _isDateInRange(DateTime dt) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    if (progressFilter.value == 'Today') {
      return dt.isAfter(todayStart.subtract(const Duration(milliseconds: 1))) &&
          dt.isBefore(todayEnd.add(const Duration(milliseconds: 1)));
    } else if (progressFilter.value == 'Yesterday') {
      final yStart = todayStart.subtract(const Duration(days: 1));
      final yEnd = DateTime(yStart.year, yStart.month, yStart.day, 23, 59, 59, 999);
      return dt.isAfter(yStart.subtract(const Duration(milliseconds: 1))) &&
          dt.isBefore(yEnd.add(const Duration(milliseconds: 1)));
    } else if (progressFilter.value == 'Last 7 Days') {
      final sevenDaysAgo = todayStart.subtract(const Duration(days: 6));
      return dt.isAfter(sevenDaysAgo.subtract(const Duration(milliseconds: 1))) &&
          dt.isBefore(todayEnd.add(const Duration(milliseconds: 1)));
    } else if (progressFilter.value == 'Last Month') {
      final start = DateTime(now.year, now.month - 1, 1);
      final end = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
      return dt.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
          dt.isBefore(end.add(const Duration(milliseconds: 1)));
    } else if (customStartDate != null && customEndDate != null) {
      final start = DateTime(customStartDate!.year, customStartDate!.month, customStartDate!.day);
      final end = DateTime(customEndDate!.year, customEndDate!.month, customEndDate!.day, 23, 59, 59, 999);
      return dt.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
          dt.isBefore(end.add(const Duration(milliseconds: 1)));
    }
    return true; // All Time
  }

  DateTime? _parseResponseDateTime(LeadResponseModel resp) {
    if (resp.rawCreatedAt != null && resp.rawCreatedAt!.isNotEmpty) {
      final parsed = DateTime.tryParse(resp.rawCreatedAt!);
      if (parsed != null) return parsed.toLocal();
    }
    // Try parsing formatted createdAt 'dd/MM/yyyy HH:mm a'
    if (resp.createdAt.isNotEmpty) {
      try {
        final parts = resp.createdAt.split(' ');
        if (parts.isNotEmpty) {
          final dateParts = parts[0].split('/');
          if (dateParts.length == 3) {
            final day = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final year = int.parse(dateParts[2]);
            return DateTime(year, month, day);
          }
        }
      } catch (_) {}
      final direct = DateTime.tryParse(resp.createdAt);
      if (direct != null) return direct.toLocal();
    }
    return null;
  }

  Future<void> fetchMemberProgress(UserDataModel member) async {
    selectedMember.value = member;
    isProgressLoading.value = true;

    try {
      final passkeyVal = passkey.value.isNotEmpty ? passkey.value : resolvePasskey();
      final dateQuery = _buildDateQuery();
      final String memberId = member.id ?? '';
      final String memberName = (member.name ?? '').trim();

      String query = "passkey=$passkeyVal$dateQuery";

      var res = await httpRequest(
        REQUEST.get,
        "$getResponsesApiEndPoint?$query",
        {},
      );

      List<LeadResponseModel> allResponses = [];
      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        allResponses = dataList
            .map((item) => LeadResponseModel.fromJson(item))
            .toList();
      }

      // Filter specifically for this member
      final memberResponses = allResponses.where((resp) {
        // 1. Match by userId if available
        if (memberId.isNotEmpty && resp.userId != null && resp.userId!.isNotEmpty) {
          return resp.userId == memberId;
        }
        // 2. Match by userName (case-insensitive)
        if (memberName.isNotEmpty && resp.userName != null && resp.userName!.isNotEmpty) {
          return resp.userName!.toLowerCase().trim() == memberName.toLowerCase();
        }
        return false;
      }).toList();

      // Filter by date range on client-side as well for accuracy
      final filteredResponses = memberResponses.where((resp) {
        if (progressFilter.value == 'All Time') return true;
        final dt = _parseResponseDateTime(resp);
        if (dt != null) {
          return _isDateInRange(dt);
        }
        return true;
      }).toList();

      _computeProgressMetrics(filteredResponses);
    } catch (e) {
      debugPrint("Error fetching member progress: $e");
      _computeProgressMetrics([]);
    } finally {
      isProgressLoading.value = false;
    }
  }

  void _computeProgressMetrics(List<LeadResponseModel> responses) {
    totalCalls.value = responses.length;

    // Track latest response per lead for this member
    final Map<String, LeadResponseModel> latestPerLead = {};
    for (var resp in responses) {
      final leadKey = resp.leadId.isNotEmpty ? resp.leadId : resp.id;
      if (leadKey.isNotEmpty && !latestPerLead.containsKey(leadKey)) {
        latestPerLead[leadKey] = resp;
      }
    }

    int mDone = 0;
    int mMissed = 0;
    int cDone = 0;
    int cMissed = 0;
    int conv = 0;

    // Count metrics
    for (var resp in responses) {
      final outcome = resp.outcome.toLowerCase();

      if (resp.isDone) {
        if (outcome.contains('deal') || outcome.contains('conversion')) {
          conv++;
        } else if (outcome.contains('meeting')) {
          mDone++;
        } else if (outcome.contains('callback')) {
          cDone++;
        } else {
          // general done task / conversion
          conv++;
        }
      } else if (resp.isMissed) {
        if (outcome.contains('meeting')) {
          mMissed++;
        } else if (outcome.contains('callback')) {
          cMissed++;
        } else {
          cMissed++;
        }
      }
    }

    meetingsDone.value = mDone;
    meetingsMissed.value = mMissed;
    callbackDone.value = cDone;
    callbackMissed.value = cMissed;
    conversions.value = conv;

    // Conversion rate calculation: (conversions / totalCalls) * 100
    if (totalCalls.value > 0) {
      conversionRate.value = (conv / totalCalls.value) * 100.0;
    } else {
      conversionRate.value = 0.0;
    }
  }

  void updateProgressFilter(String filter, BuildContext context) {
    if (filter == 'Custom') {
      pickCustomProgressDate(context);
    } else {
      customStartDate = null;
      customEndDate = null;
      progressFilter.value = filter;
      if (selectedMember.value != null) {
        fetchMemberProgress(selectedMember.value!);
      }
    }
  }

  Future<void> pickCustomProgressDate(BuildContext context) async {
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
      final String formatted =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      progressFilter.value = formatted;
      if (selectedMember.value != null) {
        fetchMemberProgress(selectedMember.value!);
      }
    }
  }

  void openMemberProgressDialog(BuildContext context, UserDataModel member) {
    progressFilter.value = 'Today';
    customStartDate = null;
    customEndDate = null;
    fetchMemberProgress(member);
    _showProgressDialog(context, member);
  }

  void _showProgressDialog(BuildContext context, UserDataModel member) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _MemberProgressDialog(
        member: member,
        controller: this,
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class _MemberProgressDialog extends StatelessWidget {
  final UserDataModel member;
  final TeamController controller;

  const _MemberProgressDialog({
    required this.member,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName =
        (member.name != null && member.name!.trim().isNotEmpty)
            ? member.name!.trim()
            : 'Team Member';
    final String initial = displayName[0].toUpperCase();

    final filterOptions = [
      'Today',
      'Yesterday',
      'Last 7 Days',
      'Last Month',
      'All Time',
      'Custom',
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row (Avatar, Name, Role, Close Button)
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        AppColors.primaryBlue.withValues(alpha: 0.12),
                    backgroundImage: (member.profileUrl != null &&
                            member.profileUrl!.isNotEmpty)
                        ? NetworkImage(member.profileUrl!)
                        : null,
                    child: (member.profileUrl == null ||
                            member.profileUrl!.isEmpty)
                        ? Text(
                            initial,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.email ?? (member.role?.toUpperCase() ?? 'MEMBER'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.getUserData().role == 'admin' &&
                      member.id != null &&
                      member.id!.isNotEmpty) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primaryBlue,
                        size: 21,
                      ),
                      tooltip: 'View Notifications',
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.notificationsScreen,
                          arguments: {
                            'userId': member.id,
                            'userName': displayName,
                          },
                        );
                      },
                      padding: const EdgeInsets.only(right: 8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textGrey),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Colors.black12),
              const SizedBox(height: 12),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  final activeFilter = controller.progressFilter.value;
                  return Row(
                    children: filterOptions.map((filter) {
                      final bool isSelected = activeFilter == filter ||
                          (filter == 'Custom' &&
                              !['Today', 'Yesterday', 'Last 7 Days', 'Last Month', 'All Time']
                                  .contains(activeFilter));

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () =>
                              controller.updateProgressFilter(filter, context),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (filter == 'Custom' &&
                                    !['Today', 'Yesterday', 'Last 7 Days', 'Last Month', 'All Time']
                                        .contains(activeFilter)) ...[
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  filter == 'Custom' &&
                                          !['Today', 'Yesterday', 'Last 7 Days', 'Last Month', 'All Time']
                                              .contains(activeFilter)
                                      ? activeFilter
                                      : filter,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Content / Progress Stats
              Flexible(
                child: Obx(() {
                  if (controller.isProgressLoading.value) {
                    return const SizedBox(
                      height: 220,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                                color: AppColors.primaryBlue),
                            SizedBox(height: 12),
                            Text(
                              'Loading progress...',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final total = controller.totalCalls.value;
                  final mDone = controller.meetingsDone.value;
                  final mMissed = controller.meetingsMissed.value;
                  final cDone = controller.callbackDone.value;
                  final cMissed = controller.callbackMissed.value;
                  final conv = controller.conversions.value;
                  final rate = controller.conversionRate.value;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Conversion Rate Banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.primaryBlue.withValues(alpha: 0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.trending_up_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Conversion Rate',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${rate.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Total Calls',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    total.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Metrics Grid
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Meetings Done',
                                value: mDone.toString().padLeft(2, '0'),
                                icon: Icons.calendar_month_rounded,
                                color: Colors.green.shade600,
                                bgColor: Colors.green.shade50,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricCard(
                                title: 'Meetings Missed',
                                value: mMissed.toString().padLeft(2, '0'),
                                icon: Icons.event_busy_rounded,
                                color: Colors.red.shade600,
                                bgColor: Colors.red.shade50,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Callback Done',
                                value: cDone.toString().padLeft(2, '0'),
                                icon: Icons.phone_callback_rounded,
                                color: Colors.blue.shade600,
                                bgColor: Colors.blue.shade50,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricCard(
                                title: 'Callback Missed',
                                value: cMissed.toString().padLeft(2, '0'),
                                icon: Icons.phone_missed_rounded,
                                color: Colors.orange.shade700,
                                bgColor: Colors.orange.shade50,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Deals / Conversions',
                                value: conv.toString().padLeft(2, '0'),
                                icon: Icons.check_circle_rounded,
                                color: Colors.teal.shade700,
                                bgColor: Colors.teal.shade50,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricCard(
                                title: 'Total Calls Logged',
                                value: total.toString().padLeft(2, '0'),
                                icon: Icons.phone_in_talk_rounded,
                                color: Colors.indigo.shade600,
                                bgColor: Colors.indigo.shade50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
