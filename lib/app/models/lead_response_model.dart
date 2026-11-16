class LeadResponseModel {
  final String id;
  final String passkey;
  final String leadId;
  final String? userId;
  final String? userName;
  final String responseNumber;
  final String outcome;
  final String? scheduledDate;
  final String? callback;
  final String text;
  final String? reminder;
  final String createdAt;
  final String? rawCreatedAt;
  final bool isDone;
  final bool isMissed;

  LeadResponseModel({
    this.id = '',
    this.passkey = '',
    this.leadId = '',
    this.userId,
    this.userName,
    required this.responseNumber,
    required this.outcome,
    this.scheduledDate,
    this.callback,
    required this.text,
    this.reminder,
    required this.createdAt,
    this.rawCreatedAt,
    this.isDone = false,
    this.isMissed = false,
  });

  static String? _formatToLocalTime(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return null;
    final str = rawDate.trim();
    final parsed = DateTime.tryParse(str);
    if (parsed != null) {
      final dt = parsed.toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      final hour = (dt.hour % 12 == 0 ? 12 : dt.hour % 12)
          .toString()
          .padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$day/$month/$year $hour:$minute $period';
    }
    return str;
  }

  factory LeadResponseModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt']?.toString() ??
        json['date']?.toString() ??
        json['callDate']?.toString() ??
        '';
    final rawScheduledDate = json['scheduledDate']?.toString() ??
        json['meeting']?.toString() ??
        json['meetingScheduled']?.toString();
    final rawCallback = json['callback']?.toString();
    final rawReminder = json['reminder']?.toString();
    final isDone = json['isDone'] == true;
    final isMissed = json['isMissed'] == true;

    final rawUserId = json['userId']?.toString();
    final rawUserName = json['userName']?.toString() ??
        json['callerName']?.toString() ??
        json['user']?.toString();
    final cleanUserName = (rawUserName != null &&
            rawUserName.trim().isNotEmpty &&
            rawUserName.trim().toLowerCase() != 'null')
        ? rawUserName.trim()
        : null;

    return LeadResponseModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      passkey: json['passkey']?.toString() ?? '',
      leadId: json['leadId']?.toString() ?? '',
      userId: rawUserId,
      userName: cleanUserName,
      responseNumber: json['responseNumber']?.toString() ?? 'Response #1',
      outcome: json['outcome']?.toString() ?? '',
      scheduledDate: _formatToLocalTime(rawScheduledDate),
      callback: _formatToLocalTime(rawCallback),
      text: json['text']?.toString() ?? json['note']?.toString() ?? '',
      reminder: _formatToLocalTime(rawReminder),
      createdAt: _formatToLocalTime(rawCreatedAt) ?? '',
      rawCreatedAt: rawCreatedAt.isNotEmpty ? rawCreatedAt : null,
      isDone: isDone,
      isMissed: isMissed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      if (passkey.isNotEmpty) 'passkey': passkey,
      if (leadId.isNotEmpty) 'leadId': leadId,
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
      if (userName != null) 'callerName': userName,
      'responseNumber': responseNumber,
      'outcome': outcome,
      'scheduledDate': scheduledDate,
      if (callback != null) 'callback': callback,
      'text': text,
      if (reminder != null) 'reminder': reminder,
      'createdAt': createdAt,
      'isDone': isDone,
      'isMissed': isMissed,
    };
  }

  LeadResponseModel copyWith({
    String? id,
    String? passkey,
    String? leadId,
    String? userId,
    String? userName,
    String? responseNumber,
    String? outcome,
    String? scheduledDate,
    String? callback,
    String? text,
    String? reminder,
    String? createdAt,
    String? rawCreatedAt,
    bool? isDone,
    bool? isMissed,
  }) {
    return LeadResponseModel(
      id: id ?? this.id,
      passkey: passkey ?? this.passkey,
      leadId: leadId ?? this.leadId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      responseNumber: responseNumber ?? this.responseNumber,
      outcome: outcome ?? this.outcome,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      callback: callback ?? this.callback,
      text: text ?? this.text,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt ?? this.createdAt,
      rawCreatedAt: rawCreatedAt ?? this.rawCreatedAt,
      isDone: isDone ?? this.isDone,
      isMissed: isMissed ?? this.isMissed,
    );
  }
}
