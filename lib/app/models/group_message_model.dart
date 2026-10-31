import 'package:start3x_app/exports.dart';

class GroupMessageModel {
  final String id;
  final String senderName;
  final String messageText;
  final String messageType;
  final LeadModel? flaggedLead;
  final String createdAt;
  final bool? _isMe;

  bool get isMe => _isMe ?? false;

  GroupMessageModel({
    this.id = '',
    required this.senderName,
    required this.messageText,
    this.messageType = 'text',
    this.flaggedLead,
    this.createdAt = '',
    bool isMe = false,
  }) : _isMe = isMe;

  factory GroupMessageModel.fromJson(Map<String, dynamic> json, {String currentUserName = ''}) {
    LeadModel? lead;
    if (json['flaggedLead'] != null) {
      if (json['flaggedLead'] is Map<String, dynamic>) {
        lead = LeadModel.fromJson(json['flaggedLead']);
      }
    }

    final sender = json['senderName']?.toString() ?? 'User';
    final bool me = currentUserName.isNotEmpty &&
        (sender.trim().toLowerCase() == currentUserName.trim().toLowerCase());

    return GroupMessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      senderName: sender,
      messageText: json['messageText']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? (lead != null ? 'flagged_lead' : 'text'),
      flaggedLead: lead,
      createdAt: json['createdAt']?.toString() ?? '',
      isMe: me,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderName': senderName,
      'messageText': messageText,
      'messageType': messageType,
      if (flaggedLead != null) 'leadId': flaggedLead!.id,
      if (flaggedLead != null) 'leadRank': flaggedLead!.rank,
    };
  }
}
