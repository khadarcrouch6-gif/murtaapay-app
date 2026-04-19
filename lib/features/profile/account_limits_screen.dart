import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';

class AccountLimitsScreen extends StatelessWidget {
  const AccountLimitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(state.translate("Account Limits", "Xadka Akooonka", ar: "حدود الحساب")),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, state, isDark),
            const SizedBox(height: 32),
            _buildLimitSection(
              context,
              state.translate("Daily Limit", "Xadka Maalinta", ar: "الحد اليومي"),
              state.getDailyRemaining(),
              5000.0,
              Icons.today_rounded,
              isDark,
            ),
            const SizedBox(height: 24),
            _buildLimitSection(
              context,
              state.translate("Monthly Limit", "Xadka Bisaha", ar: "الحد الشهري"),
              state.getMonthlyRemaining(),
              20000.0,
              Icons.calendar_month_rounded,
              isDark,
            ),
            const SizedBox(height: 40),
            _buildUpgradeCard(context, state, isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AppState state, bool isDark) {
    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.speed_rounded, color: AppColors.accentTeal, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              state.translate("Verified Tier 2", "Heerka 2aad ee La Hubiyay", ar: "المستوى 2 تم التحقق منه"),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              state.translate(
                "Your account has standard limits. Complete KYC for higher limits.",
                "Akoonku wuxuu leeyahay xaddid heerkiisu caadi yahay. Dhammaystir KYC si aad u hesho xad sare.",
                ar: "حسابك له حدود قياسية. أكمل KYC للحصول على حدود أعلى."
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitSection(BuildContext context, String title, double remaining, double total, IconData icon, bool isDark) {
    final used = total - remaining;
    final percent = (used / total).clamp(0.0, 1.0);
    final currencyFormat = NumberFormat.currency(symbol: r"$", decimalDigits: 0);

    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primaryDark.withValues(alpha: 0.5) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.secondary, size: 24),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${(percent * 100).toInt()}%",
                    style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  percent > 0.9 ? Colors.redAccent : (percent > 0.7 ? Colors.orangeAccent : AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountInfo("Used", currencyFormat.format(used), isDark),
                _buildAmountInfo("Remaining", currencyFormat.format(remaining), isDark, isPrimary: true),
                _buildAmountInfo("Total Limit", currencyFormat.format(total), isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String label, String amount, bool isDark, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: isPrimary ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: isPrimary ? 16 : 14,
            fontWeight: FontWeight.w900,
            color: isPrimary ? AppColors.secondary : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(BuildContext context, AppState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: AppColors.accentTeal, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.translate("Increase your limits", "Kordhi xadkaaga", ar: "زيادة حدودك"),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                Text(
                  state.translate("Verify your identity to send more.", "Hubi aqoonsigaaga si aad u dirto wax badan.", ar: "تحقق من هويتك لإرسال المزيد."),
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.accentTeal),
        ],
      ),
    );
  }
}
