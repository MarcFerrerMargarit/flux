class Organization {
  final String id;
  final String name;
  final String? inviteCode;
  final DateTime createdAt;

  Organization({
    required this.id,
    required this.name,
    this.inviteCode,
    required this.createdAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
