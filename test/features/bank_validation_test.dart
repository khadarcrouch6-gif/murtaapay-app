import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:murtaaxpay_app/features/withdraw/mixins/withdrawal_logic_mixin.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import '../test_helper.dart';

// A dummy widget to test the mixin
class ValidationTestWidget extends StatefulWidget {
  const ValidationTestWidget({super.key});
  @override
  State<ValidationTestWidget> createState() => _ValidationTestWidgetState();
}

class _ValidationTestWidgetState extends State<ValidationTestWidget> with WithdrawalLogicMixin {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  group('Bank and Mobile Money Validation Tests', () {
    late _ValidationTestWidgetState state;

    setUp(() {
      state = _ValidationTestWidgetState();
    });

    test('Somali Bank Account Length Validation', () {
      expect(state.getBankAccountNumberLength('IBS Bank'), 12);
      expect(state.getBankAccountNumberLength('Premier Bank'), 10);
      expect(state.getBankAccountNumberLength('Salaam Bank'), 10);
      expect(state.getBankAccountNumberLength('Amal Bank'), 10);
      expect(state.getBankAccountNumberLength('MyBank'), 10);
      expect(state.getBankAccountNumberLength('Unknown Bank'), 16);
    });

    test('SWIFT/BIC Code Validation', () {
      // 8 characters
      expect(state.isValidSwiftCode('ABCCUS44'), true);
      // 11 characters
      expect(state.isValidSwiftCode('ABCCUS44XXX'), true);
      // Invalid length
      expect(state.isValidSwiftCode('ABCCUS'), false);
      expect(state.isValidSwiftCode('ABCCUS44XXXX'), false);
      // Invalid characters
      expect(state.isValidSwiftCode('ABC!US44'), false);
    });

    testWidgets('Mobile Money Provider Detection', (tester) async {
      await tester.pumpWidget(createTestableWidget(const ValidationTestWidget()));
      final BuildContext context = tester.element(find.byType(ValidationTestWidget));
      final l10n = AppLocalizations.of(context)!;

      expect(state.detectProvider('615123456', l10n), l10n.evcPlus);
      expect(state.detectProvider('775123456', l10n), l10n.evcPlus);
      expect(state.detectProvider('685123456', l10n), l10n.evcPlus);
      expect(state.detectProvider('635123456', l10n), l10n.zaad);
      expect(state.detectProvider('655123456', l10n), l10n.edahab);
      expect(state.detectProvider('905123456', l10n), l10n.sahal);
      expect(state.detectProvider('125123456', l10n), null);
    });

    testWidgets('Mobile Money Prefix Error Messages', (tester) async {
      await tester.pumpWidget(createTestableWidget(const ValidationTestWidget()));
      final BuildContext context = tester.element(find.byType(ValidationTestWidget));
      final l10n = AppLocalizations.of(context)!;

      // EVC Plus correct
      expect(state.getWithdrawPrefixError('6123456', l10n.evcPlus, l10n), null);
      // EVC Plus incorrect
      expect(state.getWithdrawPrefixError('6523456', l10n.evcPlus, l10n), contains('EVC Plus prefix must be 61, 77 or 68'));

      // ZAAD correct
      expect(state.getWithdrawPrefixError('6323456', l10n.zaad, l10n), null);
      // ZAAD incorrect
      expect(state.getWithdrawPrefixError('6123456', l10n.zaad, l10n), contains('ZAAD prefix must be 63'));
    });
  });
}
