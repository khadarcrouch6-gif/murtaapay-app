import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SavingsScreen extends StatefulWidget {
  final bool isTab;
  const SavingsScreen({super.key, this.isTab = false});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: widget.isTab ? null : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(state.translate("Savings & Goals", "Kaydka & Hadafka", ar: "الادخار والأهداف", de: "Ersparnisse & Ziele"), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 20 * context.fontSizeFactor)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(state.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.colorScheme.primary),
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
                  Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: _buildTotalSavings(context, state),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(state.translate("Active Goals", "Hadafyada Socda", ar: "الأهداف النشطة", de: "Aktive Ziele"), style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      TextButton(
                        onPressed: () {},
                        child: Text(state.translate("See All", "Arag Dhammaan", ar: "عرض الكل", de: "Alle sehen"), style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSavingsGoalCard(
                    context: context,
                    state: state,
                    title: state.translate("Hajj Fund", "Sanduuqa Xajka", ar: "صندوق الحج", de: "Hajj-Fonds"),
                    savedAmount: 1200,
                    targetAmount: 5000,
                    icon: Icons.mosque_rounded,
                    color: AppColors.accentTeal,
                    delay: 100,
                  ),
                  _buildSavingsGoalCard(
                    context: context,
                    state: state,
                    title: state.translate("New Car", "Gaadhi Cusub", ar: "سيارة جديدة", de: "Neues Auto"),
                    savedAmount: 4500,
                    targetAmount: 15000,
                    icon: Icons.directions_car_rounded,
                    color: const Color(0xFF6366F1),
                    delay: 200,
                  ),
                  _buildSavingsGoalCard(
                    context: context,
                    state: state,
                    title: state.translate("Emergency Fund", "Sanduuqa Degdegga", ar: "صندوق الطوارئ", de: "Notfallfonds"),
                    savedAmount: 850,
                    targetAmount: 2000,
                    icon: Icons.health_and_safety_rounded,
                    color: const Color(0xFFF43F5E),
                    delay: 300,
                  ),
                  const SizedBox(height: 100), // Spacing for the fixed button
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(context.horizontalPadding, 0, context.horizontalPadding, 20),
            child: FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: MaxWidthBox(
                      maxWidth: 400,
                      child: SizedBox(
                        width: double.infinity,
                        height: 60 * context.fontSizeFactor,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24 * context.fontSizeFactor),
                          label: Text(state.translate("Create New Goal", "Samee Hadaf Cusub", ar: "إنشاء هدف جديد", de: "Neues Ziel erstellen"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            elevation: 4,
                            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSavings(BuildContext context, AppState state) {
    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 25, offset: const Offset(0, 15)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(state.translate("Total Savings", "Kaydka Dhan", ar: "إجمالي المدخرات", de: "Gesamtersparnisse"), style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: Colors.greenAccent, size: 14 * context.fontSizeFactor),
                      const SizedBox(width: 6),
                      Text("2.5%", style: TextStyle(color: Colors.white, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text("\$6,550.00", style: TextStyle(color: Colors.white, fontSize: 42 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceAction(context, state.translate("Deposit", "Dhig", ar: "إيداع", de: "Einzahlen"), Icons.add_rounded, Colors.white, AppColors.primaryDark),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBalanceAction(context, state.translate("Withdraw", "La Bax", ar: "سحب", de: "Abheben"), Icons.remove_rounded, Colors.white.withValues(alpha: 0.15), Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceAction(BuildContext context, String label, IconData icon, Color bgColor, Color textColor) {
    return Container(
      height: 52 * context.fontSizeFactor,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20 * context.fontSizeFactor),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor)),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalCard({
    required BuildContext context,
    required AppState state,
    required String title,
    required double savedAmount,
    required double targetAmount,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    double progress = savedAmount / targetAmount;
    final theme = Theme.of(context);
    
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: theme.brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52 * context.fontSizeFactor, height: 52 * context.fontSizeFactor,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: color, size: 24 * context.fontSizeFactor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17 * context.fontSizeFactor, color: theme.colorScheme.primary)),
                      const SizedBox(height: 4),
                      Text(
                        "${state.translate("Goal:", "Hadafka:", ar: "الهدف:", de: "Ziel:")} \$${targetAmount.toStringAsFixed(0)}",
                        style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("\$${savedAmount.toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17 * context.fontSizeFactor, color: theme.colorScheme.primary)),
                    const SizedBox(height: 4),
                    Text("${(progress * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor, color: color)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

