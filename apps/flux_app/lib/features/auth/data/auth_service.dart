import 'package:supabase_flutter/supabase_flutter.dart';

/// Service responsible for handling Supabase Authentication.
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Signs in a user with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  /// Registers a new OWNER and creates their organization
  Future<AuthResponse> signUpOwner({
    required String email,
    required String password,
    required String fullName,
    required String organizationName,
    String? phone,
  }) async {
    try {
      // Step 1: Create auth user with metadata
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'OWNER',
          'organization_name': organizationName,
          'phone': phone,
        },
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      // Step 2: Create organization
      final orgResponse = await _supabase
          .from('organizations')
          .insert({
            'name': organizationName,
            'invite_code': _generateInviteCode(organizationName),
          })
          .select()
          .single();

      final organizationId = orgResponse['id'] as String;

      // Step 3: Create profile using RPC function (bypasses RLS)
      await _supabase.rpc(
        'create_user_profile',
        params: {
          'user_id': response.user!.id,
          'user_role': 'OWNER',
          'user_full_name': fullName,
          'user_phone': phone,
          'user_organization_id': organizationId,
        },
      );

      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up: $e');
    }
  }

  /// Registers a new CLIENT without organization (can join later)
  Future<AuthResponse> signUpClient({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      // Step 1: Create auth user with metadata
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'CLIENT', 'phone': phone},
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      // Step 2: Create profile WITHOUT organization_id using RPC (bypasses RLS)
      await _supabase.rpc(
        'create_user_profile',
        params: {
          'user_id': response.user!.id,
          'user_role': 'CLIENT',
          'user_full_name': fullName,
          'user_phone': phone,
          'user_organization_id': null,
        },
      );

      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up: $e');
    }
  }

  /// Generates a simple invite code from organization name
  String _generateInviteCode(String organizationName) {
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

  /// Signs out the current user.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Returns the current authenticated user, or null if not logged in.
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream to listen to auth state changes (login, logout, token refresh).
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
