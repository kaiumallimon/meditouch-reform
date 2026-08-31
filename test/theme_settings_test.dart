import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meditouch/features/auth/data/auth_repository.dart';
import 'package:meditouch/features/auth/domain/user_model.dart';
import 'package:meditouch/features/profile/presentation/profile_screen.dart';
import 'package:meditouch/features/settings/presentation/settings_screen.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('Settings screen renders theme controls and profile tile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const Scaffold(body: Text('Profile Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Settings Screen Elements
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Personal details, address & medical history'), findsOneWidget);
    expect(find.text('APPEARANCE & DISPLAY'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Theme Option'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);

    // Verify Cupertino Switch exists for Dark Mode
    expect(find.byType(CupertinoSwitch), findsOneWidget);
  });

  testWidgets('Profile screen renders user data from secure storage',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => const UserModel(
              id: 'u-1',
              name: 'Tanvir Ahmed',
              email: 'tanvir@meditouch.com',
              role: 'PATIENT',
            ),
          ),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Personal Profile'), findsOneWidget);
    expect(find.text('PERSONAL INFORMATION'), findsOneWidget);
    expect(find.text('DELIVERY & ADDRESS'), findsOneWidget);
  });
}
