class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String passkey;
  final String leadId;
  final bool read;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.passkey,
    required this.leadId,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? 'INFO').toString(),
      passkey: (json['passkey'] ?? '').toString(),
      leadId: (json['leadId'] ?? '').toString(),
      read: json['read'] == true,
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}
