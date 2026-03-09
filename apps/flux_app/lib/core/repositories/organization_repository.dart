import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/organization.dart';
import '../models/user_organization.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository(Supabase.instance.client);
});

final userOrganizationsProvider = FutureProvider.family<List<UserOrganization>, String>((ref, userId) async {
  final repo = ref.watch(organizationRepositoryProvider);
  return repo.getUserOrganizations(userId);
});

class OrganizationRepository {
  final SupabaseClient _supabase;

  OrganizationRepository(this._supabase);

  Future<Organization?> getOrganizationById(String organizationId) async {
    try {
      final response = await _supabase
          .from('organizations')
          .select()
          .eq('id', organizationId)
          .maybeSingle();

      if (response == null) return null;
      return Organization.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get organization: $e');
    }
  }

  Future<Organization?> getOrganizationByInviteCode(String inviteCode) async {
    try {
      final response = await _supabase
          .from('organizations')
          .select()
          .eq('invite_code', inviteCode)
          .maybeSingle();

      if (response == null) return null;
      return Organization.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get organization by invite code: $e');
    }
  }

  Future<Organization?> createOrganization(String name) async {
    try {
      // Generate a simple invite code
      final inviteCode = _generateInviteCode(name);

      final response = await _supabase
          .from('organizations')
          .insert({'name': name, 'invite_code': inviteCode})
          .select()
          .single();

      return Organization.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create organization: $e');
    }
  }

  String _generateInviteCode(String organizationName) {
    // Simple invite code generation: first 4 letters + random 4 digits
    final prefix = organizationName
        .replaceAll(RegExp(r'[^a-zA-Z]'), '')
        .toUpperCase()
        .substring(
          0,
          organizationName.length >= 4 ? 4 : organizationName.length,
        )
        .padRight(4, 'X');

    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    return '$prefix-$random';
  }

  /// Link user to organization
  Future<void> linkUserToOrganization({
    required String userId,
    required String organizationId,
    required String role,
    bool isPrimary = false,
  }) async {
    try {
      await _supabase.from('user_organizations').insert({
        'user_id': userId,
        'organization_id': organizationId,
        'role': role,
        'is_primary': isPrimary,
      });
    } catch (e) {
      throw Exception('Failed to link user to organization: $e');
    }
  }

  /// Get user's organizations
  Future<List<UserOrganization>> getUserOrganizations(String userId) async {
    try {
      final response = await _supabase
          .from('user_organizations')
          .select()
          .eq('user_id', userId)
          .order('is_primary', ascending: false);

      return (response as List)
          .map((json) => UserOrganization.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user organizations: $e');
    }
  }

  /// Get user's primary organization
  Future<UserOrganization?> getPrimaryOrganization(String userId) async {
    try {
      final response = await _supabase
          .from('user_organizations')
          .select()
          .eq('user_id', userId)
          .eq('is_primary', true)
          .maybeSingle();

      if (response == null) return null;
      return UserOrganization.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get primary organization: $e');
    }
  }

  /// Set primary organization
  Future<void> setPrimaryOrganization({
    required String userId,
    required String organizationId,
  }) async {
    try {
      // First, unset all primary flags for this user
      await _supabase
          .from('user_organizations')
          .update({'is_primary': false})
          .eq('user_id', userId);

      // Then set the new primary
      await _supabase
          .from('user_organizations')
          .update({'is_primary': true})
          .eq('user_id', userId)
          .eq('organization_id', organizationId);
    } catch (e) {
      throw Exception('Failed to set primary organization: $e');
    }
  }
}
