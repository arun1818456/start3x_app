class LeadResponseModel {
  final String id;
  final String passkey;
  final String leadId;
  final String responseNumber;
  final String outcome;
  final String? scheduledDate;
  final String? callback;
  final String text;
  final String? reminder;
  final String createdAt;
  final bool isDone;
  final bool isMissed;

  LeadResponseModel({
    this.id = '',
    this.passkey = '',
    this.leadId = '',
    required this.responseNumber,
    required this.outcome,
    this.scheduledDate,
    this.callback,
    required this.text,
    this.reminder,
    required this.createdAt,
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

    return LeadResponseModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      passkey: json['passkey']?.toString() ?? '',
      leadId: json['leadId']?.toString() ?? '',
      responseNumber: json['responseNumber']?.toString() ?? 'Response #1',
      outcome: json['outcome']?.toString() ?? '',
      scheduledDate: _formatToLocalTime(rawScheduledDate),
      callback: _formatToLocalTime(rawCallback),
      text: json['text']?.toString() ?? json['note']?.toString() ?? '',
      reminder: _formatToLocalTime(rawReminder),
      createdAt: _formatToLocalTime(rawCreatedAt) ?? '',
      isDone: isDone,
      isMissed: isMissed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      if (passkey.isNotEmpty) 'passkey': passkey,
      if (leadId.isNotEmpty) 'leadId': leadId,
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
}
