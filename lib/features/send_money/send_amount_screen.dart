import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../core/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/step_indicator.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'receiver_screen.dart';
import 'wallet_receiver_screen.dart';
import 'bank_screen.dart';
import 'card_screen.dart';

class SendAmountScreen extends StatefulWidget {
  final bool showBackButton;
  final String? prefilledWalletId;
  final String? prefilledName;
  final double? prefilledAmount;
  final String? prefilledSenderMethod;
  final String? prefilledReceiverMethod;

  const SendAmountScreen({
    super.key, 
    this.showBackButton = true,
    this.prefilledWalletId,
    this.prefilledName,
    this.prefilledAmount,
    this.prefilledSenderMethod,
    this.prefilledReceiverMethod,
  });

  @override
  State<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen> {
  final AppState state = AppState();
  final TextEditingController _sendController = TextEditingController(text: "0.00");
  final TextEditingController _receiveController = TextEditingController(text: "0.00");
  final FocusNode _sendFocusNode = FocusNode();
  final FocusNode _receiveFocusNode = FocusNode();
  String _sendCurrency = "USD";
  String _receiveCurrency = "USD";
  String _selectedMethod = "EVC Plus";
  String _selectedCategory = "All";
  bool _isCalculating = false;
  bool _isRefreshing = false;
  bool _isFeeIncluded = false; 
  DateTime? _lastRateUpdate;
  Timer? _refreshTimer;

  final List<Map<String, String>> _currencies = [
    {"code": "USD", "name": "US Dollar", "flag": "us"},
    {"code": "AUD", "name": "Australian Dollar", "flag": "au"},
    {"code": "CAD", "name": "Canadian Dollar", "flag": "ca"},
    {"code": "GBP", "name": "British Pound", "flag": "gb"},
    {"code": "EUR", "name": "Euro", "flag": "eu"},
    {"code": "SAR", "name": "Saudi Riyal", "flag": "sa"},
    {"code": "AED", "name": "UAE Dirham", "flag": "ae"},
    {"code": "QAR", "name": "Qatari Rial", "flag": "qa"},
    {"code": "CHF", "name": "Swiss Franc", "flag": "ch"},
    {"code": "CNY", "name": "Chinese Yuan", "flag": "cn"},
    {"code": "JPY", "name": "Japanese Yen", "flag": "jp"},
  ];

  final Map<String, double> rates = {
    "USD": 1.0, "AUD": 1.51, "CAD": 1.35, "GBP": 0.79, "EUR": 0.93,
    "SAR": 3.75, "AED": 3.67, "QAR": 3.64, "CHF": 0.91, "CNY": 7.24, "JPY": 156.00,
  };

  int get _sendCurrencyDecimals => _sendCurrency == "JPY" ? 0 : 2;
  int get _receiveCurrencyDecimals => _receiveCurrency == "JPY" ? 0 : 2;

  String _formatCurrency(double amount, int decimals) {
    final format = NumberFormat.currency(symbol: "", decimalDigits: decimals);
    return format.format(amount).trim();
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

  double get _fee {
    double amount = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) return 0.00;
    
    // Get fee in USD from AppState
    double feeInUsd = state.calculateFeeForSource(
      amount / (rates[_sendCurrency] ?? 1.0), 
      "Main Wallet", // Alignment: Assume Main Wallet as source for live preview
      payoutMethod: _getCanonicalMethod(_selectedMethod),
    );
    
    // Convert fee to current send currency
    double feeInCurrentCurrency = feeInUsd * (rates[_sendCurrency] ?? 1.0);
    
    return double.parse(feeInCurrentCurrency.toStringAsFixed(_sendCurrencyDecimals));
  }

  double get _totalToPay {
    double amount = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) return 0.00;
    if (_isFeeIncluded) return amount;
    double total = amount + _fee;
    return double.parse(total.toStringAsFixed(_sendCurrencyDecimals));
  }

  bool _hasSufficientBalance(double userBalanceInUsd) {
    if (_totalToPay <= 0) return true;
    double balanceInCurrentCurrency = userBalanceInUsd * (rates[_sendCurrency] ?? 1.0);
    return _totalToPay <= balanceInCurrentCurrency;
  }
  
