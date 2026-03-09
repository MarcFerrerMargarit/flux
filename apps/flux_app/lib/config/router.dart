import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../core/repositories/profile_repository.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/loading_screen.dart';
import '../features/auth/ui/email_verification_screen.dart';
import '../features/auth/ui/signup_type_screen.dart';
import '../features/auth/ui/owner_signup_screen.dart';
import '../features/auth/ui/client_signup_screen.dart';
import '../features/pro/ui/pro_dashboard.dart';
import '../features/client/ui/client_dashboard.dart';
import '../features/dashboard/ui/invite_code_screen.dart';
import '../core/repositories/organization_repository.dart';

/// Helper class to convert a Stream into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Provider that holds the GoRouter configuration
final routerProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/dashboard',
    // 1. Refresh the router every time the Auth State changes (login/logout)
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),

    // 2. Global Redirect Logic (The "Guard")
    redirect: (context, state) async {
      final session = supabase.auth.currentSession;
      final user = supabase.auth.currentUser;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation.startsWith('/signup');
      final isGoingToVerify = state.matchedLocation == '/verify-email';

      // If no session and not going to login or signup -> force to login
      if (session == null && !isGoingToLogin && !isGoingToSignup) {
        return '/login';
      }

      // If session exists but email not verified -> force to verify-email
      if (session != null && user != null && user.emailConfirmedAt == null) {
        if (!isGoingToVerify) {
          return '/verify-email';
        }
        return null;
      }

      // If session exists, email verified, and trying to access login/signup/verify -> force to dashboard
      if (session != null && (isGoingToLogin || isGoingToSignup || isGoingToVerify)) {
        return '/dashboard';
      }

      // No redirect needed
      return null;
    },

    // 3. Define the routes
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupTypeScreen(),
      ),
      GoRoute(
        path: '/signup/owner',
        name: 'signup-owner',
        builder: (context, state) => const OwnerSignupScreen(),
      ),
      GoRoute(
        path: '/signup/client',
        name: 'signup-client',
        builder: (context, state) => const ClientSignupScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          final email = supabase.auth.currentUser?.email ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/invite-code',
        name: 'invite-code',
        builder: (context, state) => const InviteCodeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) {
          final user = supabase.auth.currentUser;

          if (user == null) {
            return const LoginScreen();
          }

          return Consumer(
            builder: (context, ref, child) {
              final profileAsync = ref.watch(currentProfileProvider(user.id));

              return profileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    // Profile creation might have failed during signup or is missing
                    return Scaffold(
                      body: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                              const SizedBox(height: 16),
                              const Text(
                                'Tu perfil está incompleto.',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hubo un error al crear tu organización o perfil durante el registro. Por favor, asegúrate de aplicar la migración de base de datos o contacta con soporte.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  // Manual sign out lets the user decide, preventing infinite loops
                                  supabase.auth.signOut();
                                },
                                child: const Text('Cerrar Sesión y Volver al Login'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // For clients, check if they have an organization
                  if (profile.role.isClient) {
                    final orgsAsync = ref.watch(userOrganizationsProvider(user.id));
                    
                    return orgsAsync.when(
                      data: (organizations) {
                        // If client has no organization, redirect to invite code screen
                        if (organizations.isEmpty) {
                          return const InviteCodeScreen();
                        }
                        return ClientDashboard(profile: profile);
                      },
                      loading: () => const LoadingScreen(),
                      error: (error, stack) => Scaffold(
                        body: Center(child: Text('Error: $error')),
                      ),
                    );
                  } else {
                    return ProDashboard(profile: profile);
                  }
                },
                loading: () => const LoadingScreen(),
                error: (error, stack) => Scaffold(
                  body: Center(child: Text('Error: $error')),
                ),
              );
            },
          );
        },
      ),
    ],
  );
});
