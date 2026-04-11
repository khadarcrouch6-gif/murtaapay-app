import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/success_screen.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DepositScreen extends StatefulWidget {
  final bool isTab;
  const DepositScreen({super.key, this.isTab = false});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String? _selectedMethod;
  String? _selectedProvider;
  String? _selectedBank;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _field1Controller = TextEditingController(); // Number / Email / Account Name
  final TextEditingController _field2Controller = TextEditingController(); // Expiry / IBAN / Account Number
  final TextEditingController _field3Controller = TextEditingController(); // CVV
  final TextEditingController _field4Controller = TextEditingController(); // Cardholder Name / PIN

  @override
  void dispose() {
    _amountController.dispose();
    _field1Controller.dispose();
    _field2Controller.dispose();
    _field3Controller.dispose();
    _field4Controller.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "card",
      "titleKey": "visaMastercard",
      "descKey": "visaMastercardDesc",
      "gradient": [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
      "faIcon": FontAwesomeIcons.creditCard,
    },
    {
      "id": "mobile",
      "titleKey": "mobileMoney",
      "descKey": "mobileMoneyDesc",
      "gradient": [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
      "icon": Icons.phone_android_rounded,
    },
    {
      "id": "bank",
      "titleKey": "bankTransfer",
      "descKey": "bankTransferDesc",
      "gradient": [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)],
      "icon": Icons.account_balance_rounded,
    },
  ];

  final List<Map<String, dynamic>> _banks = [
    {
      "name": "Premier Bank",
      "accountNumber": "1022334455",
      "accountName": "MURTAPAY SOLUTIONS",
      "color": const Color(0xFF01579B)
    },
    {
      "name": "IBS Bank",
      "accountNumber": "9988776655",
      "accountName": "MURTAPAY SOLUTIONS",
      "color": const Color(0xFFC62828)
    },
    {
      "name": "Salaam Bank",
      "accountNumber": "4455667788",
      "accountName": "MURTAPAY SOLUTIONS",
      "color": const Color(0xFF2E7D32)
    },
    {
      "name": "Amal Bank",
      "accountNumber": "1122334455",
      "accountName": "MURTAPAY SOLUTIONS",
      "color": const Color(0xFFEF6C00)
    },
    {
      "name": "MyBank",
      "accountNumber": "5566778899",
      "accountName": "MURTAPAY SOLUTIONS",
      "color": const Color(0xFF4527A0)
    },
  ];

  String _getMethodTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case "visaMastercard": return l10n.visaMastercard;
      case "bankTransfer": return l10n.bankTransfer;
      case "mobileMoney": return l10n.mobileMoney;
      default: return "";
    }
  }

  String _getMethodDesc(String key, AppLocalizations l10n) {
    switch (key) {
      case "visaMastercardDesc": return l10n.visaMastercardDesc;
      case "bankTransferDesc": return l10n.bankTransferDesc;
      case "mobileMoneyDesc": return l10n.mobileMoneyDesc;
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(l10n.addMoney, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20 * context.fontSizeFactor, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.horizontalPadding,
              context.horizontalPadding,
              context.horizontalPadding,
              120, // Clear navigation bar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Amount Card
                FadeInDown(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accentTeal, AppColors.accentTeal.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentTeal.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.enterAmountToDeposit, 
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500)
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Text("\$", style: TextStyle(color: AppColors.accentTeal, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                      style: TextStyle(color: Colors.white, fontSize: 34 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: -1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "0.00",
                                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Quick amounts
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [50, 100, 200, 500].map((amt) => GestureDetector(
                                  onTap: () => setState(() => _amountController.text = amt.toString()),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _amountController.text == amt.toString() ? AppColors.accentTeal : Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: _amountController.text == amt.toString() ? AppColors.accentTeal : Colors.white.withValues(alpha: 0.05)),
                                    ),
                                    child: Text("\$$amt", style: TextStyle(color: Colors.white, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                  ),
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  child: Text(l10n.paymentMethod, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                ),
                const SizedBox(height: 16),
    
                ...List.generate(_methods.length, (index) {
                  final method = _methods[index];
                  final isSelected = _selectedMethod == method["id"];
                  final amountText = _amountController.text;
                  final double amount = double.tryParse(amountText) ?? 0;
                  final bool isEnabled = amount > 0;

                  return FadeInUp(
                    delay: Duration(milliseconds: index * 80),
                    child: Opacity(
                      opacity: isEnabled ? 1.0 : 0.5,
                      child: GestureDetector(
                        onTap: !isEnabled ? null : () {
                          setState(() {
                            _selectedMethod = method["id"];
                            _field1Controller.clear();
                            _field2Controller.clear();
                            _field3Controller.clear();
                            _field4Controller.clear();
                            _selectedProvider = null;
                            _selectedBank = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(bottom: 16),
                          width: double.infinity,
                          padding: EdgeInsets.all(20 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.05) : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.05),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56 * context.fontSizeFactor,
                                height: 56 * context.fontSizeFactor,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: (method["gradient"] as List<Color>).map((c) => c.withValues(alpha: 0.9)).toList(),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (method["gradient"] as List<Color>).first.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: AdaptiveIcon(
                                    method["faIcon"] ?? method["icon"],
                                    color: Colors.white,
                                    size: 26 * context.fontSizeFactor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getMethodTitle(method["titleKey"], l10n),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getMethodDesc(method["descKey"], l10n),
                                      style: TextStyle(color: AppColors.grey.withValues(alpha: 0.7), fontSize: 13 * context.fontSizeFactor),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                FadeInRight(
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle),
                                    child: Icon(Icons.check_rounded, color: Colors.white, size: 16 * context.fontSizeFactor),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
    
                if (_selectedMethod != null) ...[
                  const SizedBox(height: 8),
                  FadeInUp(child: _buildDetailsSection(context, l10n)),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    switch (_selectedMethod) {
      case "card":
        return FadeInUp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildCardPreview(context, l10n),
              const SizedBox(height: 24),
              Text(
                l10n.cardDetails,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color),
              ),
              const SizedBox(height: 16),
              _inputField(context, l10n.cardNumber, Icons.credit_card_rounded, "1234 5678 9012 3456", _field1Controller, isNumber: true, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), CardNumberInputFormatter()], onChanged: (_) => setState((){})),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _inputField(context, l10n.expiry, Icons.calendar_today_rounded, "MM/YY", _field2Controller, isNumber: true, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), ExpiryDateInputFormatter()], onChanged: (_) => setState((){}))),
                  const SizedBox(width: 16),
                  Expanded(child: _inputField(context, "CVV", Icons.lock_outline_rounded, "123", _field3Controller, isNumber: true, isObscure: true, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)], onChanged: (_) => setState((){}))),
                ],
              ),
              const SizedBox(height: 16),
              _inputField(context, l10n.cardholderName, Icons.person_outline_rounded, l10n.fullNameOnCard, _field4Controller, onChanged: (_) => setState((){})),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56 * context.fontSizeFactor,
                child: ElevatedButton(
                  onPressed: (_field1Controller.text.length >= 16 && _field2Controller.text.length >= 5 && _field3Controller.text.length >= 3 && _field4Controller.text.isNotEmpty) 
                    ? () => _showReviewSheet(context, l10n) 
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    disabledBackgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.continueLabel, 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                  ),
                ),
              ),
            ],
          ),
        );
      case "mobile":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectProvider,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.titleMedium?.color),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildProviderOption("EVC Plus", const Color(0xFF1B5E20), l10n),
                _buildProviderOption("e-Dahab", const Color(0xFFFBC02D), l10n),
                _buildProviderOption("Sahal", const Color(0xFF0D47A1), l10n),
                _buildProviderOption("ZAAD", const Color(0xFFB71C1C), l10n),
              ],
            ),
          ],
        );
      case "bank":
        final bank = (_selectedBank != null && _selectedBank != "Other")
          ? _banks.firstWhere((b) => b["name"] == _selectedBank) 
          : null;
        return FadeInUp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                l10n.selectBank,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showBankPicker(context, l10n),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (bank?["color"] as Color? ?? AppColors.accentTeal).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.account_balance_rounded, color: bank?["color"] as Color? ?? AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _selectedBank == "Other" ? l10n.otherBank : (_selectedBank ?? l10n.selectBank),
                        style: TextStyle(
                          fontSize: 16 * context.fontSizeFactor,
                          fontWeight: FontWeight.w600,
                          color: _selectedBank == null ? AppColors.grey.withValues(alpha: 0.5) : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey),
                    ],
                  ),
                ),
              ),
              if (_selectedBank != null) ...[
                const SizedBox(height: 16),
                if (_selectedBank == "Other") ...[
                  _inputField(context, l10n.bankName, Icons.account_balance_rounded, l10n.enterBankName, _field1Controller, onChanged: (_) => setState((){})),
                  const SizedBox(height: 16),
                ],
                _inputField(context, l10n.accountNumber, Icons.numbers_rounded, l10n.enterAccountNumber, _field2Controller, isNumber: true, onChanged: (_) => setState((){})),
                const SizedBox(height: 16),
                _inputField(context, l10n.accountName, Icons.person_outline_rounded, l10n.enterAccountName, _field4Controller, onChanged: (_) => setState((){})),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56 * context.fontSizeFactor,
                  child: ElevatedButton(
                    onPressed: (_field2Controller.text.isNotEmpty && _field4Controller.text.isNotEmpty && (_selectedBank != "Other" || _field1Controller.text.isNotEmpty))
                      ? () => _showReviewSheet(context, l10n)
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bank?["color"] as Color? ?? AppColors.primaryDark,
                      disabledBackgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.continueLabel, 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }



  Widget _buildCardPreview(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 200 * context.fontSizeFactor,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1e3c72).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Stack(
          children: [
            // Background patterns or icons
            Positioned(
              right: -20,
              bottom: -20,
              child: AdaptiveIcon(FontAwesomeIcons.ccVisa, color: Colors.white.withValues(alpha: 0.05), size: 150),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AdaptiveIcon(FontAwesomeIcons.microchip, color: Colors.amber.withValues(alpha: 0.8), size: 36 * context.fontSizeFactor),
                      AdaptiveIcon(FontAwesomeIcons.wifi, color: Colors.white.withValues(alpha: 0.6), size: 24 * context.fontSizeFactor),
                    ],
                  ),
                  Text(
                    _field1Controller.text.isEmpty ? "XXXX XXXX XXXX XXXX" : _field1Controller.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22 * context.fontSizeFactor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.cardholderName.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10 * context.fontSizeFactor)),
                          const SizedBox(height: 4),
                          Text(
                            _field4Controller.text.isEmpty ? "YOUR NAME" : _field4Controller.text.toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l10n.expiry.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10 * context.fontSizeFactor)),
                          const SizedBox(height: 4),
                          Text(
                            _field2Controller.text.isEmpty ? "MM/YY" : _field2Controller.text,
                            style: TextStyle(color: Colors.white, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBankPicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text(l10n.selectBank, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _banks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _banks.length) {
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded, color: AppColors.accentTeal, size: 20),
                        ),
                        title: Text(l10n.otherBank, style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          setState(() {
                            _selectedBank = "Other";
                            _field1Controller.clear();
                            _field2Controller.clear();
                            _field4Controller.clear();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }
                    final bank = _banks[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: (bank["color"] as Color).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.account_balance_rounded, color: bank["color"], size: 20),
                      ),
                      title: Text(bank["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        setState(() {
                          _selectedBank = bank["name"];
                          _field2Controller.text = bank["accountNumber"];
                          _field4Controller.text = bank["accountName"];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProviderOption(String id, Color color, AppLocalizations l10n) {
    bool isSelected = _selectedProvider == id;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        setState(() => _selectedProvider = id);
        _showMobileMoneyDialog(id, color, l10n);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : theme.dividerColor.withValues(alpha: 0.1), width: 2),
        ),
        child: Center(
          child: Text(
            id,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isSelected ? color : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }

  void _showMobileMoneyDialog(String provider, Color color, AppLocalizations l10n) {
    _field1Controller.clear();
    _field4Controller.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isValid = _field1Controller.text.length >= 7 && _field4Controller.text.length >= 4;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8 * context.fontSizeFactor),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.phone_android_rounded, color: color, size: 20 * context.fontSizeFactor),
                ),
                SizedBox(width: 12 * context.fontSizeFactor),
                Text(provider, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputField(context, l10n.phoneNumber, Icons.phone_iphone_rounded, "61XXXXXXX", _field1Controller, isNumber: true, onChanged: (_) => setDialogState((){})),
                SizedBox(height: 16 * context.fontSizeFactor),
                _inputField(context, l10n.servicePin, Icons.lock_outline_rounded, "••••", _field4Controller, isNumber: true, isObscure: true, onChanged: (_) => setDialogState((){})),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor))),
              ElevatedButton(
                onPressed: !isValid ? null : () {
                  Navigator.pop(context);
                  _showReviewSheet(this.context, l10n);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color, 
                  disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 10 * context.fontSizeFactor),
                ),
                child: Text(l10n.continueLabel, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _inputField(BuildContext context, String label, IconData icon, String hint, TextEditingController controller,
      {bool isNumber = false, bool isEmail = false, bool isObscure = false, List<TextInputFormatter>? formatters, Function(String)? onChanged}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        onChanged: onChanged,
        keyboardType: isNumber ? TextInputType.number : isEmail ? TextInputType.emailAddress : TextInputType.text,
        inputFormatters: formatters,
        style: TextStyle(fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.3)),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, AppLocalizations l10n) {
    final method = _methods.firstWhere((m) => m["id"] == _selectedMethod);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  Text(
                    l10n.reviewDeposit, 
                    style: TextStyle(fontSize: 22 * context.fontSizeFactor, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        _reviewRow(context, l10n.amount, "\$${_amountController.text}"),
                        Divider(height: 32, color: theme.dividerColor.withValues(alpha: 0.1)),
                        _reviewRow(context, l10n.method, _getMethodTitle(method["titleKey"], l10n)),
                        Divider(height: 32, color: theme.dividerColor.withValues(alpha: 0.1)),
                        _reviewRow(context, l10n.fee, "\$0.00", isFree: true),
                        Divider(height: 32, color: theme.dividerColor.withValues(alpha: 0.1)),
                        _reviewRow(context, l10n.totalCharged, "\$${_amountController.text}", isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 60 * context.fontSizeFactor,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _processTransaction(this.context, l10n);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.confirmAndDeposit, 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17 * context.fontSizeFactor, color: Colors.white)
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _reviewRow(BuildContext context, String label, String value, {bool isFree = false, bool isTotal = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label, 
            style: TextStyle(
              color: AppColors.grey.withValues(alpha: 0.7), 
              fontSize: 15 * context.fontSizeFactor, 
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: (isTotal ? 18 : 15) * context.fontSizeFactor, 
              color: isFree ? AppColors.accentTeal : theme.textTheme.bodyLarge?.color
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _processTransaction(BuildContext context, AppLocalizations l10n) async {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: ZoomIn(
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 220 * context.fontSizeFactor,
              padding: EdgeInsets.all(32 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 65 * context.fontSizeFactor,
                        height: 65 * context.fontSizeFactor,
                        child: const CircularProgressIndicator(
                          color: AppColors.accentTeal,
                          strokeWidth: 3,
                        ),
                      ),
                      Icon(
                        Icons.bolt_rounded,
                        color: AppColors.accentTeal,
                        size: 32 * context.fontSizeFactor,
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  Text(
                    l10n.processing, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18 * context.fontSizeFactor,
                      color: theme.textTheme.bodyLarge?.color,
                      decoration: TextDecoration.none,
                    )
                  ),
                  SizedBox(height: 8 * context.fontSizeFactor),
                  Text(
                    l10n.justAMoment,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13 * context.fontSizeFactor,
                      color: AppColors.grey,
                      decoration: TextDecoration.none,
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    
    Navigator.of(context, rootNavigator: true).pop();
    
    _showSuccess(context, l10n);
  }

  void _showSuccess(BuildContext context, AppLocalizations l10n) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.depositSuccessful,
          message: l10n.depositSuccessMessage("\$${_amountController.text}"),
          buttonText: l10n.backToHome,
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}
