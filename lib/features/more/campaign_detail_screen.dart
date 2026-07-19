import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/widgets/success_screen.dart';
import 'models/campaign.dart';

class CampaignDetailScreen extends StatefulWidget {
  final Campaign campaign;
  const CampaignDetailScreen({super.key, required this.campaign});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = AppState();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    double progress = widget.campaign.raisedAmount / widget.campaign.goalAmount;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: RepaintBoundary(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.campaign.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primaryDark),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.7)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () => _showShareSheet(context, state, l10n),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Center(
              child: MaxWidthBox(
                maxWidth: 800,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor, vertical: 6 * context.fontSizeFactor),
                            decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, color: AppColors.accentTeal, size: 16 * context.fontSizeFactor),
                                SizedBox(width: 6 * context.fontSizeFactor),
                                Text(l10n.verifiedOrganizer, style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: Text(widget.campaign.title, style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                        ),
                        SizedBox(height: 8 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Text("${l10n.organizedBy} ${widget.campaign.creator}", style: TextStyle(color: theme.textTheme.bodySmall?.color ?? AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: RepaintBoundary(child: _buildProgressCard(state, l10n, progress, theme, isDark)),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Text(l10n.about, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                        ),
                        SizedBox(height: 16 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            "${widget.campaign.description}\n\n${l10n.campaignDescriptionExtra}",
                            style: TextStyle(fontSize: 15 * context.fontSizeFactor, height: 1.6, color: theme.textTheme.bodyMedium?.color ?? AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        Divider(color: theme.dividerColor.withValues(alpha: 0.1)),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: _buildTrustSection(context, state, l10n),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 700),
                          child: _buildDonorsList(context, state, l10n),
                        ),
                        SizedBox(height: 120 * context.fontSizeFactor), // padding for bottom button
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: MaxWidthBox(
        maxWidth: 800,
        child: Container(
          padding: EdgeInsets.all(24 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
            border: isDark ? Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))) : null,
          ),
          child: ElevatedButton(
            onPressed: () => _showDonateDialog(context, state, l10n, theme, isDark),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentTeal,
              minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
            ),
            child: Text(l10n.donateNow, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(AppState state, AppLocalizations l10n, double progress, ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
        border: Border.all(color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("\$${widget.campaign.raisedAmount.toInt()}", style: TextStyle(fontSize: 28 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              SizedBox(width: 8 * context.fontSizeFactor),
              Text(l10n.sadaqahRaisedOf, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
              SizedBox(width: 4 * context.fontSizeFactor),
              Text("\$${widget.campaign.goalAmount.toInt()} ${l10n.goal}", style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16 * context.fontSizeFactor),
          ClipRRect(
            borderRadius: BorderRadius.circular(10 * context.fontSizeFactor),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
              minHeight: 12 * context.fontSizeFactor,
            ),
          ),
          SizedBox(height: 16 * context.fontSizeFactor),
          Row(
            children: [
              Icon(Icons.people_alt_rounded, color: AppColors.accentTeal, size: 16 * context.fontSizeFactor),
              SizedBox(width: 8 * context.fontSizeFactor),
              Text(
                "${widget.campaign.donorCount} ${l10n.peopleDonated}",
                style: TextStyle(color: AppColors.accentTeal, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTrustSection(BuildContext context, AppState state, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20 * context.fontSizeFactor),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark.withValues(alpha: 0.03), AppColors.primaryDark.withValues(alpha: 0.01)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildTrustItem(Icons.verified_user_rounded, l10n.secureProtected, l10n.secureProtectedDesc),
          SizedBox(height: 16 * context.fontSizeFactor),
          _buildTrustItem(Icons.monetization_on_rounded, l10n.zeroPlatformFees, l10n.zeroPlatformFeesDesc),
          SizedBox(height: 16 * context.fontSizeFactor),
          _buildTrustItem(Icons.account_balance_wallet_rounded, l10n.freeWithdrawals, l10n.freeWithdrawalsDesc),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8 * context.fontSizeFactor),
          decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
        ),
        SizedBox(width: 16 * context.fontSizeFactor),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
              Text(subtitle, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareSheet(BuildContext context, AppState state, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor))),
      builder: (context) => MaxWidthBox(
        maxWidth: 600,
        child: Container(
          padding: EdgeInsets.all(32 * context.fontSizeFactor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.shareThisCampaign, style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
              SizedBox(height: 24 * context.fontSizeFactor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareOption(Icons.message_rounded, "WhatsApp", Colors.green),
                  _buildShareOption(Icons.facebook_rounded, l10n.facebook, Colors.blue),
                  _buildShareOption(Icons.link_rounded, l10n.link, AppColors.primaryDark),
                ],
              ),
              SizedBox(height: 24 * context.fontSizeFactor),
              Container(
                padding: EdgeInsets.all(16 * context.fontSizeFactor),
                decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                child: Row(
                  children: [
                    Expanded(child: Text("https://murtaaxpay.app/donate/ahmed-surgery", style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor), overflow: TextOverflow.ellipsis)),
                    SizedBox(width: 8 * context.fontSizeFactor),
                    Icon(Icons.copy_rounded, color: AppColors.primaryDark, size: 20 * context.fontSizeFactor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16 * context.fontSizeFactor),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 30 * context.fontSizeFactor),
        ),
        SizedBox(height: 8 * context.fontSizeFactor),
        Text(label, style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDonorsList(BuildContext context, AppState state, AppLocalizations l10n) {
    final donors = [
      {"name": "Ali Hassan", "amount": 50, "time": "2m ago"},
      {"name": l10n.anonymous, "amount": 100, "time": "15m ago"},
      {"name": "Sahra Jama", "amount": 25, "time": "1h ago"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recentDonations, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        SizedBox(height: 16 * context.fontSizeFactor),
        ...donors.map((donor) => Padding(
          padding: EdgeInsets.only(bottom: 16 * context.fontSizeFactor),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                child: Text(donor["name"].toString().substring(0, 1), style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 16 * context.fontSizeFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(donor["name"].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(donor["time"].toString(), style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
                  ],
                ),
              ),
              Text("\$${donor["amount"]}", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal, fontSize: 14 * context.fontSizeFactor)),
            ],
          ),
        )).toList(),
      ],
    );
  }

  void _showDonateDialog(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme, bool isDark) {
    int selectedAmount = 50;
    int currentStep = 0;
    String selectedMethod = "Wallet";
    final TextEditingController customAmountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => MaxWidthBox(
          maxWidth: 600,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(36 * context.fontSizeFactor)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, -10)),
              ],
            ),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                SizedBox(height: 12 * context.fontSizeFactor),
                Container(width: 40 * context.fontSizeFactor, height: 4 * context.fontSizeFactor, decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2 * context.fontSizeFactor))),
                SizedBox(height: 24 * context.fontSizeFactor),
                Row(
                  children: [
                     if (currentStep > 0) IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => setModalState(() => currentStep--)),
                     const Spacer(),
                     Text(
                       currentStep == 0 ? l10n.selectAmount : 
                       currentStep == 1 ? l10n.paymentMethod :
                       l10n.securityVerification,
                       style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                     ),
                     const Spacer(),
                     if (currentStep > 0) SizedBox(width: 48 * context.fontSizeFactor),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    child: Column(
                      children: [
                        if (currentStep == 0) ...[
                          _buildAmountStep(state, l10n, selectedAmount, customAmountController, theme, (val) => setModalState(() => selectedAmount = val)),
                        ] else if (currentStep == 1) ...[
                          _buildPaymentMethodStep(state, l10n, selectedMethod, theme, (val) => setModalState(() => selectedMethod = val)),
                        ] else ...[
                          Text(
                            l10n.enterTransactionPin,
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
                                fillColor: theme.dividerColor.withValues(alpha: 0.05),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2)),
                              ),
                              onChanged: (val) {
                                if (val.length == 4) {
                                   final double amount = customAmountController.text.isNotEmpty 
                                      ? double.tryParse(customAmountController.text) ?? 0 
                                      : selectedAmount.toDouble();
                                  _processDonation(context, state, l10n, amount, val);
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24 * context.fontSizeFactor),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.total, style: const TextStyle(color: AppColors.grey)),
                          Text("\$${customAmountController.text.isNotEmpty ? customAmountController.text : selectedAmount}", style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
                        ],
                      ),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      SizedBox(
                        width: double.infinity,
                        height: 56 * context.fontSizeFactor,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor))),
                          onPressed: () {
                            if (currentStep < 2) {
                              setModalState(() => currentStep++);
                            } else {
                               final double amount = customAmountController.text.isNotEmpty 
                                  ? double.tryParse(customAmountController.text) ?? 0 
                                  : selectedAmount.toDouble();
                              _processDonation(context, state, l10n, amount, pinController.text);
                            }
                          },
                          child: Text(
                            currentStep < 2 ? l10n.continueLabel : l10n.donateNow,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * context.fontSizeFactor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 14 * context.fontSizeFactor, color: AppColors.grey),
                          SizedBox(width: 4 * context.fontSizeFactor),
                          Text(l10n.securedByMurtaaxPay, style: TextStyle(color: AppColors.grey, fontSize: 10 * context.fontSizeFactor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountStep(AppState state, AppLocalizations l10n, int selectedAmount, TextEditingController controller, ThemeData theme, Function(int) onSelect) {
    final amounts = [10, 20, 50, 100, 250, 500];
    return Column(
      children: [
        // Live Balance Display
        Container(
          padding: EdgeInsets.all(16 * context.fontSizeFactor),
          margin: EdgeInsets.only(bottom: 24 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
            border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: theme.colorScheme.secondary, size: 24 * context.fontSizeFactor),
              SizedBox(width: 12 * context.fontSizeFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.walletBalance, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                    Text(
                      NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
            crossAxisSpacing: 12 * context.fontSizeFactor, 
            mainAxisSpacing: 12 * context.fontSizeFactor, 
            childAspectRatio: 2
          ),
          itemCount: amounts.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              onSelect(amounts[index]);
              controller.clear();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: selectedAmount == amounts[index] ? AppColors.accentTeal.withValues(alpha: 0.12) : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                border: Border.all(
                  color: selectedAmount == amounts[index] ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1),
                  width: selectedAmount == amounts[index] ? 2 : 1,
                ),
                boxShadow: selectedAmount == amounts[index] 
                  ? [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
              ),
              alignment: Alignment.center,
              child: Text(
                "\$${amounts[index]}", 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16 * context.fontSizeFactor,
                  color: selectedAmount == amounts[index] ? AppColors.accentTeal : theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24 * context.fontSizeFactor),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 16 * context.fontSizeFactor),
          onChanged: (val) { if (val.isNotEmpty) onSelect(0); },
          decoration: InputDecoration(
            hintText: l10n.customAmount,
            prefixIcon: const Icon(Icons.attach_money_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodStep(AppState state, AppLocalizations l10n, String selectedMethod, ThemeData theme, Function(String) onSelect) {
    final methods = [
      {"id": "Wallet", "name": l10n.murtaaxWallet, "desc": l10n.murtaaxWalletDesc, "icon": Icons.account_balance_wallet_rounded},
      {"id": "Mobile", "name": l10n.mobileMoney, "desc": l10n.mobileMoneyDesc, "icon": Icons.phone_android_rounded},
      {"id": "Bank", "name": l10n.bankTransfer, "desc": l10n.localBankTransfer, "icon": Icons.account_balance_rounded},
      {"id": "Card", "name": l10n.debitCreditCard, "desc": l10n.payWithInternationalCard, "icon": Icons.credit_card_rounded},
    ];

    return Column(
      children: methods.map((m) => GestureDetector(
        onTap: () => onSelect(m["id"] as String),
        child: Container(
          margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
          padding: EdgeInsets.all(16 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: selectedMethod == m["id"] ? AppColors.accentTeal.withValues(alpha: 0.08) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
            border: Border.all(
              color: selectedMethod == m["id"] ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1),
              width: selectedMethod == m["id"] ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10 * context.fontSizeFactor),
                decoration: BoxDecoration(
                  color: selectedMethod == m["id"] ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.dividerColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(m["icon"] as IconData, color: selectedMethod == m["id"] ? AppColors.accentTeal : AppColors.grey, size: 20 * context.fontSizeFactor),
              ),
              SizedBox(width: 16 * context.fontSizeFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m["name"] as String, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14 * context.fontSizeFactor,
                        color: selectedMethod == m["id"] ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      m["desc"] as String,
                      style: TextStyle(fontSize: 12 * context.fontSizeFactor, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              if (selectedMethod == m["id"]) 
                Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
            ],
          ),
        ),
      )).toList(),
    );
  }

  void _processDonation(BuildContext context, AppState state, AppLocalizations l10n, double amount, String pin) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidAmount)));
      return;
    }

    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.enterSecurityPin)));
      return;
    }

    if (!state.verifyPin(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.translate("Incorrect PIN. Please try again.", "PIN-kaagu waa khalad. Fadlan isku day markale.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (state.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.insufficientBalanceSadaqah),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accentTeal),
              const SizedBox(height: 16),
              Text(l10n.processing, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    try {
      await state.donateToCampaign(widget.campaign.id, amount);
      
      if (!context.mounted) return;
      
      Navigator.of(context, rootNavigator: true).pop(); // Pop loader
      Navigator.of(context).pop(); // Pop bottom sheet

      final transactionData = {
        'title': "Sadaqah: ${widget.campaign.title}",
        'amount': "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(amount)}",
        'date': DateFormat('MMM dd, yyyy').format(DateTime.now()),
        'status': 'Success',
        'type': 'transfer_out',
        'method': 'Wallet',
        'isNegative': true,
        'id': 'TX-SAD-${DateTime.now().millisecondsSinceEpoch}',
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: l10n.donationSuccessful,
            message: l10n.donationSuccessMessage,
            subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)),
            buttonText: l10n.backToHome,
            transactionData: transactionData,
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }
}
