import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/widgets/success_screen.dart';
import 'models/campaign.dart';
import '../../core/widgets/pin_entry_dialog.dart';

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
  
  // Input mode: 'value' or 'weight'
  String _goldInputMode = 'value';
  String _silverInputMode = 'value';

  @override
  void initState() {
    super.initState();
    _cashController.addListener(calculateZakat);
    _goldController.addListener(calculateZakat);
    _silverController.addListener(calculateZakat);
    _investmentsController.addListener(calculateZakat);
    
    // Refresh Nisab on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).updateNisabValues();
    });
  }

  void calculateZakat() {
    final state = Provider.of<AppState>(context, listen: false);
    double cash = double.tryParse(_cashController.text) ?? 0.0;
    
    double gold = double.tryParse(_goldController.text) ?? 0.0;
    if (_goldInputMode == 'weight') {
      gold = gold * state.goldPrice;
    }
    
    double silver = double.tryParse(_silverController.text) ?? 0.0;
    if (_silverInputMode == 'weight') {
      silver = silver * state.silverPrice;
    }
    
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
            padding: EdgeInsets.fromLTRB(
              context.horizontalPadding,
              24 * context.fontSizeFactor,
              context.horizontalPadding,
              context.horizontalPadding,
            ),
            child: Column(
              key: const Key('zakat_calculator_content'),
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
                          boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 20 * scale, offset: Offset(0, 10 * scale))],
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.totalZakatToPay, 
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16 * scale)
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
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12 * scale)),
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
                          "${l10n.currentNisab} (${state.preferredNisab == 'gold' ? l10n.goldValue : l10n.silverValue})",
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
                            calculateZakat();
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                          _buildAssetInputField(
                            label: l10n.goldValue,
                            controller: _goldController,
                            icon: Icons.auto_awesome_rounded,
                            isDark: isDark,
                            scale: scale,
                            mode: _goldInputMode,
                            onModeChanged: (val) {
                              setState(() => _goldInputMode = val);
                              calculateZakat();
                            },
                            pricePerGram: state.goldPrice,
                            state: state,
                            l10n: l10n,
                          ),
                          SizedBox(height: 16 * scale),
                          _buildAssetInputField(
                            label: l10n.silverValue,
                            controller: _silverController,
                            icon: Icons.brightness_high_rounded,
                            isDark: isDark,
                            scale: scale,
                            mode: _silverInputMode,
                            onModeChanged: (val) {
                              setState(() => _silverInputMode = val);
                              calculateZakat();
                            },
                            pricePerGram: state.silverPrice,
                            state: state,
                            l10n: l10n,
                          ),
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
                              color: AppColors.accentTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20 * scale),
                              border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2)),
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
                              l10n.whoIsEntitledToZakat,
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13 * scale),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                              backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                            ),
                          ),
                        ],
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          context.horizontalPadding,
          16 * scale,
          context.horizontalPadding,
          (16 + MediaQuery.of(context).padding.bottom) * scale,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 20 * scale,
              offset: Offset(0, -5 * scale),
            )
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        ),
        child: MaxWidthBox(
          maxWidth: 600,
          child: SizedBox(
            width: double.infinity,
            height: 60 * scale,
            child: ElevatedButton(
              key: const Key('donate_zakat_button'),
              onPressed: _totalZakat > 0 ? _handleZakatDonation : null,
              style: context.elevatedButtonStyle(
                backgroundColor: AppColors.primaryDark,
                height: 60,
                elevation: 8,
                borderRadius: 20,
              ),
              child: Text(l10n.donateYourZakat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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
                height: 60 * context.fontSizeFactor,
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
                    Navigator.pop(context);
                    _showPinDialog(campaign, amount, selectedMethod, selectedCardId);
                  },
                  style: context.elevatedButtonStyle(
                    backgroundColor: AppColors.primaryDark,
                    height: 60,
                    elevation: 8,
                    borderRadius: 20,
                  ),
                  child: Text(l10n.confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ),
              SizedBox(height: 16 * context.fontSizeFactor),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinDialog(Campaign campaign, double amount, String selectedMethod, String? selectedCardId) {
    final state = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => PinEntryDialog(
        title: l10n.securityVerification,
        description: selectedCardId != null ? state.translate("Enter Card PIN", "Geli PIN-ka Kaadhka") : l10n.enterTransactionPin,
        isBiometricEnabled: state.biometricEnabled,
        isCardPin: selectedCardId != null,
        cardId: selectedCardId,
        onValidate: (pin) async {
          if (pin == "BIOMETRIC_SUCCESS") return true;
          if (selectedCardId != null) {
            return state.verifyCardPin(pin, cardId: selectedCardId);
          }
          return state.verifyPin(pin);
        },
        onConfirm: (pin) {
          _processDonation(campaign, amount, pin, selectedMethod, selectedCardId);
        },
      ),
    );
  }

  Future<void> _processDonation(Campaign campaign, double amount, String pin, String method, String? cardId) async {
    final state = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(l10n.processing, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    try {
      await state.donateToCampaign(campaign.id, amount, cardId: cardId, paymentMethod: method);
      
      if (!mounted) return;
      
      // Pop loader
      Navigator.of(context, rootNavigator: true).pop();

      // Navigate to Success Screen
      final transactionData = {
        'title': l10n.zakatPayment,
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
            message: l10n.zakatSuccessMessage(NumberFormat.simpleCurrency(name: state.currencyCode).format(amount)),
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
          color: isSelected ? AppColors.primaryDark.withValues(alpha: 0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : theme.dividerColor.withValues(alpha: 0.1),
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
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
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

  Widget _buildAssetInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    required double scale,
    required String mode,
    required Function(String) onModeChanged,
    required double pricePerGram,
    required AppState state,
    required AppLocalizations l10n,
  }) {
    double inputVal = double.tryParse(controller.text) ?? 0.0;
    double calculatedValue = mode == 'weight' ? inputVal * pricePerGram : inputVal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold, color: Colors.grey)),
            Container(
              height: 32 * scale,
              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Row(
                children: [
                  _buildToggleItem(l10n.value, 'value', mode, onModeChanged, scale, l10n),
                  _buildToggleItem(l10n.grams, 'weight', mode, onModeChanged, scale, l10n),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20 * scale),
            suffixText: mode == 'weight' ? "g" : "\$",
            suffixStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
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
        if (mode == 'weight' && inputVal > 0)
          Padding(
            padding: EdgeInsets.only(top: 4 * scale, left: 4 * scale),
            child: Text(
              "${l10n.estValue} \$${calculatedValue.toStringAsFixed(2)} (@\$${pricePerGram.toStringAsFixed(2)}/g)",
              style: TextStyle(fontSize: 11 * scale, color: AppColors.grey, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleItem(String label, String value, String currentMode, Function(String) onModeChanged, double scale, AppLocalizations l10n) {
    bool isSelected = currentMode == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onModeChanged(value),
        borderRadius: BorderRadius.circular(6 * scale),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6 * scale),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11 * scale,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  void _showZakatDistributionDialog(BuildContext context, double scale) {
    final state = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

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
                      state.translate("Zakat Eligibility & Evidence", "Qaybinta Sekada & Daliilada"),
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
                        _buildRequirementSection(state, scale),
                        SizedBox(height: 20 * scale),
                        _buildEvidenceSection(
                          state.translate("Evidence from Quran", "Daliilka Quraanka"),
                          "إِنَّمَا الصَّدَقَاتُ لِلْفُقَرَاءِ وَالْمَسَاكِينِ وَالْعَامِلِينَ عَلَيْهَا وَالْمُؤَلَّفَةِ قُلُوبُهُمْ وَفِي الرِّقَابِ وَالْغَارِمِينَ وَفِي سَبِيلِ اللَّهِ وَابْنِ السَّبِيلِ ۖ فَرِيضَةً مِّنَ اللَّهِ ۗ وَاللَّهُ عَلِيمٌ حَكِيمٌ",
                          "Surah At-Tawbah (9:60)",
                          scale
                        ),
                        SizedBox(height: 20 * scale),
                        Text(
                          state.translate("The 8 Categories of Recipients", "8-da Qeybood ee Sekada la siiyo"),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
                        ),
                        SizedBox(height: 12 * scale),
                        _buildCategoryItem("1", state.translate("The Poor (Al-Fuqara)", "Fuqarada"), state.translate("Those who have no property or income.", "Dadka aan haysan wax hanti ah ama dakhli."), scale),
                        _buildCategoryItem("2", state.translate("The Needy (Al-Masakin)", "Miskiiniinta"), state.translate("Those whose property or income is not enough for their basic needs.", "Dadka haysta wax yar laakiin aan ku filnayn baahidooda."), scale),
                        _buildCategoryItem("3", state.translate("Zakat Administrators", "Shaqaalaha Sekada"), state.translate("Those who collect and distribute Zakat.", "Dadka u xilsaaran ururinta iyo qaybinta sekada."), scale),
                        _buildCategoryItem("4", state.translate("New Muslims", "Kuwa Quluubtooda la soo jiidanayo"), state.translate("To strengthen their hearts in Islam.", "Dadka cusub ee Islaamka soo galay si loo taageero."), scale),
                        _buildCategoryItem("5", state.translate("Freeing Captives", "Xoraynta Addoomada"), state.translate("To help free people from bondage.", "In lagu xoreeyo dadka aan xorta ahayn."), scale),
                        _buildCategoryItem("6", state.translate("Those in Debt", "Dadka lagu leeyahay deynta"), state.translate("Those who cannot pay their debts.", "Dadka deynta culus lagu leeyahay ee aan awoodin inay iska bixiyaan."), scale),
                        _buildCategoryItem("7", state.translate("In the Cause of Allah", "Jidka Alle"), state.translate("For the struggle in the way of Allah.", "Wixii maslaxo u ah diinta iyo difaaceeda."), scale),
                        _buildCategoryItem("8", state.translate("The Wayfarer", "Socotada"), state.translate("Travelers who are stranded.", "Musaafiriinta ku go'ay waddada ee aan haysan wax ay ku laabtaan."), scale),
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

  Widget _buildRequirementSection(AppState state, double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.translate("Who must pay Zakat?", "Yey ku waajibtay Sekadu?"),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * scale, color: AppColors.primaryDark),
          ),
          SizedBox(height: 8 * scale),
          Text(
            state.translate(
              "Zakat is mandatory for every sane, adult Muslim who owns wealth above the Nisab threshold for a full lunar year (Hawl).",
              "Sekadu waxay ku waajibtay qof kasta oo Muslim ah, qaangaar ah, miyir qaba, oo haysta hanti gaaraysa Nisaabka muddo sannad ah."
            ),
            style: TextStyle(fontSize: 13 * scale, height: 1.5),
          ),
        ],
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
            color: isHadith ? Colors.green.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: (isHadith ? Colors.green : AppColors.primary).withValues(alpha: 0.1)),
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
              key: const Key('zakat_calculator_content'),
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
