import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/success_screen.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.isTab ? null : AppBar(
        title: Text(l10n.withdrawMoney, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
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
                            Text(l10n.availableBalance, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14 * context.fontSizeFactor)),
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
                  child: Text(l10n.withdrawalMethod, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
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
                                child: AdaptiveIcon(
                                  method["faIcon"] ?? method["icon"],
                                  color: Colors.white,
                                  size: 24 * context.fontSizeFactor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_getMethodTitle(method["id"], l10n), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                                  Text(_getMethodDesc(method["id"], l10n), style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor)),
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
                  FadeInUp(child: _buildDetailsSection(context, l10n)),
                  const SizedBox(height: 32),
                  FadeInUp(
                    child: ElevatedButton(
                      onPressed: _amountController.text.isEmpty ? null : () {
                        final state = AppState();
                        _showReviewSheet(context, l10n, state);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.3),
                        minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.continueToReview, 
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

  Widget _buildDetailsSection(BuildContext context, AppLocalizations l10n) {
    switch (_selectedMethod) {
      case "stripe":
        return _inputField(context, l10n.stripeEmail, Icons.email_rounded, "you@email.com", _field1Controller, isEmail: true);
      case "card":
        return Column(children: [
          _inputField(context, l10n.cardNumber, Icons.credit_card_rounded, "•••• •••• •••• ••••", _field1Controller, isNumber: true),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _inputField(context, l10n.expiry, Icons.date_range_rounded, "MM/YY", _field2Controller)),
          ]),
        ]);
      case "mobile":
        return _inputField(context, l10n.mobileNumber, Icons.phone_android_rounded, "e.g. +252 61 XXX XXXX", _field1Controller, isNumber: true);
      case "bank":
        return Column(children: [
          _inputField(context, l10n.accountHolderName, Icons.person_rounded, l10n.fullName, _field1Controller),
          const SizedBox(height: 14),
          _inputField(context, l10n.iban, Icons.account_balance_rounded, l10n.ibanHint, _field2Controller),
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

  void _showReviewSheet(BuildContext context, AppLocalizations l10n, AppState state) {
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
                      _processTransaction(context, l10n, state);
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

  void _processTransaction(BuildContext context, AppLocalizations l10n, AppState state) async {
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
    _showSuccess(context, l10n, state);
  }

  void _showSuccess(BuildContext context, AppLocalizations l10n, AppState state) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: state.translate("Withdrawal Requested!", "Kala bixista waa la codsaday!", ar: "تم طلب السحب!", de: "Auszahlung angefordert!"),
          message: "${state.translate("Your withdrawal of", "Kala bixistaadi", ar: "طلب سحبك بمبلغ", de: "Ihre Auszahlung von")} \$${_amountController.text} ${state.translate("is being processed.", "ayaa lagu guda jiraa.", ar: "قيد المعالجة.", de: "wird bearbeitet.")}",
          buttonText: state.translate("Back to Home", "Ku laabo Hoyga", ar: "العودة إلى الرئيسية", de: "Zurück zur Startseite"),
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

  String _getMethodTitle(String id, AppLocalizations l10n) {
    switch (id) {
      case "stripe":
        return "Stripe";
      case "card":
        return l10n.debitCreditCard;
      case "mobile":
        return l10n.mobileMoney;
      case "bank":
        return l10n.bankTransfer;
      default:
        return "";
    }
  }

  String _getMethodDesc(String id, AppLocalizations l10n) {
    switch (id) {
      case "stripe":
        return l10n.withdrawToStripe;
      case "card":
        return "Visa / Mastercard";
      case "mobile":
        return "ZAAD, EVC Plus, eDahab";
      case "bank":
        return l10n.bankTransferDesc;
      default:
        return "";
    }
  }
}

