import '../enums/service_type.dart';

class Service {
  final String id;
  final String organizationId;
  final String name;
  final ServiceType type;
  final int durationMinutes;
  final double price;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.type,
    required this.durationMinutes,
    required this.price,
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      name: json['name'] as String,
      type: ServiceType.fromString(json['type'] as String),
      durationMinutes: json['duration_minutes'] as int,
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'type': type.value,
      'duration_minutes': durationMinutes,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
