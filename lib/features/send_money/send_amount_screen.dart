import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
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
  final TextEditingController _sendController = TextEditingController(text: "0.00");
  final TextEditingController _receiveController = TextEditingController(text: "0.00");
  final FocusNode _sendFocusNode = FocusNode();
  final FocusNode _receiveFocusNode = FocusNode();
  String _sendCurrency = "USD";
  String _receiveCurrency = "USD";
  String _selectedMethod = "EVC Plus";
  String _selectedSource = "Main Wallet";
  String? _selectedCardId;
  bool _isCalculating = false;
  bool _isRefreshing = false;
  bool _isFeeIncluded = false; 
  bool _showShakeError = false;
  DateTime? _lastRateUpdate;
  Timer? _refreshTimer;

  final List<Map<String, String>> _currencies = [
    {"code": "USD", "name": "US Dollar", "flag": "us"},
    {"code": "EUR", "name": "Euro", "flag": "eu"},
    {"code": "GBP", "name": "British Pound", "flag": "gb"},
    {"code": "KES", "name": "Kenyan Shilling", "flag": "ke"},
    {"code": "SOS", "name": "Somali Shilling", "flag": "so"},
    {"code": "AED", "name": "UAE Dirham", "flag": "ae"},
    {"code": "TRY", "name": "Turkish Lira", "flag": "tr"},
    {"code": "DJF", "name": "Djiboutian Franc", "flag": "dj"},
    {"code": "ETB", "name": "Ethiopian Birr", "flag": "et"},
    {"code": "SAR", "name": "Saudi Riyal", "flag": "sa"},
    {"code": "CAD", "name": "Canadian Dollar", "flag": "ca"},
    {"code": "AUD", "name": "Australian Dollar", "flag": "au"},
    {"code": "CNY", "name": "Chinese Yuan", "flag": "cn"},
    {"code": "JPY", "name": "Japanese Yen", "flag": "jp"},
    {"code": "INR", "name": "Indian Rupee", "flag": "in"},
    {"code": "UGX", "name": "Ugandan Shilling", "flag": "ug"},
    {"code": "RWF", "name": "Rwandan Franc", "flag": "rw"},
    {"code": "TZS", "name": "Tanzanian Shilling", "flag": "tz"},
    {"code": "CHF", "name": "Swiss Franc", "flag": "ch"},
    {"code": "ZAR", "name": "South African Rand", "flag": "za"},
  ];

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

  double _getFee(AppState state) {
    double amount = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) return 0.00;
    
    double amountInUsd = state.convertAmount(amount, _sendCurrency, 'USD');
    double feeInUsd = state.calculateFeeForSource(
      amountInUsd, 
      _selectedSource,
      payoutMethod: _getCanonicalMethod(_selectedMethod),
    );
    
    double feeInCurrentCurrency = state.convertAmount(feeInUsd, 'USD', _sendCurrency);
    return double.parse(feeInCurrentCurrency.toStringAsFixed(_sendCurrencyDecimals));
  }

  double _getTotalToPay(AppState state) {
    double amount = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) return 0.00;
    if (_isFeeIncluded) return amount;
    double total = amount + _getFee(state);
    return double.parse(total.toStringAsFixed(_sendCurrencyDecimals));
  }

  bool _hasSufficientBalance(AppState state) {
    if (_getTotalToPay(state) <= 0) return true;
    double amountInUsd = state.convertAmount(_getTotalToPay(state), _sendCurrency, 'USD');
    return state.hasSufficientBalanceForSource(
      amountInUsd,
      _selectedSource,
      cardId: _selectedCardId,
      payoutMethod: _getCanonicalMethod(_selectedMethod),
    );
  }
  
  double _getMaxLimitInCurrentCurrency(AppState state) => state.convertAmount(state.dailyLimit, 'USD', _sendCurrency);
  double _getMinLimitInCurrentCurrency(AppState state) => state.convertAmount(10.0, 'USD', _sendCurrency);

  bool _isAmountValid(AppState state) {
    double amt = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    if (amt < _getMinLimitInCurrentCurrency(state)) return false;
    
    double amountInUsd = state.convertAmount(_getTotalToPay(state), _sendCurrency, 'USD');
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      _loadRates(state);
      _startRefreshTimer(state);
    });

    _sendFocusNode.addListener(() {
      if (_sendFocusNode.hasFocus && _sendController.text == "0.00") _sendController.clear();
    });
  }

  void _startRefreshTimer(AppState state) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) => _loadRates(state));
  }

  void _loadRates(AppState state) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await state.updateMarketRates();
      if (mounted) {
        setState(() {
          _lastRateUpdate = DateTime.now();
          _updateReceiveAmount(_sendController.text, state);
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

  void _updateReceiveAmount(String value, AppState state) {
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
    
    setState(() => _isCalculating = true);
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          double effectiveAmount = _isFeeIncluded ? (amount - _getFee(state)) : amount;
          _receiveController.text = _formatCurrency(
            state.convertAmount(effectiveAmount, _sendCurrency, _receiveCurrency), 
            _receiveCurrencyDecimals
          );
          _isCalculating = false;
        });
      }
    });
  }

  void _updateSendAmount(String value, AppState state) {
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
    
    setState(() => _isCalculating = true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          double sendAmount = state.convertAmount(amount, _receiveCurrency, _sendCurrency);
          if (_isFeeIncluded) {
            double amountInUsd = state.convertAmount(sendAmount, _sendCurrency, 'USD');
            double feeInUsd = state.calculateFeeForSource(
              amountInUsd, 
              _selectedSource, 
              payoutMethod: _getCanonicalMethod(_selectedMethod)
            );
            sendAmount = sendAmount + state.convertAmount(feeInUsd, 'USD', _sendCurrency); 
          }
          _sendController.text = _formatCurrency(sendAmount, _sendCurrencyDecimals);
          _isCalculating = false;
        });
      }
    });
  }

  void _setMaxAmount(AppState state) {
    HapticFeedback.mediumImpact();
    double availableBalance = state.balance;
    if (_selectedSource.contains("Card") && _selectedCardId != null) {
      final card = state.cards.firstWhere((c) => c.id == _selectedCardId);
      availableBalance = card.balance;
    }
    
    // Limit to $2500 per transaction for security mock
    double limitInUsd = 2500.0;
    double maxSpendUsd = availableBalance > limitInUsd ? limitInUsd : availableBalance;
    
    double feeInUsd = state.calculateFeeForSource(
      maxSpendUsd, 
      _selectedSource,
      payoutMethod: _getCanonicalMethod(_selectedMethod)
    );
    
    double maxSendUsd = _isFeeIncluded ? maxSpendUsd : (maxSpendUsd - feeInUsd);
    if (maxSendUsd < 0) maxSendUsd = 0;
    
    setState(() {
      _sendController.text = _formatCurrency(
        state.convertAmount(maxSendUsd, 'USD', _sendCurrency), 
        _sendCurrencyDecimals
      );
      _updateReceiveAmount(_sendController.text, state);
    });
  }

  void _addQuickAmount(int amount, AppState state) {
    HapticFeedback.lightImpact();
    double current = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    _sendController.text = _formatCurrency(
      current + state.convertAmount(amount.toDouble(), 'USD', _sendCurrency), 
      _sendCurrencyDecimals
    );
    _updateReceiveAmount(_sendController.text, state);
  }

  void _showCurrencyPicker(bool isSource, AppLocalizations l10n, AppState state) {
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
              _updateReceiveAmount(_sendController.text, state);
            }
          });
        },
      ),
    );
  }

  String _getFlagCode(String currencyCode) => _currencies.firstWhere((c) => c['code'] == currencyCode, orElse: () => {"flag": "us"})['flag']!;
  String _getCurrencySymbol(String code) { try { return NumberFormat.simpleCurrency(name: code).currencySymbol; } catch (e) { return code; } }

  void _handleContinue(AppLocalizations l10n, AppState state) {
    if (!_isAmountValid(state) || !_hasSufficientBalance(state)) {
      setState(() => _showShakeError = true);
      Future.delayed(const Duration(milliseconds: 500), () => setState(() => _showShakeError = false));
      HapticFeedback.vibrate();
      return;
    }

    double amount = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    double receiveAmount = double.tryParse(_receiveController.text.replaceAll(',', '')) ?? 0;
    
    Widget nextScreen;
    if (_selectedMethod == "Bank Transfer") {
      nextScreen = BankScreen(
        amount: amount.toString(), 
        currencyCode: _sendCurrency, 
        senderSource: _selectedSource,
        cardId: _selectedCardId,
        method: _selectedMethod,
      );
    } else if (_selectedMethod == "Murtaax Wallet") {
      nextScreen = WalletReceiverScreen(
        amount: amount.toString(), 
        currencyCode: _sendCurrency, 
        senderSource: _selectedSource,
        cardId: _selectedCardId,
        method: _selectedMethod,
      );
    } else {
      nextScreen = ReceiverScreen(
        amount: amount.toString(), 
        currencyCode: _sendCurrency,
        method: _selectedMethod,
        senderSource: _selectedSource,
        cardId: _selectedCardId,
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen));
  }

  void _showFeeInfo(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 10),
            Text(l10n.feeInfoTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(l10n.feeInfoDescription),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSourceChip({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final factor = context.fontSizeFactor.toDouble();
    return Padding(
      padding: EdgeInsets.only(right: 8 * factor),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16 * factor,
              color: isSelected ? Colors.white : theme.colorScheme.secondary,
            ),
            SizedBox(width: 8 * factor),
            Text(
              title,
              style: TextStyle(
                fontSize: 12 * factor,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.secondary,
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * factor)),
        side: BorderSide(color: isSelected ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1)),
        padding: EdgeInsets.symmetric(horizontal: 4 * factor),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildAmountInput({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String currency,
    required Function(String) onChanged,
    required VoidCallback onCurrencyTap,
    required AppState state,
    String? balance,
    bool isError = false,
    bool isReceiver = false,
    bool isLoading = false,
    VoidCallback? onMaxTap,
    required int decimals,
  }) {
    final theme = Theme.of(context);
    final factor = context.fontSizeFactor.toDouble();
    
    return Container(
      padding: EdgeInsets.all(12 * factor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20 * factor),
        border: Border.all(color: isError ? Colors.red.withValues(alpha: 0.5) : theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 12 * factor, fontWeight: FontWeight.bold, color: AppColors.grey)),
              if (balance != null)
                GestureDetector(
                  onTap: onMaxTap,
                  child: Text("${AppLocalizations.of(context)!.balance}: $balance $currency", style: TextStyle(fontSize: 11 * factor, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onCurrencyTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8 * factor, vertical: 4 * factor),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12 * factor)),
                  child: Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network("https://flagcdn.com/w40/${_getFlagCode(currency)}.png", width: 24 * factor, height: 16 * factor, fit: BoxFit.cover)),
                      SizedBox(width: 6 * factor),
                      Text(currency, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * factor)),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 18 * factor),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoading 
                  ? Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(height: 30, color: Colors.white))
                  : TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 24 * factor, fontWeight: FontWeight.w900, color: isError ? Colors.red : theme.textTheme.titleLarge?.color, letterSpacing: -1),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      onChanged: onChanged,
                      inputFormatters: [ThousandsFormatter(decimals: decimals)],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutMethodsGrid(ThemeData theme, AppLocalizations l10n) {
    final methods = [
      {"name": "EVC Plus", "icon": Icons.phone_android_rounded},
      {"name": "ZAAD Service", "icon": Icons.account_balance_wallet_rounded},
      {"name": "e-Dahab", "icon": Icons.wallet_rounded},
      {"name": "Bank Transfer", "icon": Icons.account_balance_rounded},
      {"name": "Murtaax Wallet", "icon": Icons.swap_horiz_rounded},
    ];
    final factor = context.fontSizeFactor.toDouble();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: methods.map((m) {
          bool isSelected = _selectedMethod == m['name'];
          return Padding(
            padding: EdgeInsets.only(right: 8 * factor),
            child: ChoiceChip(
              label: Text(m['name'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12 * factor)),
              selected: isSelected,
              onSelected: (v) { if (v) setState(() => _selectedMethod = m['name'] as String); },
              selectedColor: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.surface,
              labelStyle: TextStyle(color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * factor)),
              side: BorderSide(color: isSelected ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLimitIndicators(AppState state, AppLocalizations l10n, ThemeData theme) {
    final factor = context.fontSizeFactor.toDouble();
    double dailyRem = state.getDailyRemaining();
    double monthlyRem = state.getMonthlyRemaining();
    double dailyTotal = state.dailyLimit;
    double monthlyTotal = state.monthlyLimit;

    return Column(
      children: [
        _buildLimitProgress(l10n.dailyLimit, dailyRem, dailyTotal, theme, factor),
        SizedBox(height: 10 * factor),
        _buildLimitProgress(l10n.monthlyLimit, monthlyRem, monthlyTotal, theme, factor),
      ],
    );
  }

  Widget _buildLimitProgress(String label, double remaining, double total, ThemeData theme, double factor) {
    double percent = total > 0 ? (total - remaining) / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 11 * factor, fontWeight: FontWeight.bold, color: AppColors.grey)),
            Text("${AppLocalizations.of(context)!.remaining}: \$${remaining.toStringAsFixed(0)}", style: TextStyle(fontSize: 11 * factor, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary)),
          ],
        ),
        SizedBox(height: 4 * factor),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: percent, backgroundColor: theme.dividerColor.withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation<Color>(percent > 0.9 ? Colors.red : theme.colorScheme.secondary), minHeight: 6 * factor),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isError = false}) {
    final factor = context.fontSizeFactor.toDouble();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * factor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 16 * factor : 14 * factor, fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold, color: isTotal ? null : AppColors.grey)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 * factor : 14 * factor, fontWeight: FontWeight.w900, color: isError ? Colors.red : (isTotal ? Theme.of(context).colorScheme.secondary : null))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context);
    final factor = context.fontSizeFactor.toDouble();

    bool hasSufficient = _hasSufficientBalance(state);
    bool canProceed = hasSufficient && _isAmountValid(state);
    double currentAmount = double.tryParse(_sendController.text.replaceAll(',', '')) ?? 0;
    bool isInputEmpty = _sendController.text.isEmpty || currentAmount == 0;
    
    double currentBalance = state.balance;
    if (_selectedSource.contains("Card") && _selectedCardId != null) {
      final card = state.cards.firstWhere((c) => c.id == _selectedCardId);
      currentBalance = card.balance;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: widget.showBackButton ? IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * factor), onPressed: () => Navigator.pop(context)) : null,
        title: Text(l10n.sendMoney, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 22 * factor, color: Colors.white, letterSpacing: -0.5)),
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
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30 * factor), bottomRight: Radius.circular(30 * factor)),
                      ),
                      padding: EdgeInsets.only(bottom: 10 * factor),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * factor),
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
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(l10n.enterAmount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * factor, color: theme.textTheme.titleMedium?.color), overflow: TextOverflow.ellipsis)),
                              SizedBox(width: 8 * factor),
                              GestureDetector(
                                onTap: () => _showFeeInfo(l10n),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(child: Text(l10n.feeInfoTitle, style: TextStyle(fontSize: 13 * factor, color: theme.colorScheme.secondary, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                                    SizedBox(width: 4 * factor),
                                    Icon(Icons.info_outline_rounded, size: 15 * factor, color: theme.colorScheme.secondary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.paymentMethod,
                                style: TextStyle(
                                  fontSize: 14 * factor,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50 * factor,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _buildSourceChip(
                                      title: l10n.mainWallet,
                                      isSelected: _selectedSource == "Main Wallet",
                                      onTap: () {
                                        setState(() {
                                          _selectedSource = "Main Wallet";
                                          _selectedCardId = null;
                                          _updateReceiveAmount(_sendController.text, state);
                                        });
                                      },
                                      icon: Icons.account_balance_wallet_rounded,
                                    ),
                                    ...state.cards.map((card) => _buildSourceChip(
                                      title: "Card ****${card.cardNumber.substring(card.cardNumber.length - 4)}",
                                      isSelected: _selectedCardId == card.id,
                                      onTap: () {
                                        setState(() {
                                          _selectedSource = "Debit Card";
                                          _selectedCardId = card.id;
                                          _updateReceiveAmount(_sendController.text, state);
                                        });
                                      },
                                      icon: Icons.credit_card_rounded,
                                    )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                          
                          _buildAmountInput(
                            label: l10n.youSend,
                            controller: _sendController,
                            focusNode: _sendFocusNode,
                            currency: _sendCurrency,
                            state: state,
                            balance: _formatCurrency(state.convertAmount(currentBalance, 'USD', _sendCurrency), _sendCurrencyDecimals),
                            onChanged: (val) => _updateReceiveAmount(val, state),
                            onCurrencyTap: () => _showCurrencyPicker(true, l10n, state),
                            isError: currentAmount > 0 && !_isAmountValid(state),
                            onMaxTap: () => _setMaxAmount(state),
                            decimals: _sendCurrencyDecimals,
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4 * factor),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [10, 50, 100, 500].map((amt) => Padding(
                                  padding: EdgeInsets.only(right: 8 * factor),
                                  child: ActionChip(
                                    label: Text("+ ${_getCurrencySymbol(_sendCurrency)} $amt", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13 * factor)),
                                    onPressed: () => _addQuickAmount(amt, state),
                                    backgroundColor: theme.colorScheme.surface,
                                    side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1), width: 1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * factor)),
                                    padding: EdgeInsets.symmetric(horizontal: 6 * factor, vertical: 2 * factor),
                                  ),
                                )).toList(),
                              ),
                            ),
                          ),

                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    setState(() {
                                      final temp = _sendCurrency; _sendCurrency = _receiveCurrency; _receiveCurrency = temp;
                                      _updateReceiveAmount(_sendController.text, state);
                                    });
                                  },
                                  child: Container(padding: EdgeInsets.all(4 * factor), decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 8 * factor)]), child: Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20 * factor)),
                                ),
                                SizedBox(height: 2 * factor),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    "1 $_sendCurrency = ${state.getExchangeRate(_sendCurrency, _receiveCurrency).toStringAsFixed(4)} $_receiveCurrency", 
                                    key: ValueKey("rate_$_sendCurrency-$_receiveCurrency"),
                                    style: TextStyle(fontSize: 14 * factor, fontWeight: FontWeight.w900, color: theme.textTheme.bodyMedium?.color, letterSpacing: -0.5)
                                  ),
                                ),
                                if (_lastRateUpdate != null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("${l10n.refreshed}: ${DateFormat('HH:mm:ss').format(_lastRateUpdate!)}", style: TextStyle(fontSize: 10 * factor, color: AppColors.grey.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
                                      SizedBox(width: 4 * factor),
                                      _isRefreshing ? SizedBox(width: 8 * factor, height: 8 * factor, child: const CircularProgressIndicator(strokeWidth: 1.5)) : Icon(Icons.auto_awesome, size: 10 * factor, color: theme.colorScheme.secondary),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 2),

                          _buildAmountInput(
                            label: l10n.receiverGets,
                            controller: _receiveController,
                            focusNode: _receiveFocusNode,
                            currency: _receiveCurrency,
                            state: state,
                            onChanged: (val) => _updateSendAmount(val, state),
                            onCurrencyTap: () => _showCurrencyPicker(false, l10n, state),
                            isReceiver: true,
                            isLoading: _isCalculating,
                            decimals: _receiveCurrencyDecimals,
                          ),

                          const SizedBox(height: 8),
                          
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10 * factor, vertical: 4 * factor),
                            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16 * factor), border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5)),
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long_rounded, color: theme.colorScheme.secondary, size: 20 * factor),
                                SizedBox(width: 8 * factor),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.deductFeeFromAmount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13 * factor)),
                                      Text(_isFeeIncluded ? l10n.receiverWillReceiveLess : l10n.payFeeSeparately, style: TextStyle(fontSize: 10 * factor, color: AppColors.grey, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.8 * factor,
                                  child: Switch.adaptive(
                                    value: _isFeeIncluded,
                                    activeTrackColor: theme.colorScheme.secondary,
                                    onChanged: (v) {
                                      setState(() {
                                        _isFeeIncluded = v;
                                        _updateReceiveAmount(_sendController.text, state);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 16 * factor),
                          Text(l10n.payoutMethod, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * factor, color: theme.textTheme.titleMedium?.color)),
                          SizedBox(height: 4 * factor),
                          _buildPayoutMethodsGrid(theme, l10n),
                          
                          SizedBox(height: 8 * factor),
                          
                          if (!isInputEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.security_rounded, size: 18 * factor, color: theme.colorScheme.secondary),
                                SizedBox(width: 8 * factor),
                                Text(
                                  l10n.transactionLimits,
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * factor, color: theme.textTheme.titleMedium?.color),
                                ),
                              ],
                            ),
                            SizedBox(height: 10 * factor),
                            _buildLimitIndicators(state, l10n, theme),
                            SizedBox(height: 16 * factor),
                          ],

                          Container(
                            padding: EdgeInsets.all(12 * factor),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20 * factor),
                              border: Border.all(color: !hasSufficient ? Colors.red.withValues(alpha: 0.8) : theme.dividerColor.withValues(alpha: 0.1), width: 2),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10 * factor, offset: Offset(0, 4 * factor))],
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow(l10n.transactionFee, isInputEmpty ? "-" : "${_getCurrencySymbol(_sendCurrency)} ${_formatCurrency(_getFee(state), _sendCurrencyDecimals)}"),
                                Divider(height: 12 * factor, thickness: 1),
                                _buildSummaryRow(l10n.totalToPay, isInputEmpty ? "-" : "${_getCurrencySymbol(_sendCurrency)} ${_formatCurrency(_getTotalToPay(state), _sendCurrencyDecimals)}", isTotal: true, isError: !hasSufficient),
                                if (_selectedMethod == "Bank Transfer" && !isInputEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8 * factor),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.access_time_filled_rounded, size: 14 * factor, color: Colors.orange),
                                        SizedBox(width: 6 * factor),
                                        Text(l10n.arrivesIn24h, style: TextStyle(fontSize: 11 * factor, color: Colors.orange.shade700, fontWeight: FontWeight.w900)),
                                      ],
                                    ),
                                  ),
                                if (!hasSufficient)
                                  Padding(padding: EdgeInsets.only(top: 4 * factor), child: Text(l10n.insufficientBalance, style: TextStyle(color: Colors.red, fontSize: 12 * factor, fontWeight: FontWeight.w900), textAlign: TextAlign.center)),
                              ],
                            ),
                          ),
                          SizedBox(height: 16 * factor),
                          ShakeX(
                            duration: const Duration(milliseconds: 500),
                            animate: _showShakeError,
                            child: SizedBox(
                              width: double.infinity,
                              height: 52 * factor,
                              child: ElevatedButton(
                                onPressed: () => _handleContinue(l10n, state),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canProceed ? theme.colorScheme.secondary : (theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300]),
                                  foregroundColor: canProceed ? theme.colorScheme.onSecondary : Colors.white70,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * factor)),
                                  elevation: canProceed ? 4 : 0,
                                ),
                                child: Text(
                                  _selectedMethod == "Bank Transfer" 
                                    ? l10n.continueToBank 
                                    : (_selectedMethod == "Murtaax Wallet" ? l10n.continueToWallet : l10n.continueToReceiver), 
                                  style: TextStyle(fontSize: 16 * factor, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20 * factor),
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
  void initState() { 
    super.initState(); 
    filteredCurrencies = widget.currencies; 
  }
  
  void _filterCurrencies(String query) { 
    setState(() => filteredCurrencies = widget.currencies.where((c) => c['code']!.toLowerCase().contains(query.toLowerCase()) || c['name']!.toLowerCase().contains(query.toLowerCase())).toList()); 
  }

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
