import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/features/appointments/presentation/appointments_screen.dart';
import 'package:meditouch/features/auth/presentation/login_screen.dart';
import 'package:meditouch/features/auth/presentation/register_screen.dart';
import 'package:meditouch/features/chatbot/presentation/chatbot_screen.dart';
import 'package:meditouch/features/doctors/presentation/doctors_screen.dart';
import 'package:meditouch/features/home/presentation/home_screen.dart';
import 'package:meditouch/features/home/presentation/home_shell_screen.dart';
import 'package:meditouch/features/notifications/presentation/notifications_screen.dart';
import 'package:meditouch/features/pharmacy/cart/presentation/cart_screen.dart';
import 'package:meditouch/features/pharmacy/medicines/presentation/medicines_screen.dart';
import 'package:meditouch/features/pharmacy/orders/presentation/orders_screen.dart';
import 'package:meditouch/features/profile/presentation/profile_screen.dart';
import 'package:meditouch/features/settings/presentation/settings_screen.dart';
import 'package:meditouch/features/splash/presentation/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

Page<dynamic> _buildSmoothShellPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: child,
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main Shell with Bottom Navigation (Smooth Transitions)
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return HomeShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.home,
            pageBuilder: (context, state) => _buildSmoothShellPage(
              const HomeScreen(),
              state,
            ),
          ),
          GoRoute(
            path: RouteNames.pharmacy,
            pageBuilder: (context, state) => _buildSmoothShellPage(
              const MedicinesScreen(),
              state,
            ),
          ),
          GoRoute(
            path: RouteNames.doctors,
            pageBuilder: (context, state) => _buildSmoothShellPage(
              const DoctorsScreen(),
              state,
            ),
          ),
          GoRoute(
            path: RouteNames.chatbot,
            pageBuilder: (context, state) => _buildSmoothShellPage(
              const ChatbotScreen(),
              state,
            ),
          ),
          GoRoute(
            path: RouteNames.settings,
            pageBuilder: (context, state) => _buildSmoothShellPage(
              const SettingsScreen(),
              state,
            ),
          ),
        ],
      ),

      // Dedicated Profile Sub-route
      GoRoute(
        path: RouteNames.profile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Full-screen Modal / Sub-routes
      GoRoute(
        path: RouteNames.cart,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: RouteNames.orders,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: RouteNames.appointments,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
