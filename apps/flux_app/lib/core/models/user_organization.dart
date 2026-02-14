class UserOrganization {
  final String id;
  final String userId;
  final String organizationId;
  final String role;
  final bool isPrimary;
  final DateTime joinedAt;

  UserOrganization({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.role,
    this.isPrimary = false,
    required this.joinedAt,
  });

  factory UserOrganization.fromJson(Map<String, dynamic> json) {
    return UserOrganization(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      organizationId: json['organization_id'] as String,
      role: json['role'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'organization_id': organizationId,
      'role': role,
      'is_primary': isPrimary,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
