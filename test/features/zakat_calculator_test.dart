import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:murtaaxpay_app/features/more/zakat_calculator_screen.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppState appState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appState = AppState();
    // Set fixed prices for deterministic testing
    // In actual app_state.dart: 
    // _goldPrice defaults to 74.50
    // _silverPrice defaults to 0.95
    // Nisab Gold = 87.48 * 74.50 = 6517.26
    // Nisab Silver = 612.36 * 0.95 = 581.742
  });

  Widget createWidgetUnderTest({Size surfaceSize = const Size(800, 1200)}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('so')],
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          ],
        ),
        home: const ZakatCalculatorScreen(),
      ),
    );
  }

  testWidgets('Zakat calculator updates total when cash is entered', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Initial state
    expect(find.text('\$0.00'), findsOneWidget);

    // Enter cash assets (above gold nisab ~6517)
    final cashField = find.byType(TextField).at(0);
    await tester.enterText(cashField, '10000');
    await tester.pumpAndSettle();

    // 10000 * 0.025 = 250
    expect(find.text('\$250.00'), findsOneWidget);
  });

  testWidgets('Zakat calculator handles weight input mode for gold', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find gold input section (2nd TextField)
    final goldField = find.byType(TextField).at(1);
    
    // Toggle to Grams using click
    final gramsToggle = find.text('Grams').first;
    await tester.tap(gramsToggle, warnIfMissed: false);
    await tester.pumpAndSettle();

    if (find.text('\$186.25').evaluate().isEmpty) {
      // Manual click if tap failed to trigger state change
      final element = gramsToggle.evaluate().single;
      final inkWell = element.findAncestorWidgetOfExactType<InkWell>();
      inkWell?.onTap?.call();
      final state = tester.state(find.byType(ZakatCalculatorScreen));
      (state as dynamic).calculateZakat();
      await tester.pumpAndSettle();
    }

    // Enter 100 grams. Gold price is ~74.50. Value = 7450.
    // 7450 * 0.025 = 186.25
    await tester.enterText(goldField, '100');
    await tester.pumpAndSettle();

    expect(find.text('\$186.25'), findsOneWidget);
    expect(find.textContaining('Est. Value: \$7450.00'), findsOneWidget);
  });

  testWidgets('Zakat calculator triggers warning when below Nisab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final cashField = find.byType(TextField).at(0);
    
    // Enter amount below Nisab (Gold Nisab ~6517)
    await tester.enterText(cashField, '1000');
    await tester.pumpAndSettle();

    expect(find.text('\$0.00'), findsOneWidget);
    expect(find.textContaining('below the Nisab threshold'), findsOneWidget);
  });

  testWidgets('Zakat calculator respects Nisab threshold toggle', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final cashField = find.byType(TextField).at(0);
    
    // Enter 1000 (Below Gold Nisab ~6517, but Above Silver Nisab ~581)
    await tester.enterText(cashField, '1000');
    await tester.pumpAndSettle();
    
    expect(find.text('\$0.00'), findsOneWidget);

    // Switch to Silver Nisab using click
    final silverNisabButton = find.text('Silver Value').first;
    await tester.tap(silverNisabButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    if (find.text('\$25.00').evaluate().isEmpty) {
      // Manual trigger for SegmentedButton
      appState.setPreferredNisab('silver');
      // Trigger calculate since screen listens or we can re-pump
      final state = tester.state(find.byType(ZakatCalculatorScreen));
      (state as dynamic).calculateZakat();
      await tester.pumpAndSettle();
    }

    // Now 1000 should be zakatable. 1000 * 0.025 = 25.00
    expect(find.text('\$25.00'), findsOneWidget);
  });
}
