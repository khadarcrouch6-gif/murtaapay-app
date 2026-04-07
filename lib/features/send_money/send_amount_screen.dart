import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../core/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'receiver_screen.dart';
import 'wallet_receiver_screen.dart';

class SendAmountScreen extends StatefulWidget {
  final bool showBackButton;
  const SendAmountScreen({super.key, this.showBackButton = true});

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
  bool _isCalculating = false;
  bool _isRefreshing = false;
  bool _isFeeIncluded = false; 
  DateTime? _lastRateUpdate;
  Timer? _refreshTimer;

  final List<Map<String, String>> _currencies = [
    {"code": "USD", "name": "US Dollar", "flag": "us"},
    {"code": "EUR", "name": "Euro", "flag": "eu"},
    {"code": "GBP", "name": "British Pound", "flag": "gb"},
    {"code": "CAD", "name": "Canadian Dollar", "flag": "ca"},
    {"code": "KES", "name": "Kenyan Shilling", "flag": "ke"},
    {"code": "SOS", "name": "Somali Shilling", "flag": "so"},
    {"code": "AED", "name": "UAE Dirham", "flag": "ae"},
    {"code": "SAR", "name": "Saudi Riyal", "flag": "sa"},
    {"code": "TRY", "name": "Turkish Lira", "flag": "tr"},
    {"code": "ETB", "name": "Ethiopian Birr", "flag": "et"},
    {"code": "DJF", "name": "Djiboutian Franc", "flag": "dj"},
    {"code": "UGX", "name": "Ugandan Shilling", "flag": "ug"},
    {"code": "TZS", "name": "Tanzanian Shilling", "flag": "tz"},
    {"code": "RWF", "name": "Rwandan Franc", "flag": "rw"},
    {"code": "SDG", "name": "Sudanese Pound", "flag": "sd"},
    {"code": "EGP", "name": "Egyptian Pound", "flag": "eg"},
    {"code": "INR", "name": "Indian Rupee", "flag": "in"},
    {"code": "CNY", "name": "Chinese Yuan", "flag": "cn"},
    {"code": "JPY", "name": "Japanese Yen", "flag": "jp"},
    {"code": "AUD", "name": "Australian Dollar", "flag": "au"},
    {"code": "CHF", "name": "Swiss Franc", "flag": "ch"},
    {"code": "ZAR", "name": "South African Rand", "flag": "za"},
  ];

  final Map<String, double> rates = {
    "USD": 1.0, "EUR": 0.93, "GBP": 0.79, "CAD": 1.35, "KES": 128.50, "SOS": 570.00,
    "AED": 3.67, "SAR": 3.75, "TRY": 32.20, "ETB": 57.50, "DJF": 177.72, "UGX": 3750.00,
    "TZS": 2600.00, "RWF": 1300.00, "SDG": 600.00, "EGP": 47.50, "INR": 83.30, "CNY": 7.24,
    "JPY": 156.00, "AUD": 1.51, "CHF": 0.91, "ZAR": 18.50,
  };

  int get _sendCurrencyDecimals => ["SOS", "JPY", "UGX", "RWF", "TZS", "KRW"].contains(_sendCurrency) ? 0 : 2;
  int get _receiveCurrencyDecimals => ["SOS", "JPY", "UGX", "RWF", "TZS", "KRW"].contains(_receiveCurrency) ? 0 : 2;

  String _formatCurrency(double amount, int decimals) {
    final format = NumberFormat.currency(symbol: "", decimalDigits: decimals);
    return format.format(amount).trim();
  }

  double get _fee {
    double amount = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) return 0.00;
    double feeRate = (_selectedMethod.contains("Visa") || _selectedMethod.contains("MasterCard")) ? 0.029 : 0.0099;
    double calculatedFee = amount * feeRate;
    return double.parse(calculatedFee.toStringAsFixed(_sendCurrencyDecimals));
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
  
  double get _maxLimitInCurrentCurrency => 2500 * (rates[_sendCurrency] ?? 1.0);
  double get _minLimitInCurrentCurrency => 10 * (rates[_sendCurrency] ?? 1.0);

  bool get _isAmountValid {
    double amt = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    return amt >= _minLimitInCurrentCurrency && amt <= _maxLimitInCurrentCurrency;
  }

