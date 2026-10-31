class LeadResponseModel {
  final String id;
  final String responseNumber;
  final String outcome;
  final String? meetingScheduled;
  final String? callback;
  final String text;
  final String callDate;

  LeadResponseModel({
    this.id = '',
    required this.responseNumber,
    required this.outcome,
    this.meetingScheduled,
    this.callback,
    required this.text,
    required this.callDate,
  });

  factory LeadResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadResponseModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      responseNumber: json['responseNumber']?.toString() ?? 'Response #1',
      outcome: json['outcome']?.toString() ?? '',
      meetingScheduled:
          json['meetingScheduled']?.toString() ?? json['meeting']?.toString(),
      callback: json['callback']?.toString(),
      text: json['text']?.toString() ?? json['note']?.toString() ?? '',
      callDate: json['callDate']?.toString() ?? json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'responseNumber': responseNumber,
      'outcome': outcome,
      'meetingScheduled': meetingScheduled,
      'callback': callback,
      'text': text,
      'callDate': callDate,
    };
  }
}
