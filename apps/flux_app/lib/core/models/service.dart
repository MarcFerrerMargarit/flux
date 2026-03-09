import '../enums/service_type.dart';

class Service {
  final String id;
  final String organizationId;
  final String name;
  final String? description;
  final ServiceType type;
  final int durationMinutes;
  final double price;
  final bool isActive;
  final int maxParticipants;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.organizationId,
    required this.name,
    this.description,
    required this.type,
    required this.durationMinutes,
    required this.price,
    this.isActive = true,
    this.maxParticipants = 1,
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: ServiceType.fromString(json['type'] as String),
      durationMinutes: json['duration_minutes'] as int,
      price: (json['price'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      maxParticipants: json['max_participants'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'organization_id': organizationId,
      'name': name,
      if (description != null) 'description': description,
      'type': type.value,
      'duration_minutes': durationMinutes,
      'price': price,
      'is_active': isActive,
      'max_participants': maxParticipants,
      // created_at is database generated typically
    };
  }

  Service copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? description,
    ServiceType? type,
    int? durationMinutes,
    double? price,
    bool? isActive,
    int? maxParticipants,
    DateTime? createdAt,
  }) {
    return Service(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
