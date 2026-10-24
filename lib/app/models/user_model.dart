class UserDataModel {
  String? id;
  String? name;
  String? email;
  String? token;
  String? profileUrl;
  String? createdAt;
  String? userName;
  String? passkey;

  UserDataModel({
    this.id,
    this.name,
    this.email,
    this.token,
    this.profileUrl,
    this.createdAt,
    this.userName,
    this.passkey,
  });

  UserDataModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    name = json['name'];
    email = json['email'];
    token = json['token'];
    profileUrl = json['profileUrl'];
    createdAt = json['createdAt'];
    userName = json['userName'];
    passkey = json['passkey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['token'] = token;
    data['profileUrl'] = profileUrl;
    data['createdAt'] = createdAt;
    data['userName'] = userName;
    data['passkey'] = passkey;
    return data;
  }
}
