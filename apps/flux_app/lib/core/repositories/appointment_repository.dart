import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment.dart';
import '../enums/appointment_status.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository(Supabase.instance.client);
});

class AppointmentRepository {
  final SupabaseClient _supabase;

  AppointmentRepository(this._supabase);

  Future<List<Appointment>> getAppointmentsByOrganization(
    String organizationId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('appointments')
          .select()
          .eq('organization_id', organizationId);

      if (startDate != null) {
        query = query.gte('start_time', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('start_time', endDate.toIso8601String());
      }

      final response = await query.order('start_time');

      return (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Appointment>> getAppointmentsByClient(String clientId) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select()
          .eq('client_id', clientId)
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Appointment?> createAppointment(Appointment appointment) async {
    try {
      final response = await _supabase
          .from('appointments')
          .insert(appointment.toJson())
          .select()
          .single();

      return Appointment.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Appointment?> updateAppointment(Appointment appointment) async {
    try {
      final response = await _supabase
          .from('appointments')
          .update(appointment.toJson())
          .eq('id', appointment.id)
          .select()
          .single();

      return Appointment.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      await _supabase
          .from('appointments')
          .update({'status': AppointmentStatus.cancelled.value})
          .eq('id', appointmentId);

      return true;
    } catch (e) {
      return false;
    }
  }
}
