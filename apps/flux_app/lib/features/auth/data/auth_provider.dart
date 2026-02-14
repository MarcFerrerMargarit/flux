import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/profile.dart';
import '../../../core/repositories/profile_repository.dart';
import 'auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthController extends AsyncNotifier<Profile?> {
  @override
  FutureOr<Profile?> build() async {
    // Check if user is already logged in
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    if (user != null) {
      final profileRepo = ref.read(profileRepositoryProvider);
      return await profileRepo.getCurrentUserProfile(user.id);
    }

    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signIn(email: email, password: password);

      final user = authService.currentUser;
      if (user != null) {
        final profileRepo = ref.read(profileRepositoryProvider);
        final profile = await profileRepo.getCurrentUserProfile(user.id);
        return profile;
      }

      return null;
    });
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, Profile?>(
  AuthController.new,
);
