import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DepositScreen extends StatefulWidget {
  final bool isTab;
  const DepositScreen({super.key, this.isTab = false});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String? _selectedMethod;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _field1Controller = TextEditingController(); // Number / Email
  final TextEditingController _field2Controller = TextEditingController(); // Expiry / IBAN
  final TextEditingController _field3Controller = TextEditingController(); // CVV
  final TextEditingController _field4Controller = TextEditingController(); // Cardholder Name / PIN

  final AudioPlayer _audioPlayer = AudioPlayer();
  String _recipientName = "";
  bool _isLoadingName = false;

  void _lookupName(String value) {
    if (value.length >= 7) {
      setState(() => _isLoadingName = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _isLoadingName = false;
            _recipientName = value.startsWith("61") ? "Mohamed Ahmed Hassan" : "Sahra Ali Warsame";
          });
        }
      });
    } else {
      setState(() {
        _recipientName = "";
        _isLoadingName = false;
      });
    }
  }

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "card",
      "title": "Debit / Credit Card",
      "desc": "Visa or Mastercard — instant",
      "gradient": [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
      "faIcon": FontAwesomeIcons.creditCard,
    },
    {
      "id": "mobile",
      "title": "Mobile Money",
      "desc": "ZAAD, EVC Plus, eDahab",
      "gradient": [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      "icon": Icons.phone_android_rounded,
    },
    {
      "id": "bank",
      "title": "Bank Transfer",
      "desc": "SEPA / IBAN transfer",
      "gradient": [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)],
      "icon": Icons.account_balance_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(state.translate("Add Money", "Ku dar Lacag", ar: "إضافة أموال", de: "Geld einzahlen"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color)),
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
                            colors: [AppColors.primaryDark, AppColors.primaryDark.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.translate("Enter Amount to Deposit", "Gali cadadka aad dhigato", ar: "أدخل المبلغ للإيداع", de: "Einzahlungsbetrag eingeben"), 
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
                  child: Text(state.translate("Deposit Method", "Qaabka Lacag Dhigashada", ar: "طريقة الإيداع", de: "Einzahlungsmethode"), style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                ),
                const SizedBox(height: 16),
    
                ...List.generate(_methods.length, (index) {
                  final method = _methods[index];
                  final isSelected = _selectedMethod == method["id"];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 80),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMethod = method["id"];
                          _field1Controller.clear();
                          _field2Controller.clear();
                          _field3Controller.clear();
                          _field4Controller.clear();
                          _recipientName = "";
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
                                    state.translate(method["title"], _getSomaliMethodTitle(method["id"]), ar: _getArabicMethodTitle(method["id"]), de: _getGermanMethodTitle(method["id"])),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.translate(method["desc"], _getSomaliMethodDesc(method["id"]), ar: _getArabicMethodDesc(method["id"]), de: _getGermanMethodDesc(method["id"])),
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
                  );
                }),
    
                if (_selectedMethod != null) ...[
                  const SizedBox(height: 8),
                  FadeInUp(child: _buildDetailsSection(context, state)),
                  const SizedBox(height: 32),
                  FadeInUp(
                    child: ElevatedButton(
                      onPressed: _amountController.text.isEmpty ? null : () => _showReviewSheet(context, state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.3),
                        minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          state.translate("Confirm Deposit", "Xaqiiji Dhigashada", ar: "تأكيد الإيداع", de: "Einzahlung bestätigen"), 
                          style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, AppState state) {
    switch (_selectedMethod) {
      case "card":
        return Column(children: [
          _inputField(context, state.translate("Card Number", "Lambarka Kaadhka"), Icons.credit_card_rounded, "0000 0000 0000 0000", _field1Controller, isNumber: true, formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            CardNumberInputFormatter(),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _inputField(context, state.translate("Expiry", "Wakhtiga dhicitaanka"), Icons.date_range_rounded, "MM/YY", _field2Controller, isNumber: true, formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
              ExpiryDateInputFormatter(),
            ])),
            const SizedBox(width: 14),
            Expanded(child: _inputField(context, "CVV", Icons.lock_rounded, "•••", _field3Controller, isNumber: true, formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ])),
          ]),
          const SizedBox(height: 14),
          _inputField(context, state.translate("Cardholder Name", "Magaca qofka iska leh"), Icons.person_rounded, "Full name on card", _field4Controller),
        ]);
      case "mobile":
        return Column(
          children: [
            _inputField(
              context,
              state.translate("Mobile Number", "Lambarka Taleefanka"),
              Icons.phone_android_rounded,
              "e.g. 61XXXXXXX",
              _field1Controller,
              isNumber: true,
              onChanged: (val) {
                if (val.length >= 7) {
                  _lookupName(val);
                } else {
                  setState(() => _recipientName = "");
                }
              },
            ),
            if (_isLoadingName)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent),
              ),
            if (_recipientName.isNotEmpty)
              FadeIn(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        _recipientName,
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            _inputField(context, state.translate("Mobile Money PIN", "PIN-ka lacagta mobaylka"), Icons.lock_rounded, "Enter PIN", _field4Controller, isNumber: true, isObscure: true),
          ],
        );
      case "bank":
        return Column(children: [
          _inputField(context, state.translate("Account Holder Name", "Magaca qofka akoonka leh"), Icons.person_rounded, "Full name", _field1Controller),
          const SizedBox(height: 14),
          _inputField(context, "IBAN", Icons.account_balance_rounded, "e.g. GB29 NWBK 6016 1331 9268 19", _field2Controller),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  String _getSomaliMethodTitle(String id) {
    switch (id) {
      case "card": return "Kaadhka Debit / Credit";
      case "mobile": return "Lacagta Mobaylka";
      case "bank": return "Xawaalad Bangi";
      default: return "";
    }
  }

  String _getArabicMethodTitle(String id) {
    switch (id) {
      case "card": return "بطاقة دفع / ائتمان";
      case "mobile": return "نقد عبر الهاتف";
      case "bank": return "تحويل بنكي";
      default: return "";
    }
  }

  String _getGermanMethodTitle(String id) {
    switch (id) {
      case "card": return "Debit- / Kreditkarte";
      case "mobile": return "Mobiles Geld";
      case "bank": return "Banküberweisung";
      default: return "";
    }
  }

  String _getSomaliMethodDesc(String id) {
    switch (id) {
      case "card": return "Visa ama Mastercard — degdeg ah";
      case "mobile": return "ZAAD, EVC Plus, eDahab";
      case "bank": return "Xawaaladda SEPA / IBAN";
      default: return "";
    }
  }

  String _getArabicMethodDesc(String id) {
    switch (id) {
      case "card": return "فيزا أو ماستركارد — فوري";
      case "mobile": return "ZAAD, EVC Plus, eDahab";
      case "bank": return "تحويل SEPA / IBAN";
      default: return "";
    }
  }

  String _getGermanMethodDesc(String id) {
    switch (id) {
      case "card": return "Visa oder Mastercard — sofort";
      case "mobile": return "ZAAD, EVC Plus, eDahab";
      case "bank": return "SEPA- / IBAN-Überweisung";
      default: return "";
    }
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

  void _showReviewSheet(BuildContext context, AppState state) {
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
                    state.translate("Review Deposit", "Eeg Dhigashada horta", ar: "مراجعة الإيداع", de: "Einzahlung prüfen"), 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        _reviewRow(context, state.translate("Amount", "Cadadka"), "\$${_amountController.text}"),
                        Divider(height: 32, color: theme.dividerColor.withValues(alpha: 0.1)),
                        _reviewRow(context, state.translate("Method", "Qaabka"), state.translate(method["title"], _getSomaliMethodTitle(method["id"]), ar: _getArabicMethodTitle(method["id"]), de: _getGermanMethodTitle(method["id"]))),
                        Divider(height: 32, color: theme.dividerColor.withValues(alpha: 0.1)),
                        _reviewRow(context, state.translate("Fee", "Kharashka"), "\$0.00", isFree: true),
                        Divider(height: 32, color: theme.dividerColor.withValues(alpha: 0.1)),
                        _reviewRow(context, state.translate("Total Charged", "Wadarta Guud"), "\$${_amountController.text}", isTotal: true),
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
                        _showSuccess(context, state);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(
                        state.translate("Confirm & Deposit", "Xaqiiji & Dhigo", ar: "تأكيد وإيداع", de: "Bestätigen & Einzahlen"), 
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
        Text(
          label, 
          style: TextStyle(color: AppColors.grey.withValues(alpha: 0.7), fontSize: 15, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)
        ),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: isTotal ? 18 : 15, 
            color: isFree ? AppColors.accentTeal : theme.textTheme.bodyLarge?.color
          )
        ),
      ],
    );
  }

  void _showSuccess(BuildContext context, AppState state) {
    _audioPlayer.play(AssetSource('sounds/success.mp3'));
    final theme = Theme.of(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: MaxWidthBox(
              maxWidth: 500,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      child: Container(
                        height: 110 * context.fontSizeFactor, width: 110 * context.fontSizeFactor,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: const Color(0xFF11998E).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 65 * context.fontSizeFactor),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(state.translate("Deposit Successful!", "Dhigashadu waa lagu guulaystay!", ar: "نجح الإيداع!", de: "Einzahlung erfolgreich!"), style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                    const SizedBox(height: 12),
                    Text(
                      "\$${_amountController.text} ${state.translate("has been added to your wallet.", "waa lagu daray boorsadaada.", ar: "تمت إضافتها إلى محفظتك.", de: "wurde Ihrem Wallet hinzugefügt.")}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.grey, fontSize: 16 * context.fontSizeFactor, height: 1.5),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        padding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor, horizontal: 40 * context.fontSizeFactor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(state.translate("Back to Home", "Ku laabo Hoyga", ar: "العودة إلى الرئيسية", de: "Zurück zur Startseite"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: Colors.white)),
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
