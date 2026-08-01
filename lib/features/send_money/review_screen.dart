import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/models/transaction.dart' as model;
import '../../core/models/quick_profile.dart' as model_quick;

import '../../core/widgets/pin_entry_dialog.dart';

class ReviewScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String method;
  final String paymentMethod;
  final String currencyCode;
  final String purpose;
  final String? sourceOfFunds;
  final String? swiftCode;
  final String? address;
  final String? city;
  final String? country;

  final String? cardId;

  const ReviewScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.method,
    required this.paymentMethod,
    required this.currencyCode,
    required this.purpose,
    this.sourceOfFunds,
    this.swiftCode,
    this.address,
    this.city,
    this.country,
    this.cardId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isProcessing = false;
  bool _isStkWaiting = false;
  bool _showPinField = false;
  final TextEditingController _pinController = TextEditingController();

  void _handlePayPress() {
    HapticFeedback.mediumImpact();
    // If it's mobile money, we trigger STK Push simulation instead of local PIN
    if (widget.paymentMethod.startsWith("Mobile Money")) {
      _triggerStkPush();
    } else {
      _showPinEntry();
    }
  }

  void _showPinEntry() {
    final state = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => PinEntryDialog(
        title: l10n.enterSecurityPin,
        description: l10n.enterTransactionPin,
        isCardPin: widget.cardId != null,
        cardId: widget.cardId,
        onConfirm: (pin) {
          _processTransaction(pin: pin);
        },
      ),
    );
  }

  Future<void> _triggerStkPush() async {
    setState(() {
      _isProcessing = true;
      _isStkWaiting = true;
    });

    // Simulate STK Push delay (waiting for user to enter PIN on their handset)
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      setState(() {
        _isStkWaiting = false;
      });
      _processTransaction(isStk: true);
    }
  }

  Future<void> _processTransaction({bool isStk = false, String? pin}) async {
    final state = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    
    if (!isStk) {
      if (pin == null) return;
      // Determine which PIN to verify (Wallet PIN or Card PIN)
      bool isPinValid = false;
      if (widget.cardId != null) {
        isPinValid = state.verifyCardPin(pin, cardId: widget.cardId);
      } else {
        isPinValid = state.verifyPin(pin);
      }

      if (!isPinValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.translate("Invalid PIN", "PIN-ku waa khalad")), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _showPinField = false;
    });

    // Final "Processing" delay
    await Future.delayed(const Duration(seconds: 2));

    double amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;

    try {
      if (widget.paymentMethod == "Main Wallet" || widget.paymentMethod == "Savings Account" || widget.paymentMethod == "Murtaax Wallet" || widget.paymentMethod.contains("Virtual Card")) {
        await state.processP2PTransfer(
          receiverId: widget.receiverPhone,
          amount: amountVal,
          currencyCode: widget.currencyCode,
          purpose: widget.purpose,
          paymentMethod: widget.paymentMethod,
          cardId: widget.cardId,
        );
      } else {
        // Mock logic for other sources
        String sourceKey = widget.paymentMethod;
        if (widget.paymentMethod.contains("Virtual Card")) sourceKey = "Debit Card";
        if (widget.paymentMethod == "Savings") sourceKey = "Savings Account";

        double fee = state.calculateFeeForSource(amountVal, sourceKey);
        double total = amountVal + fee;
        
        state.addTransaction(model.Transaction(
          id: "TX-${DateTime.now().millisecondsSinceEpoch}",
          title: widget.receiverName,
          date: DateFormat('MMM dd').format(DateTime.now()),
          amount: "-${NumberFormat.simpleCurrency(name: widget.currencyCode).format(total)}",
          numericAmount: amountVal,
          fee: fee,
          isNegative: true,
          category: "Transfer",
          status: "Success",
          type: "send",
          method: widget.method,
          paymentMethod: widget.paymentMethod,
          purpose: widget.purpose,
        ));
      }

      if (mounted) {
        _showSuccess();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccess() {
    final state = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    double amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
    
    String sourceKey = widget.paymentMethod;
    if (widget.paymentMethod.contains("Virtual Card")) sourceKey = "Debit Card";
    if (widget.paymentMethod == "Savings") sourceKey = "Savings Account";
    
    double fee = state.calculateFeeForSource(amountVal, sourceKey);
    double total = amountVal + fee;

    final transactionData = {
      'title': widget.receiverName,
      'amount': "-${NumberFormat.simpleCurrency(name: widget.currencyCode).format(total)}",
      'date': DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()),
      'status': 'Success',
      'id': 'TX${DateTime.now().millisecondsSinceEpoch}',
      'type': 'send',
      'method': widget.method,
      'paymentMethod': widget.paymentMethod,
      'purpose': widget.purpose,
      'sourceOfFunds': widget.sourceOfFunds,
      'swiftCode': widget.swiftCode,
      'address': widget.address,
      'city': widget.city,
      'country': widget.country,
      'receiverPhone': widget.receiverPhone,
    };

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.transferSuccessful,
          message: l10n.moneyOnWay,
          subMessage: "Transaction ID: ${transactionData['id']}",
          buttonText: l10n.backToHome,
          transactionData: transactionData,
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    
    double amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
    
    String sourceKey = widget.paymentMethod;
    if (widget.paymentMethod.contains("Virtual Card")) sourceKey = "Debit Card";
    if (widget.paymentMethod.contains("Bank Account")) sourceKey = "Bank Transfer";
    if (widget.paymentMethod == "Savings Account") sourceKey = "Savings Account";
    
    // FX Calculation
    double exchangeRate = appState.getExchangeRate("USD", widget.currencyCode);
    double amountInSourceCurrency = amountVal; // Assuming source is always USD for now
    
    double fee = appState.calculateFeeForSource(amountVal, sourceKey);
    double total = amountVal + fee;

    if (_isProcessing) {
      return _buildProcessingScreen(theme, l10n);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.reviewTransfer, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, theme, l10n),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  FadeInDown(
                    child: _buildDetailsCard(context, theme, l10n, appState, amountVal, fee, total),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(child: _buildActionButtons(theme, l10n, total)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingScreen(ThemeData theme, AppLocalizations l10n) {
    String providerName = "";
    if (widget.paymentMethod.contains("(")) {
      providerName = widget.paymentMethod.split("(").last.split(" -").first;
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZoomIn(
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1), 
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.05), width: 8),
                  ),
                  child: Center(
                    child: _isStkWaiting 
                      ? Icon(Icons.phonelink_ring_rounded, size: 50, color: theme.colorScheme.secondary)
                      : CircularProgressIndicator(color: theme.colorScheme.secondary, strokeWidth: 5)
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                child: Text(
                  _isStkWaiting ? l10n.stkPushSent : l10n.processingTransaction, 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  _isStkWaiting 
                    ? l10n.stkPushInstructions(providerName)
                    : l10n.moneyOnWay, 
                  style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_isStkWaiting) ...[
                const SizedBox(height: 48),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 12),
                      Text(l10n.waitingForProvider, style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
      child: Center(
        child: MaxWidthBox(
          maxWidth: 500,
          child: Column(
            children: [
              // Amount & Source Display in Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.paymentMethod.contains("Wallet") || widget.paymentMethod.contains("Main") 
                        ? Icons.account_balance_wallet_outlined 
                        : Icons.credit_card_outlined, 
                      color: Colors.white70, 
                      size: 16
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "${widget.paymentMethod}: ${widget.currencyCode} ${widget.amount}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStepIndicator(context, 1, l10n.stepAmount, false, true, isHeader: true),
                  _buildStepLine(context, true, isHeader: true),
                  _buildStepIndicator(context, 2, l10n.stepReceiver, false, true, isHeader: true),
                  _buildStepLine(context, true, isHeader: true),
                  _buildStepIndicator(context, 3, l10n.stepPayment, false, true, isHeader: true),
                  _buildStepLine(context, true, isHeader: true),
                  _buildStepIndicator(context, 4, l10n.stepReview, true, false, isHeader: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, ThemeData theme, AppLocalizations l10n, AppState state, double amount, double fee, double total) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : theme.dividerColor.withValues(alpha: 0.1), 
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(l10n.youSend, NumberFormat.simpleCurrency(name: widget.currencyCode).format(amount), Icons.send_rounded, isBold: true),
          const Divider(height: 32),
          _buildSummaryRow(l10n.receiver, widget.receiverName, Icons.person_outline),
          const SizedBox(height: 12),
          _buildSummaryRow(l10n.phoneNumber, widget.receiverPhone, Icons.phone_android_outlined),
          const SizedBox(height: 12),
          _buildSummaryRow(l10n.payoutVia, widget.method, Icons.speed_rounded, valueColor: theme.colorScheme.secondary),
          const SizedBox(height: 12),
          _buildSummaryRow(
            l10n.paidUsing, 
            widget.paymentMethod, 
            widget.paymentMethod.contains("Wallet") || widget.paymentMethod.contains("Main") || widget.paymentMethod.contains("Savings")
              ? Icons.account_balance_wallet_outlined 
              : Icons.credit_card_outlined
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(l10n.purposeOfRemittance, widget.purpose, Icons.info_outline_rounded),
          if (widget.sourceOfFunds != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow("Source of Funds", widget.sourceOfFunds!, Icons.source_rounded),
          ],
          if (widget.swiftCode != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(l10n.swiftCode, widget.swiftCode!, Icons.public_rounded),
          ],
          if (widget.address != null) ...[
            const Divider(height: 32),
            _buildSummaryRow(l10n.address, widget.address!, Icons.home_rounded),
            const SizedBox(height: 12),
            _buildSummaryRow(l10n.city, widget.city ?? '', Icons.location_city_rounded),
            const SizedBox(height: 12),
            _buildSummaryRow(l10n.country, widget.country ?? '', Icons.public_rounded),
          ],
          const SizedBox(height: 12),
          _buildSummaryRow(l10n.transactionFee, NumberFormat.simpleCurrency(name: widget.currencyCode).format(fee), Icons.receipt_long_rounded),
          const Divider(height: 32),
          _buildSummaryRow(l10n.totalToPay, NumberFormat.simpleCurrency(name: widget.currencyCode).format(total), Icons.payments_rounded, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, AppLocalizations l10n, double total) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _handlePayPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
              shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 20 * context.fontSizeFactor),
                SizedBox(width: 12 * context.fontSizeFactor),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${l10n.confirmAndPay} (${NumberFormat.simpleCurrency(name: widget.currencyCode).format(total)})",
                      style: TextStyle(
                        fontSize: 18 * context.fontSizeFactor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security_rounded, size: 14, color: theme.brightness == Brightness.dark ? Colors.white54 : AppColors.grey.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              "Secured by Murtaax SSL Encryption",
              style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white54 : AppColors.grey.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, {bool isBold = false, bool isTotal = false, Color? valueColor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFF94A3B8) : AppColors.grey;
    final valueTextColor = valueColor ?? (isTotal ? AppColors.accentTeal : (isDark ? Colors.white : AppColors.textPrimary));

    return Row(
      children: [
        Icon(icon, size: 20 * context.fontSizeFactor, color: labelColor),
        SizedBox(width: 12 * context.fontSizeFactor),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.bold,
              fontSize: 14 * context.fontSizeFactor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: (isTotal ? 22 : (isBold ? 18 : 15)) * context.fontSizeFactor,
                fontWeight: FontWeight.w900,
                color: valueTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(BuildContext context, int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    final theme = Theme.of(context);
    Color activeColor = isHeader ? Colors.white : theme.colorScheme.secondary;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!);
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? theme.colorScheme.secondary : Colors.grey);

    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 4) : null
          ),
          child: Center(child: isCompleted && !isActive ? Icon(Icons.check, color: isHeader ? theme.colorScheme.secondary : Colors.white, size: 18) : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? theme.colorScheme.secondary : Colors.white) : Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 50,
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildStepLine(BuildContext context, bool isCompleted, {bool isHeader = false}) { 
    final theme = Theme.of(context);
    Color color = isHeader 
      ? (isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.3))
      : (isCompleted ? theme.colorScheme.secondary : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!));
    return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))));
  }
}
