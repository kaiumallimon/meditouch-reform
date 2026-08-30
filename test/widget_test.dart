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

  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MediTouchApp(),
      ),
    );

    // Initial frame loads the clean SplashScreen with centered logo and cupertino spinner
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

    // Fast-forward past animation and Future.delayed (2200ms)
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pumpAndSettle();

    // Navigated to LoginScreen
    expect(find.text('Welcome to MediTouch'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
