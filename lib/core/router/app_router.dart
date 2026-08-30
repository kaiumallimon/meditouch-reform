import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/features/appointments/presentation/appointments_screen.dart';
import 'package:meditouch/features/auth/presentation/login_screen.dart';
import 'package:meditouch/features/chatbot/presentation/chatbot_screen.dart';
import 'package:meditouch/features/doctors/presentation/doctors_screen.dart';
import 'package:meditouch/features/home/presentation/home_screen.dart';
import 'package:meditouch/features/home/presentation/home_shell_screen.dart';
import 'package:meditouch/features/notifications/presentation/notifications_screen.dart';
import 'package:meditouch/features/pharmacy/cart/presentation/cart_screen.dart';
import 'package:meditouch/features/pharmacy/medicines/presentation/medicines_screen.dart';
import 'package:meditouch/features/pharmacy/orders/presentation/orders_screen.dart';
import 'package:meditouch/features/profile/presentation/profile_screen.dart';
import 'package:meditouch/features/splash/presentation/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

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

      // Main Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return HomeShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.pharmacy,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MedicinesScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.doctors,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DoctorsScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.chatbot,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatbotScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
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
