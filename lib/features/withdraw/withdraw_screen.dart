import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';
import 'package:responsive_framework/responsive_framework.dart';

class WithdrawScreen extends StatefulWidget {
  final bool isTab;
  const WithdrawScreen({super.key, this.isTab = false});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String? _selectedMethod;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _field1Controller = TextEditingController();
  final TextEditingController _field2Controller = TextEditingController();

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "stripe",
      "title": "Stripe",
      "desc": "Withdraw to your Stripe account",
      "gradient": [const Color(0xFF6772E5), const Color(0xFF3E4493)],
      "faIcon": FontAwesomeIcons.stripe,
    },
    {
      "id": "card",
      "title": "Debit / Credit Card",
      "desc": "Visa or Mastercard",
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
      "desc": "IBAN / SEPA transfer",
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
      appBar: widget.isTab ? null : AppBar(
        title: Text(state.translate("Withdraw Money", "Kala Bax Lacag", ar: "سحب الأموال", de: "Geld abheben"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                FadeInDown(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.translate("Available Balance", "Haraaga diyaar ah", ar: "الرصيد المتاح", de: "Verfügbares Guthaben"), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14 * context.fontSizeFactor)),
                            const SizedBox(height: 8),
                            Text("\$2,450.00", style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            // Amount Input
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Text("\$", style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                      style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "0.00",
                                        hintStyle: TextStyle(color: Colors.white54),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Quick amounts
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [50, 100, 200, 500].map((amt) => GestureDetector(
                                  onTap: () => setState(() => _amountController.text = amt.toString()),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text("\$$amt", style: TextStyle(color: Colors.white, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
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
                  child: Text(state.translate("Withdrawal Method", "Habka Kala Bixista", ar: "طريقة السحب", de: "Auszahlungsmethode"), style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
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
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: EdgeInsets.all(18 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.accentTeal : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50 * context.fontSizeFactor, height: 50 * context.fontSizeFactor,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: (method["gradient"] as List<Color>),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: method["faIcon"] != null
                                    ? FaIcon(method["faIcon"] as IconData, color: Colors.white, size: 22 * context.fontSizeFactor)
                                    : Icon(method["icon"] as IconData, color: Colors.white, size: 24 * context.fontSizeFactor),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(state.translate(method["title"], method["title"], ar: _getArMethodTitle(method["id"]), de: _getDeMethodTitle(method["id"])), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                                  Text(state.translate(method["desc"], method["desc"], ar: _getArMethodDesc(method["id"]), de: _getDeMethodDesc(method["id"])), style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor)),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 22 * context.fontSizeFactor, height: 22 * context.fontSizeFactor,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.accentTeal : Colors.transparent,
                                border: Border.all(color: isSelected ? AppColors.accentTeal : AppColors.grey.withValues(alpha: 0.4), width: 2),
                              ),
                              child: isSelected
                                  ? Icon(Icons.check_rounded, color: Colors.white, size: 14 * context.fontSizeFactor)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
    
                // Dynamic detail fields
                if (_selectedMethod != null) ...[
                  const SizedBox(height: 8),
                  FadeInUp(child: _buildDetailsSection(context, state)),
                  const SizedBox(height: 32),
                  FadeInUp(
                    child: ElevatedButton(
                      onPressed: _amountController.text.isEmpty ? null : () => _showReviewSheet(context, state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.3),
                        minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          state.translate("Continue to Review", "Sii soco", ar: "الاستمرار للمراجعة", de: "Weiter zur Überprüfung"), 
                          style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, AppState state) {
    switch (_selectedMethod) {
      case "stripe":
        return _inputField(context, state.translate("Stripe Email", "Email-ka Stripe-ka", ar: "بريد سترايب", de: "Stripe-E-Mail"), Icons.email_rounded, "you@email.com", _field1Controller, isEmail: true);
      case "card":
        return Column(children: [
          _inputField(context, state.translate("Card Number", "Lambarka Kaadhka", ar: "رقم البطاقة", de: "Kartennummer"), Icons.credit_card_rounded, "•••• •••• •••• ••••", _field1Controller, isNumber: true),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _inputField(context, state.translate("Expiry", "Wakhtiga dhicitaanka", ar: "تاريخ الانتهاء", de: "Ablaufdatum"), Icons.date_range_rounded, "MM/YY", _field2Controller)),
          ]),
        ]);
      case "mobile":
        return _inputField(context, state.translate("Mobile Number", "Lambarka Moobaylka", ar: "رقم الجوال", de: "Mobilnummer"), Icons.phone_android_rounded, "e.g. +252 61 XXX XXXX", _field1Controller, isNumber: true);
      case "bank":
        return Column(children: [
          _inputField(context, state.translate("Account Holder Name", "Magaca xisaabta leh", ar: "اسم صاحب الحساب", de: "Name des Kontoinhabers"), Icons.person_rounded, state.translate("Full name", "Magaca oo buuxa", ar: "الاسم الكامل", de: "Vollständiger Name"), _field1Controller),
          const SizedBox(height: 14),
          _inputField(context, state.translate("IBAN", "IBAN", ar: "رقم الآيبان", de: "IBAN"), Icons.account_balance_rounded, "e.g. GB29 NWBK 6016 1331 9268 19", _field2Controller),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _inputField(BuildContext context, String label, IconData icon, String hint, TextEditingController controller, {bool isNumber = false, bool isEmail = false}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: TextStyle(fontSize: 16 * context.fontSizeFactor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryDark.withValues(alpha: 0.7), size: 24 * context.fontSizeFactor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: theme.colorScheme.surface,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
          ),
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, AppState state) {
    final method = _methods.firstWhere((m) => m["id"] == _selectedMethod);
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Text(state.translate("Review Withdrawal", "Dib u eegista Kala Bixista", ar: "مراجعة السحب", de: "Auszahlung überprüfen"), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                const SizedBox(height: 24),
                DetailRow(label: state.translate("Amount", "Cadadka", ar: "المبلغ", de: "Betrag"), value: "\$${_amountController.text}"),
                DetailRow(label: state.translate("Method", "Habka", ar: "الطريقة", de: "Methode"), value: state.translate(method["title"], method["title"], ar: _getArMethodTitle(method["id"]), de: _getDeMethodTitle(method["id"]))),
                if (_field1Controller.text.isNotEmpty) DetailRow(label: state.translate("Details", "Faahfaahinta", ar: "التفاصيل", de: "Details"), value: _field1Controller.text),
                DetailRow(label: state.translate("Fee", "Kharashka", ar: "الرسوم", de: "Gebühr"), value: state.translate("Free", "Bilaash", ar: "مجاني", de: "Kostenlos"), valueColor: AppColors.accentTeal),
                DetailRow(label: state.translate("Total Deducted", "Wadarta laga jaray", ar: "إجمالي المبلغ المخصوم", de: "Abgezogener Gesamtbetrag"), value: "\$${_amountController.text}"),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showSuccess(context, state);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(state.translate("Confirm & Withdraw", "Xaqiiji oo Kala Bax", ar: "تأكيد وسحب", de: "Bestätigen & Abheben"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: Colors.white)),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, AppState state) {
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
                        decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle),
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 65 * context.fontSizeFactor),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(state.translate("Withdrawal Requested!", "Kala bixista waa la codsaday!", ar: "تم طلب السحب!", de: "Auszahlung angefordert!"), style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                    const SizedBox(height: 12),
                    Text(
                      "${state.translate("Your withdrawal of", "Kala bixistaadi", ar: "طلب سحبك بمبلغ", de: "Ihre Auszahlung von")} \$${_amountController.text} ${state.translate("is being processed.", "ayaa lagu guda jiraa.", ar: "قيد المعالجة.", de: "wird bearbeitet.")}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.grey, fontSize: 16 * context.fontSizeFactor, height: 1.5),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
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

  String _getArMethodTitle(String id) {
    switch (id) {
      case "stripe": return "سترايب";
      case "card": return "بطاقة الخصم / الائتمان";
      case "mobile": return "عبر الجوال";
      case "bank": return "تحويل بنكي";
      default: return "";
    }
  }

  String _getDeMethodTitle(String id) {
    switch (id) {
      case "stripe": return "Stripe";
      case "card": return "Debit- / Kreditkarte";
      case "mobile": return "Mobiles Geld";
      case "bank": return "Banküberweisung";
      default: return "";
    }
  }

  String _getArMethodDesc(String id) {
    switch (id) {
      case "stripe": return "سحب إلى حساب سترايب الخاص بك";
      case "card": return "فيزا أو ماستركارد";
      case "mobile": return "ZAAD، EVC Plus، eDahab";
      case "bank": return "تحويل IBAN / SEPA";
      default: return "";
    }
  }

  String _getDeMethodDesc(String id) {
    switch (id) {
      case "stripe": return "Abheben auf Ihr Stripe-Konto";
      case "card": return "Visa oder Mastercard";
      case "mobile": return "ZAAD, EVC Plus, eDahab";
      case "bank": return "IBAN- / SEPA-Überweisung";
      default: return "";
    }
  }
}

