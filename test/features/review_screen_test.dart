import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:murtaaxpay_app/features/send_money/review_screen.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReviewScreen Widget Tests', () {
    late AppState appState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      appState = AppState();
      await appState.init();
    });

    Widget createReviewScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: appState),
        ],
        child: ResponsiveBreakpoints.builder(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const Scaffold(
              body: ReviewScreen(
                amount: '100.00',
                receiverName: 'Mohamed Abdi Ali',
                receiverPhone: '204456',
                method: 'Wallet Transfer',
                paymentMethod: 'Main Wallet',
                currencyCode: 'USD',
                purpose: 'Dinner Payment',
              ),
            ),
          ),
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          ],
        ),
      );
    }

    testWidgets('ReviewScreen displays correct transfer metadata', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createReviewScreen());
      await tester.pumpAndSettle();

      // Check for receiver name
      expect(find.text('Mohamed Abdi Ali'), findsOneWidget);
      
      // Check for receiver phone/ID
      expect(find.text('204456'), findsOneWidget);
      
      // Check for amount (Format might vary, but usually contains the number)
      expect(find.textContaining('100.00'), findsWidgets);
      
      // Check for purpose logic if visible (ReviewScreen might not show it explicitly in the summary row but it's passed)
      // Looking at the code, it shows it in the Success screen mostly, but let's check the SummaryRows.
      // In details card:
      // _buildSummaryRow(l10n.receiver, widget.receiverName, Icons.person_outline),
      
      expect(find.text('Wallet Transfer'), findsOneWidget);
      expect(find.text('Main Wallet'), findsOneWidget);
    });

    testWidgets('PIN verification logic on ReviewScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createReviewScreen());
      await tester.pumpAndSettle();

      // Tap Confirm and Pay
      final confirmButton = find.byType(ElevatedButton);
      expect(confirmButton, findsOneWidget);
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // PIN field should appear
      expect(find.byType(TextField), findsOneWidget);
      
      // Enter incorrect PIN
      await tester.enterText(find.byType(TextField), '0000');
      await tester.pump(); // TextField onChanged triggers verification if length is 4

      // Wait for any snackbar - pump more to let it show
      await tester.pump(const Duration(milliseconds: 500));
      // The code uses state.translate("Invalid PIN", "PIN-ku waa khalad")
      // In tests with 'en' locale, it should return "Invalid PIN"
      expect(find.text('Invalid PIN'), findsOneWidget);
    });

    testWidgets('Successful transfer simulation on ReviewScreen', (WidgetTester tester) async {
      // Use a larger viewport to ensure buttons are clickable
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createReviewScreen());
      await tester.pumpAndSettle();

      final confirmButton = find.byType(ElevatedButton);
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      final pinField = find.byType(TextField);
      await tester.enterText(pinField, '1234');
      await tester.pump(); 

      // Wait for the simulated API delay (2s) + processing animation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Successful!'), findsOneWidget);
    });
  });
}
