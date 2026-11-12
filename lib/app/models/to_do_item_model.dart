import 'package:start3x_app/app/models/lead_model.dart';

class ToDoItemModel {
  final LeadModel? _lead;
  final String rank;
  final String name;
  final String location;
  final String status;
  final String date;
  final String time;
  final String reminderTime;
  final DateTime? dateTime;
  final bool isOverdue;

  ToDoItemModel({
    LeadModel? lead,
    required this.rank,
    required this.name,
    required this.location,
    required this.status,
    required this.date,
    required this.time,
    required this.reminderTime,
    this.dateTime,
    this.isOverdue = false,
  }) : _lead = lead;

  LeadModel get lead {
    if (_lead != null) return _lead;
    return LeadModel(
      rank: rank,
      name: name,
      location: location,
      status: status,
      scheduledDate: date,
    );
  }
}
