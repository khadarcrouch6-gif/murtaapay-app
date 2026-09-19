import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shimmer/shimmer.dart';
import 'campaign_detail_screen.dart';
import 'create_campaign_screen.dart';
import 'zakat_calculator_screen.dart';
import 'models/campaign.dart';

class FundraiserScreen extends StatefulWidget {
  const FundraiserScreen({super.key});

  @override
  State<FundraiserScreen> createState() => _FundraiserScreenState();
}

class _FundraiserScreenState extends State<FundraiserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = "";
  String _selectedCategory = "All";
  bool _isLoading = true;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = ["All", "Education", "Health", "Food", "Zakat / Agoomo", "Emergency", "Mosque"];

    final filteredCampaigns = state.campaigns.where((c) {
      final matchesSearch = c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.creator.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "All" || c.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, state, l10n, theme, isDark),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(context.horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(context, state, l10n, theme, isDark),
                      if (_isSearchFocused && state.sadaqahSearchHistory.isNotEmpty && _searchQuery.isEmpty)
                        _buildSearchHistory(context, state),
                      SizedBox(height: 20 * context.fontSizeFactor),
                      _buildCategories(context, categories),
                      SizedBox(height: 24 * context.fontSizeFactor),
                      _buildZakatEducationBanner(context, state, l10n, theme),
                      SizedBox(height: 24 * context.fontSizeFactor),
                      _buildZakatCalculator(context, l10n, theme),
                      SizedBox(height: 32 * context.fontSizeFactor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            state.translate("Active Campaigns", "Ololayaasha Sadaqada"),
                            style: TextStyle(
                              fontSize: 22 * context.fontSizeFactor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Icon(Icons.tune_rounded, color: AppColors.grey, size: 20 * context.fontSizeFactor),
                        ],
                      ),
                      SizedBox(height: 16 * context.fontSizeFactor),
                    ],
                  ),
                ),
              ),

              if (_isLoading)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildShimmerCard(context),
                      childCount: 3,
                    ),
                  ),
                )
              else if (filteredCampaigns.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, state, l10n, theme),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final campaign = filteredCampaigns[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          child: _buildCampaignCard(context, campaign, l10n, theme, isDark, state),
                        );
                      },
                      childCount: filteredCampaigns.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 140 * context.fontSizeFactor)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomAction(context, state, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.volunteer_activism_outlined, size: 80 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.3)),
          SizedBox(height: 16 * context.fontSizeFactor),
          Text(
            state.translate("No campaigns found", "Wax ololaha lama helin"),
            style: TextStyle(color: AppColors.grey, fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          state.translate("Sadaqah & Zakat", "Sadaqo & Sekat"),
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w900,
            fontSize: 22 * context.fontSizeFactor,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accentTeal.withValues(alpha: 0.1),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 40,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.volunteer_activism_rounded, size: 150, color: AppColors.accentTeal),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSearchBar(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) => setState(() => _searchQuery = value),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            state.addToSearchHistory(value, 'sadaqah');
          }
        },
        decoration: InputDecoration(
          hintText: l10n.searchCampaigns,
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: AppColors.grey, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = "");
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context, AppState state) {
    final scale = context.fontSizeFactor;
    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.only(top: 8 * scale),
        padding: EdgeInsets.all(12 * scale),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.translate("Recent Searches", "Baaritaanadii ugu dambeeyay"),
                  style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: AppColors.grey),
                ),
                GestureDetector(
                  onTap: () => state.clearSearchHistory('sadaqah'),
                  child: Text(
                    state.translate("Clear All", "Tirtir dhamaan"),
                    style: TextStyle(fontSize: 12 * scale, color: AppColors.accentTeal, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Wrap(
              spacing: 8 * scale,
              runSpacing: 8 * scale,
              children: state.sadaqahSearchHistory.map((query) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchQuery = query;
                      _searchController.text = query;
                      _searchFocusNode.unfocus();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20 * scale),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 14 * scale, color: AppColors.grey),
                        SizedBox(width: 6 * scale),
                        Text(query, style: TextStyle(fontSize: 13 * scale, color: AppColors.grey)),
                        SizedBox(width: 4 * scale),
                        GestureDetector(
                          onTap: () => state.removeFromSearchHistory(query, 'sadaqah'),
                          child: Icon(Icons.close_rounded, size: 14 * scale, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<String> categories) {
    return SizedBox(
      height: 40 * context.fontSizeFactor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentTeal : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                  border: Border.all(color: isSelected ? AppColors.accentTeal : AppColors.grey.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14 * context.fontSizeFactor,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildZakatCalculator(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20 * context.fontSizeFactor),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
        boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.zakatCalculator, style: TextStyle(color: Colors.white, fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                SizedBox(height: 8 * context.fontSizeFactor),
                Text(l10n.calculateZakatEasily, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14 * context.fontSizeFactor)),
              ],
            ),
          ),
          SizedBox(
            width: 120 * context.fontSizeFactor,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ZakatCalculatorScreen()),
                );
              },
              style: context.elevatedButtonStyle(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                height: 44,
                borderRadius: 12,
              ),
              child: Text(l10n.calculateNow, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZakatEducationBanner(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme) {
    return FadeInRight(
      child: Container(
        padding: EdgeInsets.all(20 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
          border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentTeal.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu_book_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                ),
                SizedBox(width: 12 * context.fontSizeFactor),
                Text(
                  state.translate("Zakat Knowledge", "Aqoon Seko"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
                ),
              ],
            ),
            SizedBox(height: 12 * context.fontSizeFactor),
            Text(
              state.translate(
                "Learn about Zakat requirements, who is eligible, and the Quranic evidence.",
                "Baro shuruudaha sekada, dadka ay ku waajibtay, iyo daliilada Quraanka."
              ),
              style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, height: 1.4),
            ),
            SizedBox(height: 16 * context.fontSizeFactor),
            TextButton(
              onPressed: () => _showZakatGuide(context, state),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.translate("Read Zakat Guide", "Akhriso Hagaha Sekada"),
                    style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.accentTeal, size: 16 * context.fontSizeFactor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showZakatGuide(BuildContext context, AppState state) {
    final scale = context.fontSizeFactor;
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
                      style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
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
                        _buildCategoryInfo("1", state.translate("The Poor (Al-Fuqara)", "Fuqarada"), state.translate("Those who have no property or income.", "Dadka aan haysan wax hanti ah ama dakhli."), scale),
                        _buildCategoryInfo("2", state.translate("The Needy (Al-Masakin)", "Miskiiniinta"), state.translate("Those whose property or income is not enough for their basic needs.", "Dadka haysta wax yar laakiin aan ku filnayn baahidooda."), scale),
                        _buildCategoryInfo("3", state.translate("Zakat Administrators", "Shaqaalaha Sekada"), state.translate("Those who collect and distribute Zakat.", "Dadka u xilsaaran ururinta iyo qaybinta sekada."), scale),
                        _buildCategoryInfo("4", state.translate("New Muslims", "Kuwa Quluubtooda la soo jiidanayo"), state.translate("To strengthen their hearts in Islam.", "Dadka cusub ee Islaamka soo galay si loo taageero."), scale),
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
              "Zakat is mandatory for every sane, adult Muslim who owns wealth above the Nisab threshold for a full lunar year.",
              "Sekadu waxay ku waajibtay qof kasta oo Muslim ah, qaangaar ah, miyir qaba, oo haysta hanti gaaraysa Nisaabka muddo sannad ah."
            ),
            style: TextStyle(fontSize: 13 * scale, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceSection(String title, String arabic, String reference, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * scale, color: AppColors.grey)),
        SizedBox(height: 8 * scale),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Text(
                arabic,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.6, color: AppColors.primaryDark),
              ),
              SizedBox(height: 8 * scale),
              Text(reference, style: TextStyle(fontSize: 11 * scale, fontStyle: FontStyle.italic, color: AppColors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryInfo(String number, String title, String description, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle),
            child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * scale)),
                Text(description, style: TextStyle(fontSize: 12 * scale, color: AppColors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }

  Widget _buildCampaignCard(BuildContext context, Campaign campaign, AppLocalizations l10n, ThemeData theme, bool isDark, AppState state) {

    double progress = campaign.raisedAmount / campaign.goalAmount;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CampaignDetailScreen(
              campaign: campaign,
              autoOpenDonate: false,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24 * context.fontSizeFactor)),
              child: Stack(
                children: [
                  FadeInImage.assetNetwork(
                    placeholder: 'assets/images/logo.png', // Generic placeholder
                    image: campaign.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: AppColors.grey.withValues(alpha: 0.1),
                      child: Icon(Icons.image_not_supported_rounded, color: AppColors.grey, size: 40),
                    ),
                  ),
                  if (campaign.isUrgent)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.priority_high_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              state.translate("URGENT", "DEG-DEG"),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          campaign.category,
                          style: TextStyle(color: AppColors.accentTeal, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (campaign.endDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.orange, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                "${campaign.daysLeft}d left",
                                style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      _buildPartners(context, campaign.partnerLogos),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    campaign.title,
                    style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaign.creator,
                    style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.grey.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(progress > 0.8 ? Colors.orange : AppColors.accentTeal),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CampaignDetailScreen(
                                  campaign: campaign,
                                  autoOpenDonate: false,
                                ),
                              ),
                            ).then((_) {
                              if (_searchQuery.isNotEmpty) {
                                state.addToSearchHistory(_searchQuery, 'sadaqah');
                              }
                            });
                          },
                          style: context.elevatedButtonStyle(
                            backgroundColor: AppColors.accentTeal,
                            foregroundColor: Colors.white,
                            height: 40,
                            borderRadius: 12,
                            elevation: 0,
                          ).copyWith(
                            minimumSize: WidgetStateProperty.all(Size(0, 40 * context.fontSizeFactor)),
                          ),
                          child: Text(l10n.donateNow, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor), overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCompactCurrency(campaign.raisedAmount),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: progress > 0.8 ? Colors.orange : AppColors.accentTeal),
                          ),
                          Text("${(progress * 100).toInt()}%", style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildPartners(BuildContext context, List<String> partners) {
    if (partners.isEmpty) return const SizedBox.shrink();
    return Row(
      children: partners.take(3).map((partner) {
        return Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4 * context.fontSizeFactor),
          ),
          child: Text(
            partner.split('/').last.split('.').first.toUpperCase(),
            style: TextStyle(fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.grey),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction(BuildContext context, AppState state, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(24 * context.fontSizeFactor, 16 * context.fontSizeFactor, 24 * context.fontSizeFactor, (16 + MediaQuery.of(context).padding.bottom) * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30 * context.fontSizeFactor)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, -5 * context.fontSizeFactor))],
      ),
      child: Center(
        child: MaxWidthBox(
          maxWidth: 500,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateCampaignScreen()),
              );
            },
            style: context.elevatedButtonStyle(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              height: 60,
              borderRadius: 20,
              elevation: 8,
            ),
            child: Text(state.translate("Start Sadaqah", "Bilow Sadaqada"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scale = context.fontSizeFactor;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: 24 * scale),
        height: 350 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * scale),
        ),
      ),
    );
  }
}
