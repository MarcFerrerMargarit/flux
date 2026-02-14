import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(Supabase.instance.client);
});

class ServiceRepository {
  final SupabaseClient _supabase;

  ServiceRepository(this._supabase);

  Future<List<Service>> getServicesByOrganization(String organizationId) async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .eq('organization_id', organizationId)
          .order('name');

      return (response as List).map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Service?> getServiceById(String serviceId) async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .eq('id', serviceId)
          .single();

      return Service.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Service?> createService(Service service) async {
    try {
      final response = await _supabase
          .from('services')
          .insert(service.toJson())
          .select()
          .single();

      return Service.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Service?> updateService(Service service) async {
    try {
      final response = await _supabase
          .from('services')
          .update(service.toJson())
          .eq('id', service.id)
          .select()
          .single();

      return Service.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      await _supabase.from('services').delete().eq('id', serviceId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
