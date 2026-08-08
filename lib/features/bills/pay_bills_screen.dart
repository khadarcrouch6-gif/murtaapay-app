import 'dart:ui' as ui;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/success_screen.dart';
import '../navigation/main_navigation.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/models/transaction.dart';

class PayBillsScreen extends StatefulWidget {
  const PayBillsScreen({super.key});

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final List<Map<String, dynamic>> _categories = [
    {"title": "Electricity", "l10nKey": "electricity", "icon": Icons.lightbulb_outline_rounded, "color": Colors.orange},
    {"title": "Water", "l10nKey": "water", "icon": Icons.water_drop_outlined, "color": Colors.blue},
    {"title": "Internet", "l10nKey": "internet", "icon": Icons.wifi_rounded, "color": Colors.purple},
    {"title": "TV Cable", "l10nKey": "tvCable", "icon": Icons.tv_rounded, "color": Colors.red},
    {"title": "Education", "l10nKey": "education", "icon": Icons.school_outlined, "color": Colors.green},
    {"title": "Gov Services", "l10nKey": "govServices", "icon": Icons.account_balance_rounded, "color": Colors.teal},
  ];

  final Map<String, List<String>> _providers = {
    "electricity": ["Telesom Electric", "Eeneeyo", "Hormuud Electric", "Total Energy", "BECO"],
    "water": ["Mogadishu Water", "Hargeisa Water Agency", "Garowe Water", "Puntland Water"],
    "internet": ["Somtel Internet", "Hormuud Connect", "Telesom Golis", "Somnet Fiber", "Golis Internet"],
    "tvCable": ["DSTV Somalia", "StarTimes", "Cable Somalia", "MyTV"],
    "education": ["Somali National University", "Simad University", "Amoud University", "Mogadishu University"],
    "govServices": ["Passport Fees", "Traffic Fines", "Local Council Tax", "Ministry of Commerce"],
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(l10n.payBills, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.billsLabel, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return _buildBillCategory(context, cat['title'], cat['l10nKey'], cat['icon'], cat['color']);
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(l10n.recentBills, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Consumer<AppState>(
            builder: (context, state, _) {
              final billTransactions = state.transactions.where((t) => t.category == "Bills").toList();
              if (billTransactions.isEmpty) {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    Center(child: Text(l10n.noTransactions, style: TextStyle(color: AppColors.grey))),
                    const SizedBox(height: 100),
                  ]),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = billTransactions[index];
                    final l10nKey = _deriveL10nKey(tx.title, l10n);
                    return _buildRecentBill(
                      context, 
                      tx.title, 
                      DateFormat('MMM dd, yyyy').format(tx.timestamp), 
                      NumberFormat.simpleCurrency(name: state.currencyCode).format(tx.numericAmount.abs()),
                      l10nKey,
                      tx.referenceId ?? tx.id
                    );
                  },
                  childCount: billTransactions.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillCategory(BuildContext context, String title, String l10nKey, IconData icon, Color color) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    String translatedTitle = _getTranslatedCategory(l10n, l10nKey);
    return GestureDetector(
      onTap: () => _showPayDialog(context, title, l10nKey, icon, color),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.1 : 0.02),
              blurRadius: 15,
              offset: const Offset(0, 8)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12 * context.fontSizeFactor),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28 * context.fontSizeFactor),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                translatedTitle, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(BuildContext context, String category, String l10nKey, IconData icon, Color color) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context, listen: false);
    final translatedCategory = _getTranslatedCategory(l10n, l10nKey);

