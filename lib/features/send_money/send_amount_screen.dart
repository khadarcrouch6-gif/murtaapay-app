import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'receiver_screen.dart';
import 'wallet_receiver_screen.dart';

class SendAmountScreen extends StatefulWidget {
  const SendAmountScreen({super.key});

  @override
  State<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen> {
  final TextEditingController _sendController = TextEditingController(text: "100");
  final TextEditingController _receiveController = TextEditingController(text: "108.00");
  String _sendCurrency = "EUR";
  String _receiveCurrency = "USD";
  String _selectedMethod = "EVC Plus";

  final Map<String, double> rates = {
    "EUR": 1.08,
    "USD": 1.0,
    "GBP": 1.27,
    "CAD": 0.74,
  };

  void _updateReceiveAmount(String value) {
    double amount = double.tryParse(value) ?? 0;
    double sendRate = rates[_sendCurrency] ?? 1.0;
    double receiveRate = rates[_receiveCurrency] ?? 1.0;
    setState(() {
      _receiveController.text = ((amount * sendRate) / receiveRate).toStringAsFixed(2);
    });
  }

  void _updateSendAmount(String value) {
    double amount = double.tryParse(value) ?? 0;
    double sendRate = rates[_sendCurrency] ?? 1.0;
    double receiveRate = rates[_receiveCurrency] ?? 1.0;
    setState(() {
      _sendController.text = ((amount * receiveRate) / sendRate).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          state.translate("Send Money", "Lacag Dir"),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20 * context.fontSizeFactor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.translate("Enter Amount", "Geli Cadadka"),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                      fontSize: 14 * context.fontSizeFactor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildAmountBox(
                    context,
                    state,
                    theme,
                    state.translate("You Send", "Adiga ayaa Diraya"), 
                    _sendController, 
                    _sendCurrency, 
                    (val) => _updateReceiveAmount(val), 
                    (currency) {
                      setState(() {
                        _sendCurrency = currency;
                        _updateReceiveAmount(_sendController.text);
                      });
                    }, 
                    ["EUR", "USD", "GBP", "CAD"]
                  ),
                  
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
                      child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildAmountBox(
                    context,
                    state,
                    theme,
                    state.translate("Receiver Gets", "Qaataha wuxuu Helayaa"), 
                    _receiveController, 
                    _receiveCurrency, 
                    (val) => _updateSendAmount(val), 
                    (currency) {
                      setState(() {
                        _receiveCurrency = currency;
                        _updateReceiveAmount(_sendController.text);
                      });
                    }, 
                    ["USD", "EUR", "GBP", "CAD"], 
                    isReceiver: true
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    state.translate("Select Payment Method", "Dooro Habka Lacagta"),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18 * context.fontSizeFactor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethods(state, theme),
                  
                  const SizedBox(height: 48),
                  FadeInUp(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56 * context.fontSizeFactor,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedMethod == "Murtaax Wallet") {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WalletReceiverScreen(amount: _sendController.text, method: _selectedMethod)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ReceiverScreen(amount: _sendController.text, method: _selectedMethod)));
                          }
                        },
                        child: Text(
                          state.translate("Continue", "Sii soco"),
                          style: TextStyle(fontSize: 16 * context.fontSizeFactor),
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

  Widget _buildAmountBox(BuildContext context, AppState state, ThemeData theme, String label, TextEditingController controller, String selectedCurrency, Function(String) onChanged, Function(String) onCurrencyChanged, List<String> availableCurrencies, {bool isReceiver = false}) {
    final isDark = theme.brightness == Brightness.dark;
    
    return GlassmorphicContainer(
      width: double.infinity,
      height: 120 * context.fontSizeFactor,
      borderRadius: 24,
      blur: 15,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark 
          ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)]
          : [Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0.7)],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isReceiver ? AppColors.accentTeal.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold, 
                      fontSize: 24, 
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none, 
                      contentPadding: EdgeInsets.zero,
                      hintText: "0.00",
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildCurrencyPicker(selectedCurrency, onCurrencyChanged, availableCurrencies, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyPicker(String selected, Function(String) onSelected, List<String> options, ThemeData theme) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: PopupMenuButton<String>(
        onSelected: onSelected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (context) => options.map((c) => PopupMenuItem(
          value: c,
          child: Row(
            children: [
              _buildCurrencyFlag(c),
              const SizedBox(width: 12),
              Text(c, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCurrencyFlag(selected),
              const SizedBox(width: 8),
              Text(selected, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyFlag(String currency) {
    final Map<String, String> countryCodes = {"USD": "us", "EUR": "eu", "GBP": "gb", "CAD": "ca"};
    final code = countryCodes[currency] ?? "un";
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        "https://flagcdn.com/w40/$code.png",
        width: 24, height: 16, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag_rounded, size: 16),
      ),
    );
  }

  Widget _buildPaymentMethods(AppState state, ThemeData theme) {
    final List<Map<String, dynamic>> methods = [
      {"name": state.translate("Murtaax Wallet", "Murtaax Wallet"), "image": "assets/images/walletlogo.png"},
      {"name": "EVC Plus", "image": "assets/images/evc.png"},
      {"name": "ZAAD", "image": "assets/images/zaad.png"},
      {"name": "eDahab", "image": "assets/images/edahab.png"},
      {"name": state.translate("Bank Transfer", "Xawaalad Bangi"), "image": "assets/images/bank.png"},
    ];

    return SizedBox(
      height: 120 * (state.locale.languageCode == 'so' ? 1.1 : 1.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: methods.length,
        itemBuilder: (context, index) {
          final m = methods[index];
          bool isSelected = _selectedMethod == m["name"];
          return GestureDetector(
            onTap: () => setState(() => _selectedMethod = m["name"]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 120,
              margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.accentTeal : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
                    ),
                    child: Image.asset(m["image"], fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      m["name"],
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold, 
                        color: isSelected ? AppColors.accentTeal : null, 
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
