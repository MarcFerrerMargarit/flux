import '../enums/appointment_status.dart';

class Appointment {
  final String id;
  final String organizationId;
  final String serviceId;
  final String clientId;
  final String staffId;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.organizationId,
    required this.serviceId,
    required this.clientId,
    required this.staffId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      serviceId: json['service_id'] as String,
      clientId: json['client_id'] as String,
      staffId: json['staff_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: AppointmentStatus.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'service_id': serviceId,
      'client_id': clientId,
      'staff_id': staffId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.value,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? organizationId,
    String? serviceId,
    String? clientId,
    String? staffId,
    DateTime? startTime,
    DateTime? endTime,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      serviceId: serviceId ?? this.serviceId,
      clientId: clientId ?? this.clientId,
      staffId: staffId ?? this.staffId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
