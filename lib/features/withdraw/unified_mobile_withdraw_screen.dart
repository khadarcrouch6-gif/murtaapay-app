import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/widgets/failure_screen.dart';
import '../navigation/main_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/pin_entry_dialog.dart';
import 'mixins/withdrawal_logic_mixin.dart';

class UnifiedMobileWithdrawScreen extends StatefulWidget {
  final String source; // "Wallet" or "Virtual Card"
  final String? cardId;
  final double? initialAmount;

  const UnifiedMobileWithdrawScreen({
    super.key,
    required this.source,
    this.cardId,
    this.initialAmount,
  });

  @override
  State<UnifiedMobileWithdrawScreen> createState() => _UnifiedMobileWithdrawScreenState();
}

class _UnifiedMobileWithdrawScreenState extends State<UnifiedMobileWithdrawScreen> with WithdrawalLogicMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String? _selectedProvider;
  String? _selectedPurpose;
  String? _detectedName;

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context);
    
    final double balance = widget.source == "Wallet" 
        ? state.balance 
        : state.cards.firstWhere((c) => c.id == widget.cardId).balance;

    final double feeRate = state.calculateFeeForSource(100, "Mobile Money", payoutMethod: "Mobile Money") / 100;
    final double fee = _amount > 0 ? (_amount * feeRate < 0.10 ? 0.10 : _amount * feeRate) : 0;
    final double totalDeduct = _amount + fee;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.mobileMoney, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(context, balance, state, l10n),
            SizedBox(height: 32 * context.fontSizeFactor),
            FadeInUp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.selectProvider, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                  SizedBox(height: 12 * context.fontSizeFactor),
                  Wrap(
                    spacing: 12 * context.fontSizeFactor,
                    children: [l10n.evcPlus, l10n.edahab, l10n.zaad, l10n.sahal].map((p) => ChoiceChip(
                      label: Text(p),
                      selected: _selectedProvider == p,
                      onSelected: (val) => setState(() => _selectedProvider = val ? p : null),
                      selectedColor: AppColors.accentTeal.withValues(alpha: 0.2),
                      labelStyle: TextStyle(color: _selectedProvider == p ? AppColors.accentTeal : null, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                    )).toList(),
                  ),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  _buildRecentItems(context, state, l10n),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  _buildInputField(
                    context, 
                    l10n.phoneNumber, 
                    Icons.phone_android_rounded, 
                    _phoneController, 
                    isNumber: true, 
                    hint: "61xxxxxxx",
                    prefix: "+252 ",
                    maxLength: 9,
                    onChanged: (val) {
                      final provider = detectProvider(val, l10n);
                      if (provider != null) _selectedProvider = provider;
                      _detectedName = lookupName(val, state);
                      setState(() {});
                    },
                  ),
                  _buildErrorOrName(l10n),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  _buildPurposeDropdown(theme, l10n),
                  SizedBox(height: 32 * context.fontSizeFactor),
                  _buildWithdrawButton(context, l10n, state, balance, totalDeduct),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, AppState state, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * context.fontSizeFactor),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (widget.source == "Wallet" ? l10n.walletBalance : l10n.virtualCardBalance).toUpperCase(),
            style: TextStyle(color: Colors.white70, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          SizedBox(height: 8 * context.fontSizeFactor),
          Text(
            NumberFormat.simpleCurrency(name: state.currencyCode).format(balance),
            style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20 * context.fontSizeFactor),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Text(r"$", style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                SizedBox(width: 8 * context.fontSizeFactor),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "0.00",
                      hintStyle: TextStyle(color: Colors.white30),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final feeRate = state.calculateFeeForSource(100, "Mobile Money") / 100;
                    _amountController.text = (balance / (1 + feeRate)).toStringAsFixed(2);
                    setState(() {});
                  },
                  child: Text("MAX", style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItems(BuildContext context, AppState state, AppLocalizations l10n) {
    final recents = state.recentWithdrawals.where((e) => e['type'] == 'mobile').toList();
    final List<Map<String, String>> combined = [...recents];
    for (var profile in state.quickProfiles) {
      if (profile.walletId.length >= 9 && !combined.any((r) => r['detail'] == profile.walletId.replaceAll('252', ''))) {
        combined.add({
          'name': profile.name,
          'detail': profile.walletId.replaceAll('252', ''),
          'provider': profile.lastReceiverMethod ?? '',
        });
      }
    }

    if (combined.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recent, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        SizedBox(height: 8 * context.fontSizeFactor),
        SizedBox(
          height: 52 * context.fontSizeFactor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: combined.length,
            itemBuilder: (context, i) {
              final r = combined[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _phoneController.text = r["detail"]!;
                    if (r["provider"]?.isNotEmpty ?? false) _selectedProvider = r["provider"];
                    _detectedName = r["name"];
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 8 * context.fontSizeFactor),
                  padding: EdgeInsets.symmetric(horizontal: 14 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r["name"]!, style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                      Text(r["detail"]!, style: TextStyle(fontSize: 10 * context.fontSizeFactor, color: AppColors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorOrName(AppLocalizations l10n) {
    final error = getWithdrawPrefixError(_phoneController.text, _selectedProvider, l10n);
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, left: 4),
        child: Text(error, style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
      );
    }
    if (_detectedName != null && _phoneController.text.length >= 6) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, left: 12),
        child: Row(
          children: [
            Icon(Icons.person_outline_rounded, size: 16, color: AppColors.accentTeal),
            const SizedBox(width: 6),
            Text(_detectedName!, style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPurposeDropdown(ThemeData theme, AppLocalizations l10n) {
    final purposes = getPurposes(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.purposeOfRemittance, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
        SizedBox(height: 12 * context.fontSizeFactor),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPurpose ?? purposes.first,
            dropdownColor: theme.cardColor,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.info_outline_rounded, color: AppColors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            items: purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (val) => setState(() => _selectedPurpose = val),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawButton(BuildContext context, AppLocalizations l10n, AppState state, double balance, double totalDeduct) {
    final bool isFormValid = _amount > 0 && 
                           totalDeduct <= balance && 
                           _selectedProvider != null && 
                           _phoneController.text.length == 9 && 
                           getWithdrawPrefixError(_phoneController.text, _selectedProvider, l10n) == null;

    return SizedBox(
      width: double.infinity,
      height: 56 * context.fontSizeFactor,
      child: ElevatedButton(
        onPressed: isFormValid ? () => _showReviewSheet(context, l10n, state) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(l10n.confirmAndWithdraw, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, AppLocalizations l10n, AppState state) {
    final double feeRate = state.calculateFeeForSource(100, "Mobile Money") / 100;
    final double fee = _amount > 0 ? (_amount * feeRate < 0.10 ? 0.10 : _amount * feeRate) : 0;
    final double totalDeduct = _amount + fee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.reviewWithdrawal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            DetailRow(label: l10n.amount, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount)),
            DetailRow(label: l10n.method, value: _selectedProvider!),
            DetailRow(label: l10n.phoneNumber, value: "+252 ${_phoneController.text}"),
            DetailRow(label: l10n.feeLabel, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(fee)),
            DetailRow(label: l10n.totalDeduct, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(totalDeduct), valueColor: AppColors.accentTeal),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showPinDialog(context, l10n, state);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinDialog(BuildContext context, AppLocalizations l10n, AppState state) {
    showDialog(
      context: context,
      builder: (context) => PinEntryDialog(
        title: l10n.enterSecurityPin,
        description: l10n.enterTransactionPin,
        onConfirm: (pin) {
          bool verified = widget.source == "Wallet" 
              ? state.verifyPin(pin) 
              : state.verifyCardPin(pin, cardId: widget.cardId);
          
          if (verified) {
            _process(this.context, l10n, state);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.incorrectPin), backgroundColor: Colors.red));
          }
        },
      ),
    );
  }

  void _process(BuildContext context, AppLocalizations l10n, AppState state) async {
    final double feeRate = state.calculateFeeForSource(100, "Mobile Money") / 100;
    final double fee = _amount > 0 ? (_amount * feeRate < 0.10 ? 0.10 : _amount * feeRate) : 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accentTeal),
              const SizedBox(height: 24),
              Text(l10n.processing, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;
    Navigator.pop(context);

    try {
      final tx = widget.source == "Wallet"
          ? await state.processWalletWithdrawal(
              amount: _amount,
              fee: fee,
              method: "Mobile Money",
              detail: _phoneController.text,
              provider: _selectedProvider!,
              name: _detectedName ?? l10n.withdrawal,
              type: "mobile",
              purpose: _selectedPurpose ?? l10n.familySupport,
            )
          : await state.processCardWithdrawal(
              cardId: widget.cardId!,
              amount: _amount,
              fee: fee,
              method: "Mobile Money",
              detail: _phoneController.text,
              provider: _selectedProvider!,
              name: _detectedName ?? l10n.withdrawal,
              type: "mobile",
              purpose: _selectedPurpose ?? l10n.familySupport,
            );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: l10n.withdrawalRequested,
            message: l10n.withdrawalSuccessMessage(NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount)),
            buttonText: l10n.backToHome,
            transactionData: tx.toJson(),
            onPressed: () {
              state.setNavIndex(0);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false);
            },
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => FailureScreen(title: l10n.transactionFailed, message: e.toString(), buttonText: l10n.tryAgain, onPressed: () => Navigator.pop(context))));
    }
  }

  Widget _buildInputField(BuildContext context, String label, IconData icon, TextEditingController controller, {bool isNumber = false, String? hint, String? prefix, int? maxLength, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: "",
        prefixIcon: prefix != null 
            ? Padding(padding: const EdgeInsets.only(left: 12, top: 14), child: Text(prefix, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))
            : Icon(icon, color: AppColors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onChanged: onChanged,
    );
  }
}
