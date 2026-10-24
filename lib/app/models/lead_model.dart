import 'package:start3x_app/exports.dart';

class LeadModel {
  final String rank;
  final String name;
  final String location;
  final String status;
  final String date;
  final String phoneNumber;
  final String altPhoneNumber;
  final RxList<LeadResponseModel> responses;

  LeadModel({
    required this.rank,
    required this.name,
    required this.location,
    required this.status,
    required this.date,
    this.phoneNumber = '+919876543210',
    this.altPhoneNumber = '+919876543211',
    List<LeadResponseModel>? initialResponses,
  }) : responses = RxList<LeadResponseModel>(initialResponses ?? []);
}
