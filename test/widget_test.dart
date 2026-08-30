import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditouch/app/app.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MediTouchApp(),
      ),
    );

    // Initial frame loads the enhanced SplashScreen with branding
    expect(find.text('MediTouch'), findsOneWidget);
    expect(find.text('AI-Powered Healthcare & Pharmacy'), findsOneWidget);
    expect(find.text('Verified Healthcare & Telemedicine Platform'), findsOneWidget);

    // Fast-forward past animation and Future.delayed (2400ms)
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    // Navigated to LoginScreen
    expect(find.text('Welcome to MediTouch'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
