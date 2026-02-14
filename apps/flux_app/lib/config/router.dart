import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/profile.dart';
import '../core/repositories/profile_repository.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/loading_screen.dart';
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
  final profileRepo = ref.read(profileRepositoryProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    // 1. Refresh the router every time the Auth State changes (login/logout)
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),

    // 2. Global Redirect Logic (The "Guard")
    redirect: (context, state) async {
      final session = supabase.auth.currentSession;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation.startsWith('/signup');

      // If no session and not going to login or signup -> force to login
      if (session == null && !isGoingToLogin && !isGoingToSignup) {
        return '/login';
      }

      // If session exists and trying to access login/signup -> force to dashboard
      if (session != null && (isGoingToLogin || isGoingToSignup)) {
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

          return FutureBuilder<Profile?>(
            future: profileRepo.getCurrentUserProfile(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }

              if (!snapshot.hasData || snapshot.data == null) {
                // If profile doesn't exist, logout and go to login
                supabase.auth.signOut();
                return const LoginScreen();
              }

              final profile = snapshot.data!;

              // For clients, check if they have an organization
              if (profile.role.isClient) {
                return FutureBuilder(
                  future: ref
                      .read(organizationRepositoryProvider)
                      .getUserOrganizations(user.id),
                  builder: (context, orgSnapshot) {
                    if (orgSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const LoadingScreen();
                    }

                    final organizations = orgSnapshot.data ?? [];

                    // If client has no organization, redirect to invite code screen
                    if (organizations.isEmpty) {
                      return const InviteCodeScreen();
                    }

                    return ClientDashboard(profile: profile);
                  },
                );
              } else {
                return ProDashboard(profile: profile);
              }
            },
          );
        },
      ),
    ],
  );
});