    double amount = 0.0;
    String selectedMethod = "Main Wallet";
    String? selectedCardId;
    String? selectedProvider = _providers[l10nKey]?.first;
    bool isPinStage = false;
    final TextEditingController pinController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.all(32 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isPinStage) ...[
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10 * context.fontSizeFactor),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: Icon(icon, color: color, size: 24 * context.fontSizeFactor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              translatedCategory, 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    
                    // Provider Selector
                    Text(
                      l10n.selectProvider,
                      style: TextStyle(fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.grey),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedProvider,
                          isExpanded: true,
                          dropdownColor: theme.scaffoldBackgroundColor,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: _providers[l10nKey]?.map((String provider) {
                            return DropdownMenuItem<String>(
                              value: provider,
                              child: Text(provider, style: TextStyle(fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setModalState(() => selectedProvider = newValue);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Source Selector
                    Text(
                      l10n.selectPaymentMethod,
                      style: TextStyle(fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.grey),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSourceOption(context, "Main Wallet", l10n.walletBalance, state.balance, selectedMethod == "Main Wallet", (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }), state),
                          ...state.cards.map((card) => _buildSourceOption(context, "card_${card.id}", card.cardHolder, card.balance, selectedMethod == "card_${card.id}", (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }), state, cardId: card.id, isCard: true)),
                          _buildSourceOption(context, "EVC Plus", "EVC Plus", 0, selectedMethod == "EVC Plus", (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }), state, icon: Icons.phone_android_rounded),
                          _buildSourceOption(context, "Somnet", "Somnet", 0, selectedMethod == "Somnet", (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }), state, icon: Icons.signal_cellular_alt_rounded),
                          if (state.savingsBalance > 0)
                            _buildSourceOption(context, "Savings Account", l10n.savingsBalance, state.savingsBalance, selectedMethod == "Savings Account", (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }), state),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: idController,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16 * context.fontSizeFactor),
                      decoration: InputDecoration(
                        labelText: "$translatedCategory ID / ${l10n.accountNumber}",
                        labelStyle: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        prefixIcon: Icon(Icons.tag, color: AppColors.grey, size: 20 * context.fontSizeFactor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16 * context.fontSizeFactor),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) => setModalState(() => amount = double.tryParse(val) ?? 0.0),
                      decoration: InputDecoration(
                        labelText: l10n.amountToPay,
                        labelStyle: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        prefixIcon: Icon(Icons.attach_money, color: AppColors.grey, size: 20 * context.fontSizeFactor),
                      ),
                    ),
                    
                    if (amount > 0) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.all(16 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.amount, style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor)),
                                Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(amount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                              ],
                            ),
                            SizedBox(height: 8 * context.fontSizeFactor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.fee, style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor)),
                                Text(
                                  "+${NumberFormat.simpleCurrency(name: state.currencyCode).format(state.calculateFeeForSource(amount, selectedMethod.startsWith("card_") ? "Debit Card" : selectedMethod))}",
                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
                              child: Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.total, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                                Text(
                                  NumberFormat.simpleCurrency(name: state.currencyCode).format(amount + state.calculateFeeForSource(amount, selectedMethod.startsWith("card_") ? "Debit Card" : selectedMethod)),
                                  style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56 * context.fontSizeFactor,
                      child: ElevatedButton(
                        onPressed: () {
                          if (idController.text.isNotEmpty && amount > 0) {
                            setModalState(() => isPinStage = true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.confirmPayment, 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // PIN Stage
                    Text(l10n.enterSecurityPin, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(l10n.enterTransactionPin, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 10),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: theme.dividerColor.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => setModalState(() => isPinStage = false),
                            child: Text(l10n.back),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (state.verifyPin(pinController.text)) {
                                Navigator.pop(context);
                                _processTransaction(
                                  context, 
                                  l10nKey, 
                                  amount.toString(), 
                                  idController.text,
                                  provider: selectedProvider,
                                  paymentMethod: selectedMethod.startsWith("card_") ? "Debit Card" : selectedMethod,
                                  cardId: selectedCardId
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invalidPin)));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentTeal,
                              padding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                            ),
                            child: Text(l10n.confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSourceOption(BuildContext context, String id, String title, double balance, bool isSelected, Function(String, String?) onTap, AppState state, {String? cardId, bool isCard = false, IconData? icon}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onTap(id, cardId),
      child: Container(
        margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
        padding: EdgeInsets.all(12 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
          border: Border.all(color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1), width: 2),
        ),
        child: Row(
          children: [
            Icon(icon ?? (isCard ? Icons.credit_card_rounded : Icons.account_balance_wallet_rounded), color: isSelected ? AppColors.accentTeal : AppColors.grey, size: 20 * context.fontSizeFactor),
            SizedBox(width: 8 * context.fontSizeFactor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor)),
                if (balance > 0 || (!isCard && id != "EVC Plus" && id != "Somnet"))
                  Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(balance), style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processTransaction(BuildContext context, String l10nKey, String amountStr, String accountId, {String? provider, String? paymentMethod, String? cardId}) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context, listen: false);
    
    final double? amount = double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invalidAmount)));
      return;
    }

    if (!state.hasSufficientBalanceForSource(amount, paymentMethod ?? "Main Wallet", cardId: cardId)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance)));
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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

    try {
      // Use the atomic central state method
      final transaction = await state.processBillPayment(
        category: provider ?? _getTranslatedCategory(l10n, l10nKey),
        accountId: accountId,
        amount: amount,
        l10nKey: l10nKey,
        paymentMethod: paymentMethod,
        cardId: cardId,
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      
      _showSuccess(context, l10nKey, amountStr, state, accountId, provider: provider, paymentMethod: paymentMethod, transaction: transaction);
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')))
        );
      }
    }
  }

  void _showSuccess(BuildContext context, String l10nKey, String amountStr, AppState state, String accountId, {String? provider, String? paymentMethod, required Transaction transaction}) {
    final l10n = AppLocalizations.of(context)!;
    final translatedCategory = _getTranslatedCategory(l10n, l10nKey);
    final displayTitle = provider ?? translatedCategory;
    
    final method = paymentMethod ?? "Main Wallet";

    final transactionData = {
      'title': displayTitle,
      'amount': transaction.amount,
      'date': DateFormat('MMM dd, yyyy').format(transaction.timestamp),
      'status': transaction.status,
      'type': transaction.type,
      'category': transaction.category,
      'reference': transaction.id,
      'method': method,
      'accountId': accountId,
      'isNegative': transaction.isNegative,
    };

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.paymentSuccessful,
          message: l10n.paymentSuccessMessage(amountStr, translatedCategory),
          subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)),
          buttonText: l10n.backToHome,
          transactionData: transactionData,
          onPressed: () {
            state.setNavIndex(0); // Reset to Home tab
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
              (route) => false,
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  Widget _buildRecentBill(BuildContext context, String title, String date, String amount, String l10nKey, String id) {
    final theme = Theme.of(context);
    final categoryData = _categories.firstWhere(
      (c) => c['l10nKey'] == l10nKey,
      orElse: () => _categories.first,
    );
    final icon = categoryData['icon'] as IconData;
    final color = categoryData['color'] as Color;

    return FadeInUp(
      child: GestureDetector(
        onTap: () => _showBillDetail(context, title, date, amount, l10nKey, id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.1 : 0.02),
                blurRadius: 15, 
                offset: const Offset(0, 6)
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10 * context.fontSizeFactor),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24 * context.fontSizeFactor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)),
                    Text(date, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
                  ],
                ),
              ),
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)),
            ],
          ),
        ),
      ),
    );
  }

  void _showBillDetail(BuildContext context, String title, String date, String amount, String l10nKey, String id) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.fromLTRB(32 * context.fontSizeFactor, 20 * context.fontSizeFactor, 32 * context.fontSizeFactor, 32 * context.fontSizeFactor),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Text(
                  l10n.billDetails, 
                  style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)
                ),
                const SizedBox(height: 24),
                DetailRow(label: l10n.serviceProvider, value: title),
                DetailRow(label: l10n.category, value: _getTranslatedCategory(l10n, l10nKey)),
                DetailRow(label: l10n.accountId, value: id),
                DetailRow(label: l10n.amountPaid, value: amount),
                DetailRow(label: l10n.paymentDate, value: date),
                DetailRow(label: l10n.status, value: l10n.completed, valueColor: AppColors.accentTeal),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56 * context.fontSizeFactor,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.downloadReceipt, 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.close, 
                    style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTranslatedCategory(AppLocalizations l10n, String l10nKey) {
    switch (l10nKey) {
      case "electricity": return l10n.electricity;
      case "water": return l10n.water;
      case "internet": return l10n.internet;
      case "tvCable": return l10n.tvCable;
      case "education": return l10n.education;
      case "govServices": return l10n.govServices;
      default: return l10nKey;
    }
  }

  String _deriveL10nKey(String title, AppLocalizations l10n) {
    for (var entry in _providers.entries) {
      if (entry.value.contains(title)) return entry.key;
    }
    if (title == l10n.electricity) return "electricity";
    if (title == l10n.water) return "water";
    if (title == l10n.internet) return "internet";
    if (title == l10n.tvCable) return "tvCable";
    if (title == l10n.education) return "education";
    if (title == l10n.govServices) return "govServices";
    return "electricity";
  }

  Future<bool> _showSecurityPinDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context, listen: false);
    final TextEditingController pinController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.enterSecurityPin, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterTransactionPin, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              if (state.verifyPin(pinController.text)) {
                if (context.mounted) Navigator.pop(context, true);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.invalidPin), duration: const Duration(seconds: 2)),
                  );
                }
              }
            },
            child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
