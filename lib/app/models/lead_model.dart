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
    this.phoneNumber = '',
    this.altPhoneNumber = '',
    this.kw = '',
    this.electricityBill = '',
    this.textNote = '',
    List<LeadResponseModel>? initialResponses,
  }) : responses = RxList<LeadResponseModel>(initialResponses ?? []);

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    final List<LeadResponseModel> parsedResponses = [];
    final rawResponses = json['responses'];

    if (rawResponses is List) {
      for (final response in rawResponses) {
        if (response is Map<String, dynamic>) {
          parsedResponses.add(LeadResponseModel.fromJson(response));
        } else if (response is Map) {
          parsedResponses.add(
            LeadResponseModel.fromJson(
              Map<String, dynamic>.from(response),
            ),
          );
        } else if (response != null) {
          parsedResponses.add(
            LeadResponseModel(
              responseNumber: 'Response #1',
              outcome: response.toString(),
              text: '',
              callDate: '',
            ),
          );
        }
      }
    }

    final rawDate = (json['date'] ?? json['createdAt'] ?? '').toString();
    String formattedDate = rawDate;

    if (rawDate.isNotEmpty) {
      final parsedDate = DateTime.tryParse(rawDate);
      if (parsedDate != null) {
        final dt = parsedDate.toLocal();
        String day = dt.day.toString().padLeft(2, '0');
        String month = dt.month.toString().padLeft(2, '0');
        formattedDate = '$day/$month/${dt.year}';
      }
    }

    return LeadModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      passkey: (json['passkey'] ?? '').toString(),
      rank: (json['rank'] ?? '#1').toString(),
      name: (json['name'] ?? 'Lead').toString(),
      company: (json['company'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      status: (json['status'] ?? 'To-Do:').toString(),
      date: formattedDate.isNotEmpty ? formattedDate : '05/03/2025',
      phoneNumber:
          (json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      altPhoneNumber:
          (json['altPhoneNumber'] ?? json['altPhone'] ?? '').toString(),
      kw: (json['kw'] ?? '').toString(),
      electricityBill: (json['electricityBill'] ?? '').toString(),
      textNote: (json['textNote'] ?? '').toString(),
      initialResponses: parsedResponses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'passkey': passkey,
      'rank': rank,
      'name': name,
      'company': company,
      'location': location,
      'status': status,
      'date': date,
      'phoneNumber': phoneNumber,
      'altPhoneNumber': altPhoneNumber,
      'kw': kw,
      'electricityBill': electricityBill,
      'textNote': textNote,
      'responses': responses.map((r) => r.toJson()).toList(),
    };
  }
}
