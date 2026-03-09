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

  /// Registers a new OWNER and creates their organization in auth metadata.
  /// The database trigger `on_auth_user_created` will handle table insertions.
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

      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up: $e');
    }
  }

  /// Registers a new CLIENT and adds metadata. Trigger handles db insertions.
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

      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up: $e');
    }
  }



  /// Resends the confirmation email to the given email address.
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al reenviar el email de confirmación.');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Returns the current authenticated user, or null if not logged in.
  User? get currentUser => _supabase.auth.currentUser;

  /// Whether the current user's email has been verified.
  bool get isEmailVerified => _supabase.auth.currentUser?.emailConfirmedAt != null;

  /// Stream to listen to auth state changes (login, logout, token refresh).
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
