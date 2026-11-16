import 'package:start3x_app/exports.dart';
import 'package:url_launcher/url_launcher.dart';

class CallingController extends GetxController with BaseClass {
  final Rx<LeadModel> _lead = LeadModel(
    rank: '',
    name: '',
    location: '',
    status: '',
    scheduledDate: '',
  ).obs;

  LeadModel get lead => _lead.value;
  set lead(LeadModel value) => _lead.value = value;

  final responses = <LeadResponseModel>[].obs;
  var isLoadingResponses = false.obs;
  var showDetails = false.obs;
  var isPastDueAlertActive = false.obs;
  String pastDueDateStr = '';

  final List<String> outcomes = [
    'Got a callback',
    'Got a meeting',
    "Didn't pick up",
    'He picked up, but no result',
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        final args = Get.arguments as Map;
        lead = args['lead'] as LeadModel? ??
            LeadModel(rank: '', name: '', location: '', status: '', scheduledDate: '');
        if (args['isPastDue'] == true) {
          isPastDueAlertActive.value = true;
          pastDueDateStr = (args['pastDueDate']?.toString() ?? lead.scheduledDate);
        }
      } else if (Get.arguments is LeadModel) {
        lead = Get.arguments as LeadModel;
      }
      fetchResponsesFromApi();
    } else {
      lead = LeadModel(
        rank: '',
        name: '',
        location: '',
        status: '',
        scheduledDate: '',
      );
    }
  }

  Future<void> fetchResponsesFromApi() async {
    if (lead.phoneNumber.isEmpty && lead.passkey.isEmpty && lead.id.isEmpty) return;

    try {
      isLoadingResponses.value = true;
      String query = '';
      if (lead.passkey.isNotEmpty && lead.phoneNumber.isNotEmpty) {
        query = "passkey=${lead.passkey}&phoneNumber=${Uri.encodeComponent(lead.phoneNumber)}";
      } else if (lead.phoneNumber.isNotEmpty) {
        query = "phoneNumber=${Uri.encodeComponent(lead.phoneNumber)}";
      } else if (lead.id.isNotEmpty) {
        query = "leadId=${lead.id}";
      } else if (lead.passkey.isNotEmpty) {
        query = "passkey=${lead.passkey}";
      }

      var res = await httpRequest(
        REQUEST.get,
        "$getResponsesApiEndPoint?$query",
        {},
      );

      if (res != null && res["success"] == true && res["data"] != null) {
        List dataList = res["data"];
        if (dataList.isNotEmpty) {
          final fetched = dataList
              .map((item) => LeadResponseModel.fromJson(item))
              .toList();
          responses.value = fetched;
        }
      }
    } catch (e) {
      // Keep existing responses on error
    } finally {
      isLoadingResponses.value = false;
    }
  }

  Future<void> deleteResponseFromBackend(String responseId, int index) async {
    if (responseId.isNotEmpty) {
      try {
        await httpRequest(
          REQUEST.delete,
          "$deleteResponseApiEndPoint$responseId",
          {},
        );
      } catch (e) {
        // Fallback
      }
    }
  }

  Future<void> updateResponseInBackend(
      String responseId, LeadResponseModel resp) async {
    if (responseId.isNotEmpty) {
      try {
        await httpRequest(
          REQUEST.put,
          "$updateResponseApiEndPoint$responseId",
          resp.toJson(),
        );
      } catch (e) {
        // Fallback
      }
    }
  }

  Future<void> makePhoneCall([String? number]) async {
    final phone = (number != null && number.isNotEmpty) ? number : lead.phoneNumber;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      showMySnackBar('Could not launch dialer for $cleanPhone', error: true);
    }

    Get.toNamed(AppRoutes.callResponseScreen, arguments: lead);
  }

  Future<void> openWhatsApp([String? number]) async {
    final phone = (number != null && number.isNotEmpty) ? number : lead.phoneNumber;
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      showMySnackBar('Could not open WhatsApp for $cleanPhone', error: true);
    }
  }

  Future<void> makeAltCall() async {
    await makePhoneCall(lead.altPhoneNumber);
  }

  void showEditResponseBottomSheet(int index, LeadResponseModel resp) {
    final textController = TextEditingController(text: resp.text);
    final selectedOutcome = (resp.outcome).obs;
    final selectedDateTime = (resp.scheduledDate ?? resp.callback ?? '').obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
        decoration: const BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit ${resp.responseNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Outcome Title
              const Text(
                'Outcome',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Outcome Selector
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: outcomes.contains(selectedOutcome.value)
                            ? selectedOutcome.value
                            : outcomes.first,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: outcomes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textDark,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            selectedOutcome.value = newValue;
                          }
                        },
                      ),
                    ),
                  )),

              const SizedBox(height: 16),

              // Date & Time Picker for Callback / Meeting
              Obx(() {
                if (selectedOutcome.value == 'Got a callback' ||
                    selectedOutcome.value == 'Got a meeting') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedOutcome.value} Date & Time',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final context = Get.context;
                          if (context == null) return;

                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF007AFF),
                                    surface: Colors.white,
                                    surfaceTint: Colors.transparent,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate == null) return;

                          if (!context.mounted) return;

                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF007AFF),
                                    surface: Colors.white,
                                    surfaceTint: Colors.transparent,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedTime == null) return;

                          final DateTime combined = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          final String hour =
                              (pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod)
                                  .toString();
                          final String minute =
                              pickedTime.minute.toString().padLeft(2, '0');
                          final String period =
                              pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
                          final String month = combined.month.toString().padLeft(2, '0');
                          final String day = combined.day.toString().padLeft(2, '0');
                          final String year = combined.year.toString();

                          selectedDateTime.value =
                              '$day/$month/$year $hour:$minute $period';
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_available_rounded,
                                color: AppColors.primaryBlue,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedDateTime.value.isNotEmpty
                                      ? selectedDateTime.value
                                      : 'Tap to select Date & Time',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.edit_calendar_rounded,
                                color: AppColors.primaryBlue,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // Response Text / Note
              const Text(
                'Response Text / Note',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: textController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter response text...',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save & Delete Row
              Row(
                children: [
                  // Delete Button
                  IconButton(
                    onPressed: () {
                      final targetId = resp.id;
                      if (index < responses.length) {
                        responses.removeAt(index);
                      }
                      deleteResponseFromBackend(targetId, index);
                      Get.back();
                      showMySnackBar('Response removed', alert: true);
                    },
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red, size: 28),
                    tooltip: 'Delete Response',
                  ),
                  const SizedBox(width: 12),

                  // Save Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final updatedText = textController.text.trim();
                        final dt = selectedDateTime.value;

                        final updatedResponse = LeadResponseModel(
                          id: resp.id,
                          responseNumber: resp.responseNumber,
                          outcome: selectedOutcome.value,
                          scheduledDate:
                              selectedOutcome.value == 'Got a meeting' ? dt : null,
                          callback:
                              selectedOutcome.value == 'Got a callback' ? dt : null,
                          text: updatedText.isEmpty ? 'No response text' : updatedText,
                          createdAt: resp.createdAt,
                          userName: resp.userName,
                        );

                        if (index < responses.length) {
                          responses[index] = updatedResponse;
                        }
                        updateResponseInBackend(resp.id, updatedResponse);
                        Get.back();

                        showMySnackBar('Response updated successfully', success: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }



  Future<void> onYesTap() async {
    final userData = getUserData();
    String passkeyVal = lead.passkey;
    if (passkeyVal.isEmpty) {
      passkeyVal = userData.passkey ??
          storage.read(LocalKeys.userData)?['passkey'] ??
          '';
    }

    final callerName = (userData.name != null && userData.name!.trim().isNotEmpty)
        ? userData.name!.trim()
        : (userData.role == 'admin' ? 'Admin' : 'User');

    final formattedCallDate = getFormattedCurrentDateTime();

    final String outcomeVal =
        responses.isNotEmpty && responses.first.outcome.isNotEmpty
            ? responses.first.outcome
            : ((lead.status.toLowerCase().contains('meeting') ||
                    lead.scheduledDate.toLowerCase().contains('meeting'))
                ? 'Meeting Completed'
                : 'Task Completed');

    try {
      showCircularLoader();

      var responseRes = await httpRequest(
        REQUEST.post,
        createResponseApiEndPoint,
        {
          "passkey": passkeyVal,
          "leadId": lead.id,
          "outcome": outcomeVal,
          "text": 'This task has been completed.',
          "callDate": formattedCallDate,
          "scheduledDate": lead.scheduledDate,
          "isDone": true,
          "isMissed": false,
          "userName": callerName,
          "callerName": callerName,
        },
      );

      hideCircularLoader();

      if (responseRes != null &&
          responseRes["success"] == true &&
          responseRes["data"] != null) {
        final createdResponse =
            LeadResponseModel.fromJson(responseRes["data"]);
        responses.insert(0, createdResponse);
        isPastDueAlertActive.value = false;
      }

      if (Get.isRegistered<InsightsController>()) {
        Get.find<InsightsController>().fetchInsightsFromApi();
      }

      DealClosedPromptHelper.checkAndPromptDealClosed();
    } catch (e) {
      hideCircularLoader();
    }
  }

  Future<void> onNoTap() async {
    final userData = getUserData();
    String passkeyVal = lead.passkey;
    if (passkeyVal.isEmpty) {
      passkeyVal = userData.passkey ??
          storage.read(LocalKeys.userData)?['passkey'] ??
          '';
    }

    final callerName = (userData.name != null && userData.name!.trim().isNotEmpty)
        ? userData.name!.trim()
        : (userData.role == 'admin' ? 'Admin' : 'User');

    final formattedCallDate = getFormattedCurrentDateTime();

    final String outcomeVal =
        responses.isNotEmpty && responses.first.outcome.isNotEmpty
            ? responses.first.outcome
            : 'Task Missed';

    try {
      showCircularLoader();

      var responseRes = await httpRequest(
        REQUEST.post,
        createResponseApiEndPoint,
        {
          "passkey": passkeyVal,
          "leadId": lead.id,
          "outcome": outcomeVal,
          "scheduledDate": lead.scheduledDate,
          "text": 'This task has been Missed.',
          "callDate": formattedCallDate,
          "isMissed": true,
          "isDone": false,
          "userName": callerName,
          "callerName": callerName,
        },
      );

      hideCircularLoader();

      if (responseRes != null &&
          responseRes["success"] == true &&
          responseRes["data"] != null) {
        final createdResponse =
            LeadResponseModel.fromJson(responseRes["data"]);
        responses.insert(0, createdResponse);
        isPastDueAlertActive.value = false;
      }

      if (Get.isRegistered<InsightsController>()) {
        Get.find<InsightsController>().fetchInsightsFromApi();
      }
    } catch (e) {
      hideCircularLoader();
    }
  }

  /// Share lead directly into group chat with this lead flagged
  void shareLeadToChat() {
    Get.toNamed(
      AppRoutes.groupScreen,
      arguments: {
        'showBackButton': true,
        'initialFlaggedLead': lead,
        'passkey': lead.passkey,
      },
    );
  }

  /// Open edit lead dialog to modify lead details and update DB
  void openEditLeadDialog(BuildContext context) {
    final nameController = TextEditingController(text: lead.name);
    final phoneController = TextEditingController(text: lead.phoneNumber);
    final altPhoneController = TextEditingController(text: lead.altPhoneNumber);
    final locationController = TextEditingController(text: lead.location);
    final kwController = TextEditingController(text: lead.kw);
    final billController = TextEditingController(text: lead.electricityBill);
    final isSaving = false.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 12,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
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
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.primaryBlue,
                          size: 26,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Edit Lead Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Update lead contact and system information for ${lead.rank}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 16),

                // Form Fields
                _buildEditTextField(
                  label: 'Lead Name *',
                  controller: nameController,
                  icon: Icons.person_outline_rounded,
                  hint: 'Enter client name',
                ),
                const SizedBox(height: 14),

                _buildEditTextField(
                  label: 'Phone Number',
                  controller: phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  hint: 'Enter phone number',
                ),
                const SizedBox(height: 14),

                _buildEditTextField(
                  label: 'Alternate Phone Number',
                  controller: altPhoneController,
                  icon: Icons.phone_forwarded_outlined,
                  keyboardType: TextInputType.phone,
                  hint: 'Enter alternate phone number',
                ),
                const SizedBox(height: 14),

                _buildEditTextField(
                  label: 'Location / City',
                  controller: locationController,
                  icon: Icons.location_on_outlined,
                  hint: 'e.g. Chandigarh',
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _buildEditTextField(
                        label: 'Capacity (KW)',
                        controller: kwController,
                        icon: Icons.bolt_rounded,
                        keyboardType: TextInputType.number,
                        hint: 'e.g. 5KW',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEditTextField(
                        label: 'Electricity Bill',
                        controller: billController,
                        icon: Icons.receipt_long_rounded,
                        keyboardType: TextInputType.number,
                        hint: 'e.g. ₹5,000',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: isSaving.value
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) {
                                    showMySnackBar('Lead name cannot be empty',
                                        alert: true);
                                    return;
                                  }

                                  if (lead.id.isEmpty) {
                                    showMySnackBar(
                                        'Lead ID missing, cannot update in DB',
                                        alert: true);
                                    return;
                                  }

                                  try {
                                    isSaving.value = true;
                                    final body = {
                                      'name': name,
                                      'phoneNumber':
                                          phoneController.text.trim(),
                                      'altPhoneNumber':
                                          altPhoneController.text.trim(),
                                      'location':
                                          locationController.text.trim(),
                                      'kw': kwController.text.trim(),
                                      'electricityBill':
                                          billController.text.trim(),
                                    };

                                    final res = await httpRequest(
                                      REQUEST.put,
                                      "$updateLeadApiEndPoint${lead.id}",
                                      body,
                                    );

                                    if (res != null &&
                                        res['success'] == true) {
                                      final updatedLead = lead.copyWith(
                                        name: name,
                                        phoneNumber:
                                            phoneController.text.trim(),
                                        altPhoneNumber:
                                            altPhoneController.text.trim(),
                                        location:
                                            locationController.text.trim(),
                                        kw: kwController.text.trim(),
                                        electricityBill:
                                            billController.text.trim(),
                                      );

                                      lead = updatedLead;

                                      // Also sync in HomeController if active
                                      if (Get.isRegistered<HomeController>()) {
                                        final home =
                                            Get.find<HomeController>();
                                        final idx = home.leads.indexWhere(
                                            (l) =>
                                                (l.id.isNotEmpty &&
                                                    l.id == updatedLead.id) ||
                                                (l.rank.isNotEmpty &&
                                                    l.rank ==
                                                        updatedLead.rank));
                                        if (idx != -1) {
                                          home.leads[idx] = updatedLead;
                                          home.leads.refresh();
                                        }
                                      }

                                      if (ctx.mounted) Navigator.pop(ctx);
                                      showMySnackBar(
                                          'Lead updated successfully',
                                          success: true);
                                    } else {
                                      showMySnackBar(
                                          res?['message'] ??
                                              'Failed to update lead',
                                          alert: true);
                                    }
                                  } catch (e) {
                                    showMySnackBar('Error updating lead: $e',
                                        alert: true);
                                  } finally {
                                    isSaving.value = false;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String hint = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
