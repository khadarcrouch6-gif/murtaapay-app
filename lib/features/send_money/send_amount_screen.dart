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
          state.translate("Send Money", "Lacag Dir", ar: "إرسال الأموال", de: "Geld senden"),
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
                    state.translate("Enter Amount", "Geli Cadadka", ar: "أدخل المبلغ", de: "Betrag eingeben"),
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
                    state.translate("You Send", "Adiga ayaa Diraya", ar: "أنت ترسل", de: "Sie senden"), 
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
                    state.translate("Receiver Gets", "Qaataha wuxuu Helayaa", ar: "المستلم يستلم", de: "Empfänger erhält"), 
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
                    state.translate("Select Payment Method", "Dooro Habka Lacagta", ar: "اختر طريقة الدفع", de: "Zahlungsmethode wählen"),
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
                          double amount = double.tryParse(_sendController.text) ?? 0;
                          if (!state.hasSufficientBalance(amount)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.translate("Insufficient Balance", "Haraagu kuguma filna", ar: "رصيد غير كاف", de: "Unzureichendes Guthaben")),
                                backgroundColor: Colors.red,
                              )
                            );
                            return;
                          }
                          if (_selectedMethod == "Murtaax Wallet") {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WalletReceiverScreen(amount: _sendController.text, method: _selectedMethod)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ReceiverScreen(amount: _sendController.text, method: _selectedMethod)));
                          }
                        },
                        child: Text(
                          state.translate("Continue", "Sii soco", ar: "استمرار", de: "Weiter"),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00"),
                ),
              ),
              _buildCurrencyPicker(selectedCurrency, onCurrencyChanged, availableCurrencies, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyPicker(String selected, Function(String) onSelected, List<String> options, ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => options.map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColors.primaryDark.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text(selected, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(AppState state, ThemeData theme) {
    final List<Map<String, dynamic>> methods = [
      {"name": state.translate("Murtaax Wallet", "Murtaax Wallet", ar: "محفظة مرتاح", de: "Murtaax Wallet"), "image": "assets/images/walletlogo.png"},
      {"name": "EVC Plus", "image": "assets/images/evc.png"},
      {"name": "ZAAD", "image": "assets/images/zaad.png"},
      {"name": "eDahab", "image": "assets/images/edahab.png"},
      {"name": state.translate("Bank Transfer", "Xawaalad Bangi", ar: "تحويل بنكي", de: "Banküberweisung"), "image": "assets/images/bank.png"},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: methods.length,
        itemBuilder: (context, index) {
          final m = methods[index];
          bool isSelected = _selectedMethod == m["name"];
          return GestureDetector(
            onTap: () => setState(() => _selectedMethod = m["name"]),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.accentTeal : Colors.transparent),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(m["image"], width: 40, height: 40, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.payment)),
                  const SizedBox(height: 8),
                  Text(m["name"], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
