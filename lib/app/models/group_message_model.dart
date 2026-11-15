import 'package:start3x_app/exports.dart';

class GroupMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String messageText;
  final String messageType;
  final LeadModel? flaggedLead;
  final List<LeadModel> flaggedLeads;
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
    List<LeadModel>? flaggedLeads,
    this.createdAt = '',
    bool isMe = false,
  })  : flaggedLeads = flaggedLeads ?? (flaggedLead != null ? [flaggedLead] : const []),
        _isMe = isMe;

  factory GroupMessageModel.fromJson(
    Map<String, dynamic> json, {
    String currentUserName = '',
    bool isCurrentUserAdmin = false,
    String currentUserId = '',
  }) {
    LeadModel? singleLead;
    if (json['flaggedLead'] != null && json['flaggedLead'] is Map<String, dynamic>) {
      singleLead = LeadModel.fromJson(json['flaggedLead']);
    }

    List<LeadModel> multipleLeads = [];
    if (json['flaggedLeads'] != null && json['flaggedLeads'] is List) {
      multipleLeads = (json['flaggedLeads'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => LeadModel.fromJson(item))
          .toList();
    }

    if (multipleLeads.isEmpty && singleLead != null) {
      multipleLeads.add(singleLead);
    }

    final sender = json['senderName']?.toString() ?? 'User';
    final sId = json['senderId']?.toString() ?? '';

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
      messageType: json['messageType']?.toString() ??
          (multipleLeads.isNotEmpty ? 'flagged_lead' : 'text'),
      flaggedLead: singleLead ?? (multipleLeads.isNotEmpty ? multipleLeads.first : null),
      flaggedLeads: multipleLeads,
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
      if (flaggedLeads.isNotEmpty)
        'leadIds': flaggedLeads.map((e) => e.id).toList(),
    };
  }
}
