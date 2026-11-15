class LeadModel {
  final String id;
  final String passkey;
  final String rank;
  final String name;
  final String location;
  final String status;
  final String scheduledDate;
  final String phoneNumber;
  final String altPhoneNumber;
  final String kw;
  final String electricityBill;
  final String createdAt;
  final bool isCompleted;

  LeadModel({
    this.id = '',
    this.passkey = '',
    required this.rank,
    required this.name,
    required this.location,
    required this.status,
    required this.scheduledDate,
    this.phoneNumber = '',
    this.altPhoneNumber = '',
    this.kw = '',
    this.electricityBill = '',
    this.createdAt = '',
    this.isCompleted = false,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    final rawDate = (json['scheduledDate'] ?? json['createdAt'] ?? '').toString();
    String formattedDate = rawDate;

    if (rawDate.isNotEmpty) {
      final parsedDate = DateTime.tryParse(rawDate);
      if (parsedDate != null) {
        final dt = parsedDate.toLocal();
        String day = dt.day.toString().padLeft(2, '0');
        String month = dt.month.toString().padLeft(2, '0');
        String hour = (dt.hour % 12 == 0 ? 12 : dt.hour % 12)
            .toString()
            .padLeft(2, '0');
        String minute = dt.minute.toString().padLeft(2, '0');
        String period = dt.hour >= 12 ? 'PM' : 'AM';
        formattedDate = '$day/$month/${dt.year} $hour:$minute $period';
      }
    }

    return LeadModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      passkey: (json['passkey'] ?? '').toString(),
      rank: (json['rank'] ?? '#1').toString(),
      name: (json['name'] ?? 'Lead').toString(),
      location: (json['location'] ?? '').toString(),
      status: (json['status'] ?? 'To-Do:').toString(),
      scheduledDate: formattedDate.isNotEmpty ? formattedDate : (json['scheduledDate'] ?? '23/11/2026 09:00 AM').toString(),
      phoneNumber: (json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      altPhoneNumber: (json['altPhoneNumber'] ?? json['altPhone'] ?? '').toString(),
      kw: (json['kw'] ?? '').toString(),
      electricityBill: (json['electricityBill'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      isCompleted: json['isCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'passkey': passkey,
      'rank': rank,
      'name': name,
      'location': location,
      'status': status,
      'scheduledDate': scheduledDate,
      'phoneNumber': phoneNumber,
      'altPhoneNumber': altPhoneNumber,
      'kw': kw,
      'electricityBill': electricityBill,
      'createdAt': createdAt,
      'isCompleted': isCompleted,
    };
  }

  LeadModel copyWith({
    String? id,
    String? passkey,
    String? rank,
    String? name,
    String? location,
    String? status,
    String? scheduledDate,
    String? phoneNumber,
    String? altPhoneNumber,
    String? kw,
    String? electricityBill,
    String? createdAt,
    bool? isCompleted,
  }) {
    return LeadModel(
      id: id ?? this.id,
      passkey: passkey ?? this.passkey,
      rank: rank ?? this.rank,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      altPhoneNumber: altPhoneNumber ?? this.altPhoneNumber,
      kw: kw ?? this.kw,
      electricityBill: electricityBill ?? this.electricityBill,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
