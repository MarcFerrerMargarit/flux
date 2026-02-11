import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/ui/login_screen.dart';
import '../features/dashboard/ui/dashboard_screen.dart';

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
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final isGoingToLogin = state.matchedLocation == '/login';

      // If no session and not going to login -> force to login
      if (session == null && !isGoingToLogin) {
        return '/login';
      }

      // If session exists and trying to access login -> force to dashboard
      if (session != null && isGoingToLogin) {
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
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
