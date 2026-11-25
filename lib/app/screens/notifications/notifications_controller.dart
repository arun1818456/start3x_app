import 'package:start3x_app/exports.dart';

class NotificationsController extends GetxController with BaseClass {
  final String initialUserId;
  final String initialUserName;

  NotificationsController({
    this.initialUserId = '',
    this.initialUserName = '',
  });

  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  late String targetUserId;
  late String targetUserName;

  bool get isViewingOtherUser =>
      targetUserId.isNotEmpty && targetUserId != (getUserData().id ?? '');

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments is Map ? Get.arguments as Map : null;
    targetUserId = initialUserId.isNotEmpty
        ? initialUserId
        : (args?['userId']?.toString() ?? '');
    targetUserName = initialUserName.isNotEmpty
        ? initialUserName
        : (args?['userName']?.toString() ?? '');
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final String url = isViewingOtherUser
          ? "$getNotificationsApiEndPoint?userId=$targetUserId"
          : getNotificationsApiEndPoint;
      final res = await httpRequest(
        REQUEST.get,
        url,
        {},
      );
      if (res != null &&
          res['success'] == true &&
          res['notifications'] is List) {
        final List rawList = res['notifications'] as List;
        notifications.value = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      } else {
        notifications.clear();
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMySnackBar("Failed to load notifications", error: true);
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNotification(NotificationModel item) async {
    if (item.id.isEmpty || isActionLoading.value) return;
    try {
      isActionLoading.value = true;
      final String url = isViewingOtherUser
          ? "$deleteNotificationApiEndPoint${item.id}?userId=$targetUserId"
          : "$deleteNotificationApiEndPoint${item.id}";
      final res = await httpRequest(
        REQUEST.delete,
        url,
        {},
      );
      if (res != null && res['success'] == true) {
        notifications.removeWhere((n) => n.id == item.id);
        showMySnackBar("Notification deleted", success: true);
      }
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      showMySnackBar("Failed to delete notification", error: true);
    } finally {
      isActionLoading.value = false;
    }
  }

  void confirmDeleteAll(BuildContext context) {
    if (notifications.isEmpty) return;
    CommonDialogs().showCustomDialog(
      context,
      title: "Clear All Notifications",
      description: isViewingOtherUser
          ? "Are you sure you want to delete all notifications for $targetUserName?"
          : "Are you sure you want to delete all notifications?",
      yesButtonText: "Clear All",
      noButtonText: "Cancel",
      onTapYes: () async {
        await deleteAllNotifications();
      },
    );
  }

  Future<void> deleteAllNotifications() async {
    try {
      isActionLoading.value = true;
      final String url = isViewingOtherUser
          ? "$deleteAllNotificationsApiEndPoint?userId=$targetUserId"
          : deleteAllNotificationsApiEndPoint;
      final res = await httpRequest(
        REQUEST.delete,
        url,
        {},
      );
      if (res != null && res['success'] == true) {
        notifications.clear();
        showMySnackBar("All notifications cleared", success: true);
      }
    } catch (e) {
      debugPrint("Error deleting all notifications: $e");
      showMySnackBar("Failed to clear notifications", error: true);
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> onTapNotification(NotificationModel item) async {
    final typeLower = item.type.toLowerCase();
    if (typeLower == 'info' || typeLower == 'session_expired') return;

    final user = getUserData();
    final bool isAdmin = user.role == 'admin';
    if (!isAdmin && Get.previousRoute == AppRoutes.mainScreen) {
      Get.back();
    }

    await MyNotification.notificationNavigation({
      'type': item.type,
      if (item.passkey.isNotEmpty) 'passkey': item.passkey,
      if (item.leadId.isNotEmpty) 'leadId': item.leadId,
    });
  }

  String formatDateTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDay = DateTime(dt.year, dt.month, dt.day);
      final diffDays = today.difference(targetDay).inDays;

      int hour12 = dt.hour % 12;
      if (hour12 == 0) hour12 = 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final timeStr = '$hour12:$minute $amPm';

      if (diffDays == 0) {
        return 'Today, $timeStr';
      } else if (diffDays == 1) {
        return 'Yesterday, $timeStr';
      }

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}, $timeStr';
    } catch (_) {
      return raw;
    }
  }

  String formatTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'LEAD_ASSIGNED':
        return 'New Lead';
      case 'LEAD_UPDATED':
        return 'Lead Updated';
      case 'RESPONSE_ADDED':
        return 'Call Response';
      case 'DEAL_CLOSED':
        return 'Deal Closed';
      case 'TASK_REMINDER':
        return 'Reminder';
      case 'TASK_MISSED':
        return 'Missed Task';
      case 'CHAT_MESSAGE':
        return 'Team Chat';
      case 'CLIENT_SETUP_COMPLETED':
        return 'Setup Complete';
      case 'CLIENT_INFO_UPDATED':
        return 'Business Info';
      case 'PASSKEY_STATUS':
        return 'Passkey';
      case 'TEAM_MEMBER_JOINED':
        return 'Team';
      case 'WEB_ENQUIRY':
        return 'Web Enquiry';
      default:
        return 'Update';
    }
  }

  IconData iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'LEAD_ASSIGNED':
      case 'LEAD_UPDATED':
        return Icons.person_add_alt_1_rounded;
      case 'RESPONSE_ADDED':
        return Icons.call_rounded;
      case 'DEAL_CLOSED':
        return Icons.verified_rounded;
      case 'TASK_REMINDER':
        return Icons.alarm_rounded;
      case 'TASK_MISSED':
        return Icons.warning_amber_rounded;
      case 'CHAT_MESSAGE':
        return Icons.forum_rounded;
      case 'CLIENT_SETUP_COMPLETED':
      case 'CLIENT_INFO_UPDATED':
        return Icons.business_rounded;
      case 'PASSKEY_STATUS':
        return Icons.vpn_key_rounded;
      case 'TEAM_MEMBER_JOINED':
        return Icons.groups_rounded;
      case 'WEB_ENQUIRY':
        return Icons.public_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color colorForType(String type) {
    switch (type.toUpperCase()) {
      case 'LEAD_ASSIGNED':
      case 'LEAD_UPDATED':
        return AppColors.primaryBlue;
      case 'RESPONSE_ADDED':
        return Colors.indigo;
      case 'DEAL_CLOSED':
        return Colors.green.shade700;
      case 'TASK_REMINDER':
        return Colors.orange.shade700;
      case 'TASK_MISSED':
        return Colors.red.shade600;
      case 'CHAT_MESSAGE':
        return Colors.teal.shade600;
      case 'TEAM_MEMBER_JOINED':
        return Colors.deepPurple;
      case 'WEB_ENQUIRY':
        return Colors.blue.shade700;
      default:
        return AppColors.primaryBlue;
    }
  }
}
