import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/pin_entry_dialog.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/widgets/failure_screen.dart';
import '../navigation/main_navigation.dart';
import '../../l10n/app_localizations.dart';
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
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _customBankController = TextEditingController();
  
  String? _selectedBank;
  String? _selectedPurpose;
  bool _isOtherBank = false;
  bool _isResolvingName = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }
    _accountNumberController.addListener(_onAccountNumberChanged);
  }

  void _onAccountNumberChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (mounted) _lookupAccountName();
    });
  }

  Future<void> _lookupAccountName() async {
    final accountNumber = _accountNumberController.text.trim();
    if (accountNumber.length < 6 || _selectedBank == null || _isOtherBank) return;

    setState(() => _isResolvingName = true);
    
    try {
      final state = Provider.of<AppState>(context, listen: false);
      final resolvedName = await state.resolveAccountName(
        accountNumber, 
        type: 'bank', 
        bankName: _selectedBank
      );

      if (mounted && resolvedName != null) {
        _accountNameController.text = resolvedName;
        triggerHapticSuccess();
      }
    } finally {
      if (mounted) setState(() => _isResolvingName = false);
    }
  }

  final List<Map<String, dynamic>> _popularBanks = [
    {"name": "IBS Bank", "logo": "assets/images/bank.png", "color": const Color(0xFFC62828)},
    {"name": "Premier Bank", "logo": "assets/images/bank.png", "color": const Color(0xFF01579B)},
    {"name": "Salaam Bank", "logo": "assets/images/bank.png", "color": const Color(0xFF2E7D32)},
    {"name": "Amal Bank", "logo": "assets/images/bank.png", "color": const Color(0xFFEF6C00)},
    {"name": "Dahabshil Bank", "logo": "assets/images/bank.png", "color": const Color(0xFF004D40)},
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _customBankController.dispose();
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

    final double feeRate = state.calculateFeeForSource(100, "Bank") / 100;
    final double fee = _amount > 0 ? (_amount * feeRate < 0.10 ? 0.10 : _amount * feeRate) : 0;
    final double totalDeduct = _amount + fee;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.bankTransfer, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(context, balance, state, l10n),
            SizedBox(height: 24 * context.fontSizeFactor),
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Text(l10n.selectBank, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 16 * context.fontSizeFactor),
            _buildBankSelector(context, l10n),
            if (_isOtherBank) ...[
              SizedBox(height: 16 * context.fontSizeFactor),
              FadeInDown(
                duration: const Duration(milliseconds: 300),
                child: _buildInputField(
                  context,
                  l10n.bankName,
                  Icons.business_rounded,
                  _customBankController,
                  hint: l10n.enterBankName,
                ),
              ),
            ],
            SizedBox(height: 16 * context.fontSizeFactor),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  _buildInputField(
                    context,
                    l10n.accountNumber,
                    Icons.numbers_rounded,
                    _accountNumberController,
                    isNumber: true,
                    hint: l10n.enterAccountNumber,
                  ),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  _buildInputField(
                    context,
                    l10n.accountName,
                    Icons.person_outline_rounded,
                    _accountNameController,
                    hint: l10n.fullName,
                    isLoading: _isResolvingName,
                  ),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  _buildPurposeDropdown(theme, l10n),
                ],
              ),
            ),
            SizedBox(height: 32 * context.fontSizeFactor),
            _buildWithdrawButton(context, l10n, state, balance, totalDeduct),
            SizedBox(height: 40 * context.fontSizeFactor),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, AppState state, AppLocalizations l10n) {
    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 8 * context.fontSizeFactor),
            Text(
              NumberFormat.simpleCurrency(name: state.currencyCode).format(balance),
              style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24 * context.fontSizeFactor),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Text("\$", style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                  SizedBox(width: 12 * context.fontSizeFactor),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      onChanged: (val) {
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0.00",
                        hintStyle: TextStyle(color: Colors.white30),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final feeRate = state.calculateFeeForSource(100, "Bank") / 100;
                      final maxAmount = balance / (1 + feeRate);
                      _amountController.text = maxAmount.toStringAsFixed(2);
                      setState(() {});
                    },
                    child: Text(l10n.maxLabel, style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankSelector(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      height: 100 * context.fontSizeFactor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularBanks.length + 1,
        itemBuilder: (context, index) {
          if (index == _popularBanks.length) {
            return _buildBankItem(
              context,
              l10n.other,
              null,
              Colors.grey,
              isSelected: _isOtherBank,
              onTap: () => setState(() {
                _selectedBank = "Other";
                _isOtherBank = true;
              }),
            );
          }
          final bank = _popularBanks[index];
          final isSelected = _selectedBank == bank["name"] && !_isOtherBank;
          return _buildBankItem(
            context,
            bank["name"],
            bank["logo"],
            bank["color"],
            isSelected: isSelected,
            onTap: () => setState(() {
              _selectedBank = bank["name"];
              _isOtherBank = false;
              _lookupAccountName();
            }),
          );
        },
      ),
    );
  }

  Widget _buildBankItem(BuildContext context, String name, String? logo, Color color, {required bool isSelected, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 85 * context.fontSizeFactor,
        margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
          border: Border.all(
            color: isSelected ? color : theme.dividerColor.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                logo != null ? Icons.account_balance_rounded : Icons.add_rounded,
                color: isSelected ? Colors.white : color,
                size: 24 * context.fontSizeFactor,
              ),
            ),
            SizedBox(height: 8 * context.fontSizeFactor),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10 * context.fontSizeFactor,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : theme.textTheme.bodyMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, IconData icon, TextEditingController controller, {bool isNumber = false, String? hint, bool isLoading = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
        SizedBox(height: 8 * context.fontSizeFactor),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
            suffixIcon: isLoading ? Container(
              padding: const EdgeInsets.all(12),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentTeal),
            ) : null,
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 16 * context.fontSizeFactor),
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
        Text(l10n.purposeOfRemittance, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
        SizedBox(height: 8 * context.fontSizeFactor),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPurpose,
            hint: Text(l10n.other, style: TextStyle(fontSize: 15 * context.fontSizeFactor)),
            dropdownColor: theme.cardColor,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.info_outline_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor, horizontal: 16 * context.fontSizeFactor),
            ),
            items: purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (val) => setState(() => _selectedPurpose = val),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawButton(BuildContext context, AppLocalizations l10n, AppState state, double balance, double totalDeduct) {
    final bool isValid = _amount > 0 && 
                        totalDeduct <= balance && 
                        _selectedBank != null && 
                        (!_isOtherBank || _customBankController.text.isNotEmpty) &&
                        _accountNumberController.text.isNotEmpty && 
                        _accountNameController.text.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56 * context.fontSizeFactor,
      child: ElevatedButton(
        onPressed: isValid ? () => _showReviewSheet(context, l10n, state) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
          elevation: 0,
        ),
        child: Text(l10n.continueLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, AppLocalizations l10n, AppState state) {
    final double feeRate = state.calculateFeeForSource(100, "Bank") / 100;
    final double fee = _amount > 0 ? (_amount * feeRate < 0.10 ? 0.10 : _amount * feeRate) : 0;
    final double totalDeduct = _amount + fee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40 * context.fontSizeFactor, height: 4 * context.fontSizeFactor, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            SizedBox(height: 24 * context.fontSizeFactor),
            Text(l10n.reviewWithdrawal, style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
            SizedBox(height: 24 * context.fontSizeFactor),
            Container(
              padding: EdgeInsets.all(20 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  DetailRow(label: l10n.amount, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount)),
                  DetailRow(label: l10n.bankName, value: _isOtherBank ? _customBankController.text : _selectedBank!),
                  DetailRow(label: l10n.accountNumber, value: _accountNumberController.text),
                  DetailRow(label: l10n.accountName, value: _accountNameController.text),
                  DetailRow(label: l10n.fee, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(fee)),
                  const Divider(),
                  DetailRow(
                    label: l10n.totalToPay, 
                    value: NumberFormat.simpleCurrency(name: state.currencyCode).format(totalDeduct),
                    valueColor: AppColors.accentTeal,
                    isBold: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32 * context.fontSizeFactor),
            SizedBox(
              width: double.infinity,
              height: 56 * context.fontSizeFactor,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showPinDialog(context, l10n, state);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                ),
                child: Text(l10n.confirm, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16 * context.fontSizeFactor)),
              ),
            ),
            SizedBox(height: 16 * context.fontSizeFactor),
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
        description: "",
        onConfirm: (pin) {
          bool verified = widget.source == "Wallet" 
              ? state.verifyPin(pin) 
              : state.verifyCardPin(pin, cardId: widget.cardId);
          
          if (verified) {
            _process(context, l10n, state);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.incorrectPin), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  void _process(BuildContext context, AppLocalizations l10n, AppState state) async {
    final theme = Theme.of(context);
    final double feeRate = state.calculateFeeForSource(100, "Bank") / 100;
    final double fee = _amount > 0 ? (_amount * feeRate < 0.10 ? 0.10 : _amount * feeRate) : 0;
    
    final List<String> steps = [
      l10n.verifyingAccount,
      l10n.checkingName,
      l10n.finalizingTransaction,
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      color: AppColors.accentTeal,
                      strokeWidth: 3,
                      backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                    ),
                  ),
                  Icon(Icons.account_balance_rounded, color: AppColors.accentTeal, size: 32),
                ],
              ),
              const SizedBox(height: 32),
              _StepText(steps: steps),
              const SizedBox(height: 12),
              Text(
                l10n.pleaseWait,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor.withValues(alpha: 0.6),
                  fontFamily: theme.textTheme.bodySmall?.fontFamily,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 3));

      final tx = widget.source == "Wallet"
          ? await state.processWalletWithdrawal(
              amount: _amount,
              fee: fee,
              method: _isOtherBank ? _customBankController.text : _selectedBank!,
              detail: _accountNumberController.text,
              provider: _isOtherBank ? "Other Bank" : _selectedBank!,
              name: _accountNameController.text,
              type: "bank",
              status: "Pending", // Status-ku waa Pending sidii aad rabtay
              purpose: _selectedPurpose ?? l10n.familySupport,
            )
          : await state.processCardWithdrawal(
              cardId: widget.cardId!,
              amount: _amount,
              fee: fee,
              method: _isOtherBank ? _customBankController.text : _selectedBank!,
              detail: _accountNumberController.text,
              provider: _isOtherBank ? "Other Bank" : _selectedBank!,
              name: _accountNameController.text,
              type: "bank",
              status: "Pending",
              purpose: _selectedPurpose ?? l10n.familySupport,
            );
      
      if (!mounted) return;
      
      // Marka hore xir dialog-ga loading-ka ah
      Navigator.of(context, rootNavigator: true).pop();
      
      // Ka dib u gudbi SuccessScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: l10n.withdrawalPending,
            message: l10n.withdrawalSuccessMessage(NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount)),
            subtitle: l10n.bankProcessingNotice,
            subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)),
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
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      
      if (!mounted) return;
      Navigator.push(
        context,
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
    _timer = Timer.periodic(const Duration(milliseconds: 1300), (timer) {
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
    return FadeInUp(
      key: ValueKey(_currentStep),
      duration: const Duration(milliseconds: 400),
      child: Text(
        widget.steps[_currentStep],
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.textTheme.titleLarge?.color,
        ),
      ),
    );
  }
}