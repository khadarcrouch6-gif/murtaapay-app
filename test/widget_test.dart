// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:murtaaxpay_app/main.dart';
import 'package:murtaaxpay_app/core/app_state.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    final appState = AppState();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MurtaaxPayApp(appState: appState));

    // Wait for the splash screen to finish
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify that onboarding text is present
    expect(find.text('Send Money Home, Instantly'), findsWidgets);
  });
}
