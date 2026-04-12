import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
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
  List<Campaign> _getCampaigns(AppLocalizations l10n) {
    return [
      Campaign(
        id: "1",
        title: l10n.medicalEmergency,
        description: l10n.medicalEmergencyDesc,
        goalAmount: 5000,
        raisedAmount: 3250,
        creator: "Ali Abdi",
        icon: Icons.medical_services_rounded,
        imageUrl: "https://images.unsplash.com/photo-1576091160550-217359f4b84c?q=80&w=400&auto=format&fit=crop",
      ),
      Campaign(
        id: "2",
        title: l10n.villageWaterWell,
        description: l10n.villageWaterWellDesc,
        goalAmount: 2000,
        raisedAmount: 1800,
        creator: "Community Fund",
        icon: Icons.water_drop_rounded,
        imageUrl: "https://images.unsplash.com/photo-1541444085068-ad9bc89b3d6d?q=80&w=400&auto=format&fit=crop",
      ),
      Campaign(
        id: "3",
        title: l10n.educationSupport,
        description: l10n.educationSupportDesc,
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final campaigns = _getCampaigns(l10n);
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
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 12),
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: MaxWidthBox(
                        maxWidth: 800,
                        child: _buildCampaignCard(context, campaigns[index], l10n),
                      ),
                    );
                  },
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
              BoxShadow(color: theme.brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.06), blurRadius: 25, offset: const Offset(0, 10)),
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
                          height: 180 * context.fontSizeFactor, width: double.infinity,
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
      top: 16,
      left: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, color: const Color(0xFF10B981), size: 16 * context.fontSizeFactor),
            const SizedBox(width: 6),
            Text(l10n.verified, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Campaign campaign, AppLocalizations l10n, double progress) {
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
            Text("${l10n.by} ${campaign.creator}", style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
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
                Text(l10n.raised, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${(progress * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22 * context.fontSizeFactor, color: theme.colorScheme.primary)),
                const SizedBox(height: 2),
                Text("${l10n.goal}: \$${campaign.goalAmount.toInt()}", style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
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

  Widget _buildBottomAction(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, context.responsiveValue(mobile: 120, tablet: 24, desktop: 24)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, -5))],
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
