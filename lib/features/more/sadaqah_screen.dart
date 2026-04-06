import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'campaign_detail_screen.dart';
import 'create_campaign_screen.dart';

class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  final double raisedAmount;
  final String creator;
  final IconData icon;
  final String imageUrl;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
    required this.creator,
    required this.icon,
    required this.imageUrl,
  });
}

class SadaqahScreen extends StatefulWidget {
  const SadaqahScreen({super.key});

  @override
  State<SadaqahScreen> createState() => _SadaqahScreenState();
}

class _SadaqahScreenState extends State<SadaqahScreen> {
  List<Campaign> _getCampaigns(AppState state) {
    return [
      Campaign(
        id: "1",
        title: state.translate("Medical Emergency", "Xaalad Caafimaad", ar: "حالة طبية طارئة", de: "Medizinischer Notfall"),
        description: state.translate("Help Ahmed cover his heart surgery expenses in Turkey.", "Ka caawi Axmed kharashka qalliinka wadnaha ee Turkiga.", ar: "ساعد أحمد في تغطية تكاليف جراحة قلبه في تركيا.", de: "Helfen Sie Ahmed, seine Kosten für die Herzoperation in der Türkei zu decken."),
        goalAmount: 5000,
        raisedAmount: 3250,
        creator: "Ali Abdi",
        icon: Icons.medical_services_rounded,
        imageUrl: "https://images.unsplash.com/photo-1576091160550-217359f4b84c?q=80&w=400&auto=format&fit=crop",
      ),
      Campaign(
        id: "2",
        title: state.translate("Village Water Well", "Ceelka Biyaha Tuulada", ar: "بئر ماء للقرية", de: "Dorfbrunnen"),
        description: state.translate("Building a permanent water source for a village in Gedo.", "Dhisidda il biyo oo joogto ah oo loo sameeyo tuulo ku taal Gedo.", ar: "بناء مصدر مياه دائم لقرية في جيدو.", de: "Bau einer dauerhaften Wasserquelle für ein Dorf in Gedo."),
        goalAmount: 2000,
        raisedAmount: 1800,
        creator: "Community Fund",
        icon: Icons.water_drop_rounded,
        imageUrl: "https://images.unsplash.com/photo-1541444085068-ad9bc89b3d6d?q=80&w=400&auto=format&fit=crop",
      ),
      Campaign(
        id: "3",
        title: state.translate("Education Support", "Garab istaagga Waxbarashada", ar: "دعم التعليم", de: "Bildungsunterstützung"),
        description: state.translate("Scholarships for 10 orphans in Mogadishu.", "Deeq waxbarasho oo loogu talagalay 10 agoon ah oo ku nool Muqdisho.", ar: "منح دراسية لـ 10 أيتام في مقديشو.", de: "Stipendien für 10 Waisenkinder in Mogadischu."),
        goalAmount: 3000,
        raisedAmount: 450,
        creator: "Sahra Jama",
        icon: Icons.school_rounded,
        imageUrl: "https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=400&auto=format&fit=crop",
      ),
    ];
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
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 12),
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: MaxWidthBox(
                          maxWidth: 800,
                          child: _buildCampaignCard(context, campaigns[index], state),
                        ),
                      );
                    },
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
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: theme.brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, 10)),
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
                              height: 280 * context.fontSizeFactor, width: double.infinity,
                              color: theme.colorScheme.primary.withOpacity(0.05),
                              child: Icon(campaign.icon, size: 48 * context.fontSizeFactor, color: theme.colorScheme.primary.withOpacity(0.2)),
                            ),
                          ),
                          _buildVerifiedBadge(context, state),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.all(24 * context.fontSizeFactor),
                        child: _buildCardContent(context, campaign, state, progress),
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
                          height: 180 * context.fontSizeFactor, width: double.infinity,
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          child: Icon(campaign.icon, size: 48 * context.fontSizeFactor, color: theme.colorScheme.primary.withOpacity(0.2)),
                        ),
                      ),
                      _buildVerifiedBadge(context, state),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    child: _buildCardContent(context, campaign, state, progress),
                  ),
                ],
              );
            },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(campaign.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.colorScheme.primary)),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.person_outline_rounded, size: 14 * context.fontSizeFactor, color: AppColors.grey),
            const SizedBox(width: 4),
            Text("${state.translate("By", "Waxaa Bilaabay", ar: "بواسطة", de: "Von")} ${campaign.creator}", style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 16),
        Text(campaign.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, height: 1.5)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("\$${campaign.raisedAmount.toInt()}", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal, fontSize: 22 * context.fontSizeFactor)),
                const SizedBox(height: 2),
                Text(state.translate("Raised", "La Ururiyay", ar: "تم جمعها", de: "Gesammelt"), style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${(progress * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22 * context.fontSizeFactor, color: theme.colorScheme.primary)),
                const SizedBox(height: 2),
                Text("${state.translate("Goal", "Hadafka", ar: "الهدف", de: "Ziel")}: \$${campaign.goalAmount.toInt()}", style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10))),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.accentTeal, Color(0xFF10B981)]),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