  @override
  void initState() {
    super.initState();
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
            double feeRate = (_selectedMethod.contains("Visa") || _selectedMethod.contains("MasterCard")) ? 0.029 : 0.0099;
            inUsd = inUsd / (1 - feeRate);
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
    double feeRate = (_selectedMethod.contains("Visa") || _selectedMethod.contains("MasterCard")) ? 0.029 : 0.0099;
    double maxSend = _isFeeIncluded ? (balanceInUsd * fromRate) : ((balanceInUsd / (1 + feeRate)) * fromRate);
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: widget.showBackButton ? IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 24), onPressed: () => Navigator.pop(context)) : null,
            title: Text(l10n.sendMoney, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
            centerTitle: true,
          ),
          body: Center(
            child: MaxWidthBox(
              maxWidth: 500,
              child: SafeArea(
                child: Column(
                  children: [
                    // --- PROGRESS STEPPER (Bolder) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                      child: Row(
                        children: [
                          _buildStepIndicator(1, "Amount", true, true),
                          _buildStepLine(false),
                          _buildStepIndicator(2, "Receiver", false, false),
                          _buildStepLine(false),
                          _buildStepIndicator(3, "Review", false, false),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.enterAmount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.textTheme.titleMedium?.color)),
                                GestureDetector(
                                  onTap: () => _showFeeInfo(l10n),
                                  child: Row(
                                    children: [
                                      Text(l10n.feeRate, style: const TextStyle(fontSize: 13, color: AppColors.accentTeal, fontWeight: FontWeight.w900)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.accentTeal),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            
                            // Input 1: You Send (High Visibility)
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [10, 50, 100, 500].map((amt) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      label: Text("+\$ $amt", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                                      onPressed: () => _addQuickAmount(amt),
                                      backgroundColor: theme.colorScheme.surface,
                                      side: BorderSide(color: theme.dividerColor.withOpacity(0.1), width: 1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                    child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 8)]), child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "1 $_sendCurrency = ${((1 / (rates[_sendCurrency] ?? 1.0)) * (rates[_receiveCurrency] ?? 1.0)).toStringAsFixed(4)} $_receiveCurrency", 
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: theme.textTheme.bodyMedium?.color, letterSpacing: -0.5)
                                  ),
                                  if (_lastRateUpdate != null)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Refreshed: ${DateFormat('HH:mm:ss').format(_lastRateUpdate!)}", style: TextStyle(fontSize: 11, color: AppColors.grey.withOpacity(0.7), fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 4),
                                        _isRefreshing ? const SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 1.5)) : const Icon(Icons.auto_awesome, size: 10, color: AppColors.accentTeal),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 4),

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

                            const SizedBox(height: 12),
                            
                            // Fee Toggle
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1.5)),
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt_long_rounded, color: AppColors.accentTeal, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.deductFeeFromAmount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                        Text(_isFeeIncluded ? l10n.receiverWillReceiveLess : l10n.payFeeSeparately, style: TextStyle(fontSize: 11, color: AppColors.grey, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(value: _isFeeIncluded, activeColor: AppColors.accentTeal, onChanged: (v) { setState(() { _isFeeIncluded = v; _updateReceiveAmount(_sendController.text); }); }),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            Text(l10n.selectPaymentMethod, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: theme.textTheme.titleMedium?.color)),
                            const SizedBox(height: 6),
                            _buildPaymentMethodsGrid(theme),
                            
                            const SizedBox(height: 12),
                            
                            // Summary Card (High Visibility)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: !hasSufficient ? Colors.red.withOpacity(0.8) : theme.dividerColor.withOpacity(0.1), width: 2),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
                              ),
                              child: Column(
                                children: [
                                  _buildSummaryRow(l10n.transactionFee, isInputEmpty ? "-" : "${_getCurrencySymbol(_sendCurrency)} ${_formatCurrency(_fee, _sendCurrencyDecimals)}"),
                                  const Divider(height: 16, thickness: 1),
                                  _buildSummaryRow(l10n.totalToPay, isInputEmpty ? "-" : "${_getCurrencySymbol(_sendCurrency)} ${_formatCurrency(_totalToPay, _sendCurrencyDecimals)}", isTotal: true, isError: !hasSufficient),
                                  if (!hasSufficient)
                                    Padding(padding: const EdgeInsets.only(top: 8), child: Text(l10n.insufficientBalance, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w900))),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: canProceed ? () => _handleContinue(l10n) : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accentTeal,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 4,
                                        shadowColor: AppColors.accentTeal.withOpacity(0.3),
                                        disabledBackgroundColor: Colors.grey[300],
                                      ),
                                      child: Text(l10n.continueLabel, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  void _showFeeInfo(AppLocalizations l10n) {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text("Khidmadda Sarifka", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
      content: const Text("Khidmaddu waa 0.99%.\n\nTusaale ahaan:\n\$100 waxaad ku diraysaa khidmad ah \$0.99 kaliya.", style: TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.w600)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w900, fontSize: 18)))]
    ));
  }

  void _handleContinue(AppLocalizations l10n) {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    final cleanAmount = _sendController.text.replaceAll(',', '');
    if (_selectedMethod == "Murtaax Wallet") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => WalletReceiverScreen(amount: cleanAmount, method: _selectedMethod)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ReceiverScreen(amount: cleanAmount, method: _selectedMethod)));
    }
  }

  Widget _buildStepIndicator(int step, String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: isActive || isCompleted ? AppColors.accentTeal : Colors.grey[300], shape: BoxShape.circle, border: isActive ? Border.all(color: AppColors.accentTeal.withOpacity(0.2), width: 4) : null),
          child: Center(child: isCompleted && !isActive ? const Icon(Icons.check, color: Colors.white, size: 18) : Text("$step", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: isActive ? AppColors.accentTeal : Colors.grey)),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted) { return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: isCompleted ? AppColors.accentTeal : Colors.grey[200], borderRadius: BorderRadius.circular(10)))); }

  Widget _buildAmountInput({
    required String label, required TextEditingController controller, required FocusNode focusNode, required String currency,
    String? balance, required Function(String) onChanged, required VoidCallback onCurrencyTap,
    bool isReceiver = false, bool isError = false, bool isLoading = false, int decimals = 2, VoidCallback? onMaxTap,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        bool isFocused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isError ? Colors.red.withOpacity(0.05) : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isError ? Colors.red : (isFocused ? AppColors.accentTeal : Theme.of(context).dividerColor.withOpacity(0.1)), width: isFocused ? 2 : 1.5),
            boxShadow: isFocused ? [BoxShadow(color: AppColors.accentTeal.withOpacity(0.08), blurRadius: 10, spreadRadius: 1)] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: TextStyle(color: isError ? Colors.red : AppColors.grey, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                  if (balance != null) Row(
                    children: [
                      Text("${_getCurrencySymbol(currency)} $balance", style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w900, fontSize: 12)),
                      const SizedBox(width: 6),
                      GestureDetector(onTap: onMaxTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.accentTeal, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: AppColors.accentTeal.withOpacity(0.2), blurRadius: 4)]), child: const Text("MAX", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller, focusNode: focusNode, onChanged: onChanged,
                      keyboardType: TextInputType.numberWithOptions(decimal: decimals > 0),
                      inputFormatters: [ThousandsFormatter(decimals: decimals)],
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isError ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color, letterSpacing: -1),
                      decoration: InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: "0.00", hintStyle: TextStyle(color: Colors.grey[300])),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onCurrencyTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08))),
                      child: Row(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network("https://flagcdn.com/w40/${_getFlagCode(currency)}.png", width: 22, height: 15, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.flag, size: 16))),
                          const SizedBox(width: 6),
                          Text(currency, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.grey),
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

  Widget _buildPaymentMethodsGrid(ThemeData theme) {
    final methods = [
      {"name": "EVC Plus", "image": "assets/images/evc.png"},
      {"name": "ZAAD Service", "image": "assets/images/zaad.png"},
      {"name": "e-Dahab", "image": "assets/images/edahab.png"},
      {"name": "Murtaax Wallet", "image": "assets/images/walletlogo.png"},
      {"name": "Sahal", "image": "assets/images/evc.png"},
      {"name": "Bank Transfer", "image": "assets/images/bank.png"},
      {"name": "Visa/MasterCard", "image": "assets/images/visa.png"},
    ];
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: methods.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final method = methods[index];
          bool isSelected = _selectedMethod == method["name"];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMethod = method["name"]!);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentTeal : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.accentTeal : theme.dividerColor.withOpacity(0.15), width: 2),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.accentTeal.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.2) : theme.dividerColor.withOpacity(0.05), shape: BoxShape.circle),
                      child: Image.asset(method["image"]!, width: 22, height: 22, errorBuilder: (c, e, s) => Icon(Icons.payment, size: 20, color: isSelected ? Colors.white : AppColors.grey)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      method["name"]!, 
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isError = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: TextStyle(color: isError ? Colors.red : AppColors.grey, fontSize: 14, fontWeight: FontWeight.w900))),
        const SizedBox(width: 10),
        Text(value, style: TextStyle(color: isError ? Colors.red : (isTotal ? AppColors.primaryDark : AppColors.grey), fontSize: isTotal ? 22 : 16, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: _filterCurrencies,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: widget.searchHint, prefixIcon: const Icon(Icons.search, size: 28), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 16)),
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
                  leading: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network("https://flagcdn.com/w40/${c['flag']}.png", width: 40, height: 28, fit: BoxFit.cover)),
                  title: Text(c['code']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  subtitle: Text(c['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  onTap: () { widget.onSelected(c); Navigator.pop(context); },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
