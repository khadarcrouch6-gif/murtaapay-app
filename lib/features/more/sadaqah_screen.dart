import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'campaign_detail_screen.dart';
import 'create_campaign_screen.dart';
import 'zakat_calculator_screen.dart';

class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  final double raisedAmount;
  final String creator;
  final IconData icon;
  final String imageUrl;
  final String category;
  final int donorCount;
  final String lastDonationAgo;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
    required this.creator,
    required this.icon,
    required this.imageUrl,
    required this.category,
    required this.donorCount,
    required this.lastDonationAgo,
  });
}

class SadaqahScreen extends StatefulWidget {
  const SadaqahScreen({super.key});

  @override
  State<SadaqahScreen> createState() => _SadaqahScreenState();
}

class _SadaqahScreenState extends State<SadaqahScreen> {
  String _selectedCategory = "All";
  
  List<Campaign> _getCampaigns(AppState state) {
    final allCampaigns = [
      Campaign(
        id: "1",
        category: "Medical",
        title: state.translate("Medical Emergency", "Xaalad Caafimaad", ar: "حالة طبية طارئة", de: "Medizinischer Notfall"),
        description: state.translate("Help Ahmed cover his heart surgery expenses in Turkey.", "Ka caawi Axmed kharashka qalliinka wadnaha ee Turkiga.", ar: "ساعد أحمد في تغطية تكاليف جراحة قلبه في تركيا.", de: "Helfen Sie Ahmed, seine Kosten für die Herzoperation in der Türkei zu decken."),
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
        title: state.translate("Village Water Well", "Ceelka Biyaha Tuulada", ar: "بئر ماء للقرية", de: "Dorfbrunnen"),
        description: state.translate("Building a permanent water source for a village in Gedo.", "Dhisidda il biyo oo joogto ah oo loo sameeyo tuulo ku taal Gedo.", ar: "بناء مصدر مياه دائم لقرية في جيدو.", de: "Bau einer dauerhaften Wasserquelle für ein Dorf in Gedo."),
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
        title: state.translate("Education Support", "Garab istaagga Waxbarashada", ar: "دعم التعليم", de: "Bildungsunterstützung"),
        description: state.translate("Scholarships for 10 orphans in Mogadishu.", "Deeq waxbarasho oo loogu talagalay 10 agoon ah oo ku nool Muqdisho.", ar: "منح دراسية لـ 10 أيتام في مقديشو.", de: "Stipendien für 10 Waisenkinder in Mogadischu."),
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
        title: state.translate("Food Relief", "Deeq Raashin", ar: "إغاثة غذائية", de: "Nahrungsmittelhilfe"),
        description: state.translate("Providing essential food supplies to families affected by drought.", "Bixinta sahayda cuntada ee muhiimka ah ee qoysaska ay abartu saameysay.", ar: "توفير الإمدادات الغذائية الأساسية للأسر المتضررة من الجفاف.", de: "Bereitstellung lebenswichtiger Nahrungsmittel für von der Dürre betroffene Familien."),
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

  Widget _buildHeroSection(BuildContext context, Campaign featured, AppState state) {
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
          margin: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 16),
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
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
                      colors: [AppColors.primaryDark, AppColors.primaryDark.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(child: Icon(featured.icon, size: 60, color: Colors.white.withOpacity(0.2))),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.9),
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
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.accentTeal, borderRadius: BorderRadius.circular(20)),
                      child: Text(state.translate("URGENT", " DEG-DEG", ar: "عاجل", de: "DRINGEND"), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 12),
                    Text(featured.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$${featured.raisedAmount.toInt()} ${state.translate("raised", "la ururiyay")}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("${(progress * 100).toInt()}%", style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                        minHeight: 8,
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

  Widget _buildTrustBanner(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FadeInUp(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accentTeal.withOpacity(0.15), AppColors.accentTeal.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.accentTeal.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: AppColors.accentTeal.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_rounded, color: AppColors.accentTeal, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                state.translate(
                  "100% Secure. 0% Platform Fees. 0% Withdrawal Fees.",
                  "100% Ammaan ah. 0% Khidmad ah. 0% Kala bixis ah.",
                  ar: "آمن 100٪. 0٪ رسوم المنصة. 0٪ رسوم سحب.",
                  de: "100 % sicher. 0 % Plattformgebühren. 0 % Auszahlungsgebühren.",
                ),
                style: const TextStyle(color: AppColors.accentTeal, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, AppState state) {
    final categories = ["All", "Medical", "Water", "Education", "Emergency"];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Text(state.translate(cat, _getSoCategory(cat))),
              onSelected: (val) => setState(() => _selectedCategory = cat),
              backgroundColor: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.05),
              selectedColor: AppColors.accentTeal.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              side: BorderSide(color: isSelected ? AppColors.accentTeal : Colors.transparent),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accentTeal : AppColors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: StadiumBorder(),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  String _getSoCategory(String cat) {
    switch (cat) {
      case "All": return "Dhammaan";
      case "Medical": return "Caafimaad";
      case "Water": return "Biyo";
      case "Education": return "Waxbarasho";
      case "Emergency": return "Gurmad";
      default: return cat;
    }
  }
  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    final campaigns = _getCampaigns(state);
    
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(state.translate("Sadaqah & Community", "Sadaqada & Bulshada", ar: "الصدقة والمجتمع", de: "Sadaqah & Gemeinschaft"), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 20 * context.fontSizeFactor)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(state.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: MaxWidthBox(
            maxWidth: 1000,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    children: [
                      if (campaigns.isNotEmpty) _buildHeroSection(context, campaigns.first, state),
                      _buildTrustBanner(context, state),
                      _buildCategories(context, state),
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
                                child: _buildCampaignCard(context, campaign, state),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                _buildBottomAction(context, state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, Campaign campaign, AppState state) {
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
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: theme.dividerColor.withOpacity(isDark ? 0.08 : 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: AppColors.accentTeal.withOpacity(isDark ? 0.05 : 0.01),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    campaign.imageUrl,
                    height: 220 * context.fontSizeFactor,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220 * context.fontSizeFactor,
                      width: double.infinity,
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      child: Icon(campaign.icon, size: 48 * context.fontSizeFactor, color: theme.colorScheme.primary.withOpacity(0.2)),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                      child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 18),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(24 * context.fontSizeFactor),
                child: _buildCardContent(context, campaign, state, progress),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, color: const Color(0xFF10B981), size: 16 * context.fontSizeFactor),
            const SizedBox(width: 6),
            Text(state.translate("Verified", "La Hubiyay", ar: "تم التحقق منه", de: "Verifiziert"), style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Campaign campaign, AppState state, double progress) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.accentTeal),
            const SizedBox(width: 4),
            Text(
              "${state.translate("Trending", "Hadda Socda", ar: "رائج", de: "Beliebt")} • ${campaign.lastDonationAgo} ${state.translate("ago", "ka hor", ar: "منذ", de: "vor")}",
              style: TextStyle(color: AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(campaign.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.colorScheme.primary)),
        const SizedBox(height: 8),
        Text(campaign.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, height: 1.5)),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text("\$${campaign.raisedAmount.toInt()}", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 18 * context.fontSizeFactor)),
            const SizedBox(width: 4),
            Text("${state.translate("raised of", "la ururiyay")} \$${campaign.goalAmount.toInt()}", style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: theme.dividerColor.withOpacity(0.1), height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.people_outline_rounded, size: 16, color: AppColors.grey.withOpacity(0.8)),
            const SizedBox(width: 6),
            Text(
              "${campaign.donorCount} ${state.translate("donations", "deeqoodo")}",
              style: TextStyle(color: AppColors.grey.withOpacity(0.8), fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, context.responsiveValue(mobile: 120, tablet: 24, desktop: 24)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, -5))],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withOpacity(0.3),
              ),
              child: Text(state.translate("Start a Fundraiser", "Bilow Ururinta Sadaqo", ar: "بدء حملة تبرع", de: "Fundraiser starten"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
            ),
          ),
        ),
      ),
    );
  }
}
