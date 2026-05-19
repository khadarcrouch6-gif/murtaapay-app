import 'package:flutter_test/flutter_test.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:murtaaxpay_app/core/models/hagbad_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppState appState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appState = AppState();
    // Since it's a singleton, we might need to reset its internal state if possible,
    // but AppState doesn't provide a reset method. 
    // For unit tests, it's better if it wasn't a strict singleton or had a reset.
    // However, we'll work with what we have.
    await appState.init();
  });

  group('Hagbad Lifecycle Tests', () {
    test('Should create a Hagbad group and manage lifecycle', () async {
      final groupId = 'test-group-123';
      final newGroup = HagbadGroup(
        id: groupId,
        name: "Test Group",
        adminName: "Admin",
        amount: 100.0,
        frequency: HagbadFrequency.monthly,
        status: HagbadStatus.pending,
        startDate: DateTime.now(),
        totalCycles: 2,
        currentCycle: 1,
        members: [
          HagbadMember(
            name: "Admin",
            walletId: "102234",
            hasReceived: false,
            isTrusted: true,
            avatar: "A",
            payoutOrder: 0,
            isConfirmed: true,
            hasSignedOath: true,
          ),
          HagbadMember(
            name: "User 2",
            walletId: "102235",
            hasReceived: false,
            isTrusted: true,
            avatar: "U",
            payoutOrder: 0,
            isConfirmed: false,
            hasSignedOath: false,
          ),
        ],
      );

      appState.createHagbadGroup(newGroup);
      expect(appState.hagbadGroups.any((g) => g.id == groupId), true);

      // 1. Confirm Member 2
      final groupIndex = appState.hagbadGroups.indexWhere((g) => g.id == groupId);
      var member2 = appState.hagbadGroups[groupIndex].members[1];
      appState.updateHagbadMember(groupId, 1, member2.copyWith(isConfirmed: true, hasSignedOath: true));
      
      expect(appState.hagbadGroups[groupIndex].members[1].isConfirmed, true);
      expect(appState.hagbadGroups[groupIndex].members[1].hasSignedOath, true);

      // 2. Randomize Turns (Qori-tuur)
      appState.randomizeHagbadTurns(groupId);
      
      final randomizedGroup = appState.hagbadGroups.firstWhere((g) => g.id == groupId);
      expect(randomizedGroup.status, HagbadStatus.active);
      expect(randomizedGroup.members[0].payoutOrder, isNot(0));
      expect(randomizedGroup.members[1].payoutOrder, isNot(0));
      expect(randomizedGroup.members[0].payoutOrder != randomizedGroup.members[1].payoutOrder, true);

      // 3. Contribution
      // Initial balance is set in AppState.init() or defaults. 
      // Default in AppState is 12450.80 if not in prefs.
      double initialBalance = appState.balance;
      await appState.payHagbad(groupId, 0, 100.0);
      await appState.payHagbad(groupId, 1, 100.0);
      
      expect(appState.balance, initialBalance - 200.0);
      expect(appState.hagbadGroups[groupIndex].currentBalance, 200.0);

      // 4. Payout
      // Current cycle is 1. The member with payoutOrder 1 should receive it.
      final memberWithTurn1 = appState.hagbadGroups[groupIndex].members.firstWhere((m) => m.payoutOrder == 1);
      final memberName = memberWithTurn1.name;
      
      await appState.processHagbadPayout(groupId);
      
      final groupAfterPayout = appState.hagbadGroups.firstWhere((g) => g.id == groupId);
      final paidMember = groupAfterPayout.members.firstWhere((m) => m.name == memberName);
      
      expect(paidMember.hasReceived, true);
      expect(groupAfterPayout.currentCycle, 2);

      // Check balance update if "Me" (Admin in this test is mapped to wallet 102234 which is Me)
      // Note: AppState logic checks if name is "Me" or "Khadar". 
      // In our test we used "Admin". Let's check how "Me" is determined.
      // In AppState: if (member.name == "Me" || member.name == "Khadar") { ... }
    });
  });
}
