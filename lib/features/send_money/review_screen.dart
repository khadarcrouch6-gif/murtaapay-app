import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/step_indicator.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/models/transaction.dart' as model;
import '../../core/widgets/pin_entry_dialog.dart';
import '../navigation/main_navigation.dart';

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
  int _timerSeconds = 60;
  Timer? _timer;

  String get _sourceKey {
    String key = widget.paymentMethod;
    if (key.contains("Virtual Card")) return "Debit Card";
    if (key.contains("Bank")) return "Bank Transfer";
    if (key.contains("Savings")) return "Savings Account";
    if (key.contains("Mobile")) return "Mobile Money";
    if (key.contains("Main")) return "Main Wallet";
    return key;
  }

  String _getCanonicalMethod(String method) {
    if (method.contains("Bank")) return "Bank Transfer";
    if (method.contains("Wallet")) return "Main Wallet";
    if (method.contains("Savings")) return "Savings Account";
    if (method.contains("Card") || method.contains("Visa")) return "Debit Card";
    if (method.contains("Mobile") || method.contains("Money") || 
        ["EVC Plus", "ZAAD Service", "e-Dahab", "Sahal"].any((m) => method.contains(m))) {
      return "Mobile Money";
    }
    return method;
  }

  void _handlePayPress() {
    HapticFeedback.mediumImpact();
    // If it's mobile money, we trigger STK Push simulation instead of local PIN
    if (widget.paymentMethod.contains("Mobile Money") || widget.paymentMethod.contains("EVC") || widget.paymentMethod.contains("Sahal")) {
      _triggerStkPush();
    } else {
      _showPinEntry();
    }
  }

  void _showPinEntry() {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _triggerStkPush() async {
    setState(() {
      _isProcessing = true;
      _isStkWaiting = true;
      _timerSeconds = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        if (mounted) {
          setState(() {
            _timerSeconds--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          _handleStkTimeout();
        }
      }
    });

    // Simulate STK Push delay (waiting for user to enter PIN on their handset)
    // We'll wait 5 seconds then "complete" it for the demo, 
    // but the timer shows the user how long they have.
    await Future.delayed(const Duration(seconds: 8));

    if (mounted && _isStkWaiting) {
      _timer?.cancel();
      setState(() {
        _isStkWaiting = false;
      });
      _processTransaction(isStk: true);
    }
  }

  void _handleStkTimeout() {
    setState(() {
      _isProcessing = false;
      _isStkWaiting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment timed out. Please try again."),
        backgroundColor: Colors.red,
      ),
    );
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
          SnackBar(content: Text(l10n.invalidPin), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    // Final "Processing" delay
    await Future.delayed(const Duration(seconds: 2));

    double amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
    double fee = state.calculateFeeForSource(
      amountVal, 
      _sourceKey, 
      payoutMethod: _getCanonicalMethod(widget.method)
    );
    double total = amountVal + fee;
    
    try {
      if (widget.paymentMethod == "Main Wallet" || widget.paymentMethod == "Savings Account" || widget.paymentMethod == "Murtaax Wallet" || widget.paymentMethod.contains("Virtual Card")) {
        await state.processP2PTransfer(
          receiverId: widget.receiverPhone,
          receiverName: widget.receiverName,
          amount: amountVal,
          currencyCode: widget.currencyCode,
          purpose: widget.purpose,
          paymentMethod: widget.paymentMethod,
          payoutMethod: _getCanonicalMethod(widget.method),
          cardId: widget.cardId,
        );
      } else {
        // Mock logic for other sources
        state.addTransaction(model.Transaction(
          id: "TX-${DateTime.now().millisecondsSinceEpoch}",
          title: widget.receiverName,
          date: DateFormat('MMM dd').format(DateTime.now()),
          amount: "-${NumberFormat.simpleCurrency(name: widget.currencyCode).format(total)}",
          numericAmount: amountVal,
          fee: fee,
          isNegative: true,
          category: "Transfer",
          status: widget.method.contains("Bank") ? "Pending" : "Success",
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
    
    double fee = state.calculateFeeForSource(
      amountVal, 
      _sourceKey, 
      payoutMethod: _getCanonicalMethod(widget.method)
    );
    double total = amountVal + fee;

    final transactionData = {
      'title': widget.receiverName,
      'amount': "-${NumberFormat.simpleCurrency(name: widget.currencyCode).format(total)}",
      'numericAmount': amountVal,
      'fee': fee,
      'currencyCode': widget.currencyCode,
      'date': DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()),
      'status': widget.method.contains("Bank") ? 'Pending' : 'Success',
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
          title: widget.method.contains("Bank") 
              ? state.translate("Transfer Processing", "Xawaaladda waa la farsameeyay")
              : l10n.transferSuccessful,
          message: widget.method.contains("Bank")
              ? state.translate(
                  "Your bank transfer has been initiated and will be completed within 24 hours.",
                  "Xawaaladdaada bangiga waa la bilaabay, waxaana lagu dhammaystiri doonaa 24 saac gudahood."
                )
              : l10n.moneyOnWay,
          subMessage: "Transaction ID: ${transactionData['id']}",
          buttonText: l10n.backToHome,
          transactionData: transactionData,
          onPressed: () {
            state.setNavIndex(0); // Reset to Home tab
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
              (route) => false,
            );
          },
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
    
    // FX Calculation
    // String sourceKey = _sourceKey;
    // double exchangeRate = appState.getExchangeRate("USD", widget.currencyCode);
    // double amountInSourceCurrency = amountVal; // Assuming source is always USD for now
    
    double fee = appState.calculateFeeForSource(
      amountVal, 
      _sourceKey, 
      payoutMethod: _getCanonicalMethod(widget.method)
    );
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
        title: Text(
          l10n.reviewTransfer, 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            color: Colors.white,
            fontSize: 20 * context.fontSizeFactor
          )
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, theme, l10n),
            Padding(
              padding: EdgeInsets.all(20 * context.fontSizeFactor),
              child: Column(
                children: [
                  FadeInDown(
                    child: _buildDetailsCard(context, theme, l10n, appState, amountVal, fee, total),
                  ),
                  if (widget.method.contains("Bank")) ...[
                    SizedBox(height: 16 * context.fontSizeFactor),
                    FadeInUp(
                      child: Container(
                        padding: EdgeInsets.all(16 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: Colors.orange, size: 20 * context.fontSizeFactor),
                            SizedBox(width: 12 * context.fontSizeFactor),
                            Expanded(
                              child: Text(
                                appState.translate(
                                  "Note: Bank transfers take up to 24 hours to process.",
                                  "Ogeysiis: Xawaaladaha bangigu waxay qaataan ilaa 24 saac."
                                ),
                                style: TextStyle(
                                  fontSize: 13 * context.fontSizeFactor, 
                                  color: Colors.orange[900], 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 24 * context.fontSizeFactor),
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
          padding: EdgeInsets.symmetric(horizontal: 40 * context.fontSizeFactor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZoomIn(
                child: Container(
                  width: 120 * context.fontSizeFactor, 
                  height: 120 * context.fontSizeFactor,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1), 
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.05), 
                      width: 8 * context.fontSizeFactor
                    ),
                  ),
                  child: Center(
                    child: _isStkWaiting 
                      ? Icon(
                          Icons.phonelink_ring_rounded, 
                          size: 50 * context.fontSizeFactor, 
                          color: theme.colorScheme.secondary
                        )
                      : CircularProgressIndicator(
                          color: theme.colorScheme.secondary, 
                          strokeWidth: 5 * context.fontSizeFactor
                        )
                  ),
                ),
              ),
              SizedBox(height: 32 * context.fontSizeFactor),
              FadeInUp(
                child: Text(
                  _isStkWaiting ? l10n.stkPushSent : l10n.processingTransaction, 
                  style: TextStyle(
                    fontSize: 24 * context.fontSizeFactor, 
                    fontWeight: FontWeight.w900
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16 * context.fontSizeFactor),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  _isStkWaiting 
                    ? l10n.stkPushInstructions(providerName)
                    : l10n.moneyOnWay, 
                  style: TextStyle(
                    color: AppColors.grey, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 16 * context.fontSizeFactor
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_isStkWaiting) ...[
                SizedBox(height: 48 * context.fontSizeFactor),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16 * context.fontSizeFactor, 
                        height: 16 * context.fontSizeFactor, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: _timerSeconds / 60,
                          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                        )
                      ),
                      SizedBox(width: 12 * context.fontSizeFactor),
                      Text(
                        "${l10n.waitingForProvider} (${_timerSeconds}s)",
                        style: TextStyle(
                          color: theme.colorScheme.secondary, 
                          fontWeight: FontWeight.bold,
                          fontSize: 14 * context.fontSizeFactor
                        )
                      ),
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30 * context.fontSizeFactor), 
          bottomRight: Radius.circular(30 * context.fontSizeFactor)
        ),
      ),
      padding: EdgeInsets.only(
        bottom: 25 * context.fontSizeFactor, 
        left: 20 * context.fontSizeFactor, 
        right: 20 * context.fontSizeFactor
      ),
      child: Center(
        child: MaxWidthBox(
          maxWidth: 500,
          child: Column(
            children: [
              // Amount & Source Display in Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * context.fontSizeFactor, 
                  vertical: 8 * context.fontSizeFactor
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.paymentMethod.contains("Wallet") || widget.paymentMethod.contains("Main") 
                        ? Icons.account_balance_wallet_outlined 
                        : Icons.credit_card_outlined, 
                      color: Colors.white70, 
                      size: 16 * context.fontSizeFactor
                    ),
                    SizedBox(width: 8 * context.fontSizeFactor),
                    Flexible(
                      child: Text(
                        "${widget.paymentMethod}: ${widget.currencyCode} ${widget.amount}",
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w900, 
                          fontSize: 14 * context.fontSizeFactor
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20 * context.fontSizeFactor),
              Row(
                children: [
                  StepIndicator(step: 1, label: l10n.stepAmount, isActive: false, isCompleted: true, isHeader: true),
                  StepLine(isCompleted: true, isHeader: true),
                  StepIndicator(step: 2, label: l10n.stepReceiver, isActive: false, isCompleted: true, isHeader: true),
                  StepLine(isCompleted: true, isHeader: true),
                  StepIndicator(step: 3, label: l10n.stepPayment, isActive: false, isCompleted: true, isHeader: true),
                  StepLine(isCompleted: true, isHeader: true),
                  StepIndicator(step: 4, label: l10n.stepReview, isActive: true, isCompleted: false, isHeader: true),
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
      padding: EdgeInsets.all(24 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28 * context.fontSizeFactor),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : theme.dividerColor.withValues(alpha: 0.1), 
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03), 
            blurRadius: 20 * context.fontSizeFactor, 
            offset: Offset(0, 10 * context.fontSizeFactor)
          )
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(l10n.youSend, NumberFormat.simpleCurrency(name: widget.currencyCode).format(amount), Icons.send_rounded, isBold: true),
          Divider(height: 32 * context.fontSizeFactor),
          _buildSummaryRow(l10n.receiver, widget.receiverName, Icons.person_outline),
          SizedBox(height: 12 * context.fontSizeFactor),
          _buildSummaryRow(l10n.phoneNumber, widget.receiverPhone, Icons.phone_android_outlined),
          SizedBox(height: 12 * context.fontSizeFactor),
          _buildSummaryRow(l10n.payoutVia, widget.method, Icons.speed_rounded, valueColor: theme.colorScheme.secondary),
          SizedBox(height: 12 * context.fontSizeFactor),
          _buildSummaryRow(
            l10n.paidUsing, 
            widget.paymentMethod, 
            widget.paymentMethod.contains("Wallet") || widget.paymentMethod.contains("Main") || widget.paymentMethod.contains("Savings")
              ? Icons.account_balance_wallet_outlined 
              : Icons.credit_card_outlined
          ),
          SizedBox(height: 12 * context.fontSizeFactor),
          _buildSummaryRow(l10n.purposeOfRemittance, widget.purpose, Icons.info_outline_rounded),
          if (widget.sourceOfFunds != null) ...[
            SizedBox(height: 12 * context.fontSizeFactor),
            _buildSummaryRow(l10n.sourceOfFunds, widget.sourceOfFunds!, Icons.source_rounded),
          ],
          if (widget.swiftCode != null) ...[
            SizedBox(height: 12 * context.fontSizeFactor),
            _buildSummaryRow(l10n.swiftCode, widget.swiftCode!, Icons.public_rounded),
          ],
          if (widget.address != null) ...[
            Divider(height: 32 * context.fontSizeFactor),
            _buildSummaryRow(l10n.address, widget.address!, Icons.home_rounded),
            SizedBox(height: 12 * context.fontSizeFactor),
            _buildSummaryRow(l10n.city, widget.city ?? '', Icons.location_city_rounded),
            SizedBox(height: 12 * context.fontSizeFactor),
            _buildSummaryRow(l10n.country, widget.country ?? '', Icons.public_rounded),
          ],
          SizedBox(height: 12 * context.fontSizeFactor),
          SizedBox(height: 12 * context.fontSizeFactor),
          Builder(
            builder: (context) {
              final effectivePayoutMethod = _getCanonicalMethod(widget.method);
              final fee = state.calculateFeeForSource(
                amount, 
                _sourceKey, 
                payoutMethod: effectivePayoutMethod
              );
              final feeRate = state.getFeeRate(effectivePayoutMethod);
              final feeRateText = l10n.feeRateDynamic(
                feeRate.toStringAsFixed(1),
                NumberFormat.simpleCurrency(name: widget.currencyCode).format(fee)
              );
              
              return _buildSummaryRow(
                feeRateText,
                NumberFormat.simpleCurrency(name: widget.currencyCode).format(fee), 
                Icons.receipt_long_rounded
              );
            }
          ),
          Divider(height: 32 * context.fontSizeFactor),
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
          height: 58 * context.fontSizeFactor,
          child: ElevatedButton(
            onPressed: _handlePayPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * context.fontSizeFactor)),
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
        SizedBox(height: 16 * context.fontSizeFactor),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security_rounded, 
              size: 14 * context.fontSizeFactor, 
              color: theme.brightness == Brightness.dark ? Colors.white54 : AppColors.grey.withValues(alpha: 0.6)
            ),
            SizedBox(width: 6 * context.fontSizeFactor),
            Text(
              l10n.securedBySSL,
              style: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white54 : AppColors.grey.withValues(alpha: 0.6),
                fontSize: 12 * context.fontSizeFactor, 
                fontWeight: FontWeight.bold
              ),
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
}
