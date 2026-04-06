import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _sendController = TextEditingController(text: "0.00");
  final TextEditingController _receiveController = TextEditingController(text: "0.00");
  final FocusNode _sendFocusNode = FocusNode();
  final FocusNode _receiveFocusNode = FocusNode();
  String _sendCurrency = "USD";
  String _receiveCurrency = "USD";
  String _selectedMethod = "EVC Plus";
  final double _userBalance = 2450.00;

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
    "USD": 1.0,
    "EUR": 0.93,
    "GBP": 0.79,
    "CAD": 1.35,
    "KES": 128.50,
    "SOS": 570.00,
    "AED": 3.67,
    "SAR": 3.75,
    "TRY": 32.20,
    "ETB": 57.50,
    "DJF": 177.72,
    "UGX": 3750.00,
    "TZS": 2600.00,
    "RWF": 1300.00,
    "SDG": 600.00,
    "EGP": 47.50,
    "INR": 83.30,
    "CNY": 7.24,
    "JPY": 156.00,
    "AUD": 1.51,
    "CHF": 0.91,
    "ZAR": 18.50,
  };

  double get _fee {
    double amount = double.tryParse(_sendController.text) ?? 0;
    if (amount <= 0) return 0.00;
    return (amount / 100).ceil() * 0.99;
  }

  double get _totalToPay {
    double amount = double.tryParse(_sendController.text) ?? 0;
    return amount + _fee;
  }

  bool get _hasSufficientBalance => _totalToPay <= _userBalance;
  bool get _isAmountValid => (double.tryParse(_sendController.text) ?? 0) >= 10;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    try {
      final newRates = await ApiService.fetchAllRates();
      if (mounted) {
        setState(() {
          rates.addAll(newRates);
          _updateReceiveAmount(_sendController.text);
        });
      }
    } catch (e) {
      debugPrint("Error loading rates: $e");
    }
  }

  @override
  void dispose() {
    _sendController.dispose();
    _receiveController.dispose();
    _sendFocusNode.dispose();
    _receiveFocusNode.dispose();
    super.dispose();
  }

  void _updateReceiveAmount(String value) {
    double amount = double.tryParse(value) ?? 0;
    double fromRate = rates[_sendCurrency] ?? 1.0;
    double toRate = rates[_receiveCurrency] ?? 1.0;
    setState(() {
      double inUsd = amount / fromRate;
      _receiveController.text = (inUsd * toRate).toStringAsFixed(2);
    });
  }

  void _updateSendAmount(String value) {
    double amount = double.tryParse(value) ?? 0;
    double fromRate = rates[_sendCurrency] ?? 1.0;
    double toRate = rates[_receiveCurrency] ?? 1.0;
    setState(() {
      double inUsd = amount / toRate;
      _sendController.text = (inUsd * fromRate).toStringAsFixed(2);
    });
  }

  void _addQuickAmount(int amount) {
    double current = double.tryParse(_sendController.text) ?? 0;
    _sendController.text = (current + amount).toStringAsFixed(2);
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
              _updateReceiveAmount(_sendController.text);
            } else {
              _receiveCurrency = currency['code']!;
              _updateSendAmount(_receiveController.text);
            }
          });
        },
      ),
    );
  }

  String _getFlagCode(String currencyCode) {
    final currency = _currencies.firstWhere((c) => c['code'] == currencyCode, orElse: () => {"flag": "us"});
    return currency['flag']!;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    bool canProceed = _hasSufficientBalance && _isAmountValid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.showBackButton 
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color),
              onPressed: () => Navigator.pop(context),
            )
          : null,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.sendMoney,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 600,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.enterAmount,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.titleMedium?.color),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l10n.transferLimit, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w600)),
                          Text(
                            l10n.feeRate,
                            style: const TextStyle(fontSize: 11, color: AppColors.accentTeal, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildAmountInput(
                    label: l10n.youSend,
                    controller: _sendController,
                    focusNode: _sendFocusNode,
                    currency: _sendCurrency,
                    balance: "\$${_userBalance.toStringAsFixed(2)}",
                    onChanged: _updateReceiveAmount,
                    onCurrencyTap: () => _showCurrencyPicker(true, l10n),
                    isError: (double.tryParse(_sendController.text) ?? 0) > 0 && !_isAmountValid,
                  ),

                  const SizedBox(height: 16),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [10, 50, 100, 200].map((amt) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => _addQuickAmount(amt),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: Text("+\$$amt", style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final tempCurrency = _sendCurrency;
                              _sendCurrency = _receiveCurrency;
                              _receiveCurrency = tempCurrency;
                              _updateReceiveAmount(_sendController.text);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            "1 $_sendCurrency = ${((1 / (rates[_sendCurrency] ?? 1.0)) * (rates[_receiveCurrency] ?? 1.0)).toStringAsFixed(4)} $_receiveCurrency", 
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color)
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildAmountInput(
                    label: l10n.receiverGets,
                    controller: _receiveController,
                    focusNode: _receiveFocusNode,
                    currency: _receiveCurrency,
                    onChanged: _updateSendAmount,
                    onCurrencyTap: () => _showCurrencyPicker(false, l10n),
                    isReceiver: true,
                  ),

                  const SizedBox(height: 30),
                  Text(
                    l10n.selectPaymentMethod,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.titleMedium?.color),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodsGrid(state),

                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      border: !_hasSufficientBalance ? Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1.5) : Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(l10n.transactionFee, "\$${_fee.toStringAsFixed(2)}"),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          l10n.totalToPay, 
                          "\$${_totalToPay.toStringAsFixed(2)}", 
                          isTotal: true,
                          isError: !_hasSufficientBalance,
                        ),
                        if (!_hasSufficientBalance)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              l10n.insufficientBalance,
                              style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (canProceed) {
                                if (_selectedMethod == "Murtaax Wallet") {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => WalletReceiverScreen(amount: _sendController.text, method: _selectedMethod)));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReceiverScreen(amount: _sendController.text, method: _selectedMethod)));
                                }
                              } else {
                                String message = !_isAmountValid ? l10n.pleaseEnterDetails : l10n.insufficientBalance;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.continueLabel,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String currency,
    String? balance,
    required Function(String) onChanged,
    required VoidCallback onCurrencyTap,
    bool isReceiver = false,
    bool isError = false,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        bool isFocused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isError
                  ? Colors.red
                  : (isFocused
                      ? AppColors.accentTeal
                      : (isReceiver ? AppColors.accentTeal.withOpacity(0.3) : Colors.transparent)),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isError
                    ? Colors.red.withOpacity(0.1)
                    : (isFocused ? AppColors.accentTeal.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                blurRadius: isFocused || isError ? 20 : 15,
                offset: const Offset(0, 5),
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
                    label,
                    style: TextStyle(
                      color: isError ? Colors.red : (isFocused ? AppColors.accentTeal : AppColors.grey),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  if (balance != null)
                    Text("Balance: $balance", style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isError ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCurrencyTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              "https://flagcdn.com/w40/${_getFlagCode(currency)}.png",
                              width: 24,
                              height: 18,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(currency, style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey),
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

  Widget _buildPaymentMethodsGrid(AppState state) {
    final methods = [
      {"name": "MurtaaxPay Wallet", "icon": Icons.wallet_rounded, "image": "assets/images/walletlogo.png"},
      {"name": "EVC Plus", "icon": Icons.phone_android_rounded, "image": "assets/images/evc.png"},
      {"name": "ZAAD Service", "icon": Icons.account_balance_wallet_rounded, "image": "assets/images/zaad.png"},
      {"name": "e-Dahab", "icon": Icons.send_to_mobile_rounded, "image": "assets/images/edahab.png"},
      {"name": "Bank Transfer", "icon": Icons.account_balance_rounded, "image": "assets/images/bank.png"},
      {"name": "Visa/MasterCard", "icon": Icons.credit_card_rounded, "image": "assets/images/visa.png"},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: methods.length,
        itemBuilder: (context, index) {
          return _buildPaymentMethodItem(state, methods[index]);
        },
      ),
    );
  }

  Widget _buildPaymentMethodItem(AppState state, Map<String, dynamic> method) {
    final theme = Theme.of(context);
    final String label = method["name"];
    final String imagePath = method["image"];
    final IconData fallbackIcon = method["icon"];
    bool isSelected = _selectedMethod == label;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1), 
            width: 2.5
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.accentTeal.withOpacity(0.1) : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? theme.cardColor : theme.dividerColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                imagePath, 
                width: 28, 
                height: 28, 
                fit: BoxFit.contain, 
                errorBuilder: (c, e, s) => Icon(fallbackIcon, color: isSelected ? AppColors.accentTeal : AppColors.grey, size: 24),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label, 
              style: TextStyle(
                fontSize: 11, 
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, 
                color: isSelected ? theme.textTheme.bodyLarge?.color : AppColors.grey
              ), 
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isError = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label, 
            style: TextStyle(
              color: isError ? Colors.red : AppColors.grey, 
              fontSize: 15, 
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value, 
          style: TextStyle(
            color: isError ? Colors.red : AppColors.primaryDark, 
            fontSize: 18, 
            fontWeight: FontWeight.w900
          )
        ),
      ],
    );
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCurrencies = widget.currencies;
  }

  void _filterCurrencies(String query) {
    setState(() {
      filteredCurrencies = widget.currencies
          .where((c) =>
              c['code']!.toLowerCase().contains(query.toLowerCase()) ||
              c['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCurrencies,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                final c = filteredCurrencies[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      "https://flagcdn.com/w40/${c['flag']}.png",
                      width: 32,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag),
                    ),
                  ),
                  title: Text(c['code']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  subtitle: Text(c['name']!, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
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
