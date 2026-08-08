import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui' as ui;
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'models/campaign.dart';
import '../../core/app_state.dart';
import 'campaign_detail_screen.dart';
import 'create_campaign_screen.dart';
import 'zakat_calculator_screen.dart';
import '../../l10n/app_localizations.dart';

class SadaqahScreen extends StatefulWidget {
  const SadaqahScreen({super.key});

  @override
  State<SadaqahScreen> createState() => _SadaqahScreenState();
}

class _SadaqahScreenState extends State<SadaqahScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Campaign> _getCampaigns(AppState state, AppLocalizations l10n) {
    return state.campaigns.where((campaign) {
      final matchesSearch = campaign.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          campaign.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "All" || campaign.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showDonationHistory(BuildContext context, AppLocalizations l10n, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.donationHistory,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: Center(
                child: Text(l10n.noDonationsFound, style: TextStyle(color: AppColors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(16 * context.fontSizeFactor),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: l10n.sadaqahSearchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = "");
                },
              )
            : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, AppLocalizations l10n) {
    final categories = ["All", "Medical", "Water", "Education", "Emergency"];
    final theme = Theme.of(context);
    return Container(
      height: 60 * context.fontSizeFactor,
      padding: EdgeInsets.symmetric(vertical: 8 * context.fontSizeFactor),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 10 * context.fontSizeFactor),
            child: ChoiceChip(
              label: Text(_getL10nCategory(cat, l10n)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = cat);
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13 * context.fontSizeFactor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.volunteer_activism_outlined, size: 80 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.5)),
          SizedBox(height: 24 * context.fontSizeFactor),
          Text(l10n.noCampaignsFound, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildZakatCalculatorCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(16 * context.fontSizeFactor),
      child: Container(
        padding: EdgeInsets.all(24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.zakatCalculator, style: TextStyle(color: Colors.white, fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8 * context.fontSizeFactor),
                  Text(l10n.calculateZakatEasily, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14 * context.fontSizeFactor)),
                ],
              ),
            ),
            SizedBox(width: 16 * context.fontSizeFactor),
            Flexible(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ZakatCalculatorScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                  padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor),
                ),
                child: Text(l10n.calculateNow, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Campaign campaign, AppState state, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(16 * context.fontSizeFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 24 * context.fontSizeFactor),
              SizedBox(width: 8 * context.fontSizeFactor),
              Text(
                l10n.featuredCampaign, 
                style: TextStyle(
                  fontSize: 18 * context.fontSizeFactor, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.primary
                )
              ),
            ],
          ),
          SizedBox(height: 16 * context.fontSizeFactor),
          _buildCampaignCard(context, campaign, l10n, isFeatured: true),
        ],
      ),
    );
  }

  Widget _buildTrustBanner(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24 * context.fontSizeFactor),
      child: Column(
        children: [
          Icon(Icons.shield_rounded, color: AppColors.accentTeal, size: 32 * context.fontSizeFactor),
          SizedBox(height: 12 * context.fontSizeFactor),
          Text(l10n.safeAndSecureDonations, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
          SizedBox(height: 4 * context.fontSizeFactor),
          Text(l10n.weEnsureFundsReach, style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);
    final campaigns = _getCampaigns(state, l10n);
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    
    final responsive = ResponsiveBreakpoints.of(context);
    final crossAxisCount = responsive.isDesktop ? 3 : (responsive.isTablet ? 2 : 1);
    
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
              _showDonationHistory(context, l10n, state);
            },
          ),
          SizedBox(width: 8 * context.fontSizeFactor),
        ],
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 1200,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSearchBar(context, l10n)),
              SliverToBoxAdapter(child: _buildCategories(context, l10n)),
              if (campaigns.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, l10n),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (_searchQuery.isEmpty && _selectedCategory == "All") 
                        _buildZakatCalculatorCard(context, l10n),
                      if (campaigns.isNotEmpty && _searchQuery.isEmpty && _selectedCategory == "All") 
                        _buildHeroSection(context, campaigns.first, state, l10n),
                      if (_searchQuery.isEmpty) 
                        _buildTrustBanner(context, l10n),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(16 * context.fontSizeFactor),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24 * context.fontSizeFactor,
                      mainAxisSpacing: 32 * context.fontSizeFactor,
                      childAspectRatio: context.responsiveValue(
                        mobile: 0.85,
                        tablet: 0.9,
                        desktop: 0.8,
                      ),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Skip the first campaign if it's already shown in HeroSection
                        final actualIndex = (_searchQuery.isEmpty && _selectedCategory == "All") ? index + 1 : index;
                        if (actualIndex >= campaigns.length) return null;
                        
                        final campaign = campaigns[actualIndex];
                        return _buildCampaignCard(context, campaign, l10n);
                      },
                      childCount: (_searchQuery.isEmpty && _selectedCategory == "All") 
                          ? (campaigns.length - 1).clamp(0, 100) 
                          : campaigns.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 100 * context.fontSizeFactor)),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context, l10n),
    );
  }

  Widget _buildCampaignCard(BuildContext context, Campaign campaign, AppLocalizations l10n, {bool isFeatured = false}) {
    double progress = (campaign.raisedAmount / campaign.goalAmount).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = ResponsiveBreakpoints.of(context).largerThan(MOBILE);

    return FadeInUp(
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CampaignDetailScreen(campaign: campaign)),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: isFeatured ? 16 * context.fontSizeFactor : 0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
              border: Border.all(color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 20 * context.fontSizeFactor,
                  offset: Offset(0, 10 * context.fontSizeFactor),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Featured layout on tablet/desktop: Side by side
                if (isFeatured && isTablet) {
                  return SizedBox(
                    height: 320 * context.fontSizeFactor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildCardImage(context, campaign),
                              _buildVerifiedBadge(context, l10n),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.all(24 * context.fontSizeFactor),
                            child: _buildCardContent(context, campaign, l10n, progress, isFeatured: true),
                          ),
                        ),
                      ],
                    ),
                  );
                }
  
                // Normal grid or mobile layout: Image on top
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        _buildCardImage(context, campaign, height: isFeatured ? 220 : 180),
                        _buildVerifiedBadge(context, l10n),
                      ],
                    ),
                    if (isFeatured)
                      Padding(
                        padding: EdgeInsets.all(16 * context.fontSizeFactor),
                        child: _buildCardContent(context, campaign, l10n, progress, isFeatured: true),
                      )
                    else
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16 * context.fontSizeFactor),
                          child: _buildCardContent(context, campaign, l10n, progress, isFeatured: false),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(BuildContext context, Campaign campaign, {double? height}) {
    final theme = Theme.of(context);
    return Image.network(
      campaign.imageUrl,
      height: height != null ? height * context.fontSizeFactor : null,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height != null ? height * context.fontSizeFactor : 200 * context.fontSizeFactor,
        width: double.infinity,
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        child: Icon(campaign.icon, size: 48 * context.fontSizeFactor, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
    );
  }

  Widget _buildVerifiedBadge(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return PositionedDirectional(
      top: 12 * context.fontSizeFactor,
      start: 12 * context.fontSizeFactor,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * context.fontSizeFactor, vertical: 6 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, color: const Color(0xFF10B981), size: 14 * context.fontSizeFactor),
            SizedBox(width: 4 * context.fontSizeFactor),
            Text(
              l10n.verified, 
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color, 
                fontSize: 10 * context.fontSizeFactor, 
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Campaign campaign, AppLocalizations l10n, double progress, {bool isFeatured = false}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIndicator(context, campaign, l10n),
                if (campaign.isUrgent) ...[
                  SizedBox(width: 8 * context.fontSizeFactor),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * context.fontSizeFactor, vertical: 2 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4 * context.fontSizeFactor),
                    ),
                    child: Text(
                      l10n.sadaqahUrgent,
                      style: TextStyle(color: Colors.red, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12 * context.fontSizeFactor),
            Text(
              campaign.title, 
              maxLines: isFeatured ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: (isFeatured ? 20 : 16) * context.fontSizeFactor, 
                color: theme.colorScheme.primary,
                letterSpacing: -0.5,
              )
            ),
            SizedBox(height: 4 * context.fontSizeFactor),
            Text(
              campaign.description, 
              maxLines: isFeatured ? 3 : 2, 
              overflow: TextOverflow.ellipsis, 
              style: TextStyle(
                color: AppColors.grey, 
                fontSize: (isFeatured ? 14 : 12) * context.fontSizeFactor, 
                height: 1.4
              )
            ),
          ],
        ),
        
        Column(
          children: [
            SizedBox(height: 16 * context.fontSizeFactor),
            ClipRRect(
              borderRadius: BorderRadius.circular(4 * context.fontSizeFactor),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.9 ? Colors.orange : AppColors.accentTeal
                ),
                minHeight: 6 * context.fontSizeFactor,
              ),
            ),
            SizedBox(height: 12 * context.fontSizeFactor),
            Row(
              children: [
                Text(
                  NumberFormat.simpleCurrency(name: "USD", decimalDigits: 0).format(campaign.raisedAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 15 * context.fontSizeFactor, 
                    color: theme.colorScheme.primary
                  ),
                ),
                Text(
                  " ${l10n.sadaqahRaisedOf} ",
                  style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor),
                ),
                Text(
                  NumberFormat.simpleCurrency(name: "USD", decimalDigits: 0).format(campaign.goalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13 * context.fontSizeFactor, 
                    color: AppColors.grey
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context, Campaign campaign, AppLocalizations l10n) {
    Color color = AppColors.accentTeal;
    String text = "";
    IconData icon = Icons.trending_up_rounded;

    switch (campaign.status) {
      case 'new':
        color = Colors.blue;
        text = l10n.sadaqahNew;
        icon = Icons.fiber_new_rounded;
        break;
      case 'trending':
        color = AppColors.accentTeal;
        text = l10n.sadaqahTrending;
        icon = Icons.trending_up_rounded;
        break;
      case 'ending_soon':
        color = Colors.orange;
        text = l10n.sadaqahEndingSoon;
        icon = Icons.timer_rounded;
        break;
      case 'completed':
        color = Colors.purple;
        text = l10n.sadaqahCompleted;
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14 * context.fontSizeFactor, color: color),
          SizedBox(width: 4 * context.fontSizeFactor),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorAvatars(BuildContext context, Campaign campaign) {
    return SizedBox(
      height: 32 * context.fontSizeFactor,
      child: Row(
        children: [
          Stack(
            children: List.generate(
              campaign.donorAvatars.take(3).length,
              (index) => Container(
                margin: EdgeInsets.only(left: index * 20.0 * context.fontSizeFactor),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 14 * context.fontSizeFactor,
                  backgroundImage: NetworkImage(campaign.donorAvatars[index]),
                ),
              ),
            ),
          ),
          if (campaign.donorCount > 0) ...[
            SizedBox(width: 8 * context.fontSizeFactor),
            Text(
              l10n.sadaqahDonorsCount(campaign.donorCount),
              style: TextStyle(fontSize: 12 * context.fontSizeFactor, color: AppColors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartnerLogos(BuildContext context, Campaign campaign) {
    return Row(
      children: campaign.partnerLogos.take(3).map((partner) {
        return Container(
          margin: EdgeInsets.only(left: 8 * context.fontSizeFactor),
          padding: EdgeInsets.symmetric(horizontal: 6 * context.fontSizeFactor, vertical: 2 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4 * context.fontSizeFactor),
          ),
          child: Text(
            partner,
            style: TextStyle(fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.grey),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildBottomAction(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30 * context.fontSizeFactor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 20 * context.fontSizeFactor, 
            offset: Offset(0, -5 * context.fontSizeFactor)
          )
        ],
        border: theme.brightness == Brightness.dark 
          ? Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))) 
          : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24 * context.fontSizeFactor, 
            16 * context.fontSizeFactor, 
            24 * context.fontSizeFactor, 
            16 * context.fontSizeFactor
          ),
          child: Center(
            child: MaxWidthBox(
              maxWidth: 500,
              child: SizedBox(
                width: double.infinity,
                height: 56 * context.fontSizeFactor,
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
        ),
      ),
    );
  }
}
