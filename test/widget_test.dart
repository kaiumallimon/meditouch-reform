import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditouch/app/app.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('App initialization, login, and register navigation test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MediTouchApp(),
      ),
    );

    // Initial frame loads the clean SplashScreen
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

    // Fast-forward past animation and splash delay
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pumpAndSettle();

    // Navigated to LoginScreen
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Tap "Create Account" to navigate to RegisterScreen
    final createAccountLink = find.text('Create Account');
    await tester.ensureVisible(createAccountLink);
    await tester.tap(createAccountLink);
    await tester.pumpAndSettle();

    // Verify RegisterScreen elements (Headline + Button = 2 'Create Account' widgets)
    expect(find.text('Create Account'), findsNWidgets(2));
    expect(find.text('FULL NAME'), findsOneWidget);
    expect(find.text('PHONE NUMBER'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('CONFIRM PASSWORD'), findsOneWidget);

    // Scroll if needed and tap "Sign In" link to return to LoginScreen
    final signInLink = find.text('Sign In').last;
    await tester.ensureVisible(signInLink);
    await tester.tap(signInLink);
    await tester.pumpAndSettle();

    // Back to LoginScreen
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
