import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animate_do/animate_do.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
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
  final LocalAuthentication _auth = LocalAuthentication();
  bool _biometricsAvailable = false;
  bool _twoFactorEnabled = false;
  bool _loginAlertsEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    if (kIsWeb) {
      if (mounted) setState(() => _biometricsAvailable = false);
      return;
    }
    final isAvailable = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    if (mounted) {
      setState(() => _biometricsAvailable = isAvailable);
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (kIsWeb) return;
    
    final state = Provider.of<AppState>(context, listen: false);
    if (value) {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to enable biometric access',
      );
      if (authenticated) {
        await state.setBiometricEnabled(true);
        setState(() {});
      }
    } else {
      await state.setBiometricEnabled(false);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(state.translate("Security Center", "Xarumta Ammaanka", ar: "مركز الأمان", de: "Sicherheitszentrum", et: "Turvakeskus")),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: context.verticalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShieldHeader(context, theme, state),
            SizedBox(height: 32 * context.fontSizeFactor),
            _buildSectionTitle(theme, state.translate("Biometrics & Access", "Aqoonsiga & Helitaanka", ar: "المقاييس الحيوية والوصول", de: "Biometrie & Zugriff", et: "Biomeetria ja juurdepääs")),
            SizedBox(height: 16 * context.fontSizeFactor),
            if (_biometricsAvailable)
              _buildSecurityToggle(
                context,
                state.translate("Enable Biometric Access", "Daar Aqoonsiga Biometric-ka", ar: "تفعيل الوصول بالمقاييس الحيوية", de: "Biometrischen Zugriff aktivieren", et: "Luba biomeetriline juurdepääs"),
                Icons.fingerprint_rounded,
                state.biometricEnabled,
                _toggleBiometrics,
              ),
            _buildSecurityTile(
              context,
              state.translate("Change Transaction PIN", "Beddel PIN-ka", ar: "تغيير رقم PIN للمعاملة", de: "Transaktions-PIN ändern", et: "Muuda tehingu PIN-koodi"),
              Icons.password_rounded,
              () {},
            ),
            SizedBox(height: 32 * context.fontSizeFactor),
            _buildSectionTitle(theme, state.translate("Advanced Security", "Ammaanka Sare", ar: "الأمان المتقدم", de: "Erweiterte Sicherheit", et: "Täpsem turvalisus")),
            SizedBox(height: 16 * context.fontSizeFactor),
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
            SizedBox(height: 32 * context.fontSizeFactor),
            _buildSectionTitle(theme, state.translate("Active Devices", "Aaladaha Shaqaynaya", ar: "الأجهزة النشطة", de: "Aktive Geräte", et: "Aktiivsed seadmed")),
            SizedBox(height: 16 * context.fontSizeFactor),
            _buildDeviceItem(context, "iPhone 15 Pro", state.translate("Active Now", "Hadda Shaqaynaya", ar: "نشط الآن", de: "Jetzt aktiv", et: "Praegu aktiivne"), true),
            _buildDeviceItem(context, "MacBook Pro M2", "London, UK • 2 hours ago", false),
            SizedBox(height: 100 * context.fontSizeFactor),
          ],
        ),
      ),
    );
  }

  Widget _buildShieldHeader(BuildContext context, ThemeData theme, AppState state) {
    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40 * context.fontSizeFactor, horizontal: 24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(32 * context.fontSizeFactor),
        ),
        child: Column(
          children: [
            Pulse(
              infinite: true,
              child: Container(
                padding: EdgeInsets.all(24 * context.fontSizeFactor),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3), width: 2 * context.fontSizeFactor),
                ),
                child: Icon(Icons.shield_rounded, color: AppColors.accentTeal, size: 64 * context.fontSizeFactor),
              ),
            ),
            SizedBox(height: 24 * context.fontSizeFactor),
            Text(
              state.translate("Your account is 85% secure", "Akooonkaagu 85% waa ammaan", ar: "حسابك مؤمن بنسبة 85%", de: "Ihr Konto ist zu 85 % sicher", et: "Teie konto on 85% turvatud"),
              style: TextStyle(color: Colors.white, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8 * context.fontSizeFactor),
            Text(
              state.translate("Enable 2FA to achieve 100% security coverage.", "Daar 2FA si aad u hesho 100% ammaan.", ar: "قم بتفعيل 2FA لتحقيق تغطية أمنية بنسبة 100%.", de: "Aktivieren Sie 2FA, um eine 100%ige Sicherheitsabdeckung zu erreichen.", et: "Lülitage sisse 2FA, et saavutada 100% turvalisus."),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13 * context.fontSizeFactor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildSecurityToggle(BuildContext context, String title, IconData icon, bool value, Function(bool) onChanged) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
      padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * context.fontSizeFactor),
            decoration: BoxDecoration(color: AppColors.primaryDark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
            child: Icon(icon, color: AppColors.primaryDark, size: 20 * context.fontSizeFactor),
          ),
          SizedBox(width: 16 * context.fontSizeFactor),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14 * context.fontSizeFactor))),
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
        margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
        padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 20 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * context.fontSizeFactor),
              decoration: BoxDecoration(color: AppColors.primaryDark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
              child: Icon(icon, color: AppColors.primaryDark, size: 20 * context.fontSizeFactor),
            ),
            SizedBox(width: 16 * context.fontSizeFactor),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14 * context.fontSizeFactor))),
            Icon(
              Directionality.of(context) == TextDirection.rtl 
                  ? Icons.chevron_left_rounded 
                  : Icons.chevron_right_rounded, 
              color: Colors.grey,
              size: 20 * context.fontSizeFactor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(BuildContext context, String model, String status, bool isCurrent) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
      padding: EdgeInsets.all(16 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12 * context.fontSizeFactor),
            decoration: BoxDecoration(color: isCurrent ? AppColors.accentTeal.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(isCurrent ? Icons.phone_iphone_rounded : Icons.laptop_mac_rounded, color: isCurrent ? AppColors.accentTeal : Colors.grey, size: 24 * context.fontSizeFactor),
          ),
          SizedBox(width: 16 * context.fontSizeFactor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                Text(status, style: TextStyle(color: isCurrent ? AppColors.accentTeal : Colors.grey, fontSize: 12 * context.fontSizeFactor)),
              ],
            ),
          ),
          if (!isCurrent) TextButton(onPressed: () {}, child: Text("Logout", style: TextStyle(color: Colors.redAccent, fontSize: 14 * context.fontSizeFactor))),
        ],
      ),
    );
  }
}

