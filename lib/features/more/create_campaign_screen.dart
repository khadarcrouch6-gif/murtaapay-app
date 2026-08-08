import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
import 'models/campaign.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _titleController = TextEditingController();
  final _goalController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = "General";
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitCampaign(AppState state, AppLocalizations l10n) {
    if (_titleController.text.isEmpty || _goalController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Mock campaign creation
    final newCampaign = Campaign(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      goalAmount: double.tryParse(_goalController.text) ?? 0.0,
      raisedAmount: 0.0,
      creator: state.userName,
      icon: Icons.volunteer_activism_rounded,
      imageUrl: "https://images.unsplash.com/photo-1532629345422-7515f3d16bb8?q=80&w=2070",
      category: _selectedCategory,
      donorCount: 0,
      lastDonationAgo: "Just now",
      status: 'new',
    );

    state.addCampaign(newCampaign);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.campaignSubmitted)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.startFundraiser,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark,
            fontSize: 18 * context.fontSizeFactor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.volunteer_activism_rounded, color: AppColors.accentTeal, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.createCampaign,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 * context.fontSizeFactor,
                                  color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.createCampaignDesc,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color ?? AppColors.textPrimary,
                                  fontSize: 13 * context.fontSizeFactor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    l10n.campaignDetails,
                    style: TextStyle(
                      fontSize: 18 * context.fontSizeFactor,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildTextField(
                    l10n.campaignTitle,
                    l10n.campaignTitleHint,
                    Icons.title_rounded,
                    theme,
                    isDark,
                    controller: _titleController,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _buildTextField(
                    l10n.goalAmountUsd,
                    l10n.goalAmountHint,
                    Icons.attach_money_rounded,
                    theme,
                    isDark,
                    isNumber: true,
                    controller: _goalController,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildTextField(
                    l10n.description,
                    l10n.descriptionHint,
                    Icons.description_rounded,
                    theme,
                    isDark,
                    maxLines: 5,
                    controller: _descriptionController,
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    l10n.coverPhoto,
                    style: TextStyle(
                      fontSize: 16 * context.fontSizeFactor,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? theme.dividerColor.withValues(alpha: 0.1) : AppColors.primaryDark.withValues(alpha: 0.1), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: (isDark ? theme.colorScheme.onSurface : AppColors.primaryDark).withValues(alpha: 0.05), shape: BoxShape.circle),
                          child: Icon(Icons.cloud_upload_rounded, size: 32, color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tapToUpload,
                          style: TextStyle(
                            color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.uploadLimits,
                          style: TextStyle(color: theme.textTheme.bodySmall?.color ?? AppColors.grey, fontSize: 12 * context.fontSizeFactor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(context.horizontalPadding, 12, context.horizontalPadding, 12 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: Center(
          child: MaxWidthBox(
            maxWidth: 800,
            child: FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitCampaign(state, l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        l10n.submitForReview,
                        style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, ThemeData theme, bool isDark, {bool isNumber = false, int maxLines = 1, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14 * context.fontSizeFactor,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
            border: isDark ? Border.all(color: theme.dividerColor.withValues(alpha: 0.1)) : null,
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color ?? AppColors.grey, fontSize: 14),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 18.0) - 18 : 0), // align top if multi-line
                child: Icon(icon, color: (isDark ? theme.colorScheme.onSurface : AppColors.primaryDark).withValues(alpha: 0.7)),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}
