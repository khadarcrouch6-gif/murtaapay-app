import 'package:flutter_test/flutter_test.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:murtaaxpay_app/core/models/hagbad_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  group('Integrated Ecosystem End-to-End Tests', () {
    late AppState appState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      appState = AppState();
      await appState.init();
      
      // Reset state for the singleton instance (mocking initial state)
      appState.addBalance(1000.0 - appState.balance); // Start with exactly $1000 in wallet
    });

    test('Full Ecosystem Flow: Wallet -> Card -> Hagbad -> Sadaqah -> Payout', () async {
      // 1. Initial State Check
      expect(appState.balance, 1000.0);
      expect(appState.cards.length, 2);
      final initialCard1Balance = appState.cards[0].balance;

      // 2. Wallet to Card Transfer (Top-up Card)
      // Since AppState doesn't have a direct Wallet->Card method, 
      // we use withdrawFromSavings with toCard: true as a proxy if it were implemented that way,
      // but AppState.addCardBalance exists.
      // In UI, card top-up usually comes from Wallet.
      final topUpAmount = 200.0;
      appState.deductBalance(topUpAmount);
      await appState.addCardBalance(appState.cards[0].id, topUpAmount);
      
      expect(appState.balance, 800.0);
      expect(appState.cards[0].balance, initialCard1Balance + topUpAmount);

      // 3. Wallet to Hagbad (Contribution)
      // Create a group first
      final groupId = 'e2e-hagbad';
      final hagbadGroup = HagbadGroup(
        id: groupId,
        name: "E2E Group",
        adminName: "Me",
        amount: 100.0,
        frequency: HagbadFrequency.monthly,
        status: HagbadStatus.active,
        startDate: DateTime.now(),
        totalCycles: 2,
        currentCycle: 1,
        members: [
          HagbadMember(name: "Me", walletId: "102234", payoutOrder: 1, isConfirmed: true, hasSignedOath: true, hasReceived: false, isTrusted: true, avatar: "M"),
          HagbadMember(name: "Friend", walletId: "102235", payoutOrder: 2, isConfirmed: true, hasSignedOath: true, hasReceived: false, isTrusted: true, avatar: "F"),
        ],
      );
      appState.createHagbadGroup(hagbadGroup);
      
      await appState.payHagbad(groupId, 0, 100.0); // Me pays
      expect(appState.balance, 700.0);
      expect(appState.hagbadGroups.firstWhere((g) => g.id == groupId).members[0].paidAmount, 100.0);

      // 4. Wallet to Sadaqah (Donation)
      final campaignId = appState.campaigns.first.id;
      final initialRaised = appState.campaigns.first.raisedAmount;
      final donationAmount = 50.0;
      await appState.donateToCampaign(campaignId, donationAmount);
      
      expect(appState.balance, 650.0);
      expect(appState.campaigns.firstWhere((c) => c.id == campaignId).raisedAmount, initialRaised + donationAmount);

      // 5. Receive Hagbad Payout (Friend pays then Me receives)
      // Simulate Friend paying into the pool
      final gIdx = appState.hagbadGroups.indexWhere((g) => g.id == groupId);
      final updatedMembers = List<HagbadMember>.from(appState.hagbadGroups[gIdx].members);
      updatedMembers[1] = updatedMembers[1].copyWith(paidAmount: 100.0);
      // We manually update since processHagbadPayout checks pool balance
      // In real app, Friend would call payHagbad from their device.
      // Here we just need the group state to reflect the payment.
      appState.updateHagbadMember(groupId, 1, updatedMembers[1]);
      
      // Total pool = 200. Me is payoutOrder 1.
      final payoutAmount = 200.0 - appState.hagbadGroups[gIdx].serviceFee;
      await appState.processHagbadPayout(groupId);
      
      expect(appState.balance, 650.0 + payoutAmount);
      expect(appState.hagbadGroups.firstWhere((g) => g.id == groupId).members[0].hasReceived, true);
      expect(appState.hagbadGroups.firstWhere((g) => g.id == groupId).currentCycle, 2);

      // 6. Verify Transaction History
      expect(appState.transactions.any((tx) => tx.title.contains("Sadaqah")), true);
      expect(appState.transactions.any((tx) => tx.title.contains("Hagbad")), true);
      expect(appState.transactions.any((tx) => tx.title.contains("Payout")), true);
    });
  });
}
