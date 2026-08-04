import 'package:flutter_test/flutter_test.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('P2P Payment Integration Tests', () {
    late AppState appState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      appState = AppState();
      await appState.init();
      // Reset state for the singleton instance
      appState.addBalance(1000.0 - appState.balance);
      await appState.updateDailyLimit(5000.0);
      await appState.updateMonthlyLimit(20000.0);
    });

    test('Successful internal wallet-to-wallet transfer', () async {
      const receiverId = '204456'; // Mohamed Abdi Ali
      const amount = 100.0;
      final initialBalance = appState.balance;
      final expectedFee = 0.50; // Wallet fee is fixed at $0.50 in current AppState logic
      final expectedTotal = amount + expectedFee;

      await appState.processP2PTransfer(
        receiverId: receiverId,
        amount: amount,
        currencyCode: 'USD',
        purpose: 'Dinner',
      );

      expect(appState.balance, closeTo(initialBalance - expectedTotal, 0.001));
      expect(appState.transactions.first.type, 'send');
      expect(appState.transactions.first.numericAmount, amount);
      expect(appState.transactions.first.fee, expectedFee);
    });

    test('Insufficient funds should throw exception and rollback', () async {
      const receiverId = '204456';
      final amount = appState.balance + 10.0;
      final initialBalance = appState.balance;

      expect(
        () => appState.processP2PTransfer(
          receiverId: receiverId,
          amount: amount,
          currencyCode: 'USD',
          purpose: 'Testing overflow',
        ),
        throwsA(predicate((e) => e.toString().contains('insufficient_funds'))),
      );

      expect(appState.balance, initialBalance);
    });

    test('Daily limit enforcement', () async {
      const receiverId = '204456';
      await appState.updateDailyLimit(50.0);
      const amount = 60.0;

      expect(
        () => appState.processP2PTransfer(
          receiverId: receiverId,
          amount: amount,
          currencyCode: 'USD',
          purpose: 'Limit test',
        ),
        throwsA(predicate((e) => e.toString().contains('daily_limit_exceeded'))),
      );
    });

    test('Monthly limit enforcement', () async {
      const receiverId = '204456';
      await appState.updateMonthlyLimit(500.0);
      const amount = 600.0;

      expect(
        () => appState.processP2PTransfer(
          receiverId: receiverId,
          amount: amount,
          currencyCode: 'USD',
          purpose: 'Monthly limit test',
        ),
        throwsA(predicate((e) => e.toString().contains('monthly_limit_exceeded'))),
      );
    });

    test('Atomic deduction from Virtual Card funding source', () async {
      final cardId = appState.cards.first.id;
      final initialCardBalance = appState.cards.first.balance;
      const amount = 50.0;

      // Use transferToSavings as a proxy for card deduction logic if there's no direct P2P from card yet
      // Or check ReviewScreen logic: it seems ReviewScreen just mocks non-wallet sources currently.
      // Let's test the Card deduction specifically if AppState supports it.
      await appState.deductCardBalance(cardId, amount);

      expect(appState.cards.first.balance, initialCardBalance - amount);
    });
    test('Bank Transfer fee should be 2.5%', () async {
      const receiverId = '204456';
      const amount = 200.0;
      const paymentMethod = 'Bank Transfer';
      
      final expectedFee = amount * 0.025; // 2.5%
      final initialBalance = appState.balance;

      await appState.processP2PTransfer(
        receiverId: receiverId,
        amount: amount,
        currencyCode: 'USD',
        purpose: 'Bank payment',
        paymentMethod: paymentMethod,
      );

      // Note: In AppState.processP2PTransfer, if it's NOT a card/savings/wallet source, 
      // it doesn't deduct from internal balance (as it's an external source).
      // However, it should still record the correct fee in the transaction.
      
      expect(appState.transactions.first.fee, expectedFee);
      expect(appState.transactions.first.numericAmount, amount);
      expect(appState.transactions.first.paymentMethod, paymentMethod);
      // For bank transfer, balance shouldn't change in this mock logic
      expect(appState.balance, initialBalance);
    });

    test('Mobile Money fee should be 0.99 flat', () async {
      const receiverId = '204456';
      const amount = 100.0;
      const paymentMethod = 'EVC Plus';
      
      const expectedFee = 0.99;

      await appState.processP2PTransfer(
        receiverId: receiverId,
        amount: amount,
        currencyCode: 'USD',
        purpose: 'Mobile payment',
        paymentMethod: paymentMethod,
      );

      expect(appState.transactions.first.fee, expectedFee);
    });
  });
}
