import 'package:flutter_test/flutter_test.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:murtaaxpay_app/core/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Pay Bills Integration Tests', () {
    late AppState appState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      appState = AppState();
      await appState.init();
      // Reset state for the singleton instance
      appState.addBalance(1000.0 - appState.balance);
    });

    test('Successful Bill Payment from Main Wallet', () async {
      const amount = 50.0;
      final initialBalance = appState.balance;
      final expectedFee = appState.calculateFeeForSource(amount, "Main Wallet");
      final totalDeduction = amount + expectedFee;

      final tx = await appState.processBillPayment(
        category: "BECO",
        accountId: "12345678",
        amount: amount,
        l10nKey: "electricity",
        paymentMethod: "Main Wallet",
      );

      expect(appState.balance, closeTo(initialBalance - totalDeduction, 0.001));
      expect(tx.category, "Bills");
      expect(tx.title, "BECO");
      expect(tx.numericAmount, amount);
      expect(tx.fee, expectedFee);
      expect(appState.transactions.first.id, tx.id);
    });

    test('Successful Bill Payment from Virtual Card', () async {
      final card = appState.cards.first;
      final initialCardBalance = card.balance;
      const amount = 30.0;
      final expectedFee = appState.calculateFeeForSource(amount, "Debit Card");
      final totalDeduction = amount + expectedFee;

      final tx = await appState.processBillPayment(
        category: "Somali National University",
        accountId: "STU-999",
        amount: amount,
        l10nKey: "education",
        paymentMethod: "Debit Card",
        cardId: card.id,
      );

      final updatedCard = appState.cards.firstWhere((c) => c.id == card.id);
      expect(updatedCard.balance, closeTo(initialCardBalance - totalDeduction, 0.001));
      expect(tx.method, "Debit Card");
      expect(tx.fee, expectedFee);
    });

    test('Bill Payment from Savings Account should be blocked', () async {
      expect(
        () => appState.processBillPayment(
          category: "Water",
          accountId: "W-101",
          amount: 20.0,
          l10nKey: "water",
          paymentMethod: "Savings Account",
        ),
        throwsA(predicate((e) => e.toString().contains('Savings accounts cannot be used for bill payments'))),
      );
    });

    test('Insufficient funds should throw and rollback', () async {
      const amount = 2000.0;
      final initialBalance = appState.balance;

      expect(
        () => appState.processBillPayment(
          category: "Big Bill",
          accountId: "B-1",
          amount: amount,
          l10nKey: "internet",
          paymentMethod: "Main Wallet",
        ),
        throwsA(predicate((e) => e.toString().contains('insufficient_funds'))),
      );

      expect(appState.balance, initialBalance);
    });

    test('Verify Transaction ID and Reference generation', () async {
      final tx = await appState.processBillPayment(
        category: "Passport Fees",
        accountId: "PASS-XYZ-789",
        amount: 150.0,
        l10nKey: "govServices",
      );

      expect(tx.id, startsWith("TX-BILL-"));
      expect(tx.referenceId, startsWith("BILL-PASS-"));
      expect(tx.referenceId!.length, greaterThan(15));
    });
  });
}
