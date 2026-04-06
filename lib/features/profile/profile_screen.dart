import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../onboarding/splash_screen.dart';
import '../auth/kyc_screen.dart';
import '../more/refer_earn_screen.dart';
import 'change_pin_screen.dart';
import '../chat/chat_list_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock Data
  String _userName = "Khadar Rayaale";
  String _userEmail = "khadar@murtaaxpay.com";
  String _userPhone = "+252 615 123 456";
  String _userAddress = "Mogadishu, Somalia";
  String _profileImageUrl = 'https://i.pravatar.cc/300';
  String _coverImageUrl = 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800';

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListenableBuilder(
        listenable: state,
        builder: (context, child) {
          return Center(
            child: MaxWidthBox(
              maxWidth: 800,
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.horizontalPadding,
                    20 * context.fontSizeFactor,
                    context.horizontalPadding,
                    120,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileHeader(context, theme),
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle(state.translate("Account Settings", "Habaynta Koontada", ar: "إعدادات الحساب", de: "Kontoeinstellungen")),
                      
                      _buildProfileOption(
                        context, 
                        state.translate("Personal Information", "Xogta Shakhsiga", ar: "معلومات شخصية", de: "Persönliche Angaben"), 
                        FontAwesomeIcons.user, 
                        () => _showPersonalInfoEditor(context, state)
                      ),
                      
                      _buildProfileOption(
                        context, 
                        state.translate("Identity Verification (KYC)", "Xaqiijinta Aqoonsiga", ar: "تحقق الهوية (KYC)", de: "Identitätsprüfung"), 
                        Icons.verified_user_rounded, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KYCScreen()))
                      ),
                      
                      _buildProfileOption(
                        context, 
                        state.translate("Security & PIN", "Amniga & PIN", ar: "الأمان وكلمة السر", de: "Sicherheit & PIN"), 
                        FontAwesomeIcons.shieldHalved, 
                        () => _showSecuritySettings(context, state)
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(state.translate("Financial", "Maaliyadda", ar: "المالية", de: "Finanzen")),
                      
                      _buildProfileOption(
                        context, 
                        state.translate("Linked Bank Accounts", "Bangiyada ku Xidhan", ar: "حسابات بنكية مرتبطة", de: "Verknüpfte Bankkonten"), 
                        FontAwesomeIcons.buildingColumns, 
                        () => _showLinkedBanks(context, state)
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(state.translate("Preferences", "Dookhyada", ar: "التفضيلات", de: "Präferenzen")),
                      
                      _buildSettingSwitch(
                        context,
                        state.translate("Dark Mode", "Habka Habeenkii", ar: "الوضع الليلي", de: "Dunkler Modus"), 
                        state.themeMode == ThemeMode.dark, 
                        Icons.dark_mode_rounded, 
                        (v) => state.toggleTheme(v)
                      ),
                      
                      _buildProfileOption(
                        context, 
                        "${state.translate("Language", "Luqadda", ar: "اللغة", de: "Sprache")}: ${_getLanguageName(state.locale.languageCode)}", 
                        Icons.language_rounded, 
                        () => _showLanguagePicker(context, state)
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(state.translate("Others", "Kuwa kale", ar: "آخرون", de: "Andere")),
                      
                      _buildProfileOption(
                        context, 
                        state.translate("Refer & Earn", "Tixraac & Guulayso", ar: "دعوة الأصدقاء", de: "Empfehlen & Verdienen"), 
                        FontAwesomeIcons.userPlus, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferEarnScreen()))
                      ),
                      
                      _buildProfileOption(
                        context, 
                        state.translate("Help & Support", "Caawinaad & Taageero", ar: "المساعدة والدعم", de: "Hilfe & Support"), 
                        FontAwesomeIcons.headset, 
                        () => _showSupportOptions(context, state)
                      ),
                      
                      _buildProfileOption(
                        context, 
                        state.translate("Terms & Privacy", "Shuruudaha & Qawaaniinta", ar: "الشروط والخصوصية", de: "Bedingungen & Datenschutz"), 
                        Icons.policy_rounded, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsScreen()))
                      ),
                      
                      const SizedBox(height: 32),
                      _buildProfileOption(
                        context, 
                        state.translate("Logout", "Ka Bax", ar: "تسجيل الخروج", de: "Abmelden"), 
                        FontAwesomeIcons.rightFromBracket, 
                        () => _showLogoutDialog(context, state), 
                        isLogout: true
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.accentTeal,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme) {
    final coverHeight = 160 * context.fontSizeFactor;
    final profileSize = 100 * context.fontSizeFactor;
    
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              height: coverHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(image: NetworkImage(_coverImageUrl), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              top: coverHeight - (profileSize / 2),
              child: Container(
                height: profileSize,
                width: profileSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  image: DecorationImage(image: NetworkImage(_profileImageUrl), fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: (profileSize / 2) + 16),
        Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 4),
        Text(_userEmail, style: const TextStyle(color: AppColors.grey)),
      ],
    );
  }

  void _showPersonalInfoEditor(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final addressCtrl = TextEditingController(text: _userAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              Text(state.translate("Edit Personal Information", "Wax ka beddel Xogta", ar: "تعديل المعلومات الشخصية", de: "Persönliche Daten bearbeiten"), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildEditorField(nameCtrl, state.translate("Full Name", "Magaca oo dhammaystiran", ar: "الاسم الكامل", de: "Vollständiger Name"), Icons.person_outline),
              _buildEditorField(emailCtrl, state.translate("Email Address", "Boostada qoraalka", ar: "عنوان البريد الإلكتروني", de: "E-Mail-Adresse"), Icons.email_outlined),
              _buildEditorField(phoneCtrl, state.translate("Phone Number", "Lambarka taleefanka", ar: "رقم الهاتف", de: "Telefonnummer"), Icons.phone_outlined),
              _buildEditorField(addressCtrl, state.translate("Current Address", "Meesha uu degan yahay", ar: "العنوان الحالي", de: "Aktuelle Adresse"), Icons.location_on_outlined),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _userName = nameCtrl.text;
                      _userEmail = emailCtrl.text;
                      _userPhone = phoneCtrl.text;
                      _userAddress = addressCtrl.text;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(state.translate("Save Changes", "Keydi Isbeddelka", ar: "حفظ التغييرات", de: "Änderungen speichern"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryDark),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, String title, dynamic icon, VoidCallback onTap, {bool isLogout = false}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            icon is IconData 
              ? Icon(icon, color: isLogout ? Colors.red : AppColors.accentTeal, size: 20)
              : FaIcon(icon, color: isLogout ? Colors.red : AppColors.accentTeal, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isLogout ? Colors.red : null))),
            if (!isLogout) const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(BuildContext context, String title, bool value, IconData icon, Function(bool) onChanged) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.accentTeal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accentTeal,
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'so': return 'Af-Soomaali';
      case 'ar': return 'العربية';
      case 'de': return 'Deutsch';
      default: return 'English';
    }
  }

  void _showLanguagePicker(BuildContext context, AppState state) {
    final languages = [
      {"code": "en", "name": "English", "native": "English", "country": "gb"},
      {"code": "so", "name": "Somali", "native": "Af-Soomaali", "country": "so"},
      {"code": "ar", "name": "Arabic", "native": "العربية", "country": "sa"},
      {"code": "de", "name": "German", "native": "Deutsch", "country": "de"},
    ];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.translate("Select Language", "Dooro Luqadda", ar: "اختر اللغة", de: "Sprache auswählen"), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...languages.map((lang) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: state.locale.languageCode == lang["code"] ? AppColors.accentTeal.withValues(alpha: 0.1) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    "https://flagcdn.com/w80/${lang["country"]}.png",
                    width: 32,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag_rounded),
                  ),
                ),
                title: Text(lang["native"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: state.locale.languageCode == lang["code"] ? const Icon(Icons.check_circle, color: AppColors.accentTeal) : null,
                onTap: () {
                  state.setLanguage(lang["code"]!);
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showSecuritySettings(BuildContext context, AppState state) {
    showModalBottomSheet(context: context, useRootNavigator: true, builder: (context) => Container(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.password, color: AppColors.accentTeal),
          title: Text(state.translate("Change PIN", "Beddel PIN-ka", ar: "تغيير رقم PIN", de: "PIN ändern")),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePinScreen())),
        ),
      ]),
    ));
  }

  void _showLinkedBanks(BuildContext context, AppState state) {
    showModalBottomSheet(context: context, useRootNavigator: true, builder: (context) => Container(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(state.translate("Bank Accounts", "Akoonada Bangiga", ar: "حسابات بنكية", de: "Bankkonten"), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.account_balance, color: AppColors.accentTeal),
          title: const Text("LHV Pank"),
          subtitle: const Text("**** 8829"),
        ),
        ListTile(
          leading: const Icon(Icons.account_balance, color: AppColors.accentTeal),
          title: const Text("Swedbank"),
          subtitle: const Text("**** 1120"),
        ),
      ]),
    ));
  }

  void _showSupportOptions(BuildContext context, AppState state) {
    showModalBottomSheet(context: context, useRootNavigator: true, builder: (context) => Container(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.chat, color: AppColors.accentTeal),
          title: Text(state.translate("Live Chat", "Wada hadalka tooska ah", ar: "دردشة مباشرة", de: "Live-Chat")),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
        ),
      ]),
    ));
  }

  void _showLogoutDialog(BuildContext context, AppState state) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(state.translate("Logout", "Ka Bax", ar: "تسجيل الخروج", de: "Abmelden")),
      content: Text(state.translate("Are you sure you want to logout?", "Ma hubtaa inaad ka baxayso?", ar: "هل أنت متأكد أنك تريد تسجيل الخروج؟", de: "Sind Sie sicher, dass Sie sich abmelden möchten?")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(state.translate("Cancel", "Iska Daay", ar: "إلغاء", de: "Abbrechen"))),
        TextButton(
          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false),
          child: Text(state.translate("Logout", "Ka Bax", ar: "تسجيل الخروج", de: "Abmelden"), style: const TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }
}
