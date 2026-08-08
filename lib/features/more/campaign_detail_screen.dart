import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
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
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    double progress = widget.campaign.raisedAmount / widget.campaign.goalAmount;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomAction(),
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
              icon: Icon(
                Directionality.of(context) == ui.TextDirection.rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                color: Colors.white,
              ),
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
                          child: _buildUpdatesTimeline(context, state, l10n),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 800),
                          child: _buildDonorsList(context, state, l10n),
                        ),
                        const SizedBox(height: 24), // minimal padding as we use bottomNavigationBar
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
        border: isDark ? Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))) : null,
      ),
      child: SafeArea(
        child: Center(
          child: MaxWidthBox(
            maxWidth: 800,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24 * context.fontSizeFactor, 12 * context.fontSizeFactor, 24 * context.fontSizeFactor, 12 * context.fontSizeFactor),
              child: ElevatedButton(
                onPressed: () => _showDonateDialog(context, Provider.of<AppState>(context, listen: false), l10n, theme, isDark),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                ),
                child: Text(l10n.donateNow, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: Colors.white)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(AppState state, AppLocalizations l10n, double progress, ThemeData theme, bool isDark) {
    String milestoneText = "";
    if (progress >= 1.0) {
      milestoneText = "Goal Reached! 🎉";
    } else if (progress >= 0.9) {
      milestoneText = "Almost There! 🔥";
    } else if (progress >= 0.75) {
      milestoneText = "75% Completed 🚀";
    } else if (progress >= 0.5) {
      milestoneText = "Halfway There! 🙌";
    } else if (progress >= 0.25) {
      milestoneText = "Gaining Momentum ✨";
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("\$${widget.campaign.raisedAmount.toInt()}", style: TextStyle(fontSize: 28 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  SizedBox(width: 8 * context.fontSizeFactor),
                  Text(l10n.sadaqahRaisedOf, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                ],
              ),
              if (milestoneText.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8 * context.fontSizeFactor),
                  ),
                  child: Text(
                    milestoneText,
                    style: TextStyle(color: AppColors.accentTeal, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8 * context.fontSizeFactor),
          Text("\$${widget.campaign.goalAmount.toInt()} ${l10n.goal}", style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          SizedBox(height: 16 * context.fontSizeFactor),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10 * context.fontSizeFactor),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                    minHeight: 12 * context.fontSizeFactor,
                  ),
                ),
                SizedBox(height: 4 * context.fontSizeFactor),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text("${(value * 100).toInt()}%", style: TextStyle(color: AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                ),
              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.recentDonations, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
            if (widget.campaign.recentDonors.length > 3)
              TextButton(
                onPressed: () {},
                child: Text(l10n.viewAll, style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        SizedBox(height: 16 * context.fontSizeFactor),
        if (widget.campaign.recentDonors.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24 * context.fontSizeFactor),
              child: Text(
                l10n.beTheFirstToDonate,
                style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ...widget.campaign.recentDonors.take(5).map((donor) => Padding(
            padding: EdgeInsets.only(bottom: 16 * context.fontSizeFactor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                  backgroundImage: (donor.isAnonymous || donor.avatarUrl == null) ? null : NetworkImage(donor.avatarUrl!),
                  child: (donor.isAnonymous || donor.avatarUrl == null)
                    ? Text(donor.isAnonymous ? "?" : donor.name.substring(0, 1), style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold))
                    : null,
                ),
                SizedBox(width: 16 * context.fontSizeFactor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(donor.isAnonymous ? l10n.anonymous : donor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (donor.message != null && donor.message!.isNotEmpty) ...[
                        SizedBox(height: 4 * context.fontSizeFactor),
                        Container(
                          padding: EdgeInsets.all(12 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                          ),
                          child: Text(
                            donor.message!,
                            style: TextStyle(fontSize: 13 * context.fontSizeFactor, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                      SizedBox(height: 4 * context.fontSizeFactor),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(donor.donatedAt), 
                        style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)
                      ),
                    ],
                  ),
                ),
                Text(
                  NumberFormat.simpleCurrency(name: "USD", decimalDigits: 0).format(donor.amount), 
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal, fontSize: 14 * context.fontSizeFactor)
                ),
              ],
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildUpdatesTimeline(BuildContext context, AppState state, AppLocalizations l10n) {
    if (widget.campaign.updates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.campaignUpdates, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        SizedBox(height: 24 * context.fontSizeFactor),
        ...widget.campaign.updates.asMap().entries.map((entry) {
          final index = entry.key;
          final update = entry.value;
          final isLast = index == widget.campaign.updates.length - 1;

          return IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12 * context.fontSizeFactor,
                      height: 12 * context.fontSizeFactor,
                      decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2 * context.fontSizeFactor,
                          color: AppColors.accentTeal.withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 16 * context.fontSizeFactor),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 32 * context.fontSizeFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(update.timestamp),
                          style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor),
                        ),
                        SizedBox(height: 8 * context.fontSizeFactor),
                        Text(update.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                        SizedBox(height: 8 * context.fontSizeFactor),
                        Text(
                          update.content,
                          style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, height: 1.5),
                        ),
                        if (update.imageUrl != null) ...[
                          SizedBox(height: 16 * context.fontSizeFactor),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                            child: Image.network(update.imageUrl!, fit: BoxFit.cover),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showDonateDialog(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme, bool isDark) {
    double amount = 50.0;
    String selectedMethod = "Main Wallet";
    String? selectedCardId;
    bool isPinStage = false;
    bool isAnonymous = false;
    bool isRecurring = false;
    final TextEditingController amountController = TextEditingController(text: "50");
    final TextEditingController messageController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    final isZakat = widget.campaign.category == "Zakat / Agoomo";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36 * context.fontSizeFactor)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24 * context.fontSizeFactor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isPinStage) ...[
                Text(
                  "${l10n.sadaqahDonateTo} ${widget.campaign.title}",
                  style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (isZakat) ...[
                  SizedBox(height: 12 * context.fontSizeFactor),
                  Container(
                    padding: EdgeInsets.all(12 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                        SizedBox(width: 8 * context.fontSizeFactor),
                        Expanded(
                          child: Text(
                            "${l10n.nisabThreshold}: ${NumberFormat.simpleCurrency(name: "USD").format(state.nisabGold)}",
                            style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w600, fontSize: 13 * context.fontSizeFactor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                      _buildSourceOption(
                        context, 
                        "EVC Plus", 
                        "EVC Plus", 
                        0, 
                        selectedMethod == "EVC Plus",
                        (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }),
                        state,
                        icon: Icons.phone_android_rounded
                      ),
                      _buildSourceOption(
                        context, 
                        "Somnet", 
                        "Somnet", 
                        0, 
                        selectedMethod == "Somnet",
                        (id, cId) => setModalState(() { selectedMethod = id; selectedCardId = cId; }),
                        state,
                        icon: Icons.signal_cellular_alt_rounded
                      ),
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
                SizedBox(height: 24 * context.fontSizeFactor),

                if (selectedMethod == "EVC Plus" || selectedMethod == "Somnet") ...[
                   TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                    decoration: InputDecoration(
                      hintText: l10n.enterPhoneNumber,
                      prefixIcon: Icon(Icons.phone_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                      filled: true,
                      fillColor: theme.dividerColor.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 16 * context.fontSizeFactor),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [10, 20, 50, 100, 250].map((val) {
                    final isSel = amount == val.toDouble();
                    return GestureDetector(
                      onTap: () => setModalState(() {
                        amount = val.toDouble();
                        amountController.text = val.toString();
                      }),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.accentTeal : Colors.transparent,
                          borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                          border: Border.all(color: isSel ? AppColors.accentTeal : AppColors.grey.withValues(alpha: 0.3)),
                        ),
                        child: Text("\$$val", style: TextStyle(color: isSel ? Colors.white : theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16 * context.fontSizeFactor),
                
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => setModalState(() => amount = double.tryParse(val) ?? 0),
                  decoration: InputDecoration(
                    prefixText: r"$ ",
                    hintText: l10n.customAmount,
                    filled: true,
                    fillColor: theme.dividerColor.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                  ),
                ),

                if (isZakat && amount > 0 && amount < state.nisabGold)
                  Padding(
                    padding: EdgeInsets.only(top: 12 * context.fontSizeFactor),
                    child: Text(
                      l10n.belowNisabWarning(NumberFormat.simpleCurrency(name: "USD").format(state.nisabGold)),
                      style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),

                SizedBox(height: 16 * context.fontSizeFactor),

                // Recurring Toggle
                SwitchListTile(
                  title: Text(l10n.makeRecurringDonation, style: TextStyle(fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
                  subtitle: Text(state.translate("Donate automatically every month", "Bixi si otomaatig ah bil walba"), style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
                  value: isRecurring,
                  onChanged: (val) => setModalState(() => isRecurring = val),
                  activeThumbColor: AppColors.accentTeal,
                  contentPadding: EdgeInsets.zero,
                ),

                // Anonymity Toggle
                SwitchListTile(
                  title: Text(l10n.anonymous, style: TextStyle(fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
                  subtitle: Text(state.translate("Hide your name from the public donor list", "Magacaaga ka qari liiska dadka wax bixiyey"), style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
                  value: isAnonymous,
                  onChanged: (val) => setModalState(() => isAnonymous = val),
                  activeThumbColor: AppColors.accentTeal,
                  contentPadding: EdgeInsets.zero,
                ),
                
                SizedBox(height: 12 * context.fontSizeFactor),
                
                // Message Input
                TextField(
                  controller: messageController,
                  maxLines: 2,
                  style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                  decoration: InputDecoration(
                    hintText: state.translate("Leave a message (optional)", "Farriin ka tag (waa ikhtiyaari)"),
                    hintStyle: TextStyle(fontSize: 13 * context.fontSizeFactor),
                    filled: true,
                    fillColor: theme.dividerColor.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.all(16 * context.fontSizeFactor),
                  ),
                ),
                SizedBox(height: 24 * context.fontSizeFactor),

                // Fee Summary Block
                if (amount > 0) ...[
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
                  SizedBox(height: 24 * context.fontSizeFactor),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 56 * context.fontSizeFactor,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedMethod == "EVC Plus" || selectedMethod == "Somnet") {
                        if (phoneController.text.length < 9) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.phoneLengthError)));
                           return;
                        }
                        setModalState(() => isPinStage = true);
                        return;
                      }

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
                      backgroundColor: AppColors.accentTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                    ),
                    child: Text(l10n.donateNow, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Text(
                  l10n.securityVerification,
                  style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8 * context.fontSizeFactor),
                Text(
                  selectedMethod == "EVC Plus" || selectedMethod == "Somnet" 
                    ? state.translate("Enter Mobile Money PIN", "Geli PIN-ka Mobile-ka")
                    : selectedCardId != null ? state.translate("Enter Card PIN", "Geli PIN-ka Kaadhka") : l10n.enterTransactionPin,
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
                        if (context.mounted) {
                          _processDonation(context, state, l10n, amount, val, selectedMethod, selectedCardId, isAnonymous: isAnonymous, message: messageController.text, isRecurring: isRecurring);
                        }
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
                        onPressed: () {
                          if (context.mounted) {
                            _processDonation(context, state, l10n, amount, pinController.text, selectedMethod, selectedCardId, isAnonymous: isAnonymous, message: messageController.text, isRecurring: isRecurring);
                          }
                        },
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
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _buildSourceOption(
    BuildContext context, 
    String id, 
    String title, 
    double balance, 
    bool isSelected,
    Function(String, String?) onTap,
    AppState state,
    {String? cardId, bool isCard = false, IconData? icon}
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onTap(id, cardId),
      child: Container(
        margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
        padding: EdgeInsets.all(12 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
          border: Border.all(
            color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1),
            width: 2
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon ?? (isCard ? Icons.credit_card_rounded : Icons.account_balance_wallet_rounded),
              color: isSelected ? AppColors.accentTeal : AppColors.grey,
              size: 20 * context.fontSizeFactor,
            ),
            SizedBox(width: 8 * context.fontSizeFactor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor)),
                if (balance > 0 || !isCard && id != "EVC Plus" && id != "Somnet")
                  Text(
                    NumberFormat.simpleCurrency(name: state.currencyCode).format(balance),
                    style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processDonation(BuildContext context, AppState state, AppLocalizations l10n, double amount, String pin, String method, String? cardId, {bool isAnonymous = false, String? message, bool isRecurring = false}) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidAmount)));
      return;
    }

    if (pin.length < 4) return;

    bool isPinValid = false;
    if (cardId != null) {
      isPinValid = state.verifyCardPin(pin, cardId: cardId);
    } else {
      isPinValid = state.verifyPin(pin);
    }

    if (!isPinValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.translate("Incorrect PIN. Please try again.", "PIN-kaagu waa khalad. Fadlan isku day markale.")),
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
      await state.donateToCampaign(
        widget.campaign.id, 
        amount,
        cardId: cardId,
        paymentMethod: method,
        isAnonymous: isAnonymous,
        message: message,
        isRecurring: isRecurring,
      );
      
      if (!context.mounted) return;
      
      Navigator.of(context, rootNavigator: true).pop(); // Pop loader
      Navigator.of(context).pop(); // Pop bottom sheet

      final transactionData = {
        'title': "Sadaqah: ${widget.campaign.title}",
        'amount': "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(amount)}",
        'date': DateFormat('MMM dd, yyyy').format(DateTime.now()),
        'status': 'Success',
        'type': 'transfer_out',
        'method': method.startsWith("card_") ? 'Card' : method,
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
