import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/responsive_utils.dart';
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
  final String? sourceOfFunds;
  final String? swiftCode;
  final String? address;
  final String? city;
  final String? country;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.paymentMethod,
    required this.currencyCode,
    required this.purpose,
    this.sourceOfFunds,
    this.swiftCode,
    this.address,
    this.city,
    this.country,
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
    _selectedPaymentMethod = widget.paymentMethod;
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

    if (!appState.hasSufficientBalanceForSource(amountVal, sourceKey, cardId: selectedCardId)) {
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
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            method: widget.payoutMethod,
            paymentMethod: "Virtual Card (${card.cardHolder})",
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
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            method: widget.payoutMethod,
            paymentMethod: "Bank Account (${bank.bankName})",
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
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.choosePaymentMethod,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
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
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: Column(
                    children: [
                      // Source Display in Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.send_rounded, color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "${l10n.amount}: ${widget.currencyCode} ${widget.amount}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildStepIndicator(context, 1, l10n.stepAmount, false, true, isHeader: true),
                          _buildStepLine(context, true, isHeader: true),
                          _buildStepIndicator(context, 2, l10n.stepReceiver, false, true, isHeader: true),
                          _buildStepLine(context, true, isHeader: true),
                          _buildStepIndicator(context, 3, l10n.stepPayment, true, false, isHeader: true),
                          _buildStepLine(context, false, isHeader: true),
                          _buildStepIndicator(context, 4, l10n.stepReview, false, false, isHeader: true),
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
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- RECEIVER SUMMARY CARD ---
                          FadeInDown(
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(l10n.amount, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                                      Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: theme.colorScheme.secondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Builder(
                                    builder: (context) {
                                      final amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
                                      String sourceKey = _selectedPaymentMethod;
                                      if (_selectedPaymentMethod.startsWith("card_")) sourceKey = "Debit Card";
                                      if (_selectedPaymentMethod == "Savings") sourceKey = "Savings Account";
                                      
                                      final fee = appState.calculateFeeForSource(amountVal, sourceKey);
                                      final total = amountVal + fee;
                                      
                                      String feeLabel = "0.50";
                                      if (sourceKey.contains("Savings")) feeLabel = "0.50";
                                      else if (sourceKey.contains("Card")) feeLabel = "3.00";
                                      else if (sourceKey.contains("Bank")) feeLabel = "2.00";
                                      else if (sourceKey.contains("Mobile Money")) feeLabel = "0.99";

                                      return Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("${l10n.transactionFee} (${widget.currencyCode} $feeLabel)",
                                                style: const TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                                              Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(fee), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.grey)),
                                            ],
                                          ),
                                          const Divider(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(appState.translate("Total to Pay", "Warta guud ee baxaaya"), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                              Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(total), 
                                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.colorScheme.secondary)),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                  ),
                                  const Divider(height: 30),
                                  // Daily Limit Info
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.dividerColor.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              appState.translate("Daily Limit", "Xadka Maalinta"),
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey),
                                            ),
                                            Text(
                                              "${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.getDailySpent())} / ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.dailyLimit)}",
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: LinearProgressIndicator(
                                            value: (appState.getDailySpent() / appState.dailyLimit).clamp(0.0, 1.0),
                                            backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                                            minHeight: 6,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.grey),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                "${appState.translate("Remaining", "Hambada")}: ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.getDailyRemaining())}",
                                                style: const TextStyle(fontSize: 11, color: AppColors.grey, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSummaryRow(l10n.receiver, widget.receiverName, Icons.person_outline),
                                  const SizedBox(height: 12),
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
                                  const SizedBox(height: 12),
                                  _buildSummaryRow(l10n.payoutVia, widget.payoutMethod, Icons.speed_rounded),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          Text(
                            l10n.selectPaymentMethod,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          
                          ...sections.map((section) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
                                child: Text(
                                  section["title"],
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.grey),
                                ),
                              ),
                              ...(section["items"] as List).map((method) => FadeInLeft(
                                child: _buildPaymentMethodTile(method, theme, l10n),
                              )),
                            ],
                          )),
                          
                          const SizedBox(height: 30),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _handleContinue(l10n),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              ),
                              child: Text(
                                l10n.continueToReview,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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

    bool hasEnough = appState.hasSufficientBalanceForSource(amountVal, sourceKey, cardId: cardId);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPaymentMethod = method["id"]);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
              ? (!hasEnough ? Colors.red : theme.colorScheme.secondary) 
              : theme.dividerColor.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: isSelected ? [BoxShadow(color: (!hasEnough ? Colors.red : theme.colorScheme.secondary).withValues(alpha: 0.1), blurRadius: 10)] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected 
                  ? (!hasEnough ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.secondary.withValues(alpha: 0.1)) 
                  : theme.dividerColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(method["icon"], color: isSelected ? (!hasEnough ? Colors.red : theme.colorScheme.secondary) : AppColors.grey, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(method["name"], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                  Text(method["desc"], style: const TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                  if (method["balance"] != null)
                     Text(method["balance"], style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w800)),
                  if (method["subDesc"] != null)
                     Text(method["subDesc"], style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w600)),
                  if (method["type"] != "external" && !hasEnough)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        appState.translate("Insufficient balance", "Haraagaagu kuguma filna"),
                        style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                method["type"] != "external" && !hasEnough ? Icons.error_outline_rounded : Icons.check_circle_rounded, 
                color: method["type"] != "external" && !hasEnough ? Colors.red : theme.colorScheme.secondary,
                size: 24
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    final theme = Theme.of(context);
    Color activeColor = isHeader ? Colors.white : theme.colorScheme.secondary;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!);
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? theme.colorScheme.secondary : Colors.grey);

    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 4) : null
          ),
          child: Center(child: isCompleted && !isActive ? Icon(Icons.check, color: isHeader ? theme.colorScheme.secondary : Colors.white, size: 18) : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? theme.colorScheme.secondary : Colors.white) : Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildStepLine(BuildContext context, bool isCompleted, {bool isHeader = false}) { 
    final theme = Theme.of(context);
    Color color = isHeader 
      ? (isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.3))
      : (isCompleted ? theme.colorScheme.secondary : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!));
    return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))));
  }

  Widget _buildSkeletonLoader(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[900]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
              const SizedBox(height: 30),
              Row(children: [Container(width: 150, height: 20, color: Colors.white)]),
              const SizedBox(height: 20),
              ...List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
