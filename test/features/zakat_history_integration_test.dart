import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:murtaaxpay_app/features/history/history_screen.dart';
import 'package:murtaaxpay_app/core/models/transaction.dart' as model;
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppState appState;

  setUp(() async {
    setupMockSecureStorage();
    SharedPreferences.setMockInitialValues({});
    appState = AppState();
    await appState.init();
  });

  Widget createHistoryScreen() {
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
        home: const HistoryScreen(),
      ),
    );
  }

  testWidgets('Zakat donation from Wallet appears in History Feed', (WidgetTester tester) async {
    // 1. Setup initial state
    final initialBalance = appState.balance;
    const donationAmount = 100.0;
    final campaign = appState.campaigns.first;

    // 2. Perform donation logic (simulating what ZakatCalculatorScreen does)
    await appState.donateToCampaign(
      campaign.id,
      donationAmount,
      paymentMethod: "Main Wallet",
      message: "Zakat 2024",
    );

    // 3. Verify AppState updated
    // Fee for Wallet is 1% = 1.0
    expect(appState.balance, initialBalance - (donationAmount + 1.0));
    expect(appState.transactions.first.title.contains("Fundraiser"), true);
    expect(appState.transactions.first.numericAmount, donationAmount);

    // 4. Pump History Screen
    await tester.pumpWidget(createHistoryScreen());
    await tester.pumpAndSettle();

    // 5. Verify transaction appears in the list
    expect(find.textContaining("Fundraiser: ${campaign.title}"), findsOneWidget);
    
    // Check amount formatting (Negative for sent)
    final formattedAmount = "-${NumberFormat.simpleCurrency(name: 'USD').format(donationAmount + 1.0)}";
    expect(find.text(formattedAmount), findsOneWidget);
  });

  testWidgets('History Screen filters Zakat donation correctly', (WidgetTester tester) async {
    const donationAmount = 50.0;
    final campaign = appState.campaigns.first;

    await appState.donateToCampaign(
      campaign.id,
      donationAmount,
      paymentMethod: "Main Wallet",
    );

    await tester.pumpWidget(createHistoryScreen());
    await tester.pumpAndSettle();

    // Verify it's there in "All"
    expect(find.textContaining("Fundraiser: ${campaign.title}"), findsAtLeastNWidgets(1));

    // Switch to "Received" - should disappear
    await tester.tap(find.text("Received"));
    await tester.pumpAndSettle();
    expect(find.textContaining("Fundraiser: ${campaign.title}"), findsNothing);
    expect(find.text("No transactions found"), findsOneWidget);

    // Switch to "Sent" - should reappear
    await tester.tap(find.text("Sent"));
    await tester.pumpAndSettle();
    expect(find.textContaining("Fundraiser: ${campaign.title}"), findsAtLeastNWidgets(1));
  });
}
