import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/widgets/pin_entry_dialog.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/shimmer_loading.dart';
import 'models/campaign.dart';

class CampaignDetailScreen extends StatefulWidget {
  final Campaign campaign;
  final bool autoOpenDonate;
  const CampaignDetailScreen({super.key, required this.campaign, this.autoOpenDonate = false});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  bool _isLoading = true;
  late ScrollController _scrollController;
  bool _showStickyButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadData();
    if (widget.autoOpenDonate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        final state = Provider.of<AppState>(context, listen: false);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        _showDonateDialog(context, state, l10n, theme, isDark);
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showStickyButton) {
        setState(() {
          _showStickyButton = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showStickyButton) {
        setState(() {
          _showStickyButton = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Simulate network delay for shimmer effect
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildShimmerLoading(BuildContext context, ThemeData theme, bool isDark) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ShimmerLoading(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerPlaceholder(width: double.infinity, height: 250, borderRadius: 0),
              Padding(
                padding: EdgeInsets.all(24 * context.fontSizeFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerPlaceholder(width: 120, height: 24, borderRadius: 12),
                    const SizedBox(height: 16),
                    const ShimmerPlaceholder(width: double.infinity, height: 32, borderRadius: 8),
                    const SizedBox(height: 8),
                    const ShimmerPlaceholder(width: 150, height: 16, borderRadius: 4),
                    const SizedBox(height: 32),
                    const ShimmerPlaceholder(width: double.infinity, height: 150, borderRadius: 24),
                    const SizedBox(height: 32),
                    const ShimmerPlaceholder(width: 80, height: 24, borderRadius: 4),
                    const SizedBox(height: 16),
                    const ShimmerPlaceholder(width: double.infinity, height: 20, borderRadius: 4),
                    const SizedBox(height: 8),
                    const ShimmerPlaceholder(width: double.infinity, height: 20, borderRadius: 4),
                    const SizedBox(height: 8),
                    const ShimmerPlaceholder(width: 200, height: 20, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    double progress = widget.campaign.raisedAmount / widget.campaign.goalAmount;
    
    if (_isLoading) {
      return _buildShimmerLoading(context, theme, isDark);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: RepaintBoundary(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FadeInImage.assetNetwork(
                      placeholder: 'assets/images/logo.png',
                      image: widget.campaign.imageUrl,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) => Container(color: AppColors.primaryDark),
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
                          child: widget.campaign.isVerified ? Container(
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
                          ) : const SizedBox.shrink(),
                        ),
                        SizedBox(height: 16 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.campaign.title, 
                                  style: TextStyle(
                                    fontSize: 26 * context.fontSizeFactor, 
                                    fontWeight: FontWeight.w800, 
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                    color: theme.textTheme.titleLarge?.color
                                  )
                                ),
                              ),
                              if (widget.campaign.endDate != null)
                                Padding(
                                  padding: EdgeInsets.only(left: 12 * context.fontSizeFactor, top: 4 * context.fontSizeFactor),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10 * context.fontSizeFactor, vertical: 5 * context.fontSizeFactor),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8 * context.fontSizeFactor),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.timer_outlined, color: Colors.orange, size: 14 * context.fontSizeFactor),
                                        SizedBox(width: 4 * context.fontSizeFactor),
                                        Text(
                                          "${widget.campaign.daysLeft}d left",
                                          style: TextStyle(color: Colors.orange, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 16 * context.fontSizeFactor, color: theme.textTheme.bodySmall?.color ?? AppColors.grey),
                              SizedBox(width: 6 * context.fontSizeFactor),
                              Text(
                                widget.campaign.creator, 
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color, 
                                  fontSize: 14 * context.fontSizeFactor,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              Text(
                                " ${l10n.organizedBy.toLowerCase()}", 
                                style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color ?? AppColors.grey, 
                                  fontSize: 14 * context.fontSizeFactor
                                )
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: RepaintBoundary(child: _buildProgressCard(state, l10n, progress, theme, isDark)),
                        ),
                        SizedBox(height: 24 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 310),
                          child: ElevatedButton(
                            onPressed: () => _showDonateDialog(context, state, l10n, theme, isDark),
                            style: context.elevatedButtonStyle(
                              backgroundColor: AppColors.accentTeal,
                              foregroundColor: Colors.white,
                              height: 54,
                              borderRadius: 16,
                            ),
                            child: Text(l10n.donateNow, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                          ),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 350),
                          child: _buildOrganizerSection(context, state, l10n),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 360),
                          child: _buildTrustSection(context, state, l10n),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        if (widget.campaign.galleryUrls.isNotEmpty) ...[
                          FadeInUp(
                            delay: const Duration(milliseconds: 380),
                            child: _buildGallery(context),
                          ),
                          SizedBox(height: 32 * context.fontSizeFactor),
                        ],
                        if (widget.campaign.category == "Zakat / Agoomo") ...[
                          FadeInUp(
                            delay: const Duration(milliseconds: 390),
                            child: _buildZakatGuide(context, l10n),
                          ),
                          SizedBox(height: 32 * context.fontSizeFactor),
                        ],
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Text(
                            l10n.about, 
                            style: TextStyle(
                              fontSize: 20 * context.fontSizeFactor, 
                              fontWeight: FontWeight.w800, 
                              letterSpacing: -0.3,
                              color: theme.textTheme.titleMedium?.color
                            )
                          ),
                        ),
                        SizedBox(height: 16 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            widget.campaign.description,
                            style: TextStyle(
                              fontSize: 16 * context.fontSizeFactor, 
                              height: 1.7, 
                              color: theme.textTheme.bodyMedium?.color ?? AppColors.textPrimary,
                              letterSpacing: 0.1
                            ),
                          ),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        Divider(color: theme.dividerColor.withValues(alpha: 0.1)),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: _buildUpdatesTimeline(context, state, l10n),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        FadeInUp(
                          delay: const Duration(milliseconds: 700),
                          child: _buildDonorsList(context, state, l10n),
                        ),
                        if (widget.campaign.isVerified) ...[
                          SizedBox(height: 32 * context.fontSizeFactor),
                          FadeInUp(
                            delay: const Duration(milliseconds: 800),
                            child: _buildSecurityVerification(context, l10n),
                          ),
                        ],
                        SizedBox(height: 40 * context.fontSizeFactor),
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

  Widget _buildStickyDonateAction(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme, bool isDark) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: _showStickyButton ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showStickyButton ? 1.0 : 0.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            context.horizontalPadding,
            16 * context.fontSizeFactor,
            context.horizontalPadding,
            (16 + MediaQuery.of(context).padding.bottom) * context.fontSizeFactor,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 20 * context.fontSizeFactor,
                offset: Offset(0, -5 * context.fontSizeFactor),
              )
            ],
            borderRadius: BorderRadius.vertical(top: Radius.circular(24 * context.fontSizeFactor)),
          ),
          child: MaxWidthBox(
            maxWidth: 800,
            child: ElevatedButton(
              onPressed: () => _showDonateDialog(context, state, l10n, theme, isDark),
              style: context.elevatedButtonStyle(
                backgroundColor: AppColors.accentTeal,
                foregroundColor: Colors.white,
                height: 56,
                borderRadius: 16,
              ),
              child: Text(
                l10n.donateNow,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityVerification(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * context.fontSizeFactor),
            decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle),
            child: Icon(Icons.verified_user_rounded, color: Colors.white, size: 20 * context.fontSizeFactor),
          ),
          SizedBox(width: 16 * context.fontSizeFactor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.secureProtected, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                Text(l10n.secureProtectedDesc, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(AppState state, AppLocalizations l10n, double progress, ThemeData theme, bool isDark) {
    final milestoneText = widget.campaign.milestoneText;

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        "\$${widget.campaign.raisedAmount.toInt()}", 
                        style: TextStyle(
                          fontSize: 32 * context.fontSizeFactor, 
                          fontWeight: FontWeight.w800, 
                          color: theme.colorScheme.primary, 
                          letterSpacing: -1
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8 * context.fontSizeFactor),
                    Text(l10n.fundraiserRaisedOf, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (milestoneText.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 8 * context.fontSizeFactor),
                  child: Container(
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

  Widget _buildOrganizerSection(BuildContext context, AppState state, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2 * context.fontSizeFactor),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentTeal, width: 2),
            ),
            child: CircleAvatar(
              radius: 26 * context.fontSizeFactor,
              backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
              child: Icon(Icons.person_rounded, color: AppColors.accentTeal, size: 30 * context.fontSizeFactor),
            ),
          ),
          SizedBox(width: 16 * context.fontSizeFactor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.campaign.organizerTitle ?? l10n.verifiedOrganizer,
                  style: TextStyle(color: AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4 * context.fontSizeFactor),
                Text(
                  widget.campaign.organizerSubtitle ?? widget.campaign.creator,
                  style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2 * context.fontSizeFactor),
                Text(
                  l10n.secureProtectedDesc,
                  style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(BuildContext context) {
    if (widget.campaign.galleryUrls.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.gallery,
          style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16 * context.fontSizeFactor),
        SizedBox(
          height: 180 * context.fontSizeFactor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.campaign.galleryUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 16 * context.fontSizeFactor),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/logo.png',
                    image: widget.campaign.galleryUrls[index],
                    width: 280 * context.fontSizeFactor,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) => Container(
                      width: 280 * context.fontSizeFactor,
                      color: AppColors.grey.withValues(alpha: 0.1),
                      child: Icon(Icons.image_not_supported_rounded, color: AppColors.grey, size: 40 * context.fontSizeFactor),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildZakatGuide(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(24 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: AppColors.accentTeal, size: 22 * context.fontSizeFactor),
              SizedBox(width: 12 * context.fontSizeFactor),
              Expanded(
                child: Text(
                  l10n.eightCategoriesOfZakat,
                  style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.accentTeal),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * context.fontSizeFactor),
          _buildZakatCategoryItem(l10n.fuqaraTitle, l10n.fuqaraDesc),
          _buildZakatCategoryItem(l10n.masakinTitle, l10n.masakinDesc),
          _buildZakatCategoryItem(l10n.amilinaTitle, l10n.amilinaDesc),
          _buildZakatCategoryItem(l10n.muallafatiTitle, l10n.muallafatiDesc),
          _buildZakatCategoryItem(l10n.riqabTitle, l10n.riqabDesc),
          _buildZakatCategoryItem(l10n.ghariminTitle, l10n.ghariminDesc),
          _buildZakatCategoryItem(l10n.fisabilillahTitle, l10n.fisabilillahDesc),
          _buildZakatCategoryItem(l10n.ibnusSabilTitle, l10n.ibnusSabilDesc),
          SizedBox(height: 16 * context.fontSizeFactor),
          Container(
            padding: EdgeInsets.all(16 * context.fontSizeFactor),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: theme.brightness == Brightness.dark ? 0.05 : 0.5),
              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.evidenceFromQuran, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
                SizedBox(height: 8 * context.fontSizeFactor),
                Text(
                  "\"Innama as-sadaqatu lil fuqara'i wal masakeeni wal 'amilina 'alayha...\" (9:60)",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12 * context.fontSizeFactor, color: AppColors.grey),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZakatCategoryItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor), softWrap: true),
                SizedBox(height: 2 * context.fontSizeFactor),
                Text(desc, style: TextStyle(fontSize: 12 * context.fontSizeFactor, color: AppColors.grey, height: 1.4), softWrap: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context, AppState state, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor))),
      builder: (context) => MaxWidthBox(
        maxWidth: 600,
        child: Container(
          padding: EdgeInsets.all(24 * context.fontSizeFactor),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.shareThisCampaign, style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                SizedBox(height: 24 * context.fontSizeFactor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShareOption(context, Icons.message_rounded, "WhatsApp", Colors.green, () {
                      Share.share("${l10n.supportCampaign}: ${widget.campaign.title}\nhttps://murtaaxpay.app/donate/${widget.campaign.id}");
                    }),
                    _buildShareOption(context, Icons.facebook_rounded, l10n.facebook, Colors.blue, () {
                      Share.share("${l10n.supportCampaign}: ${widget.campaign.title}\nhttps://murtaaxpay.app/donate/${widget.campaign.id}");
                    }),
                    _buildShareOption(context, Icons.link_rounded, l10n.link, AppColors.primaryDark, () {
                      Clipboard.setData(ClipboardData(text: "https://murtaaxpay.app/donate/${widget.campaign.id}"));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
                      Navigator.pop(context);
                    }),
                  ],
                ),
                SizedBox(height: 24 * context.fontSizeFactor),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: "https://murtaaxpay.app/donate/${widget.campaign.id}"));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                  child: Container(
                    padding: EdgeInsets.all(16 * context.fontSizeFactor),
                    decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                    child: Row(
                      children: [
                        Expanded(child: Text("https://murtaaxpay.app/donate/${widget.campaign.id}", style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor), overflow: TextOverflow.ellipsis)),
                        SizedBox(width: 8 * context.fontSizeFactor),
                        Icon(Icons.copy_rounded, color: AppColors.primaryDark, size: 20 * context.fontSizeFactor),
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

  Widget _buildShareOption(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
      child: Padding(
        padding: EdgeInsets.all(8 * context.fontSizeFactor),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16 * context.fontSizeFactor),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30 * context.fontSizeFactor),
            ),
            SizedBox(height: 8 * context.fontSizeFactor),
            Text(label, style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
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
                  radius: 20 * context.fontSizeFactor,
                  backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                  child: (donor.isAnonymous || donor.avatarUrl == null)
                    ? Text(
                        donor.isAnonymous ? "?" : donor.name.substring(0, 1), 
                        style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                      )
                    : ClipOval(
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/logo.png',
                          image: donor.avatarUrl!,
                          fit: BoxFit.cover,
                          width: 40 * context.fontSizeFactor,
                          height: 40 * context.fontSizeFactor,
                          imageErrorBuilder: (context, error, stackTrace) => Text(
                            donor.name.substring(0, 1), 
                            style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                          ),
                        ),
                      ),
                ),
                SizedBox(width: 16 * context.fontSizeFactor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor.isAnonymous ? l10n.anonymous : donor.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (donor.message != null && donor.message!.isNotEmpty) ...[
                        SizedBox(height: 4 * context.fontSizeFactor),
                        Container(
                          width: double.infinity,
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
                Padding(
                  padding: EdgeInsets.only(left: 8 * context.fontSizeFactor),
                  child: Text(
                    NumberFormat.simpleCurrency(name: "USD", decimalDigits: 0).format(donor.amount), 
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal, fontSize: 14 * context.fontSizeFactor)
                  ),
                ),
              ],
            ),
          )),
        if (widget.campaign.recentDonors.length > 5)
          Padding(
            padding: EdgeInsets.only(top: 8 * context.fontSizeFactor),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: context.outlinedButtonStyle(
                  foregroundColor: AppColors.accentTeal,
                  borderRadius: 12,
                  height: 48,
                ),
                child: Text(l10n.viewAll),
              ),
            ),
          ),
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
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/logo.png',
                              image: update.imageUrl!,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: AppColors.grey.withValues(alpha: 0.1),
                                child: const Icon(Icons.broken_image_rounded, color: AppColors.grey),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showDonateDialog(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme, bool isDark) {
    double amount = 50.0;
    // Categories: "Wallet", "Card", "Mobile"
    String selectedCategory = "Wallet"; 
    String? selectedCardId = state.cards.isNotEmpty ? state.cards[0].id : null;
    String selectedMobileProvider = "EVC Plus";
    
    bool isAnonymous = false;
    bool isRecurring = false;
    
    final TextEditingController amountController = TextEditingController(text: "50");
    final TextEditingController messageController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    final isZakat = widget.campaign.category == "Zakat / Agoomo";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          
          String getEffectiveMethod() {
            if (selectedCategory == "Wallet") return "Main Wallet";
            if (selectedCategory == "Card") return "Debit Card";
            return selectedMobileProvider;
          }

          double currentFee = state.calculateFeeForSource(amount, getEffectiveMethod(), cardId: selectedCardId);

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                l10n.fundraiserDonateTo,
                                style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 4 * context.fontSizeFactor),
                              Text(
                                widget.campaign.title,
                                style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                          
                          if (isZakat) ...[
                            SizedBox(height: 16 * context.fontSizeFactor),
                            Container(
                              padding: EdgeInsets.all(12 * context.fontSizeFactor),
                              decoration: BoxDecoration(
                                color: AppColors.accentTeal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_awesome_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                                  SizedBox(width: 12 * context.fontSizeFactor),
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
                          
                          // Amount Selection
                          Text(state.translate("Choose amount", "Dooro cadadka"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                          SizedBox(height: 12 * context.fontSizeFactor),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: context.responsiveValue(mobile: 3, tablet: 4, desktop: 6),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2.2,
                            children: [10, 20, 50, 100, 250, 500].map((val) {
                              final isSel = amount == val.toDouble();
                              return GestureDetector(
                                onTap: () => setModalState(() {
                                  amount = val.toDouble();
                                  amountController.text = val.toString();
                                }),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.accentTeal : theme.cardColor,
                                    borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                                    border: Border.all(color: isSel ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1)),
                                    boxShadow: isSel ? [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                                  ),
                                  child: Text("\$$val", style: TextStyle(color: isSel ? Colors.white : theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor)),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          TextField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (val) => setModalState(() => amount = double.tryParse(val) ?? 0),
                            style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              prefixText: r"$ ",
                              hintText: l10n.customAmount,
                              filled: true,
                              fillColor: theme.dividerColor.withValues(alpha: 0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16 * context.fontSizeFactor),
                            ),
                          ),

                          SizedBox(height: 32 * context.fontSizeFactor),

                          // Payment Method Selection
                          Text(state.translate("Payment Method", "Habka Lacag-bixinta"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          
                          // Category Selector
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildCategoryTab(context, "Wallet", Icons.account_balance_wallet_rounded, l10n.wallet, selectedCategory == "Wallet", (c) => setModalState(() => selectedCategory = c)),
                                SizedBox(width: 12 * context.fontSizeFactor),
                                _buildCategoryTab(context, "Card", Icons.credit_card_rounded, state.translate("Card", "Kaadhka"), selectedCategory == "Card", (c) => setModalState(() => selectedCategory = c)),
                                SizedBox(width: 12 * context.fontSizeFactor),
                                _buildCategoryTab(context, "Mobile", Icons.phone_android_rounded, state.translate("Mobile", "Mobile"), selectedCategory == "Mobile", (c) => setModalState(() => selectedCategory = c)),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 16 * context.fontSizeFactor),

                          // Detailed Selection based on category
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildSubMethodSelector(
                              context, 
                              state, 
                              selectedCategory, 
                              selectedCardId, 
                              selectedMobileProvider,
                              (id) => setModalState(() => selectedCardId = id),
                              (prov) => setModalState(() => selectedMobileProvider = prov),
                            ),
                          ),

                          if (selectedCategory == "Mobile") ...[
                            SizedBox(height: 16 * context.fontSizeFactor),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: l10n.enterPhoneNumber,
                                prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.accentTeal, size: 20),
                                filled: true,
                                fillColor: theme.dividerColor.withValues(alpha: 0.05),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                              ),
                            ),
                          ],

                          SizedBox(height: 24 * context.fontSizeFactor),

                          // Options
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                _buildOptionToggle(
                                  l10n.makeRecurringDonation,
                                  state.translate("Donate automatically every month", "Bixi si otomaatig ah bil walba"),
                                  isRecurring,
                                  (val) => setModalState(() => isRecurring = val)
                                ),
                                _buildOptionToggle(
                                  l10n.anonymous,
                                  state.translate("Hide your name from public list", "Magacaaga ka qari liiska"),
                                  isAnonymous,
                                  (val) => setModalState(() => isAnonymous = val)
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16 * context.fontSizeFactor),
                          TextField(
                            controller: messageController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: state.translate("Leave a message (optional)", "Farriin ka tag (waa ikhtiyaari)"),
                              filled: true,
                              fillColor: theme.dividerColor.withValues(alpha: 0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
                            ),
                          ),

                          SizedBox(height: 24 * context.fontSizeFactor),

                          // Summary
                          Container(
                            padding: EdgeInsets.all(20 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                              border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.amount, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                                    Text(NumberFormat.simpleCurrency(name: "USD").format(amount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor)),
                                  ],
                                ),
                                SizedBox(height: 8 * context.fontSizeFactor),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.fee, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                                    Text("+${NumberFormat.simpleCurrency(name: "USD").format(currentFee)}", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor)),
                                  ],
                                ),
                                Divider(height: 24 * context.fontSizeFactor, color: AppColors.accentTeal.withValues(alpha: 0.1)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.total, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                                    Text(
                                      NumberFormat.simpleCurrency(name: "USD").format(amount + currentFee),
                                      style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 22 * context.fontSizeFactor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24 * context.fontSizeFactor),

                          ElevatedButton(
                            onPressed: () {
                              if (amount <= 0) return;
                              if (selectedCategory == "Mobile" && phoneController.text.length < 9) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.phoneLengthError)));
                                return;
                              }
                              
