import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';

class PremiumUpgradeScreen extends StatelessWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: FadeInDown(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 64),
                        const SizedBox(height: 12),
                        Text(
                          state.translate("MURTAAX PREMIUM", "MURTAAX PREMIUM", ar: "مورتاكس بريميوم"),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24 * context.fontSizeFactor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(context.horizontalPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                FadeInUp(
                  child: Text(
                    state.translate(
                      "Elevate Your Experience",
                      "Kor u qaad khibradaada",
                      ar: "ارتقِ بتجربتك"
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    state.translate(
                      "Unlock exclusive features and higher limits tailored for your needs.",
                      "Fur sifooyin gaar ah iyo xad sare oo loogu talagalay baahiyahaaga.",
                      ar: "افتح الميزات الحصرية والحدود الأعلى المصممة لاحتياجاتك."
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14 * context.fontSizeFactor),
                  ),
                ),
                const SizedBox(height: 40),
                _buildFeatureItem(
                  context,
                  Icons.people_alt_rounded,
                  state.translate("Unlimited Quick Profiles", "Profiles aan xad lahayn", ar: "ملفات تعريف سريعة غير محدودة"),
                  state.translate("Save as many receivers as you want. Standard limit is 5.", "Keydi inta aad rabto oo qaataha ah. Xadka caadiga ah waa 5.", ar: "احفظ عددًا لا يحوا من المستلمين كما تريد. الحد القياسي هو 5."),
                  isDark,
                ),
                _buildFeatureItem(
                  context,
                  Icons.trending_up_rounded,
                  state.translate("Higher Transaction Limits", "Xadka lacag dirista oo sare", ar: "حدود معاملات أعلى"),
                  state.translate("Send up to \$10,000 daily and \$50,000 monthly.", "Dir ilaa \$10,000 maalintii iyo \$50,000 bishii.", ar: "أرسل ما يصل إلى 10000 دولار يوميًا و 50000 دولار شهريًا."),
                  isDark,
                ),
                _buildFeatureItem(
                  context,
                  Icons.support_agent_rounded,
                  state.translate("Priority 24/7 Support", "Taageero mudnaan leh 24/7", ar: "دعم أولوية على مدار الساعة طوال أيام الأسبوع"),
                  state.translate("Get instant access to our senior support agents.", "Si degdeg ah ula xidhiidh wakiilada taageerada ee sare.", ar: "احصل على وصول فوري إلى وكلاء الدعم الكبار لدينا."),
                  isDark,
                ),
                _buildFeatureItem(
                  context,
                  Icons.percent_rounded,
                  state.translate("Reduced Fees", "Qiimo dhimis lacag bixinta", ar: "رسوم مخفضة"),
                  state.translate("Save 50% on all transaction fees across the app.", "Keydi 50% dhammaan khidmadaha kala iibsiga ee app-ka.", ar: "وفر 50٪ على جميع رسوم المعاملات عبر التطبيق."),
                  isDark,
                ),
                const SizedBox(height: 48),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentTeal.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          state.translate("Premium Membership", "Xubinnimada Premium", ar: "عضوية بريميوم"),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "\$",
                              style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.accentTeal),
                            ),
                            Text(
                              "9.99",
                              style: TextStyle(fontSize: 40 * context.fontSizeFactor, fontWeight: FontWeight.w900, color: AppColors.accentTeal),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20 * context.fontSizeFactor),
                              child: Text(
                                "/month",
                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              state.togglePremium(true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Welcome to Murtaax Premium!"),
                                  backgroundColor: AppColors.accentTeal,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(
                              state.translate("Upgrade Now", "Hadda kor u qaad", ar: "ترقية الآن"),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.translate("Cancel anytime. No hidden fees.", "Iska daa wakhti kasta. Ma jiraan khidmado qarsoon.", ar: "إلغاء في أي وقت. لا توجد رسوم خفية."),
                          style: TextStyle(color: Colors.grey, fontSize: 12 * context.fontSizeFactor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle, bool isDark) {
    return FadeInLeft(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13 * context.fontSizeFactor, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
