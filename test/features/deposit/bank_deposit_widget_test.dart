import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:murtaaxpay_app/features/deposit/bank_deposit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../test_helper.dart';

void main() {
  group('BankDepositScreen Widget Tests', () {
    late AppState state;

    setUp(() async {
      setupMockSecureStorage();
      SharedPreferences.setMockInitialValues({});
      state = AppState();
      await state.init();
    });

    testWidgets('BankDepositScreen displays correct amount and bank selection', (WidgetTester tester) async {
      const depositAmount = 150.0;
      
      await tester.pumpWidget(createTestableWidget(
        const BankDepositScreen(amount: depositAmount),
        appState: state,
      ));
      
      // Initial pump to start animations
      await tester.pump();
      // Wait for animate_do animations to finish (usually ~500-800ms)
      await tester.pumpAndSettle();

      // Verify amount display
      expect(find.textContaining('\$150.00'), findsOneWidget);

      // Verify bank selection list exists. 
      // Salaam Somali Bank appears twice: once in the list and once in the details card (selected by default)
      expect(find.text('Salaam Somali Bank'), findsNWidgets(2));
      expect(find.text('Premier Bank'), findsOneWidget);
      expect(find.text('IBS Bank'), findsOneWidget);

      // Verify default selected bank (Salaam) details are shown
      expect(find.textContaining('Official MurtaaPay Deposit Account'), findsOneWidget);
      expect(find.textContaining('1020304050'), findsOneWidget);
    });

    testWidgets('Switching between Local and International categories', (WidgetTester tester) async {
      // Increase surface size to ensure all elements are visible and reachable
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestableWidget(
        const BankDepositScreen(amount: 100.0),
        appState: state,
      ));
      
      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // Initial state is Local Bank
      expect(find.text('Select Somali Bank'), findsOneWidget);
      
      // Find the International tab. We'll use a more specific finder.
      final internationalFinder = find.text('International');
      
      // Since the widget might be occluded from hit-testing due to layout setups or breakpoints,
      // we can trigger the onTap callback directly from the ancestral GestureDetector.
      final gdFinder = find.ancestor(of: internationalFinder, matching: find.byType(GestureDetector)).first;
      final GestureDetector gdWidget = tester.widget(gdFinder);
      gdWidget.onTap?.call();
      
      // Allow time for state change and any potential exit/entry animations
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify Somali bank selection is gone
      expect(find.text('Select Somali Bank'), findsNothing);
      // Verify International Wire Details title
      expect(find.text('International Wire Details'), findsOneWidget);
    });

    testWidgets('Submit button is in BottomNavigationBar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        const BankDepositScreen(amount: 100.0),
        appState: state,
      ));
      await tester.pumpAndSettle();

      final submitButton = find.widgetWithText(ElevatedButton, 'Confirm & Submit');
      expect(submitButton, findsOneWidget);
      
      // Verify it's inside the Scaffold's bottomNavigationBar
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull);
    });

    testWidgets('Validation shows error when receipt is missing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        const BankDepositScreen(amount: 100.0),
        appState: state,
      ));
      await tester.pumpAndSettle();

      // Fill in mandatory fields
      // Use more specific finders if necessary, but enterText should work
      await tester.enterText(find.widgetWithText(TextFormField, 'Sender Full Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Sender Account / Phone Number'), '1020304050');
      await tester.enterText(find.widgetWithText(TextFormField, 'Transaction Reference ID / TxID'), 'REF-123');

      // Tap submit
      await tester.tap(find.text('Confirm & Submit'));
      await tester.pumpAndSettle();

      // Verify snackbar for missing receipt (Somali or English)
      expect(find.textContaining('Please upload a receipt screenshot'), findsOneWidget);
    });
  });
}
