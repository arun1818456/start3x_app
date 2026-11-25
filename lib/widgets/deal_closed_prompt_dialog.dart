import 'package:start3x_app/exports.dart';

class DealClosedPromptHelper {
  static bool _isPromptShowing = false;

  /// Check if there are 4 unique completed meeting clients unprompted, and trigger the deal closed prompt.
  static Future<void> checkAndPromptDealClosed() async {
    if (_isPromptShowing) return;

    try {
      final storage = GetStorage();
      String passkey = '';
      if (Get.isRegistered<HomeController>()) {
        passkey = Get.find<HomeController>().clientPasskey;
      }
      if (passkey.isEmpty) {
        passkey = storage.read('clientPasskey')?.toString() ?? '';
      }
      if (passkey.isEmpty && storage.hasData(LocalKeys.userData)) {
        final uData = storage.read(LocalKeys.userData);
        passkey = uData?['passkey']?.toString() ?? '';
      }
      if (passkey.isEmpty) return;

      // 1. Fetch leads
      List<LeadModel> allLeads = [];
      if (Get.isRegistered<HomeController>() &&
          Get.find<HomeController>().leads.isNotEmpty) {
        allLeads = Get.find<HomeController>().leads.toList();
      } else {
        var leadRes = await _makeHttpRequest(
          REQUEST.get,
          "$getLeadsApiEndPoint?passkey=$passkey",
          {},
        );
        if (leadRes != null &&
            leadRes["success"] == true &&
            leadRes["data"] != null) {
          List dataList = leadRes["data"];
          allLeads = dataList.map((item) => LeadModel.fromJson(item)).toList();
        }
      }

      if (allLeads.isEmpty) return;

      // 2. Fetch responses to find completed meetings
      var respRes = await _makeHttpRequest(
        REQUEST.get,
        "$getResponsesApiEndPoint?passkey=$passkey",
        {},
      );

      List<LeadResponseModel> allResponses = [];
      if (respRes != null &&
          respRes["success"] == true &&
          respRes["data"] != null) {
        List dataList = respRes["data"];
        allResponses =
            dataList.map((item) => LeadResponseModel.fromJson(item)).toList();
      }

      // 3. Find unique clients whose meeting is Done
      final Set<String> meetingDoneLeadIds = {};
      for (final resp in allResponses) {
        if (resp.leadId.isNotEmpty &&
            resp.isDone &&
            resp.outcome.toLowerCase().contains('meeting')) {
          meetingDoneLeadIds.add(resp.leadId);
        }
      }

      for (final lead in allLeads) {
        if (lead.id.isNotEmpty) {
          final isDoneStatus =
              lead.isCompleted || lead.status.toLowerCase().startsWith('done');
          final isMeeting =
              lead.scheduledDate.toLowerCase().contains('meeting') ||
                  lead.status.toLowerCase().contains('meeting');
          if (isDoneStatus && isMeeting) {
            meetingDoneLeadIds.add(lead.id);
          }
        }
      }

      if (meetingDoneLeadIds.length < 4) return;

      // 4. Filter out leads that have already been prompted
      final List promptedIds = (storage
              .read('prompted_meetings_deal_closed_ids_$passkey') as List?) ??
          [];
      final Set<String> promptedSet =
          promptedIds.map((e) => e.toString()).toSet();

      final List<LeadModel> unpromptedLeads = [];
      for (final leadId in meetingDoneLeadIds) {
        if (!promptedSet.contains(leadId)) {
          final foundLead = allLeads.firstWhereOrNull((l) => l.id == leadId);
          if (foundLead != null) {
            unpromptedLeads.add(foundLead);
          }
        }
      }

      if (unpromptedLeads.length < 4) return;

      // Take the first 4 unique clients
      final batchOf4 = unpromptedLeads.take(4).toList();

      _isPromptShowing = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showQuestionDialog(batchOf4, passkey);
      });
    } catch (e) {
      _isPromptShowing = false;
      debugPrint("Error checking deal closed: $e");
    }
  }

  /// Step 1: Question Widget - "Is there any deal closed with the client?" Options: Yes / No
  static void _showQuestionDialog(List<LeadModel> batchOf4, String passkey) {
    final context = Get.context;
    if (context == null) {
      _isPromptShowing = false;
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Deal Closed Check',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(ctx).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge: 4 Meetings Done
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.primaryBlue, size: 16),
                          SizedBox(width: 6),
                          Text(
                            '4 Meetings Completed',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Handshake Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF86EFAC), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.handshake_rounded,
                        color: Color(0xFF16A34A),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Question Text
                    const Text(
                      'Is there any deal closed with the client?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'You have completed meetings with ${batchOf4.length} unique clients.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options: NO / YES
                    Row(
                      children: [
                        // NO Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _onNoSelected(batchOf4, passkey);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'NO',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // YES Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _showClientSelectionSheet(batchOf4, passkey);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'YES',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// When NO is selected: No conversion is recorded. Mark batch as prompted.
  static void _onNoSelected(List<LeadModel> batchOf4, String passkey) {
    final storage = GetStorage();
    final List promptedIds = (storage
            .read('prompted_meetings_deal_closed_ids_$passkey') as List?) ??
        [];
    final Set<String> promptedSet =
        promptedIds.map((e) => e.toString()).toSet();
    promptedSet.addAll(batchOf4.map((l) => l.id));
    storage.write(
        'prompted_meetings_deal_closed_ids_$passkey', promptedSet.toList());

    _isPromptShowing = false;

    // Check if another batch of 4 is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      checkAndPromptDealClosed();
    });
  }

  /// Step 2: Client Selection Widget - Show list of the 4 clients and select who closed deals
  static void _showClientSelectionSheet(
      List<LeadModel> batchOf4, String passkey) {
    final context = Get.context;
    if (context == null) {
      _isPromptShowing = false;
      return;
    }

    final selectedLeadIds = <String>{}.obs;
    final isSaving = false.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 14,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.stars_rounded,
                            color: Color(0xFFF59E0B), size: 26),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Select Closed Deals',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final allSelected =
                        selectedLeadIds.length == batchOf4.length;
                    return TextButton(
                      onPressed: () {
                        if (allSelected) {
                          selectedLeadIds.clear();
                        } else {
                          selectedLeadIds
                              .addAll(batchOf4.map((lead) => lead.id));
                        }
                      },
                      child: Text(
                        allSelected ? 'Deselect All' : 'Select All',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 2),

              const Text(
                'Select the client(s) with whom deals have been closed. Each selected client will be added as 1 conversion in Insights.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textGrey,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Clients List (4 Clients)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetCtx).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: batchOf4.length,
                  separatorBuilder: (ctx, index) => const SizedBox(height: 10),
                  itemBuilder: (ctx, index) {
                    final client = batchOf4[index];
                    return Obx(() {
                      final isSelected = selectedLeadIds.contains(client.id);
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            selectedLeadIds.remove(client.id);
                          } else {
                            selectedLeadIds.add(client.id);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : Colors.grey.shade300,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Checkbox
                              Icon(
                                isSelected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade400,
                                size: 22,
                              ),
                              const SizedBox(width: 12),

                              // Rank Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  client.rank,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Client Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      client.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    if (client.location.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 13,
                                              color: AppColors.textGrey),
                                          const SizedBox(width: 3),
                                          Flexible(
                                            child: Text(
                                              client.location,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textGrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Deal Closed badge when selected
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Deal Closed',
                                    style: TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Actions: Skip / None vs Confirm
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        _onNoSelected(batchOf4, passkey);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'None / Skip',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: isSaving.value
                            ? null
                            : () async {
                                final selectedIds = selectedLeadIds.toList();
                                if (selectedIds.isEmpty) {
                                  // No client selected -> Treat as No
                                  Navigator.of(sheetCtx).pop();
                                  _onNoSelected(batchOf4, passkey);
                                  return;
                                }

                                try {
                                  isSaving.value = true;
                                  await _recordConversions(
                                      selectedIds, batchOf4, passkey);
                                  if (sheetCtx.mounted) {
                                    Navigator.of(sheetCtx).pop();
                                  }
                                } finally {
                                  isSaving.value = false;
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSaving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Obx(() {
                                final count = selectedLeadIds.length;
                                return Text(
                                  count > 0
                                      ? 'Confirm Deals ($count)'
                                      : 'Confirm (None)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Record each selected client as 1 conversion in DB and update Insights
  static Future<void> _recordConversions(List<String> selectedIds,
      List<LeadModel> batchOf4, String passkey) async {
    final storage = GetStorage();
    final callerName = _resolveCallerName(storage);
    final formattedDate = _getFormattedCurrentDateTime();
    final uData = storage.read(LocalKeys.userData);
    final currentUserId = uData?['_id']?.toString() ?? uData?['id']?.toString() ?? '';

    int successCount = 0;

    for (final id in selectedIds) {
      try {
        final client = batchOf4.firstWhereOrNull((l) => l.id == id);
        if (client == null) continue;

        // 1. Post a new response marking Deal Closed
        await _makeHttpRequest(
          REQUEST.post,
          createResponseApiEndPoint,
          {
            "passkey": passkey,
            "leadId": client.id,
            "outcome": "Deal Closed",
            "text": "Deal closed with client.",
            "callDate": formattedDate,
            "isDone": true,
            "isMissed": false,
            "userId": currentUserId,
            "userName": callerName,
            "callerName": callerName,
          },
        );

        // 2. Update lead status in DB
        await _makeHttpRequest(
          REQUEST.put,
          "$updateLeadApiEndPoint${client.id}",
          {
            "status": "Deal Closed",
            "isCompleted": true,
          },
        );

        // 3. Update in HomeController if registered
        if (Get.isRegistered<HomeController>()) {
          final home = Get.find<HomeController>();
          final idx = home.leads.indexWhere((l) => l.id == client.id);
          if (idx != -1) {
            home.leads[idx] = client.copyWith(
              status: "Deal Closed",
              isCompleted: true,
            );
            home.leads.refresh();
          }
        }

        successCount++;
      } catch (e) {
        debugPrint("Error recording conversion for lead $id: $e");
      }
    }

    // Mark all 4 leads of this batch as prompted
    final List promptedIds = (storage
            .read('prompted_meetings_deal_closed_ids_$passkey') as List?) ??
        [];
    final Set<String> promptedSet =
        promptedIds.map((e) => e.toString()).toSet();
    promptedSet.addAll(batchOf4.map((l) => l.id));
    storage.write(
        'prompted_meetings_deal_closed_ids_$passkey', promptedSet.toList());

    _isPromptShowing = false;

    // Refresh Insights if active
    if (Get.isRegistered<InsightsController>()) {
      Get.find<InsightsController>().fetchInsightsFromApi();
    }

    Get.showSnackbar(
      GetSnackBar(
        message:
            '$successCount client(s) deal closed & added to Insights → Conversions!',
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF16A34A),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      ),
    );

    // Check if another batch of 4 is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      checkAndPromptDealClosed();
    });
  }

  static String _resolveCallerName(GetStorage storage) {
    if (storage.hasData(LocalKeys.userData)) {
      final uData = storage.read(LocalKeys.userData);
      final role = uData?['role']?.toString();
      final name = uData?['name']?.toString().trim();
      if (role == 'admin') return 'Admin';
      if (name != null && name.isNotEmpty) return name;
    }
    return 'User';
  }

  static String _getFormattedCurrentDateTime() {
    final now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String year = now.year.toString();
    final String hour = (now.hour % 12 == 0 ? 12 : now.hour % 12)
        .toString()
        .padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    final String period = now.hour >= 12 ? 'PM' : 'AM';
    return '$day/$month/$year $hour:$minute $period';
  }

  static Future<dynamic> _makeHttpRequest(
      REQUEST requestType, String url, Map<String, dynamic> body) async {
    final storage = GetStorage();
    final uData = storage.read(LocalKeys.userData);
    final jwt = uData?['token']?.toString() ?? '';
    return await httpRequest(requestType, url, body, token: jwt);
  }
}
