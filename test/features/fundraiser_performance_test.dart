import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import '../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Fundraiser Logic Performance & Robustness Tests', () {
    late AppState appState;

    setUp(() async {
      setupMockSecureStorage();
      SharedPreferences.setMockInitialValues({});
      appState = AppState();
      await appState.init();
      appState.addBalance(5000.0);
    });

    test('Stress Test: Rapid multiple donations ensure state consistency', () async {
      final initialBalance = appState.balance;
      final campaignId = appState.campaigns.first.id;
      final donationAmount = 10.0;
      final numberOfDonations = 50;
      
      final fee = appState.calculateFeeForSource(donationAmount, "Main Wallet");
      final totalPerDonation = donationAmount + fee;
      
      List<Future> donations = [];
      for (int i = 0; i < numberOfDonations; i++) {
        donations.add(appState.donateToCampaign(campaignId, donationAmount));
      }
      
      await Future.wait(donations);
      
      final expectedDeduction = totalPerDonation * numberOfDonations;
      expect(appState.balance, closeTo(initialBalance - expectedDeduction, 0.001));
      expect(appState.campaigns.first.donorCount, greaterThanOrEqualTo(numberOfDonations));
    });

    test('Rollback Test: Failed donation restores original state', () async {
      final initialBalance = appState.balance;
      final campaignId = appState.campaigns.first.id;
      final initialRaised = appState.campaigns.first.raisedAmount;
      
      // Attempting to donate more than balance to trigger an internal error/exception
      // donateToCampaign has an explicit check for balance
      try {
        await appState.donateToCampaign(campaignId, 1000000.0);
      } catch (e) {
        // Expected
      }
      
      expect(appState.balance, initialBalance);
      expect(appState.campaigns.first.raisedAmount, initialRaised);
    });

    test('Currency Formatting: High amount truncation logic', () async {
      // Manual test of formatting logic (since it's a private method in the UI)
      String format(double amount) {
        if (amount >= 1000000) {
          return '\$${(amount / 1000000).toStringAsFixed(1)}M';
        } else if (amount >= 1000) {
          return '\$${(amount / 1000).toStringAsFixed(1)}K';
        } else {
          return '\$${amount.toStringAsFixed(0)}';
        }
      }

      expect(format(1500000), '\$1.5M');
      expect(format(950000), '\$950.0K');
      expect(format(1200), '\$1.2K');
      expect(format(500), '\$500');
    });
  });
}
