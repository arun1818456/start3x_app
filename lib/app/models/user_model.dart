class UserDataModel {
  String? id;
  String? name;
  String? email;
  String? token;
  String? createdAt;
  String? role;

  UserDataModel({
    this.id,
    this.name,
    this.email,
    this.token,
    this.createdAt,
    this.role,
  });

  UserDataModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    name = json['name'];
    email = json['email'];
    token = json['token'];
    createdAt = json['createdAt'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['token'] = token;
    data['createdAt'] = createdAt;
    data['role'] = role;
    return data;
  }
}
