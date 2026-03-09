import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

final currentProfileProvider = FutureProvider.family<Profile?, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getCurrentUserProfile(userId);
});

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  Future<Profile?> getCurrentUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, organization_id, role, full_name, phone, created_at')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<List<Profile>> getClientsByOrganization(String organizationId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('organization_id', organizationId)
          .eq('role', 'CLIENT')
          .order('full_name');

      return (response as List).map((json) => Profile.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get clients for organization: $e');
    }
  }

  Future<Profile?> updateProfile(Profile profile) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
