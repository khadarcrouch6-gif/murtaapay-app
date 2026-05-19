import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'models/campaign.dart';
import 'success_donation_screen.dart';

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
              background: Stack(
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
                          child: _buildProgressCard(state, l10n, progress, theme, isDark),
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
                            "${widget.campaign.description}\n\nThis fundraiser was started to handle the urgent costs for Ahmed's surgery. Every dollar brings us closer to the goal and helps save a life. Join the 142 donors who have already contributed.",
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
                  _buildShareOption(Icons.facebook_rounded, "Facebook", Colors.blue),
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
      {"name": "Anonymous", "amount": 100, "time": "15m ago"},
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
    String selectedMethod = "Mobile";
    final TextEditingController customAmountController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

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
                       l10n.finalizeDonation,
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
                          _buildDetailsStep(state, l10n, selectedMethod, phoneController),
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
                              _processDonation(context, state, l10n, amount);
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
      {"id": "Mobile", "name": l10n.mobileMoney, "icon": Icons.phone_android_rounded},
      {"id": "Bank", "name": l10n.bankTransfer, "icon": Icons.account_balance_rounded},
      {"id": "Card", "name": l10n.debitCreditCard, "icon": Icons.credit_card_rounded},
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
              Text(
                m["name"] as String, 
                style: TextStyle(
                  fontWeight: selectedMethod == m["id"] ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14 * context.fontSizeFactor,
                  color: selectedMethod == m["id"] ? theme.colorScheme.primary : AppColors.grey,
                ),
              ),
              const Spacer(),
              if (selectedMethod == m["id"]) 
                Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDetailsStep(AppState state, AppLocalizations l10n, String method, TextEditingController phoneController) {
    if (method == "Mobile") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.enterPhoneNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
          SizedBox(height: 12 * context.fontSizeFactor),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 16 * context.fontSizeFactor),
            decoration: InputDecoration(
              hintText: "E.g. 061XXXXXXX",
              prefixIcon: const Icon(Icons.phone_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
            ),
          ),
          SizedBox(height: 16 * context.fontSizeFactor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProviderLogo("EVC+", Colors.blue),
              _buildProviderLogo("Sahal", Colors.orange),
              _buildProviderLogo("Zaad", Colors.red),
            ],
          ),
        ],
      );
    } else if (method == "Bank") {
      return Column(
        children: [
           Icon(Icons.account_balance_rounded, size: 64 * context.fontSizeFactor, color: AppColors.grey),
           SizedBox(height: 16 * context.fontSizeFactor),
           Text(l10n.selectLocalBank, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
           SizedBox(height: 8 * context.fontSizeFactor),
           Text(l10n.transferDirectlyDesc, style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
        ],
      );
    } else {
      return Column(
        children: [
           Icon(Icons.credit_card_rounded, size: 64 * context.fontSizeFactor, color: AppColors.grey),
           SizedBox(height: 16 * context.fontSizeFactor),
           Text(l10n.payWithVisaMastercard, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
           SizedBox(height: 8 * context.fontSizeFactor),
           Text(l10n.secureInternationalGateway, style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
        ],
      );
    }
  }

  Widget _buildProviderLogo(String name, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12 * context.fontSizeFactor), border: Border.all(color: color.withValues(alpha: 0.5))),
      child: Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor)),
    );
  }

  void _processDonation(BuildContext context, AppState state, AppLocalizations l10n, double amount) {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount")));
      return;
    }

    if (!state.hasSufficientBalance(amount)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.insufficientBalanceSadaqah),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    state.deductBalance(amount);
    Navigator.pop(context); // Close dialog
    Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessDonationScreen(amount: amount)));
  }
}