                              if (selectedCategory != "Mobile") {
                                String sourceKey = getEffectiveMethod();
                                if (!state.hasSufficientBalanceForSource(amount, sourceKey, cardId: selectedCardId)) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red));
                                  return;
                                }
                              }
                              
                              showDialog(
                                context: context,
                                builder: (context) => PinEntryDialog(
                                  title: l10n.securityVerification,
                                  description: selectedCategory == "Mobile" 
                                    ? state.translate("Enter your Mobile Money PIN", "Geli PIN-ka Mobile-kaaga")
                                    : selectedCategory == "Card" ? state.translate("Enter Card PIN", "Geli PIN-ka Kaadhka") : l10n.enterTransactionPin,
                                  isCardPin: selectedCategory == "Card",
                                  cardId: selectedCardId,
                                  onValidate: (pin) async {
                                    if (pin == "BIOMETRIC_SUCCESS") return true;
                                    if (selectedCategory == "Card") {
                                      return state.verifyCardPin(pin, cardId: selectedCardId);
                                    }
                                    return state.verifyPin(pin);
                                  },
                                  onConfirm: (pin) {
                                    _processDonation(context, state, l10n, amount, pin, getEffectiveMethod(), selectedCardId, isAnonymous: isAnonymous, message: messageController.text, isRecurring: isRecurring);
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentTeal,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(l10n.donateNow, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab(BuildContext context, String id, IconData icon, String label, bool isSelected, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(id),
      child: Container(
        width: 110 * context.fontSizeFactor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentTeal : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.accentTeal : Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.grey, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMethodSelector(
    BuildContext context, 
    AppState state, 
    String category, 
    String? selectedCardId, 
    String selectedMobileProvider,
    Function(String) onCardSelect,
    Function(String) onMobileSelect
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (category == "Wallet") {
      return _buildSelectionItem(
        context, 
        l10n: l10n, 
        title: "Murtaax Wallet", 
        subtitle: "${NumberFormat.simpleCurrency(name: "USD").format(state.balance)} Available", 
        icon: Icons.account_balance_wallet_rounded, 
        isSelected: true,
        trailing: const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal),
      );
    }
    
    if (category == "Card") {
      if (state.cards.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Text(state.translate("No virtual cards found", "Ma jiraan kaadhka virtual-ka ah"), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        );
      }
      return Column(
        children: state.cards.map((card) {
          final isSel = selectedCardId == card.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSelectionItem(
              context, 
              l10n: l10n, 
              title: card.cardHolder, 
              subtitle: "**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}", 
              icon: Icons.credit_card_rounded, 
              isSelected: isSel,
              onTap: () => onCardSelect(card.id),
              trailing: isSel ? const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal) : null,
            ),
          );
        }).toList(),
      );
    }
    
    // Mobile Money
    final providers = ["EVC Plus", "Sahal", "ZAAD Service", "E-Dahab"];
    return Column(
      children: providers.map((prov) {
        final isSel = selectedMobileProvider == prov;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildSelectionItem(
            context, 
            l10n: l10n, 
            title: prov, 
            subtitle: "Mobile Payment", 
            icon: Icons.phone_android_rounded, 
            isSelected: isSel,
            onTap: () => onMobileSelect(prov),
            trailing: isSel ? const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal) : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectionItem(BuildContext context, {required AppLocalizations l10n, required String title, required String subtitle, required IconData icon, bool isSelected = false, VoidCallback? onTap, Widget? trailing}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: (isSelected ? AppColors.accentTeal : AppColors.grey).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: isSelected ? AppColors.accentTeal : AppColors.grey, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                  Text(subtitle, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      activeThumbColor: AppColors.accentTeal,
      contentPadding: EdgeInsets.zero,
    );
  }


  void _processDonation(BuildContext context, AppState state, AppLocalizations l10n, double amount, String pin, String method, String? cardId, {bool isAnonymous = false, String? message, bool isRecurring = false}) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidAmount)));
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
        'title': "Fundraiser: ${widget.campaign.title}",
        'amount': "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(amount)}",
        'date': DateFormat('MMM dd, yyyy').format(DateTime.now()),
        'status': 'Success',
        'type': 'transfer_out',
        'method': method.startsWith("card_") ? 'Card' : method,
        'isNegative': true,
        'id': 'TX-FUND-${DateTime.now().millisecondsSinceEpoch}',
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
            subtitle: isRecurring ? l10n.makeRecurringDonation : null,
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
