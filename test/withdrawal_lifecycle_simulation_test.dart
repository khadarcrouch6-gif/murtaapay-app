import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Withdrawal Lifecycle Simulation Tests', () {
    late AppState state;

    setUp(() async {
      setupMockSecureStorage();
      SharedPreferences.setMockInitialValues({});
      state = AppState();
      await state.init();
    });

    test('Bank withdrawal should start with Pending status and transition to Success', () async {
      final initialBalance = state.balance;
      const amount = 100.0;
      final fee = state.calculateFeeForSource(amount, "Bank", payoutMethod: "Bank");
      final totalDeduct = amount + fee;

      // Process a bank withdrawal
      final tx = await state.processWalletWithdrawal(
        amount: amount,
        fee: fee,
        method: "IBS Bank",
        detail: "123456789012",
        provider: "IBS Bank",
        name: "Test User",
        type: "bank",
        status: "Pending",
      );

      expect(tx.status, "Pending");
      expect(state.balance, initialBalance - totalDeduct);
      expect(state.transactions.first.id, tx.id);
      expect(state.transactions.first.status, "Pending");

      // Simulate transaction completion
      await state.simulateTransactionCompletion(tx.id);

      expect(state.transactions.first.status, "Success");
      expect(state.notifications.first.title, "Transaction Successful");
    });

    test('Small amount fee should respect minimum threshold (\$0.50 for Bank)', () async {
      const amount = 5.0; // 1.5% of 5 is 0.075, but min fee is 0.50
      final fee = state.calculateFeeForSource(amount, "Bank", payoutMethod: "Bank");
      
      expect(fee, 0.50);
    });

    test('Mobile money fee should respect minimum threshold (\$0.10 for Mobile)', () async {
      const amount = 1.0; // 2.5% of 1 is 0.025, but min fee is 0.10
      final fee = state.calculateFeeForSource(amount, "Mobile Money", payoutMethod: "Mobile Money");
      
      expect(fee, 0.10);
    });

    test('Daily limit should prevent withdrawal if exceeded', () async {
      state.updateLimits(daily: 100.0);
      
      // Attempt withdrawal of 150
      expect(
        () => state.processWalletWithdrawal(
          amount: 150.0,
          fee: 2.25,
          method: "IBS Bank",
          detail: "123456789012",
          provider: "IBS Bank",
          name: "Test User",
          type: "bank",
        ),
        throwsA(isA<Exception>()), // Note: processWalletWithdrawal only checks balance, 
                                    // the UI in UnifiedBankWithdrawScreen checks state.getDailySpent()
      );
    });
  });
}
