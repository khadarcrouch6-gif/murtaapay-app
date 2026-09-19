import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_auth_helper.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/pin_entry_dialog.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/widgets/failure_screen.dart';
import '../../core/models/bank_account.dart';
import '../navigation/main_navigation.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'mixins/withdrawal_logic_mixin.dart';

class UnifiedBankWithdrawScreen extends StatefulWidget {
  final String source; // "Wallet" or "Virtual Card"
  final String? cardId;
  final double? initialAmount;

  const UnifiedBankWithdrawScreen({
    super.key,
    required this.source,
    this.cardId,
    this.initialAmount,
  });

  @override
  State<UnifiedBankWithdrawScreen> createState() => _UnifiedBankWithdrawScreenState();
}

class _UnifiedBankWithdrawScreenState extends State<UnifiedBankWithdrawScreen> with WithdrawalLogicMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  
  String? _selectedPurpose;
  bool _isResolvingName = false;
  bool _saveBeneficiary = false;
  Timer? _debounce;
  final _formKey = GlobalKey<FormState>();

  final List<double> _quickAmounts = [10.0, 50.0, 100.0, 200.0, 500.0];

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context);
    
    final double balance = widget.source == "Wallet" 
        ? state.balance 
        : state.cards.firstWhere((c) => c.id == widget.cardId).balance;

    final double fee = _amount > 0 ? state.calculateFeeForSource(_amount, "Bank") : 0;
    final double totalDeduct = _amount + fee;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.bankTransfer, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(context, balance, state, l10n),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  _buildQuickAmountPresets(context),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  
                  if (state.savedBeneficiaries.isNotEmpty) ...[
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Saved Accounts", style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 12 * context.fontSizeFactor),
                    _buildSavedBeneficiaries(context, state),
                    SizedBox(height: 24 * context.fontSizeFactor),
                  ],

                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: EdgeInsets.only(left: 4 * context.fontSizeFactor),
                      child: Text(
                        state.translate("Select Somali Bank", "Dooro Bankiga Soomaaliga"),
                        style: TextStyle(fontSize: 15 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * context.fontSizeFactor),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: SizedBox(
                      height: 64 * context.fontSizeFactor,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildSomaliBankCard(context, "Salaam Somali Bank"),
                          _buildSomaliBankCard(context, "Premier Bank"),
                          _buildSomaliBankCard(context, "IBS Bank"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24 * context.fontSizeFactor),

                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Text("Recipient Bank Information", style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        _buildInputField(
                          context,
                          l10n.bankName,
                          Icons.account_balance_rounded,
                          _bankNameController,
                          hint: "e.g. Premier Bank, IBS, Chase",
                          validator: (v) => v!.isEmpty ? "Bank name is required" : null,
                        ),
                        SizedBox(height: 16 * context.fontSizeFactor),
                        _buildInputField(
                          context,
                          l10n.accountNumber,
                          Icons.numbers_rounded,
                          _accountNumberController,
                          isNumber: true,
                          hint: l10n.enterAccountNumber,
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Account number is required";
                            if (_bankNameController.text == "Salaam Somali Bank" && v.length != 10) {
                              return "Salaam Somali Bank account must be 10 digits";
                            }
                            if (_bankNameController.text == "Premier Bank" && v.length != 10) {
                              return "Premier Bank account must be 10 digits";
                            }
                            if (_bankNameController.text == "IBS Bank" && v.length != 12) {
                              return "IBS Bank account must be 12 digits";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16 * context.fontSizeFactor),
                        _buildInputField(
                          context,
                          l10n.accountName,
                          Icons.person_outline_rounded,
                          _accountNameController,
                          hint: l10n.fullName,
                          validator: (v) => v!.isEmpty ? "Account holder name is required" : null,
                        ),
                        SizedBox(height: 16 * context.fontSizeFactor),
                        _buildPurposeDropdown(theme, l10n),
                        SizedBox(height: 16 * context.fontSizeFactor),
                        _buildSaveBeneficiarySwitch(theme, l10n),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  _buildLimitBars(context, state, l10n),
                  SizedBox(height: 40 * context.fontSizeFactor),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 12 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: MaxWidthBox(
            maxWidth: 800,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWithdrawButton(context, l10n, state, balance, totalDeduct),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSomaliBankCard(BuildContext context, String bankName) {
    final theme = Theme.of(context);
    final isSelected = _bankNameController.text == bankName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _bankNameController.text = bankName;
        });
        triggerHapticSuccess();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
        padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 10 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(18 * context.fontSizeFactor),
          border: Border.all(
            color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_rounded, color: isSelected ? AppColors.accentTeal : AppColors.grey, size: 20 * context.fontSizeFactor),
            SizedBox(width: 10 * context.fontSizeFactor),
            Text(
              bankName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.accentTeal : theme.textTheme.bodyLarge?.color,
                fontSize: 14 * context.fontSizeFactor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountPresets(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _quickAmounts.map((amt) {
            final isSelected = _amount == amt;
            return GestureDetector(
              onTap: () {
                setState(() => _amountController.text = amt.toStringAsFixed(0));
                triggerHapticSuccess();
              },
              child: Container(
                margin: EdgeInsets.only(right: 10 * context.fontSizeFactor),
                padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 10 * context.fontSizeFactor),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentTeal : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? AppColors.accentTeal : AppColors.accentTeal.withValues(alpha: 0.2),
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                  ] : null,
                ),
                child: Text(
                  "\$${amt.toInt()}",
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.accentTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * context.fontSizeFactor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, AppState state, AppLocalizations l10n) {
    return FadeInDown(
      child: Center(
        child: MaxWidthBox(
          maxWidth: 600,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24 * context.fontSizeFactor),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.3),
                  blurRadius: 20 * context.fontSizeFactor,
                  offset: Offset(0, 10 * context.fontSizeFactor),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (widget.source == "Wallet" ? l10n.walletBalance : l10n.virtualCardBalance).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11 * context.fontSizeFactor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Icon(Icons.account_balance_wallet_outlined, color: Colors.white.withValues(alpha: 0.5), size: 20 * context.fontSizeFactor),
                  ],
                ),
                SizedBox(height: 8 * context.fontSizeFactor),
                Text(
                  NumberFormat.simpleCurrency(name: state.currencyCode).format(balance),
                  style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24 * context.fontSizeFactor),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("\$", 
                            style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                          SizedBox(width: 12 * context.fontSizeFactor),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                              onChanged: (val) => setState(() {}),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "0.00",
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                contentPadding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final double feeRate = state.calculateFeeForSource(100, "Bank") / 100;
                              final double maxAmount = balance / (1 + feeRate);
                              _amountController.text = maxAmount.toStringAsFixed(2);
                              setState(() {});
                              triggerHapticSuccess();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(l10n.maxLabel, style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w900, fontSize: 12 * context.fontSizeFactor)),
                          ),
                        ],
                      ),
                      if (_amount > 0)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Fee: ${NumberFormat.simpleCurrency(name: state.currencyCode).format(state.calculateFeeForSource(_amount, "Bank"))}",
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12 * context.fontSizeFactor),
                              ),
                              Text(
                                "Total: ${NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount + state.calculateFeeForSource(_amount, "Bank"))}",
                                style: TextStyle(color: AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedBeneficiaries(BuildContext context, AppState state) {
    return SizedBox(
      height: 80 * context.fontSizeFactor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: state.savedBeneficiaries.length,
        itemBuilder: (context, index) {
          final beneficiary = state.savedBeneficiaries[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _bankNameController.text = beneficiary.bankName;
                _accountNumberController.text = beneficiary.accountNumber;
                _accountNameController.text = beneficiary.accountHolder ?? "";
              });
              triggerHapticSuccess();
            },
            child: Container(
              margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
              padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))
                ]
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22 * context.fontSizeFactor,
                    backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                    child: Text(
                      (beneficiary.accountHolder != null && beneficiary.accountHolder!.isNotEmpty) ? beneficiary.accountHolder![0].toUpperCase() : "?",
                      style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor),
                    ),
                  ),
                  SizedBox(width: 12 * context.fontSizeFactor),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(beneficiary.accountHolder ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                      Text(beneficiary.bankName, style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, IconData icon, TextEditingController controller, {bool isNumber = false, String? hint, bool isLoading = false, String? Function(String?)? validator}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * context.fontSizeFactor),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13 * context.fontSizeFactor, color: AppColors.grey)),
        ),
        SizedBox(height: 8 * context.fontSizeFactor),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.hintColor.withValues(alpha: 0.4), fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 22 * context.fontSizeFactor),
            suffixIcon: isLoading ? Container(
              padding: EdgeInsets.all(14 * context.fontSizeFactor),
              width: 24 * context.fontSizeFactor,
              height: 24 * context.fontSizeFactor,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accentTeal),
            ) : null,
            filled: true,
            fillColor: theme.cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18 * context.fontSizeFactor), 
              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05))
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18 * context.fontSizeFactor), 
              borderSide: const BorderSide(color: AppColors.accentTeal, width: 2)
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 18 * context.fontSizeFactor),
          ),
          onChanged: (val) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPurposeDropdown(ThemeData theme, AppLocalizations l10n) {
    final purposes = getPurposes(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * context.fontSizeFactor),
          child: Text(l10n.purposeOfRemittance, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13 * context.fontSizeFactor, color: AppColors.grey)),
        ),
        SizedBox(height: 8 * context.fontSizeFactor),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18 * context.fontSizeFactor),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPurpose,
            hint: Text(l10n.other, style: TextStyle(fontSize: 15 * context.fontSizeFactor, fontWeight: FontWeight.normal)),
            dropdownColor: theme.cardColor,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.accentTeal),
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.info_outline_rounded, color: AppColors.accentTeal, size: 22 * context.fontSizeFactor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14 * context.fontSizeFactor, horizontal: 16 * context.fontSizeFactor),
            ),
            items: purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (val) => setState(() => _selectedPurpose = val),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveBeneficiarySwitch(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 10 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18 * context.fontSizeFactor),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: AppColors.accentTeal, size: 22 * context.fontSizeFactor),
              SizedBox(width: 14 * context.fontSizeFactor),
              Text(l10n.saveBeneficiary, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14 * context.fontSizeFactor)),
            ],
          ),
          Switch.adaptive(
            value: _saveBeneficiary,
            onChanged: (val) => setState(() => _saveBeneficiary = val),
            activeColor: AppColors.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitBars(BuildContext context, AppState state, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    final currency = state.currencyCode;

    return Column(
      children: [
        _buildLimitProgress(
          context,
          state: state,
          title: state.translate("Daily Limit", "Xadka Maalinta"),
          spent: state.getDailySpent(),
          limit: state.dailyLimit,
          remaining: state.getDailyRemaining(),
          currency: currency,
          theme: theme,
          scale: scale,
        ),
        SizedBox(height: 12 * scale),
        _buildLimitProgress(
          context,
          state: state,
          title: state.translate("Monthly Limit", "Xadka Bisha"),
          spent: (state.monthlyLimit - state.getMonthlyRemaining()),
          limit: state.monthlyLimit,
          remaining: state.getMonthlyRemaining(),
          currency: currency,
          theme: theme,
          scale: scale,
        ),
      ],
    );
  }

  Widget _buildLimitProgress(
    BuildContext context, {
    required AppState state,
    required String title,
    required double spent,
    required double limit,
    required double remaining,
    required String currency,
    required ThemeData theme,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w800, color: AppColors.grey),
              ),
              Text(
                "${NumberFormat.simpleCurrency(name: currency).format(spent)} / ${NumberFormat.simpleCurrency(name: currency).format(limit)}",
                style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          ClipRRect(
            borderRadius: BorderRadius.circular(10 * scale),
            child: LinearProgressIndicator(
              value: (spent / limit).clamp(0.0, 1.0),
              backgroundColor: theme.dividerColor.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                (spent / limit) > 0.9 ? Colors.redAccent : theme.colorScheme.secondary,
              ),
              minHeight: 8 * scale,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            "${state.translate("Remaining", "Hambada")}: ${NumberFormat.simpleCurrency(name: currency).format(remaining)}",
            style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.bold, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton(BuildContext context, AppLocalizations l10n, AppState state, double balance, double totalDeduct) {
    final bool isDailyLimitExceeded = state.getDailySpent() + _amount > state.dailyLimit;
    final bool isMonthlyLimitExceeded = (state.monthlyLimit - state.getMonthlyRemaining()) + _amount > state.monthlyLimit;

    final bool isValid = _amount > 0 && 
                        totalDeduct <= balance && 
                        !isDailyLimitExceeded &&
                        !isMonthlyLimitExceeded &&
                        _formKey.currentState?.validate() == true;

    return Center(
      child: MaxWidthBox(
        maxWidth: 500,
        child: Column(
          children: [
            if (isDailyLimitExceeded)
              FadeInDown(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
                  child: Text(
                    l10n.dailyLimitExceeded(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.dailyLimit)),
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 13 * context.fontSizeFactor),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 60 * context.fontSizeFactor,
              child: ElevatedButton(
                onPressed: isValid ? () => _showReviewSheet(context, l10n, state) : null,
                style: context.elevatedButtonStyle().copyWith(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  elevation: WidgetStateProperty.all(8),
                ),
                child: Text(l10n.continueLabel, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, AppLocalizations l10n, AppState state) {
    final double fee = _amount > 0 ? state.calculateFeeForSource(_amount, "Bank") : 0;
    final double totalDeduct = _amount + fee;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Center(
          child: MaxWidthBox(
            maxWidth: 600,
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36 * context.fontSizeFactor)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 12 * context.fontSizeFactor),
                  Container(
                    width: 45 * context.fontSizeFactor, 
                    height: 5 * context.fontSizeFactor, 
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(28 * context.fontSizeFactor),
                      children: [
                        Center(
                          child: Text(
                            l10n.reviewWithdrawal, 
                            style: TextStyle(fontSize: 22 * context.fontSizeFactor, fontWeight: FontWeight.w900)
                          ),
                        ),
                        SizedBox(height: 28 * context.fontSizeFactor),
                        Container(
                          padding: EdgeInsets.all(24 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
                            border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            children: [
                              DetailRow(label: l10n.amount, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount)),
                              DetailRow(label: l10n.bankName, value: _bankNameController.text),
                              DetailRow(label: l10n.accountNumber, value: _accountNumberController.text),
                              DetailRow(label: l10n.accountName, value: _accountNameController.text),
                              DetailRow(label: "${l10n.fee}", value: NumberFormat.simpleCurrency(name: state.currencyCode).format(fee)),
                              DetailRow(label: "Est. Arrival", value: "Instant / 24h", valueColor: Colors.orange, isBold: true),
                              const Divider(height: 32),
                              DetailRow(
                                label: l10n.totalToPay, 
                                value: NumberFormat.simpleCurrency(name: state.currencyCode).format(totalDeduct),
                                valueColor: AppColors.accentTeal,
                                isBold: true,
                                valueSize: 18 * context.fontSizeFactor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(24 * context.fontSizeFactor),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60 * context.fontSizeFactor,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showPinDialog(context, l10n, state);
                          },
                          style: context.elevatedButtonStyle().copyWith(
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          ),
                          child: Text(l10n.confirm, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18 * context.fontSizeFactor)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _showPinDialog(BuildContext context, AppLocalizations l10n, AppState state) {
    final theme = Theme.of(context);
    final scaffoldContext = context;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PinEntryDialog(
        title: l10n.enterSecurityPin,
        description: l10n.enterTransactionPin,
        isBiometricEnabled: state.biometricEnabled,
        isCardPin: widget.source != "Wallet",
        cardId: widget.cardId,
        onValidate: (pin) async {
          if (pin == "BIOMETRIC_SUCCESS") return true;
          if (widget.source == "Wallet") {
            return state.verifyPin(pin);
          } else {
            return state.verifyCardPin(pin, cardId: widget.cardId);
          }
        },
        onConfirm: (pin) {
          if (mounted) {
            _process(scaffoldContext, theme, l10n, state);
          }
        },
      ),
    );
  }

  Future<void> _process(BuildContext scaffoldContext, ThemeData theme, AppLocalizations l10n, AppState state) async {
    final double fee = _amount > 0 ? state.calculateFeeForSource(_amount, "Bank") : 0;

    final List<String> steps = [
      l10n.verifyingAccount,
      "Performing security checks...",
      "Finalising transaction..",
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final scale = context.fontSizeFactor;
        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40 * scale),
            padding: EdgeInsets.all(36 * scale),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(30 * scale),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 15)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90 * scale,
                      height: 90 * scale,
                      child: CircularProgressIndicator(
                        color: AppColors.accentTeal,
                        strokeWidth: 4 * scale,
                        backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                      ),
                    ),
                    Icon(Icons.shield_rounded, color: AppColors.accentTeal, size: 36 * scale),
                  ],
                ),
                SizedBox(height: 32 * scale),
                _StepText(steps: steps),
                SizedBox(height: 14 * scale),
                Text(
                  l10n.pleaseWait,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8 * scale,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await Future.delayed(const Duration(seconds: 3));

      final tx = widget.source == "Wallet"
          ? await state.processWalletWithdrawal(
              amount: _amount,
              fee: fee,
              method: _bankNameController.text,
              detail: _accountNumberController.text,
              provider: _bankNameController.text,
              name: _accountNameController.text,
              type: "bank",
              status: "Pending", 
              purpose: _selectedPurpose ?? l10n.familySupport,
            )
          : await state.processCardWithdrawal(
              cardId: widget.cardId!,
              amount: _amount,
              fee: fee,
              method: _bankNameController.text,
              detail: _accountNumberController.text,
              provider: _bankNameController.text,
              name: _accountNameController.text,
              type: "bank",
              status: "Pending",
              purpose: _selectedPurpose ?? l10n.familySupport,
            );
      
      if (!mounted) return;
      
      if (_saveBeneficiary) {
        await state.saveBeneficiary(BankAccount(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          accountNumber: _accountNumberController.text,
          accountHolder: _accountNameController.text,
          bankName: _bankNameController.text,
        ));
      }

      if (mounted) {
        Navigator.of(scaffoldContext, rootNavigator: true).pop();
      }
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        scaffoldContext,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: "waa la helay fariintaada na sug 24hrs",
            message: "Your withdrawal of \$${_amount.toStringAsFixed(2)} to ${_bankNameController.text} has been initiated.",
            subtitle: "Processing Notice",
            subMessage: "Due to banking hours, transfers may take up to 24 hours to reflect in your account. You will be notified once it is completed.",
            buttonText: l10n.backToHome,
            transactionData: tx.toJson(),
            onPressed: () {
              state.setNavIndex(0);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) => false,
              );
            },
          ),
        ),
      );

      if (tx.status == "Pending") {
        Future.delayed(const Duration(seconds: 15), () {
          state.simulateTransactionCompletion(tx.id);
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(scaffoldContext, rootNavigator: true).pop();
      }
      
      if (!mounted) return;
      Navigator.push(
        scaffoldContext,
        MaterialPageRoute(
          builder: (context) => FailureScreen(
            title: l10n.transactionFailed,
            message: e.toString(),
            buttonText: l10n.tryAgain,
            onPressed: () => Navigator.pop(context), 
          ),
        ),
      );
    }
  }
}

class _StepText extends StatefulWidget {
  final List<String> steps;
  const _StepText({required this.steps});

  @override
  State<_StepText> createState() => _StepTextState();
}

class _StepTextState extends State<_StepText> {
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (mounted) {
        setState(() {
          if (_currentStep < widget.steps.length - 1) {
            _currentStep++;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    
    return FadeInUp(
      key: ValueKey(_currentStep),
      duration: const Duration(milliseconds: 500),
      child: Text(
        widget.steps[_currentStep],
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.textTheme.titleLarge?.color,
          fontSize: 18 * scale,
        ),
      ),
    );
  }
}
