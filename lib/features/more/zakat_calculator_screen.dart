import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/widgets/success_screen.dart';
import 'models/campaign.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _investmentsController = TextEditingController();
  double _totalZakat = 0.0;
  bool _isNisabMet = false;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_calculateZakat);
    _goldController.addListener(_calculateZakat);
    _silverController.addListener(_calculateZakat);
    _investmentsController.addListener(_calculateZakat);
    
    // Refresh Nisab on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).updateNisabValues();
    });
  }

  void _calculateZakat() {
    final state = Provider.of<AppState>(context, listen: false);
    double cash = double.tryParse(_cashController.text) ?? 0.0;
    double gold = double.tryParse(_goldController.text) ?? 0.0;
    double silver = double.tryParse(_silverController.text) ?? 0.0;
    double investments = double.tryParse(_investmentsController.text) ?? 0.0;

    double totalAssets = cash + gold + silver + investments;
    setState(() {
      _totalZakat = totalAssets >= state.effectiveNisab ? totalAssets * 0.025 : 0.0;
      _isNisabMet = totalAssets >= state.effectiveNisab;
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _investmentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);

    final scale = context.fontSizeFactor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.zakatCalculator, 
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 20 * scale)
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl 
                ? Icons.arrow_forward_rounded 
                : Icons.arrow_back_rounded
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(32 * scale),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(32 * scale),
                          boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.3), blurRadius: 20 * scale, offset: Offset(0, 10 * scale))],
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.totalZakatToPay, 
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16 * scale)
                            ),
                            SizedBox(height: 8 * scale),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("\$${_totalZakat.toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 42 * scale, fontWeight: FontWeight.bold))
                            ),
                            if (!_isNisabMet && (double.tryParse(_cashController.text) ?? 0) > 0)
                              FadeIn(
                                child: Container(
                                  margin: EdgeInsets.only(top: 12 * scale),
                                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12 * scale)),
                                  child: Text(
                                    l10n.belowNisabWarning(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.effectiveNisab)),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 11 * scale, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),
                Center(
                  child: FadeIn(
                    child: Column(
                      children: [
                        Text(
                          "${state.translate("Current Nisab", "Nisaabka hadda")} (${state.preferredNisab == 'gold' ? l10n.goldValue : l10n.silverValue})",
                          style: TextStyle(color: AppColors.grey, fontSize: 12 * scale, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          "\$${state.effectiveNisab.toStringAsFixed(2)}",
                          style: TextStyle(color: AppColors.primary, fontSize: 18 * scale, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12 * scale),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'gold', label: Text(l10n.goldValue), icon: const Icon(Icons.auto_awesome_rounded)),
                            ButtonSegment(value: 'silver', label: Text(l10n.silverValue), icon: const Icon(Icons.brightness_high_rounded)),
                          ],
                          selected: {state.preferredNisab},
                          onSelectionChanged: (Set<String> newSelection) {
                            state.setPreferredNisab(newSelection.first);
                            _calculateZakat();
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: AppColors.primary.withOpacity(0.1),
                            selectedForegroundColor: AppColors.primary,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
                FadeInUp(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.enterYourAssets, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold)),
                          SizedBox(height: 24 * scale),
                          _buildInputField(l10n.cashAndSavings, _cashController, Icons.account_balance_wallet_rounded, isDark, scale),
                          SizedBox(height: 16 * scale),
                          _buildInputField(l10n.goldValue, _goldController, Icons.auto_awesome_rounded, isDark, scale),
                          SizedBox(height: 16 * scale),
                          _buildInputField(l10n.silverValue, _silverController, Icons.brightness_high_rounded, isDark, scale),
                          SizedBox(height: 16 * scale),
                          _buildInputField(l10n.otherInvestments, _investmentsController, Icons.trending_up_rounded, isDark, scale),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40 * scale),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20 * scale),
                              border: Border.all(color: AppColors.accentTeal.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: AppColors.accentTeal, size: 24 * scale),
                                SizedBox(width: 16 * scale),
                                Expanded(
                                  child: Text(
                                    l10n.zakatInfo,
                                    style: TextStyle(fontSize: 13 * scale, color: AppColors.accentTeal, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          TextButton.icon(
                            onPressed: () => _showZakatDistributionDialog(context, scale),
                            icon: Icon(Icons.people_outline_rounded, size: 18 * scale, color: AppColors.primary),
                            label: Text(
                              state.translate("Who is entitled to Zakat?", "Yaa la siiyaa Zakada? (8-da Qaybood)"),
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13 * scale),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                              backgroundColor: AppColors.primary.withOpacity(0.05),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 60 * scale),
                Center(
                  child: MaxWidthBox(
                    maxWidth: 600,
                    child: SizedBox(
                      width: double.infinity,
                      height: 60 * scale,
                      child: ElevatedButton(
                        onPressed: _totalZakat > 0 ? _handleZakatDonation : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * scale)),
                          elevation: 4,
                        ),
                        child: Text(l10n.donateYourZakat, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * scale)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40 * scale),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleZakatDonation() {
    final state = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    
    // Find a campaign specifically for Zakat if available, otherwise use a suitable one
    Campaign zakatCampaign;
    try {
      zakatCampaign = state.campaigns.firstWhere((c) => c.category.toLowerCase().contains('zakat'));
    } catch (e) {
      zakatCampaign = state.campaigns.first;
    }
    
    _showZakatDonationSheet(context, zakatCampaign, state, _totalZakat);
  }

  void _showZakatDonationSheet(BuildContext context, Campaign campaign, AppState state, double amount) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    String selectedMethod = "Main Wallet";
    String? selectedCardId;
    bool isPinStage = false;
    final TextEditingController pinController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 24 * context.fontSizeFactor,
            left: 24 * context.fontSizeFactor,
            right: 24 * context.fontSizeFactor,
            bottom: (24 * context.fontSizeFactor) + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isPinStage) ...[
                Text(
                  l10n.donateYourZakat,
                  style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8 * context.fontSizeFactor),
                Text(
                  NumberFormat.simpleCurrency(name: state.currencyCode).format(amount),
                  style: TextStyle(fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
                SizedBox(height: 24 * context.fontSizeFactor),
                
                // Funding Source Selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSourceOption(
                        context, 
                        "Main Wallet", 
                        l10n.walletBalance, 
                        state.balance, 
                        selectedMethod == "Main Wallet",
                        (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }),
                        state
                      ),
                      ...state.cards.map((card) => _buildSourceOption(
                        context, 
                        "card_${card.id}", 
                        card.cardHolder, 
                        card.balance, 
                        selectedMethod == "card_${card.id}",
                        (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }),
                        state,
                        cardId: card.id,
                        isCard: true
                      )),
                      if (state.savingsBalance > 0)
                        _buildSourceOption(
                          context, 
                          "Savings Account", 
                          l10n.savingsBalance, 
                          state.savingsBalance, 
                          selectedMethod == "Savings Account",
                          (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }),
                          state
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 32 * context.fontSizeFactor),
                SizedBox(
                  width: double.infinity,
                  height: 56 * context.fontSizeFactor,
                  child: ElevatedButton(
                    onPressed: () {
                      String sourceKey = selectedMethod;
                      if (selectedMethod.startsWith("card_")) sourceKey = "Debit Card";
                      
                      if (!state.hasSufficientBalanceForSource(amount, sourceKey, cardId: selectedCardId)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      setModalState(() => isPinStage = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                    ),
                    child: Text(l10n.confirm, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Text(
                  l10n.securityVerification,
                  style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8 * context.fontSizeFactor),
                Text(
                  selectedCardId != null ? state.translate("Enter Card PIN", "Geli PIN-ka Kaadhka") : l10n.enterTransactionPin,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24 * context.fontSizeFactor),
                SizedBox(
                  width: 200 * context.fontSizeFactor,
                  child: TextField(
                    controller: pinController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: TextStyle(fontSize: 24 * context.fontSizeFactor, letterSpacing: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      hintText: "****",
                      hintStyle: TextStyle(letterSpacing: 16 * context.fontSizeFactor, fontSize: 24 * context.fontSizeFactor),
                      filled: true,
                      fillColor: theme.dividerColor.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2)),
                    ),
                    onChanged: (val) {
                      if (val.length == 4) {
                        _processDonation(campaign, amount, val, selectedMethod, selectedCardId);
                      }
                    },
                  ),
                ),
                SizedBox(height: 32 * context.fontSizeFactor),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => setModalState(() => isPinStage = false),
                        child: Text(l10n.cancel, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 16 * context.fontSizeFactor),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _processDonation(campaign, amount, pinController.text, selectedMethod, selectedCardId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                        ),
                        child: Text(l10n.confirm, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 16 * context.fontSizeFactor),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processDonation(Campaign campaign, double amount, String pin, String method, String? cardId) async {
    final state = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (pin.length < 4) return;

    bool isPinValid = false;
    if (cardId != null) {
      isPinValid = state.verifyCardPin(pin, cardId: cardId);
    } else {
      isPinValid = state.verifyPin(pin);
    }

    if (!isPinValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.translate("Incorrect PIN. Please try again.", "PIN-kaagu waa khalad. Fadlan isku day markale.")),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryDark),
            const SizedBox(height: 16),
            Text(l10n.processing, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    try {
      await state.donateToCampaign(campaign.id, amount, cardId: cardId, paymentMethod: method);
      
      if (!mounted) return;
      
      // Pop loader and bottom sheet
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();

      // Navigate to Success Screen
      final transactionData = {
        'title': "Zakat Payment",
        'amount': "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(amount)}",
        'date': DateFormat('MMM dd, yyyy').format(DateTime.now()),
        'status': 'Success',
        'type': 'transfer_out',
        'recipient': "Zakat Fund",
        'transactionId': "ZAK-${DateTime.now().millisecondsSinceEpoch}",
        'source': method.startsWith("card_") ? "Debit Card" : method,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: l10n.paymentSuccessful,
            message: "Your Zakat of ${NumberFormat.simpleCurrency(name: state.currencyCode).format(amount)} has been paid.",
            buttonText: l10n.done,
            transactionData: transactionData,
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildSourceOption(
    BuildContext context, 
    String id, 
    String title, 
    double balance, 
    bool isSelected,
    Function(String, String?) onTap,
    AppState state,
    {String? cardId, bool isCard = false}
  ) {
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    return GestureDetector(
      onTap: () => onTap(id, cardId),
      child: Container(
        margin: EdgeInsets.only(right: 12 * scale),
        padding: EdgeInsets.all(12 * scale),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : theme.dividerColor.withOpacity(0.1),
            width: 2
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCard ? Icons.credit_card_rounded : Icons.account_balance_wallet_rounded,
              color: isSelected ? AppColors.primaryDark : AppColors.grey,
              size: 20 * scale,
            ),
            SizedBox(width: 8 * scale),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * scale)),
                Text(
                  NumberFormat.simpleCurrency(name: state.currencyCode).format(balance),
                  style: TextStyle(color: AppColors.grey, fontSize: 11 * scale),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, bool isDark, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold, color: Colors.grey)),
        SizedBox(height: 8 * scale),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20 * scale),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide: BorderSide(color: Colors.transparent, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            hintText: "0.00",
            contentPadding: EdgeInsets.symmetric(vertical: 16 * scale, horizontal: 16 * scale),
          ),
        ),
      ],
    );
  }

  void _showZakatDistributionDialog(BuildContext context, double scale) {
    final state = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24 * scale)),
        insetPadding: EdgeInsets.all(16 * scale),
        child: MaxWidthBox(
          maxWidth: 700,
          child: Container(
            padding: EdgeInsets.all(24 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.translate("8 Categories of Zakat", "8-da Qaybood ee Zakada"),
                      style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEvidenceSection(
                          state.translate("Evidence from Quran", "Daliilka Quraanka"),
                          "إِنَّمَا الصَّدَقَاتُ لِلْفُقَرَاءِ وَالْمَسَاكِينِ وَالْعَامِلِينَ عَلَيْهَا وَالْمُؤَلَّفَةِ قُلُوبُهُمْ وَفِي الرِّقَابِ وَالْغَارِمِينَ وَفِي سَبِيلِ اللَّهِ وَابْنِ السَّبِيلِ ۖ فَرِيضَةً مِّنَ اللَّهِ ۗ وَاللَّهُ عَلِيمٌ حَكِيمٌ",
                          "Surah At-Tawbah (9:60)",
                          scale
                        ),
                        SizedBox(height: 12 * scale),
                        _buildEvidenceSection(
                          state.translate("Evidence from Hadith", "Daliilka Xadiiska"),
                          "تُؤْخَذُ مِنْ أَغْنِيَائِهِمْ فَتُرَدُّ عَلَى فُقَرَائِهِمْ",
                          state.translate("Sahih Bukhari - Prophet (PBUH) to Mu'adh (RA)", "Saxiixul Bukhaari - Nabiga (CSW) wuxuu ku yiri Mucaad (RC)"),
                          scale,
                          isHadith: true
                        ),
                        SizedBox(height: 20 * scale),
                        _buildCategoryItem(
                          "1",
                          state.translate("Al-Fuqara' (The Poor)", "Fuqarada (Dadka Baahan)"),
                          state.translate(
                            "Those who have no income or property and cannot meet their basic needs.",
                            "Dadka aan haysan wax ay cunaan ama wax ay quutaan, oo aan haysan hanti ku filan."
                          ),
                          scale,
                        ),
                        _buildCategoryItem(
                          "2",
                          state.translate("Al-Masakin (The Needy)", "Masaakiinta (Dadka Danyarta ah)"),
                          state.translate(
                            "Those who have some income but it is not enough to cover their basic necessities.",
                            "Dadka haysata dakhli yar balse aan ku filnayn baahiyahooda aasaasiga ah."
                          ),
                          scale,
                        ),
                        _buildCategoryItem(
                          "3",
                          state.translate("Al-Amilina 'Alayha (Zakat Collectors)", "Kuwa ka Shaqeeya (Ururiyaasha)"),
                          state.translate(
                            "Those appointed to collect, manage and distribute Zakat funds.",
                            "Dadka loo xilsaaray ururinta, maamulidda iyo qaybinta hantida Zakada."
                          ),
                          scale,
                        ),
                        _buildCategoryItem(
                          "4",
                          state.translate("Al-Mu'allafati Qulubuhum", "Kuwa Quluubtooda la soo dhoweynayo"),
                          state.translate(
                            "New Muslims or those who are close to Islam to strengthen their faith.",
                            "Dadka ku cusub Islaamka ama kuwa loo soo dhoweynayo diinta si loo xoojiyo quluubtooda."
                          ),
                          scale,
                        ),
                        _buildCategoryItem(
                          "5",
                          state.translate("Fir-Riqab (Freeing Captives)", "Addoomada (Xoraynta)"),
                          state.translate(
                            "Used to free slaves or captives from bondage.",
                            "Zaka waxaa loo isticmaali karaa in lagu xoreeyo addoomada ama maxaabiista laga rabo madax-furasho."
                          ),
                          scale,
                        ),
                        _buildCategoryItem(
                          "6",
                          state.translate("Al-Gharimin (Debtors)", "Kuwa lagu leeyahay deynta"),
                          state.translate(
                            "Those overwhelmed by debt incurred for basic needs or social harmony.",
                            "Dadka deyntu ku raagtay ee aan awoodin inay iska bixiyaan, haddii ay u soo deynteen baahi sharci ah."
                          ),
                          scale,
                        ),
                        _buildCategoryItem(
                          "7",
                          state.translate("Fi Sabilillah (Path of Allah)", "Jidka Alle"),
                          state.translate(
                            "Those striving for the cause of Allah, including education and community welfare.",
                            "Kuwa u adeegaya jidka Alle, sida faafinta diinta, waxbarashada, iyo danta guud ee muslimiinta."
                          ),
                          scale,
                        ),
                        _buildCategoryItem(
                          "8",
                          state.translate("Ibnus-Sabil (The Wayfarer)", "Socotada (Musafirka)"),
                          state.translate(
                            "Travelers who are stranded and need financial assistance to reach home.",
                            "Socotada ku go'doontay safarka oo u baahan caawinaad lacageed si ay gurigooda u gaaraan."
                          ),
                          scale,
                        ),
                        SizedBox(height: 16 * scale),
                        Container(
                          padding: EdgeInsets.all(16 * scale),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16 * scale),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.translate("Fatwa & Madhahib", "Fatwada & Madhaahibta"),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * scale, color: Colors.brown),
                              ),
                              SizedBox(height: 8 * scale),
                              Text(
                                state.translate(
                                  "According to the majority of scholars (Shafi'i, Maliki, Hanbali, and Hanafi), Zakat must be distributed to these 8 categories specifically. Some Madhahib allow giving to one category if the need is greater there.",
                                  "Sida ay qabaan badankood culimada (Shaafici, Maaliki, Xanbali, iyo Xanafi), Zakada waa in la siiyaa 8-dan qaybood. Qaar kamid ah madhaahibta ayaa oggol in la siiyo hal qayb haddii baahidu ku weyn tahay."
                                ),
                                style: TextStyle(fontSize: 12 * scale, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceSection(String title, String arabic, String reference, double scale, {bool isHadith = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * scale, color: AppColors.grey)),
        SizedBox(height: 6 * scale),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: isHadith ? Colors.green.withOpacity(0.05) : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: (isHadith ? Colors.green : AppColors.primary).withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                arabic,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                  color: isHadith ? Colors.green[800] : AppColors.primaryDark,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                reference, 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11 * scale, fontStyle: FontStyle.italic, color: AppColors.grey)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String number, String title, String description, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12 * scale),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * scale)),
                SizedBox(height: 2 * scale),
                Text(
                  description,
                  style: TextStyle(fontSize: 13 * scale, color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
