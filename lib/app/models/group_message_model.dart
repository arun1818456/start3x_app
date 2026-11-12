import 'package:start3x_app/exports.dart';

class GroupMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String messageText;
  final String messageType;
  final LeadModel? flaggedLead;
  final String createdAt;
  final bool? _isMe;

  bool get isMe => _isMe ?? false;

  GroupMessageModel({
    this.id = '',
    this.senderId = '',
    required this.senderName,
    required this.messageText,
    this.messageType = 'text',
    this.flaggedLead,
    this.createdAt = '',
    bool isMe = false,
  }) : _isMe = isMe;

  factory GroupMessageModel.fromJson(
    Map<String, dynamic> json, {
    String currentUserName = '',
    bool isCurrentUserAdmin = false,
    String currentUserId = '',
  }) {
    LeadModel? lead;
    if (json['flaggedLead'] != null) {
      if (json['flaggedLead'] is Map<String, dynamic>) {
        lead = LeadModel.fromJson(json['flaggedLead']);
      }
    }

    final sender = json['senderName']?.toString() ?? 'User';
    final sId = json['senderId']?.toString() ?? '';

    // Robust isMe determination:
    // 1. If senderId matches logged-in user id -> definitely ME!
    // 2. If current user is Admin and sender is "Admin" -> definitely ME!
    // 3. If senderName matches currentUserName -> ME!
    bool me = false;
    if (currentUserId.isNotEmpty && sId.isNotEmpty && currentUserId == sId) {
      me = true;
    } else if (isCurrentUserAdmin && sender.trim().toLowerCase() == 'admin') {
      me = true;
    } else if (currentUserName.isNotEmpty &&
        (sender.trim().toLowerCase() == currentUserName.trim().toLowerCase())) {
      me = true;
    }

    return GroupMessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      senderId: sId,
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
      if (id.isNotEmpty) 'id': id,
      if (senderId.isNotEmpty) 'senderId': senderId,
      'senderName': senderName,
      'messageText': messageText,
      'messageType': messageType,
      if (flaggedLead != null) 'leadId': flaggedLead!.id,
      if (flaggedLead != null) 'leadRank': flaggedLead!.rank,
    };
  }
}
