import 'package:flutter_test/flutter_test.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AppState.donateToCampaign Tests', () {
    late AppState appState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      appState = AppState();
      await appState.init();
      // Ensure enough balance for tests
      appState.addBalance(1000.0);
    });

    test('Donate using Main Wallet calculates and deducts fee correctly', () async {
      final initialBalance = appState.balance;
      final donationAmount = 100.0;
      final campaignId = appState.campaigns.first.id;
      
      final fee = appState.calculateFeeForSource(donationAmount, "Main Wallet");
      final totalExpected = donationAmount + fee;
      
      await appState.donateToCampaign(campaignId, donationAmount, paymentMethod: "Main Wallet");
      
      expect(appState.balance, initialBalance - totalExpected);
      expect(appState.transactions.first.numericAmount, donationAmount);
      expect(appState.transactions.first.fee, fee);
      expect(appState.transactions.first.paymentMethod, "Main Wallet");
    });

    test('Donate using Debit Card deducts from correct card', () async {
      final donationAmount = 50.0;
      final card = appState.cards.first;
      final initialCardBalance = card.balance;
      final campaignId = appState.campaigns.first.id;
      
      final fee = appState.calculateFeeForSource(donationAmount, "Debit Card", cardId: card.id);
      final totalExpected = donationAmount + fee;
      
      await appState.donateToCampaign(campaignId, donationAmount, paymentMethod: "Debit Card", cardId: card.id);
      
      final updatedCard = appState.cards.firstWhere((c) => c.id == card.id);
      expect(updatedCard.balance, initialCardBalance - totalExpected);
    });

    test('Donate using Mobile Money (External) does not deduct from internal balance', () async {
      final initialBalance = appState.balance;
      final donationAmount = 75.0;
      final campaignId = appState.campaigns.first.id;
      
      // EVC Plus is one of the mobileProviders in donateToCampaign
      await appState.donateToCampaign(campaignId, donationAmount, paymentMethod: "EVC Plus");
      
      // External methods shouldn't deduct from appState.balance
      expect(appState.balance, initialBalance);
      
      final tx = appState.transactions.first;
      expect(tx.paymentMethod, "EVC Plus");
      expect(tx.numericAmount, donationAmount);
      // Fee should still be calculated for the transaction record
      expect(tx.fee, appState.calculateFeeForSource(donationAmount, "EVC Plus"));
    });

    test('Donate with insufficient funds throws exception', () async {
      final donationAmount = 100000.0; // Extremely high amount
      final campaignId = appState.campaigns.first.id;
      
      expect(
        () async => await appState.donateToCampaign(campaignId, donationAmount, paymentMethod: "Main Wallet"),
        throwsA(isA<Exception>().having((e) => e.toString(), 'description', contains('insufficient_funds'))),
      );
    });
  });
}
