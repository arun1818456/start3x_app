import 'package:start3x_app/exports.dart';

class GroupMessageModel {
  final String senderName;
  final String messageText;
  final LeadModel? flaggedLead;

  GroupMessageModel({
    required this.senderName,
    required this.messageText,
    this.flaggedLead,
  });
}
