import '../enums/role.dart';

class Profile {
  final String id;
  final String? organizationId; // Nullable for clients without organization
  final Role role;
  final String fullName;
  final String? phone;
  final DateTime createdAt;

  Profile({
    required this.id,
    this.organizationId, // Nullable
    required this.role,
    required this.fullName,
    this.phone,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String?, // Nullable
      role: Role.fromString(json['role'] as String),
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'role': role.value,
      'full_name': fullName,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? organizationId,
    Role? role,
    String? fullName,
    String? phone,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
