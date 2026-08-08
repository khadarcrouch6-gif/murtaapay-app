import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/step_indicator.dart';
import 'package:intl/intl.dart';
import 'review_screen.dart';
import 'wallet_payment_screen.dart';
import 'credit_card_screen.dart';
import 'sender_bank_screen.dart';
import 'mobile_money_screen.dart';

import 'package:shimmer/shimmer.dart';

class PaymentScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String payoutMethod;
  final String paymentMethod;
  final String currencyCode;
  final String purpose;
  final String? cardId;
  final String? sourceOfFunds;
  final String? swiftCode;
  final String? address;
  final String? city;
  final String? country;
  final ScrollController? scrollController;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.paymentMethod,
    required this.currencyCode,
    required this.purpose,
    this.cardId,
    this.sourceOfFunds,
    this.swiftCode,
    this.address,
    this.city,
    this.country,
    this.scrollController,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String _selectedPaymentMethod;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.cardId != null) {
      _selectedPaymentMethod = "card_${widget.cardId}";
    } else {
      _selectedPaymentMethod = widget.paymentMethod;
    }
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleContinue(AppLocalizations l10n) {
    HapticFeedback.heavyImpact();
    final appState = Provider.of<AppState>(context, listen: false);
    final amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;

    String sourceKey = _selectedPaymentMethod;
    String? selectedCardId;

    if (_selectedPaymentMethod.startsWith("card_")) {
      sourceKey = "Debit Card";
      selectedCardId = _selectedPaymentMethod.replaceFirst("card_", "");
    } else if (_selectedPaymentMethod == "Savings") {
      sourceKey = "Savings Account";
    }

    if (!appState.hasSufficientBalanceForSource(amountVal, sourceKey, cardId: selectedCardId, payoutMethod: widget.payoutMethod)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.translate(
            "Insufficient balance in the selected source", 
            "Haraagaagu kuguma filna meesha aad dooratay"
          )),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == "Main Wallet") {
      if (widget.scrollController != null) Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalletPaymentScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            payoutMethod: widget.payoutMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
            sourceOfFunds: widget.sourceOfFunds,
            swiftCode: widget.swiftCode,
            address: widget.address,
            city: widget.city,
            country: widget.country,
          ),
        ),
      );
    } else if (_selectedPaymentMethod == "New Card") {
      if (widget.scrollController != null) Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreditCardScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            payoutMethod: widget.payoutMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
          ),
        ),
      );
    } else if (_selectedPaymentMethod.startsWith("card_")) {
      final cardId = _selectedPaymentMethod.replaceFirst("card_", "");
      final card = appState.cards.firstWhere((c) => c.id == cardId);
      
      if (widget.scrollController != null) Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            method: widget.payoutMethod,
            paymentMethod: "Virtual Card",
            cardId: card.id,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
            sourceOfFunds: widget.sourceOfFunds,
            swiftCode: widget.swiftCode,
            address: widget.address,
            city: widget.city,
            country: widget.country,
          ),
        ),
      );
    } else if (_selectedPaymentMethod.startsWith("bank_")) {
      final bankId = _selectedPaymentMethod.replaceFirst("bank_", "");
      final bank = appState.linkedBanks.firstWhere((b) => b.id == bankId);
      
      if (widget.scrollController != null) Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            method: widget.payoutMethod,
            paymentMethod: "Bank Transfer",
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
            sourceOfFunds: widget.sourceOfFunds,
            swiftCode: widget.swiftCode,
            address: widget.address,
            city: widget.city,
            country: widget.country,
          ),
        ),
      );
    } else if (_selectedPaymentMethod == "Bank Transfer") {
      if (widget.scrollController != null) Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SenderBankScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            payoutMethod: widget.payoutMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
          ),
        ),
      );
    } else if (_selectedPaymentMethod == "Mobile Money") {
      if (widget.scrollController != null) Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileMoneyScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            payoutMethod: widget.payoutMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
          ),
        ),
      );
    } else {
      String displayMethod = _selectedPaymentMethod;
      if (_selectedPaymentMethod == "Savings") {
        displayMethod = "Savings Account";
      }

      if (widget.scrollController != null) Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            method: widget.payoutMethod,
            paymentMethod: displayMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
            sourceOfFunds: widget.sourceOfFunds,
            swiftCode: widget.swiftCode,
            address: widget.address,
            city: widget.city,
            country: widget.country,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context);

    final List<Map<String, dynamic>> sections = [
      {
        "title": appState.translate("Murtaax Wallet", "Murtaax Wallet"),
        "items": [
          {
            "id": "Main Wallet", 
            "name": appState.translate("Main Wallet", "Boorsada rasmiga ah"), 
            "icon": Icons.account_balance_wallet_rounded, 
            "desc": "Balance: ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.balance)}",
            "type": "wallet",
            "subDesc": appState.balance < (double.tryParse(widget.amount.replaceAll(',', '')) ?? 0) && appState.savingsBalance > 0 
                ? appState.translate("Auto top-up from savings available", "Waxa laga soo buuxin karaa Kaydka")
                : null
          },
          {
            "id": "Savings", 
            "name": appState.translate("Savings Account", "Xisaabta Kaydka"), 
            "icon": Icons.savings_rounded, 
            "desc": "Balance: ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.savingsBalance)}",
            "type": "savings"
          },
        ]
      },
      {
        "title": appState.translate("Debit Cards", "Kaadhadhka Debit-ka"),
        "items": [
          // Virtual Cards
          ...appState.cards.map((card) => {
            "id": "card_${card.id}",
            "name": card.cardHolder,
            "icon": Icons.credit_card_rounded,
            "desc": "Virtual Card •••• ${card.cardNumber.substring(card.cardNumber.length - 4)}",
            "balance": "Balance: ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(card.balance)}",
            "type": "card",
            "cardId": card.id
          }),
          {
            "id": "New Card", 
            "name": appState.translate("Add New Card", "Ku dar kaadh cusub"), 
            "icon": Icons.add_card_rounded, 
            "desc": "Visa / Mastercard / Amex", 
            "type": "external_card"
          },
        ]
      },
      {
        "title": appState.translate("Bank Transfer", "Xawaalad Bangi"),
        "items": [
          {
            "id": "Bank Transfer", 
            "name": appState.translate("Bank Account", "Xisaab Bangi"), 
            "icon": Icons.account_balance_rounded, 
            "desc": appState.translate("Transfer from linked bank", "Ka soo dir bangi ku xidhan"), 
            "type": "external"
          },
        ]
      },
      {
        "title": appState.translate("Mobile Money", "Lacagta Mobilka"),
        "items": [
          {
            "id": "Mobile Money", 
            "name": "EVC Plus / Sahal / Zaad", 
            "icon": Icons.phone_android_rounded, 
            "desc": appState.translate("Instant mobile payment", "Lacag bixin mobilka ah"), 
            "type": "external"
          },
        ]
      }
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.scrollController != null ? null : AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * context.fontSizeFactor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.choosePaymentMethod,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * context.fontSizeFactor, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER BACKGROUND (Step Indicator) ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30 * context.fontSizeFactor), bottomRight: Radius.circular(30 * context.fontSizeFactor)),
              ),
              padding: EdgeInsets.only(bottom: 25 * context.fontSizeFactor, left: 20 * context.fontSizeFactor, right: 20 * context.fontSizeFactor),
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: Column(
                    children: [
                      // Source Display in Header
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white70, size: 16 * context.fontSizeFactor),
                            SizedBox(width: 8 * context.fontSizeFactor),
                            Text(
                              "${l10n.amount}: ${widget.currencyCode} ${widget.amount}",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14 * context.fontSizeFactor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20 * context.fontSizeFactor),
                      Row(
                        children: [
                          StepIndicator(step: 1, label: l10n.stepAmount, isActive: false, isCompleted: true, isHeader: true),
                          StepLine(isCompleted: true, isHeader: true),
                          StepIndicator(step: 2, label: l10n.stepReceiver, isActive: false, isCompleted: true, isHeader: true),
                          StepLine(isCompleted: true, isHeader: true),
                          StepIndicator(step: 3, label: l10n.stepPayment, isActive: true, isCompleted: false, isHeader: true),
                          StepLine(isCompleted: false, isHeader: true),
                          StepIndicator(step: 4, label: l10n.stepReview, isActive: false, isCompleted: false, isHeader: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: _isLoading 
                ? _buildSkeletonLoader(theme)
                : SingleChildScrollView(
                controller: widget.scrollController,
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Padding(
                      padding: EdgeInsets.all(20.0 * context.fontSizeFactor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- RECEIVER SUMMARY CARD ---
                          FadeInDown(
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              padding: EdgeInsets.all(20 * context.fontSizeFactor),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
                                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5 * context.fontSizeFactor),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10 * context.fontSizeFactor, offset: Offset(0, 4 * context.fontSizeFactor))],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(l10n.amount, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                                      Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22 * context.fontSizeFactor, color: theme.colorScheme.secondary)),
                                    ],
                                  ),
                                  SizedBox(height: 8 * context.fontSizeFactor),
                                  Builder(
                                    builder: (context) {
                                      final amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
                                      String sourceKey = _selectedPaymentMethod;
                                      if (_selectedPaymentMethod.startsWith("card_")) sourceKey = "Debit Card";
                                      if (_selectedPaymentMethod == "Savings") sourceKey = "Savings Account";
                                      
                                      final fee = appState.calculateFeeForSource(amountVal, sourceKey, payoutMethod: widget.payoutMethod);
                                      final total = amountVal + fee;
                                      
                                      final feePer100 = appState.calculateFeeForSource(100.0, sourceKey, payoutMethod: widget.payoutMethod);
                                      final feePercent = feePer100.toStringAsFixed(feePer100 % 1 == 0 ? 0 : 1);
                                      final feeRateText = l10n.feeRateDynamic(feePercent, feePer100.toStringAsFixed(2));

                                      return Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(feeRateText,
                                                  style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                              ),
                                              Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(fee), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
                                            ],
                                          ),
                                          Divider(height: 24 * context.fontSizeFactor),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(appState.translate("Total to Pay", "Warta guud ee baxaaya"), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor)),
                                              Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(total), 
                                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor, color: theme.colorScheme.secondary)),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                  ),
                                  Divider(height: 30 * context.fontSizeFactor),
                                  // Daily Limit Info
                                  Container(
                                    padding: EdgeInsets.all(16 * context.fontSizeFactor),
                                    decoration: BoxDecoration(
                                      color: theme.dividerColor.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.0 * context.fontSizeFactor),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              appState.translate("Daily Limit", "Xadka Maalinta"),
                                              style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.grey),
                                            ),
                                            Text(
                                              "${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.getDailySpent())} / ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.dailyLimit)}",
                                              style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10 * context.fontSizeFactor),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10 * context.fontSizeFactor),
                                          child: LinearProgressIndicator(
                                            value: (appState.getDailySpent() / appState.dailyLimit).clamp(0.0, 1.0),
                                            backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                                            minHeight: 6 * context.fontSizeFactor,
                                          ),
                                        ),
                                        SizedBox(height: 8 * context.fontSizeFactor),
                                        Row(
                                          children: [
                                            Icon(Icons.info_outline_rounded, size: 14 * context.fontSizeFactor, color: AppColors.grey),
                                            SizedBox(width: 6 * context.fontSizeFactor),
                                            Expanded(
                                              child: Text(
                                                "${appState.translate("Remaining", "Hambada")}: ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.getDailyRemaining())}",
                                                style: TextStyle(fontSize: 11 * context.fontSizeFactor, color: AppColors.grey, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16 * context.fontSizeFactor),
                                  _buildSummaryRow(l10n.receiver, widget.receiverName, Icons.person_outline),
                                  SizedBox(height: 12 * context.fontSizeFactor),
                                  _buildSummaryRow(
                                    widget.payoutMethod.contains("Bank")
                                        ? l10n.accountNumber
                                        : (widget.payoutMethod == "Murtaax Wallet"
                                            ? l10n.walletId
                                            : (widget.payoutMethod.contains("Visa") || widget.payoutMethod.contains("MasterCard")
                                                ? l10n.cardNumber
                                                : l10n.phoneNumber)),
                                    widget.receiverPhone,
                                    widget.payoutMethod.contains("Bank") ? Icons.account_balance_outlined : Icons.phone_android_outlined,
                                  ),
                                  SizedBox(height: 12 * context.fontSizeFactor),
                                  _buildSummaryRow(l10n.payoutVia, widget.payoutMethod, Icons.speed_rounded),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 24 * context.fontSizeFactor),
                          Text(
                            l10n.selectPaymentMethod,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor),
                          ),
                          
                          ...sections.map((section) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 24 * context.fontSizeFactor, bottom: 12 * context.fontSizeFactor, left: 4 * context.fontSizeFactor),
                                child: Text(
                                  section["title"],
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15 * context.fontSizeFactor, color: AppColors.grey),
                                ),
                              ),
                              ...(section["items"] as List).map((method) => FadeInLeft(
                                child: _buildPaymentMethodTile(method, theme, l10n),
                              )),
                            ],
                          )),
                          
                          SizedBox(height: 30 * context.fontSizeFactor),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 56 * context.fontSizeFactor,
                            child: ElevatedButton(
                              onPressed: () => _handleContinue(l10n),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                                elevation: 4,
                                shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              ),
                              child: Text(
                                l10n.continueToReview,
                                style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                          SizedBox(height: 20 * context.fontSizeFactor),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    final fontSizeFactor = context.fontSizeFactor;
    return Row(
      children: [
        Icon(icon, size: (18 * fontSizeFactor).toDouble(), color: AppColors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label, 
            style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: (14 * fontSizeFactor).toDouble()),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: (14 * fontSizeFactor).toDouble()),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method, ThemeData theme, AppLocalizations l10n) {
    bool isSelected = _selectedPaymentMethod == method["id"];
    final appState = Provider.of<AppState>(context, listen: false);
    
    final amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
    
    String sourceKey = method["id"];
    String? cardId = method["cardId"];
    if (sourceKey.startsWith("card_")) sourceKey = "Debit Card";
    if (sourceKey == "Savings") sourceKey = "Savings Account";

    bool hasEnough = appState.hasSufficientBalanceForSource(amountVal, sourceKey, cardId: cardId, payoutMethod: widget.payoutMethod);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPaymentMethod = method["id"]);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
        padding: EdgeInsets.all(16 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
          border: Border.all(
            color: isSelected 
              ? (!hasEnough ? Colors.red : theme.colorScheme.secondary) 
              : theme.dividerColor.withValues(alpha: 0.1),
            width: 2 * context.fontSizeFactor,
          ),
          boxShadow: isSelected ? [BoxShadow(color: (!hasEnough ? Colors.red : theme.colorScheme.secondary).withValues(alpha: 0.1), blurRadius: 10 * context.fontSizeFactor)] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: isSelected 
                  ? (!hasEnough ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.secondary.withValues(alpha: 0.1))
                  : theme.dividerColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(method["icon"], color: isSelected ? (!hasEnough ? Colors.red : theme.colorScheme.secondary) : AppColors.grey, size: 24 * context.fontSizeFactor),
            ),
            SizedBox(width: 16 * context.fontSizeFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(method["name"], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor)),
                    ],
                  ),
                  Text(method["desc"], style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                  if (method["balance"] != null)
                     Text(method["balance"], style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.w800)),
                  if (method["subDesc"] != null)
                     Text(method["subDesc"], style: TextStyle(color: Colors.blue, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
                  if (method["type"] != "external" && !hasEnough)
                    Padding(
                      padding: EdgeInsets.only(top: 4 * context.fontSizeFactor),
                      child: Text(
                        appState.translate("Insufficient balance", "Haraagaagu kuguma filna"),
                        style: TextStyle(color: Colors.red, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                method["type"] != "external" && !hasEnough ? Icons.error_outline_rounded : Icons.check_circle_rounded, 
                color: method["type"] != "external" && !hasEnough ? Colors.red : theme.colorScheme.secondary,
                size: 24 * context.fontSizeFactor
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[900]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20.0 * context.fontSizeFactor),
          child: Column(
            children: [
              Container(height: 180 * context.fontSizeFactor, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24 * context.fontSizeFactor))),
              SizedBox(height: 30 * context.fontSizeFactor),
              Row(children: [Container(width: 150 * context.fontSizeFactor, height: 20 * context.fontSizeFactor, color: Colors.white)]),
              const SizedBox(height: 20),
              ...List.generate(3, (index) => Padding(
                padding: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
                child: Container(height: 80 * context.fontSizeFactor, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20 * context.fontSizeFactor))),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
