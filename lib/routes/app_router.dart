import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/role_helper.dart';

import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/profile/profile_setup_screen.dart';
import '../features/admin/admin_screen.dart';
import '../features/home/main_navigation_screen.dart';
import '../features/schemes/scheme_details_screen.dart';
import '../core/models/scheme_model.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final loc = state.matchedLocation;
    final isAuthRoute = loc == '/login' || loc == '/signup';

    // Always allow the Flutter SplashScreen at '/'
    if (loc == '/') {
      return null;
    }

    if (user == null) {
      if (isAuthRoute) return null;
      return '/login';
    }

    final isAdmin = user.email == RoleHelper.adminEmail;
    if (isAdmin && loc == '/profile-setup') return '/main';

    // Do not auto-redirect authenticated users away from auth routes.
    // Splash + explicit navigation will control when to show login/main.
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email == RoleHelper.adminEmail) {
          return const AdminScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: Text("Access Denied"),
            ),
          );
        }
      },
    ),
    GoRoute(
      path: '/scheme-details',
      builder: (context, state) {
        final scheme = state.extra as SchemeModel;
        return SchemeDetailsScreen(scheme: scheme);
      },
    ),
  ],
);