  double get _maxLimitInCurrentCurrency => state.dailyLimit * (rates[_sendCurrency] ?? 1.0);
  double get _minLimitInCurrentCurrency => 10 * (rates[_sendCurrency] ?? 1.0);

  bool get _isAmountValid {
    double amt = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    if (amt < _minLimitInCurrentCurrency) return false;
    
    double amountInUsd = _totalToPay / (rates[_sendCurrency] ?? 1.0);
    return amountInUsd <= state.getDailyRemaining() && amountInUsd <= state.getMonthlyRemaining();
  }

  @override
  void initState() {
    super.initState();
    if (widget.prefilledAmount != null) {
      _sendController.text = widget.prefilledAmount!.toStringAsFixed(2);
    }
    if (widget.prefilledReceiverMethod != null) {
      _selectedMethod = widget.prefilledReceiverMethod!;
    }
    _loadRates();
    _startRefreshTimer();
    _sendFocusNode.addListener(() {
      if (_sendFocusNode.hasFocus && _sendController.text == "0.00") _sendController.clear();
    });
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) => _loadRates());
  }

  Future<void> _loadRates() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final newRates = await ApiService.fetchAllRates();
      if (mounted) {
        setState(() {
          rates.addAll(newRates);
          _lastRateUpdate = DateTime.now();
          _updateReceiveAmount(_sendController.text);
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _sendController.dispose();
    _receiveController.dispose();
    _sendFocusNode.dispose();
    _receiveFocusNode.dispose();
    super.dispose();
  }

  void _updateReceiveAmount(String value) {
    if (value.isEmpty) {
      setState(() { _receiveController.text = ""; _isCalculating = false; });
      return;
    }
    String cleanValue = value.replaceAll(',', '');
    double amount = double.tryParse(cleanValue) ?? 0;
    if (amount == 0) {
      setState(() { _receiveController.text = ""; _isCalculating = false; });
      return;
    }
    double fromRate = rates[_sendCurrency] ?? 1.0;
    double toRate = rates[_receiveCurrency] ?? 1.0;
    setState(() => _isCalculating = true);
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          double effectiveAmount = _isFeeIncluded ? (amount - _fee) : amount;
          double inUsd = effectiveAmount / fromRate;
          _receiveController.text = _formatCurrency(inUsd * toRate, _receiveCurrencyDecimals);
          _isCalculating = false;
        });
      }
    });
  }

  void _updateSendAmount(String value) {
    if (value.isEmpty) {
      setState(() { _sendController.text = ""; _isCalculating = false; });
      return;
    }
    String cleanValue = value.replaceAll(',', '');
    double amount = double.tryParse(cleanValue) ?? 0;
    if (amount == 0) {
      setState(() { _sendController.text = ""; _isCalculating = false; });
      return;
    }
    double fromRate = rates[_sendCurrency] ?? 1.0;
    double toRate = rates[_receiveCurrency] ?? 1.0;
    setState(() => _isCalculating = true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          double inUsd = amount / toRate;
          if (_isFeeIncluded) {
            double feeInUsd = state.calculateFeeForSource(
              inUsd, 
              "Main Wallet", 
              payoutMethod: _getCanonicalMethod(_selectedMethod)
            );
            inUsd = inUsd + feeInUsd; 
          }
          _sendController.text = _formatCurrency(inUsd * fromRate, _sendCurrencyDecimals);
          _isCalculating = false;
        });
      }
    });
  }

  void _setMaxAmount() {
    HapticFeedback.mediumImpact();
    double balanceInUsd = state.balance > 2500 ? 2500 : state.balance;
    double fromRate = rates[_sendCurrency] ?? 1.0;
    double feeInUsd = state.calculateFeeForSource(
      balanceInUsd, 
      "Main Wallet", 
      payoutMethod: _getCanonicalMethod(_selectedMethod)
    );
    
    double maxSend = _isFeeIncluded ? (balanceInUsd * fromRate) : ((balanceInUsd - feeInUsd) * fromRate);
    if (maxSend < 0) maxSend = 0;
    setState(() {
      _sendController.text = _formatCurrency(maxSend, _sendCurrencyDecimals);
      _updateReceiveAmount(_sendController.text);
    });
  }

  void _addQuickAmount(int amount) {
    HapticFeedback.lightImpact();
    double current = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    _sendController.text = (current + (amount * (rates[_sendCurrency] ?? 1.0))).toStringAsFixed(_sendCurrencyDecimals);
    _updateReceiveAmount(_sendController.text);
  }

  void _showCurrencyPicker(bool isSource, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(
        currencies: _currencies,
        searchHint: l10n.searchCurrency,
        onSelected: (currency) {
          setState(() {
            if (isSource) {
              _sendCurrency = currency['code']!;
              _sendController.text = "0.00";
              _receiveController.text = "0.00";
            } else {
              _receiveCurrency = currency['code']!;
              _updateReceiveAmount(_sendController.text);
            }
          });
        },
      ),
    );
  }

  String _getFlagCode(String currencyCode) => _currencies.firstWhere((c) => c['code'] == currencyCode, orElse: () => {"flag": "us"})['flag']!;
  String _getCurrencySymbol(String code) { try { return NumberFormat.simpleCurrency(name: code).currencySymbol; } catch (e) { return code; } }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        bool hasSufficient = _hasSufficientBalance(state.balance);
        bool canProceed = hasSufficient && _isAmountValid;
        double currentAmount = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
        bool isInputEmpty = _sendController.text.isEmpty || currentAmount == 0;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
            elevation: 0,
            leading: widget.showBackButton ? IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * context.fontSizeFactor), onPressed: () => Navigator.pop(context)) : null,
            title: Text(l10n.sendMoney, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 22 * context.fontSizeFactor, color: Colors.white, letterSpacing: -0.5)),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          body: SafeArea(
            top: false,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // --- HEADER BACKGROUND ---
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30 * context.fontSizeFactor), bottomRight: Radius.circular(30 * context.fontSizeFactor)),
                          ),
                          padding: EdgeInsets.only(bottom: 10 * context.fontSizeFactor), // Booska hoose waa la yareeyay
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor),
                            child: Row(
                              children: [
                                StepIndicator(step: 1, label: l10n.stepAmount, isActive: true, isCompleted: false, isHeader: true),
                                StepLine(isCompleted: false, isHeader: true),
                                StepIndicator(step: 2, label: l10n.stepReceiver, isActive: false, isCompleted: false, isHeader: true),
                                StepLine(isCompleted: false, isHeader: true),
                                StepIndicator(step: 3, label: l10n.stepPayment, isActive: false, isCompleted: false, isHeader: true),
                                StepLine(isCompleted: false, isHeader: true),
                                StepIndicator(step: 4, label: l10n.stepReview, isActive: false, isCompleted: false, isHeader: true),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8), // Waxaa laga dhigay 8 (hore 16)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(l10n.enterAmount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.titleMedium?.color), overflow: TextOverflow.ellipsis)),
                                  SizedBox(width: 8 * context.fontSizeFactor),
                                  GestureDetector(
                                    onTap: () => _showFeeInfo(l10n),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(child: Text(l10n.feeInfoTitle, style: TextStyle(fontSize: 13 * context.fontSizeFactor, color: theme.colorScheme.secondary, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                                        SizedBox(width: 4 * context.fontSizeFactor),
                                        Icon(Icons.info_outline_rounded, size: 15 * context.fontSizeFactor, color: theme.colorScheme.secondary),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8), // Waxaa laga dhigay 8 (hore 12)
                              
                              // Input 1: You Send
                              _buildAmountInput(
                                label: l10n.youSend,
                                controller: _sendController,
                                focusNode: _sendFocusNode,
                                currency: _sendCurrency,
                                balance: _formatCurrency(state.balance * (rates[_sendCurrency] ?? 1.0), _sendCurrencyDecimals),
                                onChanged: _updateReceiveAmount,
                                onCurrencyTap: () => _showCurrencyPicker(true, l10n),
                                isError: currentAmount > 0 && !_isAmountValid,
                                onMaxTap: _setMaxAmount,
                                decimals: _sendCurrencyDecimals,
                              ),

                              // Quick Actions
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 4 * context.fontSizeFactor), // Waxaa laga dhigay 4 (hore 8)
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [10, 50, 100, 500].map((amt) => Padding(
                                      padding: EdgeInsets.only(right: 8 * context.fontSizeFactor),
                                      child: ActionChip(
                                        label: Text("+ ${_getCurrencySymbol(_sendCurrency)} $amt", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13 * context.fontSizeFactor)),
                                        onPressed: () => _addQuickAmount(amt),
                                        backgroundColor: theme.colorScheme.surface,
                                        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1), width: 1),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                                        padding: EdgeInsets.symmetric(horizontal: 6 * context.fontSizeFactor, vertical: 2 * context.fontSizeFactor),
                                      ),
                                    )).toList(),
                                  ),
                                ),
                              ),

                              // Swap & Rates
                              Center(
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        setState(() {
                                          final temp = _sendCurrency; _sendCurrency = _receiveCurrency; _receiveCurrency = temp;
                                          _updateReceiveAmount(_sendController.text);
                                        });
                                      },
                                      child: Container(padding: EdgeInsets.all(4 * context.fontSizeFactor), decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 8 * context.fontSizeFactor)]), child: Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20 * context.fontSizeFactor)),
                                    ),
                                    SizedBox(height: 2 * context.fontSizeFactor),
                                    Text(
                                      "1 $_sendCurrency = ${((1 / (rates[_sendCurrency] ?? 1.0)) * (rates[_receiveCurrency] ?? 1.0)).toStringAsFixed(4)} $_receiveCurrency", 
                                      style: TextStyle(fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w900, color: theme.textTheme.bodyMedium?.color, letterSpacing: -0.5)
                                    ),
                                    if (_lastRateUpdate != null)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("${l10n.refreshed}: ${DateFormat('HH:mm:ss').format(_lastRateUpdate!)}", style: TextStyle(fontSize: 10 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
                                          SizedBox(width: 4 * context.fontSizeFactor),
                                          _isRefreshing ? SizedBox(width: 8 * context.fontSizeFactor, height: 8 * context.fontSizeFactor, child: const CircularProgressIndicator(strokeWidth: 1.5)) : Icon(Icons.auto_awesome, size: 10 * context.fontSizeFactor, color: theme.colorScheme.secondary),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 2),

                              // Input 2: Receiver Gets
                              _buildAmountInput(
                                label: l10n.receiverGets,
                                controller: _receiveController,
                                focusNode: _receiveFocusNode,
                                currency: _receiveCurrency,
                                onChanged: _updateSendAmount,
                                onCurrencyTap: () => _showCurrencyPicker(false, l10n),
                                isReceiver: true,
                                isLoading: _isCalculating,
                                decimals: _receiveCurrencyDecimals,
                              ),

                              const SizedBox(height: 8), // Waxaa laga dhigay 8 (hore 12)
                              
                              // Fee Toggle
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor), // Padding-ka waa la yareeyay
                                decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5)),
                                child: Row(
                                  children: [
                                    Icon(Icons.receipt_long_rounded, color: theme.colorScheme.secondary, size: 20 * context.fontSizeFactor),
                                    SizedBox(width: 8 * context.fontSizeFactor),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(l10n.deductFeeFromAmount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13 * context.fontSizeFactor)),
                                          Text(_isFeeIncluded ? l10n.receiverWillReceiveLess : l10n.payFeeSeparately, style: TextStyle(fontSize: 10 * context.fontSizeFactor, color: AppColors.grey, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8 * context.fontSizeFactor,
                                      child: Switch.adaptive(
                                        value: _isFeeIncluded,
                                        activeTrackColor: theme.colorScheme.secondary,
                                        onChanged: (v) {
                                          setState(() {
                                            _isFeeIncluded = v;
                                            _updateReceiveAmount(_sendController.text);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 8 * context.fontSizeFactor),
                              
                              SizedBox(height: 16 * context.fontSizeFactor),
                              Text(l10n.payoutMethod, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.titleMedium?.color)),
                              SizedBox(height: 4 * context.fontSizeFactor),
                              _buildPayoutMethodsGrid(theme, l10n),
                              
                              SizedBox(height: 8 * context.fontSizeFactor),
                              
                              // Financial Safety Indicators
                              if (!isInputEmpty) ...[
                                Row(
                                  children: [
                                    Icon(Icons.security_rounded, size: 18 * context.fontSizeFactor, color: theme.colorScheme.secondary),
                                    SizedBox(width: 8 * context.fontSizeFactor),
                                    Text(
                                      l10n.transactionLimits,
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.titleMedium?.color),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10 * context.fontSizeFactor),
                                _buildLimitIndicators(state, l10n, theme),
                                SizedBox(height: 16 * context.fontSizeFactor),
                              ],

                              // Summary Card
                              Container(
                                padding: EdgeInsets.all(12 * context.fontSizeFactor), // Padding-ka waa la yareeyay (hore 16)
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                                  border: Border.all(color: !hasSufficient ? Colors.red.withValues(alpha: 0.8) : theme.dividerColor.withValues(alpha: 0.1), width: 2),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10 * context.fontSizeFactor, offset: Offset(0, 4 * context.fontSizeFactor))],
                                ),
                                child: Column(
                                  children: [
                                    _buildSummaryRow(l10n.transactionFee, isInputEmpty ? "-" : "${_getCurrencySymbol(_sendCurrency)} ${_formatCurrency(_fee, _sendCurrencyDecimals)}"),
                                    Divider(height: 12 * context.fontSizeFactor, thickness: 1),
                                    _buildSummaryRow(l10n.totalToPay, isInputEmpty ? "-" : "${_getCurrencySymbol(_sendCurrency)} ${_formatCurrency(_totalToPay, _sendCurrencyDecimals)}", isTotal: true, isError: !hasSufficient),
                                    if (_selectedMethod == "Bank Transfer" && !isInputEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 8 * context.fontSizeFactor),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.access_time_filled_rounded, size: 14 * context.fontSizeFactor, color: Colors.orange),
                                            SizedBox(width: 6 * context.fontSizeFactor),
                                            Text(
                                              l10n.arrivesIn24h,
                                              style: TextStyle(fontSize: 11 * context.fontSizeFactor, color: Colors.orange.shade700, fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (!hasSufficient)
                                      Padding(padding: EdgeInsets.only(top: 4 * context.fontSizeFactor), child: Text(l10n.insufficientBalance, style: TextStyle(color: Colors.red, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.w900), textAlign: TextAlign.center)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16 * context.fontSizeFactor), // Booska badhanka kor ayuu u soo kacay (hore 30)
                              SizedBox(
                                width: double.infinity,
                                height: 52 * context.fontSizeFactor, // Wax yar ayaa laga dhimay dhererka
                                child: ElevatedButton(
                                  onPressed: canProceed ? () => _handleContinue(l10n) : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.secondary,
                                    foregroundColor: theme.colorScheme.onSecondary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                                    elevation: 4,
                                    shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                    disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                                    disabledForegroundColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.3) : Colors.white70,
                                  ),
                                  child: Text(
                                    _selectedMethod == "Bank Transfer" 
                                      ? l10n.continueToBank 
                                      : (_selectedMethod == "Murtaax Wallet" ? l10n.continueToWallet : l10n.continueToReceiver), 
                                    style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                                  ),
                                ),
                              ),
                              SizedBox(height: 20 * context.fontSizeFactor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  void _showFeeInfo(AppLocalizations l10n) {
    final theme = Theme.of(context);
    String feeInfo = "";
    if (_selectedMethod == "Bank Transfer") {
      feeInfo = l10n.bankFeeInfo;
    } else if (_selectedMethod == "Murtaax Wallet") {
      feeInfo = l10n.walletFeeInfo;
    } else if (_selectedMethod == "Visa / MasterCard") {
      feeInfo = l10n.cardFeeInfo;
    } else {
      feeInfo = l10n.mobileMoneyFeeInfo;
    }

    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(l10n.feeInfoTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
      content: Text(feeInfo, style: const TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.w600)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok, style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w900, fontSize: 18)))]
    ));
  }

  void _handleContinue(AppLocalizations l10n) {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    final cleanAmount = _sendController.text.replaceAll(',', '');

    if (_selectedMethod == "Murtaax Wallet") {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => WalletReceiverScreen(
          amount: cleanAmount, 
          method: _selectedMethod, 
          currencyCode: _sendCurrency,
          senderSource: "Main Wallet",
          prefilledName: widget.prefilledName,
          prefilledPhone: widget.prefilledWalletId,
        )
      ));
    } else if (_selectedMethod == "EVC Plus" || _selectedMethod == "ZAAD Service" || _selectedMethod == "e-Dahab" || _selectedMethod == "Sahal") {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => ReceiverScreen(
          amount: cleanAmount, 
          method: _selectedMethod, 
          currencyCode: _sendCurrency,
          senderSource: "Main Wallet",
          prefilledName: widget.prefilledName,
          prefilledPhone: widget.prefilledWalletId,
        )
      ));
    } else if (_selectedMethod == "Bank Transfer") {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => BankScreen(
          amount: cleanAmount, 
          method: _selectedMethod, 
          currencyCode: _sendCurrency,
          senderSource: "Main Wallet",
          prefilledName: widget.prefilledName,
          prefilledAccount: widget.prefilledWalletId,
        )
      ));
    } else if (_selectedMethod == "Visa / MasterCard") {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => CardScreen(
          amount: cleanAmount, 
          method: _selectedMethod, 
          currencyCode: _sendCurrency,
          senderSource: "Main Wallet",
        )
      ));
    }
  }

  Widget _buildAmountInput({
    required String label, required TextEditingController controller, required FocusNode focusNode, required String currency,
    String? balance, required Function(String) onChanged, required VoidCallback onCurrencyTap,
    bool isReceiver = false, bool isError = false, bool isLoading = false, int decimals = 2, VoidCallback? onMaxTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        bool isFocused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: isError ? Colors.red.withValues(alpha: 0.05) : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
            border: Border.all(color: isError ? Colors.red : (isFocused ? Theme.of(context).colorScheme.secondary : Theme.of(context).dividerColor.withValues(alpha: 0.1)), width: isFocused ? 2 * context.fontSizeFactor : 1.5 * context.fontSizeFactor),
            boxShadow: isFocused ? [BoxShadow(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10 * context.fontSizeFactor, spreadRadius: 1 * context.fontSizeFactor)] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isError ? Colors.red : AppColors.grey,
                        fontWeight: FontWeight.w900,
                        fontSize: 13 * context.fontSizeFactor,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (balance != null) 
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              "${_getCurrencySymbol(currency)} $balance",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w900,
                                fontSize: 12 * context.fontSizeFactor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6 * context.fontSizeFactor),
                          GestureDetector(
                            onTap: onMaxTap,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor, vertical: 3 * context.fontSizeFactor),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(8 * context.fontSizeFactor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                    blurRadius: 4 * context.fontSizeFactor,
                                  ),
                                ],
                              ),
                              child: Text(
                                l10n.maxLabel,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10 * context.fontSizeFactor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2 * context.fontSizeFactor),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller, focusNode: focusNode, onChanged: onChanged,
                      keyboardType: TextInputType.numberWithOptions(decimal: decimals > 0),
                      inputFormatters: [ThousandsFormatter(decimals: decimals)],
                      style: TextStyle(fontSize: 28 * context.fontSizeFactor, fontWeight: FontWeight.w900, color: isError ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color, letterSpacing: -1),
                      decoration: InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: "0.00", hintStyle: TextStyle(color: Colors.grey[300])),
                    ),
                  ),
                  SizedBox(width: 8 * context.fontSizeFactor),
                  InkWell(
                    onTap: onCurrencyTap,
                    borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10 * context.fontSizeFactor, vertical: 6 * context.fontSizeFactor),
                      decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12 * context.fontSizeFactor), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08))),
                      child: Row(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(4 * context.fontSizeFactor), child: Image.network("https://flagcdn.com/w40/${_getFlagCode(currency)}.png", width: 22 * context.fontSizeFactor, height: 15 * context.fontSizeFactor, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.flag, size: 16 * context.fontSizeFactor))),
                          SizedBox(width: 6 * context.fontSizeFactor),
                          Text(currency, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor)),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 18 * context.fontSizeFactor, color: AppColors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayoutMethodsGrid(ThemeData theme, AppLocalizations l10n) {
    final allMethods = [
      {"name": "EVC Plus", "image": "assets/images/evc.png", "category": "Mobile Money", "sublabel": l10n.instantTransfer},
      {"name": "ZAAD Service", "image": "assets/images/zaad.png", "category": "Mobile Money", "sublabel": l10n.instantTransfer},
      {"name": "e-Dahab", "image": "assets/images/edahab.png", "category": "Mobile Money", "sublabel": l10n.instantTransfer},
      {"name": "Murtaax Wallet", "image": "assets/images/walletlogo.png", "category": "Murtaax Wallet", "sublabel": l10n.instantTransfer},
      {"name": "Sahal", "image": "assets/images/evc.png", "category": "Mobile Money", "sublabel": l10n.instantTransfer},
      {"name": "Bank Transfer", "image": "assets/images/bank.png", "category": "Bank", "sublabel": l10n.arrivesIn24h},
    ];

    final categories = ["All", "Bank", "Mobile Money", "Murtaax Wallet"];
    
    final filteredMethods = _selectedCategory == "All" 
        ? allMethods 
        : allMethods.where((m) => m["category"] == _selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories
        SizedBox(
          height: 36 * context.fontSizeFactor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              bool isCatSelected = _selectedCategory == cat;
              return Padding(
                padding: EdgeInsets.only(right: 8 * context.fontSizeFactor),
                child: ChoiceChip(
                  label: Text(cat, style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.w900, color: isCatSelected ? Colors.white : theme.textTheme.bodyMedium?.color)),
                  selected: isCatSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: theme.colorScheme.secondary,
                  backgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                  side: BorderSide(color: isCatSelected ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1)),
                  padding: EdgeInsets.symmetric(horizontal: 4 * context.fontSizeFactor),
                  visualDensity: VisualDensity.compact,
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12 * context.fontSizeFactor),
        // Methods
        SizedBox(
          height: 70 * context.fontSizeFactor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredMethods.length,
            padding: EdgeInsets.symmetric(vertical: 2 * context.fontSizeFactor),
            itemBuilder: (context, index) {
              final method = filteredMethods[index];
              bool isSelected = _selectedMethod == method["name"];
              return Padding(
                padding: EdgeInsets.only(right: 12 * context.fontSizeFactor),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedMethod = method["name"]!);
                  },
                  borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                      border: Border.all(color: isSelected ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.15), width: 2 * context.fontSizeFactor),
                      boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.4), blurRadius: 10 * context.fontSizeFactor, offset: Offset(0, 4 * context.fontSizeFactor))] : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6 * context.fontSizeFactor),
                          decoration: BoxDecoration(color: isSelected ? Colors.white.withValues(alpha: 0.2) : theme.dividerColor.withValues(alpha: 0.05), shape: BoxShape.circle),
                          child: Image.asset(method["image"]!, width: 22 * context.fontSizeFactor, height: 22 * context.fontSizeFactor, errorBuilder: (c, e, s) => Icon(Icons.payment, size: 20 * context.fontSizeFactor, color: isSelected ? Colors.white : AppColors.grey)),
                        ),
                        SizedBox(width: 10 * context.fontSizeFactor),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method["name"]!, 
                              style: TextStyle(fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color),
                            ),
                            Text(
                              method["sublabel"]!,
                              style: TextStyle(fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : AppColors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isError = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: TextStyle(color: isError ? Colors.red : AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
        SizedBox(width: 8 * context.fontSizeFactor),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(color: isError ? Colors.red : (isTotal ? (theme.brightness == Brightness.dark ? Colors.white : AppColors.primaryDark) : AppColors.grey), fontSize: isTotal ? 20 * context.fontSizeFactor : 15 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitIndicators(AppState state, AppLocalizations l10n, ThemeData theme) {
    double dailyRemaining = state.getDailyRemaining();
    double monthlyRemaining = state.getMonthlyRemaining();
    
    // Convert current total to pay to USD for limit comparison
    double amountInUsd = _totalToPay / (rates[_sendCurrency] ?? 1.0);

    return Container(
      padding: EdgeInsets.all(12 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildLimitBar(
            label: l10n.dailyLimit,
            remaining: dailyRemaining,
            limit: state.dailyLimit,
            projected: amountInUsd,
            theme: theme,
            l10n: l10n,
          ),
          SizedBox(height: 12 * context.fontSizeFactor),
          _buildLimitBar(
            label: l10n.monthlyLimit,
            remaining: monthlyRemaining,
            limit: state.monthlyLimit,
            projected: amountInUsd,
            theme: theme,
            l10n: l10n,
          ),
          if (amountInUsd > dailyRemaining || amountInUsd > monthlyRemaining)
            Padding(
              padding: EdgeInsets.only(top: 12 * context.fontSizeFactor),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16 * context.fontSizeFactor),
                  SizedBox(width: 8 * context.fontSizeFactor),
                  Expanded(
                    child: Text(
                      l10n.exceedsLimitWarning,
                      style: TextStyle(color: Colors.red, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else if (amountInUsd > dailyRemaining * 0.8)
             Padding(
              padding: EdgeInsets.only(top: 12 * context.fontSizeFactor),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16 * context.fontSizeFactor),
                  SizedBox(width: 8 * context.fontSizeFactor),
                  Expanded(
                    child: Text(
                      l10n.approachingLimitWarning,
                      style: TextStyle(color: Colors.orange, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLimitBar({
    required String label,
    required double remaining,
    required double limit,
    required double projected,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
    double currentPercent = (remaining / limit).clamp(0.0, 1.0);
    double afterPercent = ((remaining - projected) / limit).clamp(0.0, 1.0);
    bool exceeds = projected > remaining;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.grey)),
            Text(
              exceeds 
                ? l10n.limitExceeded 
                : "${_formatCurrency(remaining - projected, 2)} USD ${l10n.remaining}",
              style: TextStyle(
                fontSize: 11 * context.fontSizeFactor, 
                fontWeight: FontWeight.w900, 
                color: exceeds ? Colors.red : (afterPercent < 0.2 ? Colors.orange : theme.colorScheme.secondary)
              ),
            ),
          ],
        ),
        SizedBox(height: 6 * context.fontSizeFactor),
        Stack(
          children: [
            // Background
            Container(
              height: 6 * context.fontSizeFactor,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3 * context.fontSizeFactor),
              ),
            ),
            // Projected Progress (What will be left after this transaction)
            if (!exceeds)
              FractionallySizedBox(
                widthFactor: afterPercent,
                child: Container(
                  height: 6 * context.fontSizeFactor,
                  decoration: BoxDecoration(
                    color: afterPercent < 0.2 ? Colors.orange : theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(3 * context.fontSizeFactor),
                  ),
                ),
              ),
            if (exceeds)
              Container(
                height: 6 * context.fontSizeFactor,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3 * context.fontSizeFactor),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class ThousandsFormatter extends TextInputFormatter {
  final int decimals;
  ThousandsFormatter({this.decimals = 2});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String cleanText = newValue.text.replaceAll(',', '');
    if (cleanText.split('.').length > 2) return oldValue;
    if (cleanText.contains('.') && decimals == 0) return oldValue;
    if (cleanText.contains('.') && cleanText.split('.')[1].length > decimals) return oldValue;

    List<String> parts = cleanText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    if (integerPart.isEmpty) integerPart = "0";
    final formatter = NumberFormat("#,###");
    try {
      double parsed = double.parse(integerPart);
      String formattedInteger = formatter.format(parsed);
      String finalString = formattedInteger + (decimalPart != null ? ".$decimalPart" : (cleanText.endsWith('.') ? "." : ""));
      return TextEditingValue(text: finalString, selection: TextSelection.collapsed(offset: finalString.length));
    } catch (e) {
      return oldValue;
    }
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  final List<Map<String, String>> currencies;
  final String searchHint;
  final Function(Map<String, String>) onSelected;
  const _CurrencyPickerSheet({required this.currencies, required this.searchHint, required this.onSelected});
  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  late List<Map<String, String>> filteredCurrencies;
  @override
  void initState() { super.initState(); filteredCurrencies = widget.currencies; }
  void _filterCurrencies(String query) { setState(() => filteredCurrencies = widget.currencies.where((c) => c['code']!.toLowerCase().contains(query.toLowerCase()) || c['name']!.toLowerCase().contains(query.toLowerCase())).toList()); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: _filterCurrencies,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey),
                prefixIcon: Icon(Icons.search, size: 28, color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                final c = filteredCurrencies[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      "https://flagcdn.com/w40/${c['flag']}.png",
                      width: 40,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 28,
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        child: const Icon(Icons.flag, size: 20),
                      ),
                    ),
                  ),
                  title: Text(
                    c['code']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    c['name']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.grey,
                    ),
                  ),
                  onTap: () {
                    widget.onSelected(c);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
