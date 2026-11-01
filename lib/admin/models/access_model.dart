import 'package:get/get.dart';
import 'package:start3x_app/app/models/lead_model.dart';

class AccessClientModel {
  final String id;
  final String name;
  final String rank;
  final String? _phone;
  final String? _location;
  final String? _company;
  final String createdAt;
  final RxBool isActive;

  String get phone => _phone ?? '';
  String get location => _location ?? '';
  String get company => _company ?? '';

  AccessClientModel({
    required this.id,
    required this.name,
    required this.rank,
    String phone = '',
    String location = '',
    String company = '',
    this.createdAt = '',
    bool active = true,
  })  : _phone = phone,
        _location = location,
        _company = company,
        isActive = active.obs;

  factory AccessClientModel.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    if (json['createdAt'] != null && json['createdAt'].toString().isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(json['createdAt'].toString()).toLocal();
        String day = dt.day.toString().padLeft(2, '0');
        String month = dt.month.toString().padLeft(2, '0');
        String hour = (dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString().padLeft(2, '0');
        String minute = dt.minute.toString().padLeft(2, '0');
        String period = dt.hour >= 12 ? 'PM' : 'AM';
        formattedDate = '$day/$month/${dt.year} $hour:$minute $period';
      } catch (e) {
        formattedDate = json['createdAt'].toString();
      }
    }

    final clientInfo = json['clientInfo'] is Map<String, dynamic>
        ? json['clientInfo'] as Map<String, dynamic>
        : {};

    final phoneVal = json['phone']?.toString() ??
        json['phoneNumber']?.toString() ??
        clientInfo['phone']?.toString() ??
        clientInfo['phoneNumber']?.toString() ??
        '';

    final locationVal = json['targetedLocation']?.toString() ??
        json['location']?.toString() ??
        clientInfo['targetedLocation']?.toString() ??
        clientInfo['fullAddress']?.toString() ??
        '';

    final companyVal = json['companyName']?.toString() ??
        json['company']?.toString() ??
        clientInfo['companyName']?.toString() ??
        '';

    return AccessClientModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? "",
      name: (json['name'] != null && json['name'].toString().isNotEmpty)
          ? json['name'].toString()
          : (json['createdBy']?.toString() ?? ''),
      rank: json['rank']?.toString() ?? '#1',
      phone: phoneVal,
      location: locationVal,
      company: companyVal,
      createdAt: formattedDate,
      active: json['isActive'] ?? true,
    );
  }
}
