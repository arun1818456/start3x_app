class AccessClientModel {
  final String id;
  final String name;
  final String rank;

  AccessClientModel({
    required this.id,
    required this.name,
    required this.rank,
  });

  factory AccessClientModel.fromJson(Map<String, dynamic> json) {
    return AccessClientModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? "",
      name: (json['name'] != null && json['name'].toString().isNotEmpty)
          ? json['name'].toString()
          : (json['createdBy']?.toString() ?? 'Ramananda'),
      rank: json['rank']?.toString() ?? '#1',
    );
  }
}
