import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'models/campaign.dart';
import 'campaign_detail_screen.dart';
import 'create_campaign_screen.dart';
import 'zakat_calculator_screen.dart';

import 'zakat_calculator_screen.dart';

class SadaqahScreen extends StatefulWidget {
  const SadaqahScreen({super.key});

  @override
  State<SadaqahScreen> createState() => _SadaqahScreenState();
}

class _SadaqahScreenState extends State<SadaqahScreen> {
  String _selectedCategory = "All";
  
  List<Campaign> _getCampaigns(AppState state, AppLocalizations l10n) {
    final allCampaigns = [
      Campaign(
        id: "1",
        category: "Medical",
        title: l10n.campaignMedicalTitle,
        description: l10n.campaignMedicalDesc,
        goalAmount: 5000,
        raisedAmount: 3250,
        creator: "Ali Abdi",
        icon: Icons.medical_services_rounded,
        imageUrl: "https://images.unsplash.com/photo-1584515169010-2590d757b333?q=80&w=800&auto=format&fit=crop",
        donorCount: 142,
        lastDonationAgo: "5m",
      ),
      Campaign(
        id: "2",
        category: "Water",
        title: l10n.campaignWaterTitle,
        description: l10n.campaignWaterDesc,
        goalAmount: 2000,
        raisedAmount: 1800,
        creator: "Community Fund",
        icon: Icons.water_drop_rounded,
        imageUrl: "https://images.unsplash.com/photo-1518398046578-8cca57782e17?q=80&w=800&auto=format&fit=crop",
        donorCount: 89,
        lastDonationAgo: "12m",
      ),
      Campaign(
        id: "3",
        category: "Education",
        title: l10n.campaignEducationTitle,
        description: l10n.campaignEducationDesc,
        goalAmount: 3000,
        raisedAmount: 450,
        creator: "Sahra Jama",
        icon: Icons.school_rounded,
        imageUrl: "https://images.unsplash.com/photo-1503676260728-1c00da096a0b?q=80&w=800&auto=format&fit=crop",
        donorCount: 24,
        lastDonationAgo: "1h",
      ),
      Campaign(
        id: "4",
        category: "Emergency",
        title: l10n.campaignEmergencyTitle,
        description: l10n.campaignEmergencyDesc,
        goalAmount: 10000,
        raisedAmount: 7200,
        creator: "Red Crescent",
        icon: Icons.volunteer_activism_rounded,
        imageUrl: "https://images.unsplash.com/photo-1593113598332-cd288d649433?q=80&w=800&auto=format&fit=crop",
        donorCount: 256,
        lastDonationAgo: "2m",
      ),
    ];
    
    if (_selectedCategory == "All") return allCampaigns;
    return allCampaigns.where((c) => c.category == _selectedCategory).toList();
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
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    
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
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 1000,
          child: Column(
            children: [
              _buildCategories(context, l10n),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
                  children: [
                    if (campaigns.isNotEmpty) _buildHeroSection(context, campaigns.first, state, l10n),
                    _buildTrustBanner(context, l10n),
                    ...campaigns.asMap().entries.map((entry) {
                      final index = entry.key;
                      final campaign = entry.value;
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
            Text(
              "${l10n.sadaqahTrending} • ${campaign.lastDonationAgo} ${l10n.sadaqahAgo}",
              style: TextStyle(color: AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12 * context.fontSizeFactor),
        Text(campaign.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.colorScheme.primary)),
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
          children: [
            Text("\$${campaign.raisedAmount.toInt()}", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 18 * context.fontSizeFactor)),
            SizedBox(width: 4 * context.fontSizeFactor),
            Text("${l10n.sadaqahRaisedOf} \$${campaign.goalAmount.toInt()}", style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
          ],
        ),
        SizedBox(height: 12 * context.fontSizeFactor),
        Divider(color: theme.dividerColor.withValues(alpha: 0.1), height: 1),
        SizedBox(height: 12 * context.fontSizeFactor),
        Row(
          children: [
            Icon(Icons.people_outline_rounded, size: 16 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.8)),
            SizedBox(width: 6 * context.fontSizeFactor),
            Text(
              "${campaign.donorCount} ${l10n.sadaqahDonations}",
              style: TextStyle(color: AppColors.grey.withValues(alpha: 0.8), fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500),
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
