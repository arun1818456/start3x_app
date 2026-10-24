class LeadResponseModel {
  final String responseNumber;
  final String outcome;
  final String? meetingScheduled;
  final String? callback;
  final String text;
  final String callDate;

  LeadResponseModel({
    required this.responseNumber,
    required this.outcome,
    this.meetingScheduled,
    this.callback,
    required this.text,
    required this.callDate,
  });
}
