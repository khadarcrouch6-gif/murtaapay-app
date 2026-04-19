import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'account_limits_screen.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  bool _faceIdEnabled = true;
  bool _twoFactorEnabled = false;
  bool _loginAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(state.translate("Security Center", "Xarumta Ammaanka", ar: "مركز الأمان", de: "Sicherheitszentrum", et: "Turvakeskus")),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShieldHeader(theme, state),
            const SizedBox(height: 32),
            _buildSectionTitle(theme, state.translate("Biometrics & Access", "Aqoonsiga & Helitaanka", ar: "المقاييس الحيوية والوصول", de: "Biometrie & Zugriff", et: "Biomeetria ja juurdepääs")),
            const SizedBox(height: 16),
            _buildSecurityToggle(
              context,
              state.translate("Enable Face ID / Touch ID", "Daar Face ID / Touch ID", ar: "تفعيل Face ID / Touch ID", de: "Face ID / Touch ID aktivieren", et: "Luba Face ID / Touch ID"),
              Icons.face_retouching_natural_rounded,
              _faceIdEnabled,
              (val) => setState(() => _faceIdEnabled = val),
            ),
            _buildSecurityTile(
              context,
              state.translate("Change Transaction PIN", "Beddel PIN-ka", ar: "تغيير رقم PIN للمعاملة", de: "Transaktions-PIN ändern", et: "Muuda tehingu PIN-koodi"),
              Icons.password_rounded,
              () {},
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(theme, state.translate("Advanced Security", "Ammaanka Sare", ar: "الأمان المتقدم", de: "Erweiterte Sicherheit", et: "Täpsem turvalisus")),
            const SizedBox(height: 16),
            _buildSecurityTile(
              context,
              state.translate("Account Limits", "Xadka Akooonka", ar: "حدود الحساب", de: "Kontolimits", et: "Konto piirangud"),
              Icons.speed_rounded,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountLimitsScreen())),
            ),
            _buildSecurityToggle(
              context,
              state.translate("Two-Factor Authentication", "Xaqiijinta Labada-Talaabo", ar: "المصادقة الثنائية", de: "Zwei-Faktor-Authentifizierung", et: "Kaheastmeline kinnitamine"),
              Icons.security_rounded,
              _twoFactorEnabled,
              (val) => setState(() => _twoFactorEnabled = val),
            ),
            _buildSecurityToggle(
              context,
              state.translate("Login Notifications", "Ogeysiisyada Gelitaanka", ar: "إشعارات تسجيل الدخول", de: "Anmeldebenachrichtigungen", et: "Sisselogimise teavitused"),
              Icons.notification_important_rounded,
              _loginAlertsEnabled,
              (val) => setState(() => _loginAlertsEnabled = val),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(theme, state.translate("Active Devices", "Aaladaha Shaqaynaya", ar: "الأجهزة النشطة", de: "Aktive Geräte", et: "Aktiivsed seadmed")),
            const SizedBox(height: 16),
            _buildDeviceItem(context, "iPhone 15 Pro", state.translate("Active Now", "Hadda Shaqaynaya", ar: "نشط الآن", de: "Jetzt aktiv", et: "Praegu aktiivne"), true),
            _buildDeviceItem(context, "MacBook Pro M2", "London, UK • 2 hours ago", false),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildShieldHeader(ThemeData theme, AppState state) {
    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            Pulse(
              infinite: true,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.accentTeal, size: 64),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              state.translate("Your account is 85% secure", "Akooonkaagu 85% waa ammaan", ar: "حسابك مؤمن بنسبة 85%", de: "Ihr Konto ist zu 85 % sicher", et: "Teie konto on 85% turvatud"),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.translate("Enable 2FA to achieve 100% security coverage.", "Daar 2FA si aad u hesho 100% ammaan.", ar: "قم بتفعيل 2FA لتحقيق تغطية أمنية بنسبة 100%.", de: "Aktivieren Sie 2FA, um eine 100%ige Sicherheitsabdeckung zu erreichen.", et: "Lülitage sisse 2FA, et saavutada 100% turvalisus."),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildSecurityToggle(BuildContext context, String title, IconData icon, bool value, Function(bool) onChanged) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryDark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primaryDark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(BuildContext context, String model, String status, bool isCurrent) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isCurrent ? AppColors.accentTeal.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(isCurrent ? Icons.phone_iphone_rounded : Icons.laptop_mac_rounded, color: isCurrent ? AppColors.accentTeal : Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(color: isCurrent ? AppColors.accentTeal : Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (!isCurrent) TextButton(onPressed: () {}, child: const Text("Logout", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}
