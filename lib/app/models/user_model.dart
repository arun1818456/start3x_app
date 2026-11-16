
class UserDataModel {
  String? id;
  String? name;
  String? email;
  String? token;
  String? createdAt;
  String? role;
  String? passkey;
  bool? isSetupComplete;
  String? profileUrl;
  String? deviceToken;

  UserDataModel({
    this.id,
    this.name,
    this.email,
    this.token,
    this.createdAt,
    this.role,
    this.passkey,
    this.isSetupComplete,
    this.profileUrl,
    this.deviceToken,
  });

  UserDataModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    name = json['name'];
    email = json['email'];
    token = json['token'];
    createdAt = json['createdAt'];
    role = json['role'];
    passkey = json['passkey'];
    isSetupComplete = json['isSetupComplete'];
    profileUrl = json['profileUrl'];
    deviceToken = json['deviceToken'];
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
    data['isSetupComplete'] = isSetupComplete;
    data['profileUrl'] = profileUrl;
    data['deviceToken'] = deviceToken;
    return data;
  }
}
