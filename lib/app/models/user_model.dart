class ClientInfoModel {
  String legalName;
  String companyName;
  String gstName;
  String gstNumber;
  String phone;
  String targetedLocation;
  String fullAddress;
  String onGrid3kW;
  String onGrid4kW;
  String onGrid5kW;
  String hybrid3kW;
  String hybrid4kW;
  String hybrid5kW;
  String inverterSpec;
  String batterySpec;
  bool isSetupComplete;

  ClientInfoModel({
    this.legalName = '',
    this.companyName = '',
    this.gstName = '',
    this.gstNumber = '',
    this.phone = '',
    this.targetedLocation = '',
    this.fullAddress = '',
    this.onGrid3kW = '',
    this.onGrid4kW = '',
    this.onGrid5kW = '',
    this.hybrid3kW = '',
    this.hybrid4kW = '',
    this.hybrid5kW = '',
    this.inverterSpec = '',
    this.batterySpec = '',
    this.isSetupComplete = false,
  });

  factory ClientInfoModel.fromJson(Map<String, dynamic> json) {
    return ClientInfoModel(
      legalName: json['legalName']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      gstName: json['gstName']?.toString() ?? '',
      gstNumber: json['gstNumber']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      targetedLocation: json['targetedLocation']?.toString() ?? '',
      fullAddress: json['fullAddress']?.toString() ?? '',
      onGrid3kW: json['onGrid3kW']?.toString() ?? '',
      onGrid4kW: json['onGrid4kW']?.toString() ?? '',
      onGrid5kW: json['onGrid5kW']?.toString() ?? '',
      hybrid3kW: json['hybrid3kW']?.toString() ?? '',
      hybrid4kW: json['hybrid4kW']?.toString() ?? '',
      hybrid5kW: json['hybrid5kW']?.toString() ?? '',
      inverterSpec: json['inverterSpec']?.toString() ?? '',
      batterySpec: json['batterySpec']?.toString() ?? '',
      isSetupComplete: json['isSetupComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'legalName': legalName,
      'companyName': companyName,
      'gstName': gstName,
      'gstNumber': gstNumber,
      'phone': phone,
      'targetedLocation': targetedLocation,
      'fullAddress': fullAddress,
      'onGrid3kW': onGrid3kW,
      'onGrid4kW': onGrid4kW,
      'onGrid5kW': onGrid5kW,
      'hybrid3kW': hybrid3kW,
      'hybrid4kW': hybrid4kW,
      'hybrid5kW': hybrid5kW,
      'inverterSpec': inverterSpec,
      'batterySpec': batterySpec,
      'isSetupComplete': isSetupComplete,
    };
  }
}

class UserDataModel {
  String? id;
  String? name;
  String? email;
  String? token;
  String? createdAt;
  String? role;
  String? passkey;
  ClientInfoModel? clientInfo;

  UserDataModel({
    this.id,
    this.name,
    this.email,
    this.token,
    this.createdAt,
    this.role,
    this.passkey,
    this.clientInfo,
  });

  UserDataModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    name = json['name'];
    email = json['email'];
    token = json['token'];
    createdAt = json['createdAt'];
    role = json['role'];
    passkey = json['passkey'];
    if (json['clientInfo'] != null) {
      clientInfo = ClientInfoModel.fromJson(
          Map<String, dynamic>.from(json['clientInfo']));
    } else {
      clientInfo = ClientInfoModel();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['token'] = token;
    data['createdAt'] = createdAt;
    data['role'] = role;
    data['passkey'] = passkey;
    if (clientInfo != null) {
      data['clientInfo'] = clientInfo!.toJson();
    }
    return data;
  }
}
