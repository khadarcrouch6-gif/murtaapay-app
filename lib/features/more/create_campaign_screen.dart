import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          state.translate("Start Fundraiser", "Bilow Ururinta Sadaqo", ar: "بدء حملة تبرع", de: "Fundraiser starten"),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            state.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                            state.translate("Create a Campaign", "Samee Ololaha", ar: "إنشاء حملة", de: "Kampagne erstellen"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.translate("Raise funds for a cause you care about. We'll verify your campaign to build trust.", "Lacag u soo ururi sabab aad danayso. Waxaan xaqiijin doonaa ololahaaga si loo dhiso kalsoonida.", ar: "اجمع الأموال لقضية تهمك. سنقوم بالتحقق من حملتك لبناء الثقة.", de: "Sammeln Sie Spenden für einen Zweck, der Ihnen am Herzen liegt. Wir verifizieren Ihre Kampagne, um Vertrauen aufzubauen."),
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color ?? AppColors.textPrimary,
                              fontSize: 13,
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
                state.translate("Campaign Details", "Faahfaahinta Ololaha", ar: "تفاصيل الحملة", de: "Kampagnendetails"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildTextField(
                state.translate("Campaign Title", "Cinwaanka Ololaha", ar: "عنوان الحملة", de: "Kampagnentitel"),
                state.translate("E.g. Help build a water well in Gedo", "Tusaale: Caawi dhisidda ceel biyood Gedo", ar: "مثال: ساعد في بناء بئر مياه في جيدو", de: "Z. B. Hilfe beim Bau eines Wasserbrunnens in Gedo"),
                Icons.title_rounded,
                theme,
                isDark,
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildTextField(
                state.translate("Goal Amount (USD)", "Cadadka Hadafka (USD)", ar: "المبلغ المستهدف (USD)", de: "Zielbetrag (USD)"),
                "E.g. 5000",
                Icons.attach_money_rounded,
                theme,
                isDark,
                isNumber: true,
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildTextField(
                state.translate("Description", "Sharaxaadda", ar: "الوصف", de: "Beschreibung"),
                state.translate("Describe why you need help and how the funds will be used...", "Sharax sababta aad caawimo ugu baahan tahay iyo sida lacagta loo isticmaali doono...", ar: "صف لماذا تحتاج إلى المساعدة وكيف سيتم استخدام الأموال...", de: "Beschreiben Sie, warum Sie Hilfe benötigen und wie die Gelder verwendet werden..."),
                Icons.description_rounded,
                theme,
                isDark,
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Text(
                state.translate("Cover Photo", "Sawirka Daboolka", ar: "صورة الغلاف", de: "Titelbild"),
                style: TextStyle(
                  fontSize: 16,
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
                      state.translate("Tap to upload photo", "Taabo si aad sawir u soo geliso", ar: "انقر لتحميل الصورة", de: "Tippen, um ein Foto hochzuladen"),
                      style: TextStyle(
                        color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.translate("JPG, PNG up to 5MB", "JPG, PNG ilaa 5MB", ar: "JPG، PNG حتى 5 ميغابايت", de: "JPG, PNG bis zu 5 MB"),
                      style: TextStyle(color: theme.textTheme.bodySmall?.color ?? AppColors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate("Campaign submitted for review!", "Ololaha waa loo gudbiyay dib u eegis!", ar: "تم تقديم الحملة للمراجعة!", de: "Kampagne zur Überprüfung eingereicht!"))));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? theme.colorScheme.primary : AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    state.translate("Submit for Review", "Gudbi si dib loogu eego", ar: "تقديم للمراجعة", de: "Zur Überprüfung einreichen"),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, ThemeData theme, bool isDark, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
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
