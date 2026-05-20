import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/widgets/success_screen.dart';
import 'models/campaign.dart';
import 'campaign_detail_screen.dart';
import 'create_campaign_screen.dart';
import 'zakat_calculator_screen.dart';

class SadaqahScreen extends StatefulWidget {
  const SadaqahScreen({super.key});

  @override
  State<SadaqahScreen> createState() => _SadaqahScreenState();
}

class _SadaqahScreenState extends State<SadaqahScreen> {
  String _selectedCategory = "All";
  String _searchQuery = "";
  String _selectedSort = "Newest"; // Newest, Near Goal, Top Raised
  final TextEditingController _searchController = TextEditingController();
  
  List<Campaign> _getCampaigns(AppState state, AppLocalizations l10n) {
    List<Campaign> filtered = state.campaigns.where((campaign) {
      final query = _searchQuery.toLowerCase();
      return campaign.title.toLowerCase().contains(query) || 
             campaign.description.toLowerCase().contains(query) ||
             campaign.creator.toLowerCase().contains(query);
    }).toList();

    if (_selectedCategory != "All") {
      filtered = filtered.where((c) => c.category == _selectedCategory).toList();
    }

    // Sorting Logic
    if (_selectedSort == "Near Goal") {
      filtered.sort((a, b) => (b.raisedAmount / b.goalAmount).compareTo(a.raisedAmount / a.goalAmount));
    } else if (_selectedSort == "Top Raised") {
      filtered.sort((a, b) => b.raisedAmount.compareTo(a.raisedAmount));
    } else {
      // Newest
      filtered = filtered.reversed.toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildHeroSection(BuildContext context, Campaign featured, AppState state, AppLocalizations l10n) {
    double progress = featured.raisedAmount / featured.goalAmount;
    final theme = Theme.of(context);
    
    return FadeInDown(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CampaignDetailScreen(campaign: featured)),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 16 * context.fontSizeFactor),
          height: 400 * context.fontSizeFactor,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32 * context.fontSizeFactor),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, 10 * context.fontSizeFactor))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                featured.imageUrl, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryDark.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(child: Icon(featured.icon, size: 60 * context.fontSizeFactor, color: Colors.white.withValues(alpha: 0.2))),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      height: 160 * context.fontSizeFactor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24 * context.fontSizeFactor,
                left: 24 * context.fontSizeFactor,
                right: 24 * context.fontSizeFactor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor, vertical: 6 * context.fontSizeFactor),
                      decoration: BoxDecoration(color: AppColors.accentTeal, borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
                      child: Text(l10n.sadaqahUrgent, style: TextStyle(color: Colors.white, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                    SizedBox(height: 12 * context.fontSizeFactor),
                    Text(featured.title, style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$${featured.raisedAmount.toInt()} ${l10n.sadaqahRaised}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
                        Text("${(progress * 100).toInt()}%", style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
                      ],
                    ),
                    SizedBox(height: 8 * context.fontSizeFactor),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10 * context.fontSizeFactor),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                        minHeight: 8 * context.fontSizeFactor,
                      ),
                    ),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showQuickDonateSheet(context, featured, state),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                        ),
                        child: Text(l10n.sadaqahDonateNow, style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBanner(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FadeInUp(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 8 * context.fontSizeFactor),
        padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 16 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accentTeal.withValues(alpha: 0.15), AppColors.accentTeal.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
          border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.05), blurRadius: 15 * context.fontSizeFactor, offset: Offset(0, 5 * context.fontSizeFactor)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8 * context.fontSizeFactor),
              decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.verified_user_rounded, color: AppColors.accentTeal, size: 22 * context.fontSizeFactor),
            ),
            SizedBox(width: 16 * context.fontSizeFactor),
            Expanded(
              child: Text(
                l10n.secureProtected + ". " + l10n.zeroPlatformFees + ". " + l10n.freeWithdrawals + ".",
                style: TextStyle(color: AppColors.accentTeal, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w600, letterSpacing: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonationHistory(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12 * context.fontSizeFactor),
              width: 40 * context.fontSizeFactor,
              height: 4 * context.fontSizeFactor,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2 * context.fontSizeFactor),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24 * context.fontSizeFactor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.sadaqahHistory,
                    style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor, vertical: 6 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                    ),
                    child: Text(
                      "\$420.00 ${l10n.sadaqahTotal}",
                      style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor),
                itemCount: 3,
                itemBuilder: (context, index) {
                  final history = [
                    {"title": l10n.campaignMedicalTitle, "amount": 150, "date": "Oct 12, 2023"},
                    {"title": l10n.campaignWaterTitle, "amount": 50, "date": "Sep 28, 2023"},
                    {"title": l10n.campaignEmergencyTitle, "amount": 220, "date": "Aug 15, 2023"},
                  ];
                  final item = history[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16 * context.fontSizeFactor),
                    padding: EdgeInsets.all(16 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.volunteer_activism_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                        ),
                        SizedBox(width: 16 * context.fontSizeFactor),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["title"].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                              Text(item["date"].toString(), style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
                            ],
                          ),
                        ),
                        Text(
                          "+\$${item["amount"]}",
                          style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 8 * context.fontSizeFactor),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(fontSize: 14 * context.fontSizeFactor),
              decoration: InputDecoration(
                hintText: l10n.sadaqahSearchHint,
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey, size: 20 * context.fontSizeFactor),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: AppColors.grey, size: 20 * context.fontSizeFactor),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                  : null,
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
              ),
            ),
          ),
          SizedBox(width: 12 * context.fontSizeFactor),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.tune_rounded, color: AppColors.accentTeal),
              onSelected: (val) => setState(() => _selectedSort = val),
              itemBuilder: (context) => [
                const PopupMenuItem(value: "Newest", child: Text("Newest")),
                const PopupMenuItem(value: "Near Goal", child: Text("Near Goal")),
                const PopupMenuItem(value: "Top Raised", child: Text("Top Raised")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickDonateSheet(BuildContext context, Campaign campaign, AppState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    double amount = 10.0;
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
                  "${l10n.sadaqahDonateTo} ${campaign.title}",
                  style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24 * context.fontSizeFactor),
                
                // Live Balance Display
                Container(
                  padding: EdgeInsets.all(16 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                    border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
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
                SizedBox(height: 24 * context.fontSizeFactor),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [5, 10, 20, 50, 100].map((val) {
                    final isSel = amount == val.toDouble();
                    return GestureDetector(
                      onTap: () => setModalState(() => amount = val.toDouble()),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.accentTeal : Colors.transparent,
                          borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                          border: Border.all(color: isSel ? AppColors.accentTeal : AppColors.grey.withOpacity(0.3)),
                        ),
                        child: Text("\$$val", style: TextStyle(color: isSel ? Colors.white : theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32 * context.fontSizeFactor),
                SizedBox(
                  width: double.infinity,
                  height: 56 * context.fontSizeFactor,
                  child: ElevatedButton(
                    onPressed: () {
                      if (state.balance < amount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      setModalState(() => isPinStage = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                    ),
                    child: Text(l10n.sadaqahDonateNow, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Text(
                  l10n.securityVerification,
                  style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8 * context.fontSizeFactor),
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
                      fillColor: theme.dividerColor.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2)),
                    ),
                    onChanged: (val) {
                      if (val.length == 4) {
                        _handleDonation(context, campaign, state, amount, val);
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
                        onPressed: () => _handleDonation(context, campaign, state, amount, pinController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal,
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

  Future<void> _handleDonation(BuildContext context, Campaign campaign, AppState state, double amount, String pin) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (pin.length < 4) return;

    if (!state.verifyPin(pin)) {
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
      await state.donateToCampaign(campaign.id, amount);
      
      if (!context.mounted) return;
      
      // Pop loader and bottom sheet
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();

      // Navigate to Success Screen
      final transactionData = {
        'title': "Sadaqah: ${campaign.title}",
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.3)),
            SizedBox(height: 16 * context.fontSizeFactor),
            Text(
              l10n.noCampaignsFound,
              style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
            ),
            SizedBox(height: 8 * context.fontSizeFactor),
            Text(
              l10n.tryAdjustingFilters,
              style: TextStyle(color: AppColors.grey.withValues(alpha: 0.6), fontSize: 14 * context.fontSizeFactor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZakatCalculatorCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FadeInDown(
      child: Container(
        margin: EdgeInsets.fromLTRB(context.horizontalPadding, 0, context.horizontalPadding, 16 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [const Color(0xFFF8FAFC), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
          border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentTeal.withValues(alpha: isDark ? 0.1 : 0.05),
              blurRadius: 20 * context.fontSizeFactor,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ZakatCalculatorScreen()),
              );
            },
            borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
            child: Padding(
              padding: EdgeInsets.all(20 * context.fontSizeFactor),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                    ),
                    child: Icon(Icons.calculate_rounded, color: AppColors.accentTeal, size: 28 * context.fontSizeFactor),
                  ),
                  SizedBox(width: 16 * context.fontSizeFactor),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.zakatCalculator,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 16 * context.fontSizeFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4 * context.fontSizeFactor),
                        Text(
                          l10n.sadaqahZakatCalcDesc,
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 12 * context.fontSizeFactor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Directionality.of(context) == ui.TextDirection.rtl 
                        ? Icons.chevron_left_rounded 
                        : Icons.chevron_right_rounded, 
                    color: AppColors.accentTeal
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, AppLocalizations l10n) {
    final categories = ["All", "Medical", "Water", "Education", "Emergency"];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 50 * context.fontSizeFactor,
      margin: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 12 * context.fontSizeFactor),
            child: FilterChip(
              selected: isSelected,
              label: Text(_getL10nCategory(cat, l10n)),
              onSelected: (val) => setState(() => _selectedCategory = cat),
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.withValues(alpha: 0.05),
              selectedColor: AppColors.accentTeal.withValues(alpha: 0.15),
              padding: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
              side: BorderSide(color: isSelected ? AppColors.accentTeal : Colors.transparent),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accentTeal : AppColors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13 * context.fontSizeFactor,
              ),
              shape: StadiumBorder(),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  String _getL10nCategory(String cat, AppLocalizations l10n) {
    switch (cat) {
      case "All": return l10n.catAll;
      case "Medical": return l10n.catMedical;
      case "Water": return l10n.catWater;
      case "Education": return l10n.catEducation;
      case "Emergency": return l10n.catEmergency;
      default: return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);
    final campaigns = _getCampaigns(state, l10n);
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.sadaqahCommunity, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: theme.colorScheme.primary),
            onPressed: () {
              _showDonationHistory(context, l10n);
            },
          ),
          SizedBox(width: 8 * context.fontSizeFactor),
        ],
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 1000,
          child: Column(
            children: [
              _buildSearchBar(context, l10n),
              _buildCategories(context, l10n),
              Expanded(
                child: campaigns.isEmpty 
                  ? _buildEmptyState(context, l10n)
                  : ListView(
                      padding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
                      children: [
                        if (_searchQuery.isEmpty && _selectedCategory == "All") _buildZakatCalculatorCard(context, l10n),
                        if (campaigns.isNotEmpty && _searchQuery.isEmpty) _buildHeroSection(context, campaigns.first, state, l10n),
                        if (_searchQuery.isEmpty) _buildTrustBanner(context, l10n),
                        ...campaigns.asMap().entries.map((entry) {
                          final index = entry.key;
                          final campaign = entry.value;
                          // If hero is shown, skip the first one in the list to avoid duplication
                          if (_searchQuery.isEmpty && _selectedCategory == "All" && index == 0) return const SizedBox.shrink();
                          
                          return FadeInUp(
                            delay: Duration(milliseconds: 100 * index),
                            child: Center(
                              child: MaxWidthBox(
                                maxWidth: 800,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                                  child: _buildCampaignCard(context, campaign, l10n),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 100 * context.fontSizeFactor),
                      ],
                    ),
              ),
              _buildBottomAction(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, Campaign campaign, AppLocalizations l10n) {
    double progress = campaign.raisedAmount / campaign.goalAmount;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = ResponsiveBreakpoints.of(context).largerThan(MOBILE);

    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CampaignDetailScreen(campaign: campaign)),
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 32 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32 * context.fontSizeFactor),
            border: Border.all(color: theme.dividerColor.withValues(alpha: isDark ? 0.08 : 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                blurRadius: 30 * context.fontSizeFactor,
                offset: Offset(0, 15 * context.fontSizeFactor),
              ),
              BoxShadow(
                color: AppColors.accentTeal.withValues(alpha: isDark ? 0.05 : 0.01),
                blurRadius: 20 * context.fontSizeFactor,
                offset: Offset(0, 10 * context.fontSizeFactor),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isTablet) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: [
                          Image.network(
                            campaign.imageUrl,
                            height: 280 * context.fontSizeFactor,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 280 * context.fontSizeFactor,
                              width: double.infinity,
                              color: theme.colorScheme.primary.withValues(alpha: 0.05),
                              child: Icon(campaign.icon, size: 48 * context.fontSizeFactor, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                            ),
                          ),
                          _buildVerifiedBadge(context, l10n),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.all(24 * context.fontSizeFactor),
                        child: _buildCardContent(context, campaign, l10n, progress),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        campaign.imageUrl,
                        height: 180 * context.fontSizeFactor,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180 * context.fontSizeFactor,
                          width: double.infinity,
                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                          child: Icon(campaign.icon, size: 48 * context.fontSizeFactor, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                      ),
                      _buildVerifiedBadge(context, l10n),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    child: _buildCardContent(context, campaign, l10n, progress),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Positioned(
      top: 16 * context.fontSizeFactor,
      left: 16 * context.fontSizeFactor,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20 * context.fontSizeFactor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10 * context.fontSizeFactor)]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, color: const Color(0xFF10B981), size: 16 * context.fontSizeFactor),
            SizedBox(width: 6 * context.fontSizeFactor),
            Text(l10n.verified, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Campaign campaign, AppLocalizations l10n, double progress) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up_rounded, size: 14 * context.fontSizeFactor, color: AppColors.accentTeal),
            SizedBox(width: 4 * context.fontSizeFactor),
            Expanded(
              child: Text(
                "${l10n.sadaqahTrending} • ${campaign.lastDonationAgo} ${l10n.sadaqahAgo}",
                style: TextStyle(color: AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (campaign.isUrgent)
              Container(
                margin: EdgeInsets.only(left: 8 * context.fontSizeFactor),
                padding: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8 * context.fontSizeFactor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flash_on_rounded, size: 12 * context.fontSizeFactor, color: Colors.red),
                    SizedBox(width: 4 * context.fontSizeFactor),
                    Text(
                      l10n.sadaqahUrgent.toUpperCase(),
                      style: TextStyle(color: Colors.red, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 12 * context.fontSizeFactor),
        Row(
          children: [
            Expanded(
              child: Text(campaign.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.colorScheme.primary)),
            ),
            IconButton(
              onPressed: () {
                // Share functionality
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sharing ${campaign.title}...")));
              },
              icon: Icon(Icons.share_rounded, size: 20 * context.fontSizeFactor, color: AppColors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        SizedBox(height: 8 * context.fontSizeFactor),
        Text(campaign.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, height: 1.5)),
        SizedBox(height: 24 * context.fontSizeFactor),
        ClipRRect(
          borderRadius: BorderRadius.circular(10 * context.fontSizeFactor),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
            minHeight: 8 * context.fontSizeFactor,
          ),
        ),
        SizedBox(height: 16 * context.fontSizeFactor),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("\$${campaign.raisedAmount.toInt()}", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 18 * context.fontSizeFactor)),
                      SizedBox(width: 4 * context.fontSizeFactor),
                      Expanded(
                        child: Text(
                          "${l10n.sadaqahRaisedOf} \$${campaign.goalAmount.toInt()}",
                          style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4 * context.fontSizeFactor),
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded, size: 14 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.8)),
                      SizedBox(width: 4 * context.fontSizeFactor),
                      Expanded(
                        child: Text(
                          "${campaign.donorCount} ${l10n.sadaqahDonations}",
                          style: TextStyle(color: AppColors.grey.withValues(alpha: 0.8), fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * context.fontSizeFactor),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _showQuickDonateSheet(context, campaign, Provider.of<AppState>(context, listen: false)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                  elevation: 0,
                ),
                child: Text(
                  l10n.sadaqahDonate,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildBottomAction(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(24 * context.fontSizeFactor, 16 * context.fontSizeFactor, 24 * context.fontSizeFactor, context.responsiveValue(mobile: 120, tablet: 24, desktop: 24)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30 * context.fontSizeFactor)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, -5 * context.fontSizeFactor))],
      ),
      child: Center(
        child: MaxWidthBox(
          maxWidth: 500,
          child: SizedBox(
            width: double.infinity,
            height: 60 * context.fontSizeFactor,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateCampaignScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              child: Text(l10n.startAFundraiser, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
            ),
          ),
        ),
      ),
    );
  }
}
