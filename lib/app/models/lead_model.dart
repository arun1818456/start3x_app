import 'package:start3x_app/exports.dart';

class LeadModel {
  final String id;
  final String passkey;
  final String rank;
  final String name;
  final String company;
  final String location;
  final String status;
  final String date;
  final String phoneNumber;
  final String altPhoneNumber;
  final String kw;
  final String electricityBill;
  final String textNote;
  final RxList<LeadResponseModel> responses;

  LeadModel({
    this.id = '',
    this.passkey = '',
    required this.rank,
    required this.name,
    this.company = '',
    required this.location,
    required this.status,
    required this.date,
    this.phoneNumber = '+919876543210',
    this.altPhoneNumber = '+919876543211',
    this.kw = '',
    this.electricityBill = '',
    this.textNote = '',
    List<LeadResponseModel>? initialResponses,
  }) : responses = RxList<LeadResponseModel>(initialResponses ?? []);

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    List respList = json['responses'] ?? [];
    List<LeadResponseModel> parsedResponses = respList.map((r) {
      if (r is Map<String, dynamic>) {
        return LeadResponseModel.fromJson(r);
      }
      return LeadResponseModel(
        responseNumber: 'Response #1',
        outcome: r.toString(),
        text: '',
        callDate: '',
      );
    }).toList();

    String rawDate = json['date']?.toString() ?? json['createdAt']?.toString() ?? '';
    String formattedDate = rawDate;
    if (rawDate.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(rawDate).toLocal();
        String day = dt.day.toString().padLeft(2, '0');
        String month = dt.month.toString().padLeft(2, '0');
        formattedDate = '$day/$month/${dt.year}';
      } catch (e) {
        formattedDate = rawDate;
      }
    }

    return LeadModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      passkey: json['passkey']?.toString() ?? '',
      rank: json['rank']?.toString() ?? '#1',
      name: json['name']?.toString() ?? 'Lead',
      company: json['company']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Chandigarh',
      status: json['status']?.toString() ?? 'To-Do:',
      date: formattedDate.isNotEmpty ? formattedDate : '05/03/2025',
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '+919876543210',
      altPhoneNumber: json['altPhoneNumber']?.toString() ?? json['altPhone']?.toString() ?? '+919876543211',
      kw: json['kw']?.toString() ?? '',
      electricityBill: json['electricityBill']?.toString() ?? '',
      textNote: json['textNote']?.toString() ?? '',
      initialResponses: parsedResponses,
    );
  }
}
