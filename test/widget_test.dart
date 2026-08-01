// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murtaaxpay_app/main.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:murtaaxpay_app/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    
    await tester.runAsync(() async {
      await appState.init();
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(MurtaaxPayApp(appState: appState));

    await tester.pump();
    // Use a large duration to skip the 2s delay in SplashScreen
    await tester.pump(const Duration(seconds: 5));
    
    // Process transition frames
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
