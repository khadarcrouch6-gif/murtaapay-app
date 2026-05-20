import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/models/bank_account.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../onboarding/splash_screen.dart';
import '../auth/kyc_screen.dart';
import '../more/refer_earn_screen.dart';
import '../more/vouchers_screen.dart';

import '../chat/chat_screen.dart';
import 'terms_screen.dart';
import 'security_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userDob = "1990-01-01";
  String _userNationality = "Somali";
  String _userIdNumber = "ABC123456";
  String _userOccupation = "Software Engineer";
  String _userStreet = "Maka Al-Mukarama Road";
  String _userCity = "Mogadishu";
  String _userPostalCode = "10001";
  String _userCountry = "Somalia";

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: MaxWidthBox(
          maxWidth: 1000,
          child: Column(
            children: [
              _buildHeader(context, state, isDark),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor),
                child: Column(
                  children: [
                    SizedBox(height: 32 * context.fontSizeFactor),
                    _buildQuickActions(context, state, isDark),
                    SizedBox(height: 40 * context.fontSizeFactor),
                    _buildSectionHeader(state.translate("Account Settings", "Habaynta Akoonka", ar: "إعدادات الحساب", de: "Kontoeinstellungen", et: "Konto seaded"), context),
                    SizedBox(height: 12 * context.fontSizeFactor),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        context,
                        Icons.person_outline_rounded,
                        state.translate("Personal Information", "Xogta Shakhsiga", ar: "معلومات شخصية", de: "Persönliche Angaben", et: "Isikuandmed"),
                        state.translate("Edit your profile details", "Wax ka beddel xogtaada", ar: "تعديل بيانات ملفك الشخصي", de: "Profil bearbeiten", et: "Muuda profiili andmeid"),
                        onTap: () => _showEditProfile(context, state),
                      ),
                      _buildSettingsTile(
                        context,
                        Icons.account_balance_outlined,
                        state.translate("Linked Banks", "Bangiyada ku Xidhan", ar: "البنوك المرتبطة", de: "Verknüpfte Banken", et: "Seotud pangad"),
                        state.translate("Manage bank accounts", "Maamul akoonada bangiga", ar: "إدارة الحسابات البنكية", de: "Bankkonten verwalten", et: "Pangakontode haldamine"),
                        onTap: () => _showLinkedBanks(context, state),
                      ),
                      _buildSettingsTile(
                        context,
                        Icons.verified_user_outlined,
                        state.translate("Identity (KYC)", "Aqoonsiga (KYC)", ar: "الهوية (KYC)", de: "Identität (KYC)", et: "Isikutuvastus (KYC)"),
                        state.translate("Verify your account", "Xaqiiji akoonkaaga", ar: "توثيق حسابك", de: "Konto verifizieren", et: "Kinnita oma konto"),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KYCScreen())),
                      ),
                    ], isDark, context),
                    SizedBox(height: 32 * context.fontSizeFactor),
                    _buildSectionHeader(state.translate("Security & Preferences", "Amniga & Xulashooyinka", ar: "الأمن والتفضيلات", de: "Sicherheit & Einstellungen", et: "Turvalisus ja eelistused"), context),
                    SizedBox(height: 12 * context.fontSizeFactor),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        context,
                        Icons.security_rounded,
                        state.translate("Security Center", "Xarunta Amniga", ar: "مركز الأمان", de: "Sicherheitszentrum", et: "Turvakeskus"),
                        state.translate("Passwords, 2FA, & Devices", "Password-ka, 2FA, & Qalabka", ar: "كلمات المرور ، 2FA ، والأجهزة", de: "Passwörter, 2FA & Geräte", et: "Paroolid, 2FA ja seadmed"),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityCenterScreen())),
                      ),
                      _buildSettingsTile(
                        context,
                        Icons.notifications_none_rounded,
                        state.translate("Notifications", "Ogeysiisyada", ar: "الإشعارات", de: "Benachrichtigungen", et: "Teavitused"),
                        state.translate("Alerts & messaging", "Ogeysiisyada & farriimaha", ar: "التنبيهات والرسائل", de: "Warnungen & Nachrichten", et: "Hoiatused ja sõnumid"),
                      ),
                      _buildSettingsTile(
                        context,
                        Icons.language_rounded,
                        state.translate("Language", "Luqadda", ar: "اللغة", de: "Sprache", et: "Keel"),
                        "${state.languageName} (${state.locale.languageCode.toUpperCase()})",
                        onTap: () => _showLanguagePicker(context, state),
                      ),
                      _buildSettingsTile(
                        context,
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        state.translate("Dark Mode", "Habka Habeenkii", ar: "الوضع المظلم", de: "Dunkelmodus", et: "Tume režiim"),
                        state.translate("Toggle app theme", "Beddel muuqaalka app-ka", ar: "تبديل مظهر التطبيق", de: "App-Theme umschalten", et: "Lülita rakenduse teemat"),
                        trailing: Transform.scale(
                          scale: 0.8 * context.fontSizeFactor,
                          child: Switch(
                            value: isDark,
                            onChanged: (value) => state.toggleTheme(value),
                            activeColor: AppColors.accentTeal,
                          ),
                        ),
                      ),
                    ], isDark, context),
                    SizedBox(height: 32 * context.fontSizeFactor),
                    _buildSectionHeader(state.translate("Support", "Taageero", ar: "الدعم", de: "Support", et: "Tugi"), context),
                    SizedBox(height: 12 * context.fontSizeFactor),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        context,
                        Icons.help_outline_rounded,
                        state.translate("Help Center", "Xarunta Caawinaada", ar: "مركز المساعدة", de: "Hilfezentrum", et: "Abikeskus"),
                        state.translate("FAQs and support contact", "Su'aalaha & xidhiidhka", ar: "الأسئلة الشائعة والاتصال بالدعم", de: "FAQs und Support", et: "KKK ja tugi"),
                        onTap: () => _showSupportOptions(context, state),
                      ),
                      _buildSettingsTile(
                        context,
                        Icons.info_outline_rounded,
                        state.translate("Legal", "Sharciga", ar: "قانوني", de: "Rechtliches", et: "Õiguslik"),
                        state.translate("Terms & Privacy Policy", "Shuruudaha & Qaanuunka", ar: "الشروط وسياسة الخصوصية", de: "AGB & Datenschutz", et: "Tingimused ja privaatsus"),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsScreen())),
                      ),
                    ], isDark, context),
                    SizedBox(height: 48 * context.fontSizeFactor),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _showLogoutDialog(context, state),
                        icon: const Icon(Icons.logout_rounded, color: Colors.red),
                        label: Text(
                          state.translate("Logout", "Ka Bax", ar: "تسجيل الخروج", de: "Abmelden", et: "Logi välja"),
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                          backgroundColor: Colors.red.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * context.fontSizeFactor),
                    Text("MurtaaxPay v2.1.0", style: TextStyle(color: Colors.grey, fontSize: 12 * context.fontSizeFactor)),
                    SizedBox(height: 120 * context.fontSizeFactor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 30 * context.fontSizeFactor,
        left: 24 * context.fontSizeFactor,
        right: 24 * context.fontSizeFactor,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryDark : Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.translate("My Profile", "Profile-kayga", ar: "ملفي الشخصي", de: "Mein Profil", et: "Minu profiil"),
                style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              IconButton(
                onPressed: () => _showQRCode(context, state),
                icon: Container(
                  padding: EdgeInsets.all(8 * context.fontSizeFactor),
                  decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.qr_code_scanner_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                ),
              ),
            ],
          ),
          SizedBox(height: 24 * context.fontSizeFactor),
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80 * context.fontSizeFactor,
                    height: 80 * context.fontSizeFactor,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentTeal, width: 2 * context.fontSizeFactor),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://ui-avatars.com/api/?name=${state.userName.replaceAll(' ', '+')}&background=0D47A1&color=fff',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/user.png', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4 * context.fontSizeFactor),
                      decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14 * context.fontSizeFactor),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20 * context.fontSizeFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.userName, style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4 * context.fontSizeFactor),
                    Text(state.userEmail, style: TextStyle(color: Colors.grey, fontSize: 14 * context.fontSizeFactor)),
                    SizedBox(height: 8 * context.fontSizeFactor),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.green, size: 14 * context.fontSizeFactor),
                          SizedBox(width: 4 * context.fontSizeFactor),
                          Text(
                            state.translate("Verified Account", "Akoon Xaqiijisan", ar: "حساب موثق", de: "Verifiziertes Konto", et: "Kinnitatud konto"),
                            style: TextStyle(color: Colors.green, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppState state, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionItem(context, Icons.account_balance_wallet_outlined, state.translate("Wallet", "Kiishka", ar: "المحفظة", de: "Wallet", et: "Rahakott"), () => state.setNavIndex(0)),
        _buildQuickActionItem(context, Icons.card_giftcard_rounded, state.translate("Vouchers", "Vouchers-ka", ar: "القسائم", de: "Gutscheine", et: "Voucherid"), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const VouchersScreen()));
        }),
        _buildQuickActionItem(context, Icons.people_outline_rounded, state.translate("Referral", "Tixraac", ar: "الإحالة", de: "Empfehlung", et: "Soovitus"), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferEarnScreen()));
        }),
        _buildQuickActionItem(context, Icons.history_rounded, state.translate("History", "Taariikhda", ar: "السجل", de: "Verlauf", et: "Ajalugu"), () => state.setNavIndex(1)),
      ],
    );
  }

  Widget _buildQuickActionItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16 * context.fontSizeFactor),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
            ),
            child: Icon(icon, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
          ),
          SizedBox(height: 8 * context.fontSizeFactor),
          Text(label, style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, bool isDark, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryDark.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
      leading: Container(
        padding: EdgeInsets.all(10 * context.fontSizeFactor),
        decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
        child: Icon(icon, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 13 * context.fontSizeFactor)),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20 * context.fontSizeFactor),
    );
  }

  void _showEditProfile(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController(text: state.userName);
    final emailCtrl = TextEditingController(text: state.userEmail);
    final phoneCtrl = TextEditingController(text: state.userPhone);
    final dobCtrl = TextEditingController(text: _userDob);
    final nationalityCtrl = TextEditingController(text: _userNationality);
    final idNumberCtrl = TextEditingController(text: _userIdNumber);
    final occupationCtrl = TextEditingController(text: _userOccupation);
    
    final streetCtrl = TextEditingController(text: _userStreet);
    final cityCtrl = TextEditingController(text: _userCity);
    final postalCtrl = TextEditingController(text: _userPostalCode);
    final countryCtrl = TextEditingController(text: _userCountry);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MaxWidthBox(
          maxWidth: 600,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  SizedBox(height: 12 * context.fontSizeFactor),
                  Container(width: 40 * context.fontSizeFactor, height: 5 * context.fontSizeFactor, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  SizedBox(height: 12 * context.fontSizeFactor),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.translate("Edit Personal Information", "Wax ka beddel Xogta", ar: "تعديل المعلومات الشخصية", de: "Persönliche Daten bearbeiten", et: "Muuda isikuandmeid"), 
                        style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.w800, letterSpacing: -0.5)
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormHeader(state.translate("Identity Information", "Macluumaadka Aqoonsiga", ar: "معلومات الهوية", de: "Identitätsinformationen", et: "Isikutuvastus"), context),
                        _buildEditorField(nameCtrl, state.translate("Full Name", "Magaca oo dhammaystiran", ar: "الاسم الكامل", de: "Vollständiger Name", et: "Täisnimi"), Icons.person_outline, context: context),
                        Row(
                          children: [
                            Expanded(child: _buildEditorField(dobCtrl, state.translate("Date of Birth", "Taariikhda dhalashada", ar: "تاريخ الميلاد", de: "Geburtsdatum", et: "Sünniaeg"), Icons.calendar_today_outlined, context: context)),
                            SizedBox(width: 12 * context.fontSizeFactor),
                            Expanded(child: _buildEditorField(nationalityCtrl, state.translate("Nationality", "Dhalashada", ar: "الجنسية", de: "Nationalität", et: "Kodakondsus"), Icons.flag_outlined, context: context)),
                          ],
                        ),
                        _buildEditorField(idNumberCtrl, state.translate("National ID / Tax Number", "Lambarka Aqoonsiga", ar: "رقم الهوية الوطنية", de: "Personalausweis- / Steuernummer", et: "Isikukood / Maksunumber"), Icons.badge_outlined, context: context),

                        SizedBox(height: 24 * context.fontSizeFactor),
                        _buildFormHeader(state.translate("Contact Details", "Xogta Lagala Xidhiidho", ar: "تفاصيل الاتصال", de: "Kontaktdetails", et: "Kontaktandmed"), context),
                        _buildEditorField(emailCtrl, state.translate("Email Address", "Boostada qoraalka", ar: "عنوان البريد الإلكتروني", de: "E-Mail-Adresse", et: "E-posti aadress"), Icons.email_outlined, context: context),
                        _buildEditorField(phoneCtrl, state.translate("Phone Number", "Lambarka taleefanka", ar: "رقم الهاتف", de: "Telefonnummer", et: "Telefoninumber"), Icons.phone_outlined, context: context),

                        SizedBox(height: 24 * context.fontSizeFactor),
                        _buildFormHeader(state.translate("Residential Address", "Cinwaanka Hoyga", ar: "عنوان السكن", de: "Wohnadresse", et: "Elukoha aadress"), context),
                        _buildEditorField(streetCtrl, state.translate("Street Address", "Wadada", ar: "عنوان الشارع", de: "Straßenadresse", et: "Tänava aadress"), Icons.home_outlined, context: context),
                        Row(
                          children: [
                            Expanded(child: _buildEditorField(cityCtrl, state.translate("City", "Magaalada", ar: "المدينة", de: "Stadt", et: "Linn"), Icons.location_city_outlined, context: context)),
                            SizedBox(width: 12 * context.fontSizeFactor),
                            Expanded(child: _buildEditorField(postalCtrl, state.translate("Postal Code", "Boostada", ar: "الرمز البريدي", de: "Postleitzahl", et: "Postiindeks"), Icons.mark_as_unread_outlined, context: context)),
                          ],
                        ),
                        _buildEditorField(countryCtrl, state.translate("Country", "Wadanka", ar: "البلد", de: "Land", et: "Riik"), Icons.public_outlined, context: context),

                        SizedBox(height: 24 * context.fontSizeFactor),
                        _buildFormHeader(state.translate("Employment", "Shaqada", ar: "العمل", de: "Beschäftigung", et: "Tööhõive"), context),
                        _buildEditorField(occupationCtrl, state.translate("Occupation / Source of Funds", "Nooca Shaqada", ar: "المهنة / مصدر الأموال", de: "Beruf / Herkunft der Mittel", et: "Amet / Rahaliste vahendite allikas"), Icons.work_outline, context: context),
                        
                        SizedBox(height: 40 * context.fontSizeFactor),
                        SizedBox(
                          width: double.infinity,
                          height: 56 * context.fontSizeFactor,
                          child: ElevatedButton(
                            onPressed: () {
                              state.updateProfile(
                                name: nameCtrl.text,
                                email: emailCtrl.text,
                                phone: phoneCtrl.text,
                              );
                              setState(() {
                                _userDob = dobCtrl.text;
                                _userNationality = nationalityCtrl.text;
                                _userIdNumber = idNumberCtrl.text;
                                _userOccupation = occupationCtrl.text;
                                _userStreet = streetCtrl.text;
                                _userCity = cityCtrl.text;
                                _userPostalCode = postalCtrl.text;
                                _userCountry = countryCtrl.text;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.accentTeal : AppColors.primaryDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * context.fontSizeFactor)),
                              elevation: 0,
                            ),
                            child: Text(
                              state.translate("Save Changes", "Keydi Isbeddelka", ar: "حفظ التغييرات", de: "Änderungen speichern", et: "Salvesta muudatused"),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildFormHeader(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * context.fontSizeFactor, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w800, color: AppColors.accentTeal, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildEditorField(TextEditingController controller, String label, IconData icon, {required BuildContext context}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 16 * context.fontSizeFactor),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark == true ? Colors.white : Colors.black87, fontSize: 16 * context.fontSizeFactor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey, fontSize: 14 * context.fontSizeFactor),
          prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 16 * context.fontSizeFactor),
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) => MaxWidthBox(
        maxWidth: 600,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32 * context.fontSizeFactor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12 * context.fontSizeFactor),
                Text(state.translate("Share Profile", "La wadaag Profile-ka", ar: "مشاركة الملف الشخصي", de: "Profil teilen", et: "Jaga profiili"), style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                SizedBox(height: 24 * context.fontSizeFactor),
                Container(
                  padding: EdgeInsets.all(16 * context.fontSizeFactor),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24 * context.fontSizeFactor)),
                  child: QrImageView(data: state.userEmail, version: QrVersions.auto, size: 200 * context.fontSizeFactor, gapless: false),
                ),
                SizedBox(height: 24 * context.fontSizeFactor),
                Text(state.userName, style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                Text(state.userEmail, style: TextStyle(color: Colors.grey, fontSize: 13 * context.fontSizeFactor)),
                SizedBox(height: 32 * context.fontSizeFactor),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.copy_rounded, size: 18 * context.fontSizeFactor),
                        label: Text(state.translate("Copy", "Nuuxi", ar: "نسخ", de: "Kopieren", et: "Kopeeri")),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                          foregroundColor: AppColors.accentTeal,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * context.fontSizeFactor),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.share_rounded, size: 18 * context.fontSizeFactor),
                        label: Text(state.translate("Share", "Wadaag", ar: "مشاركة", de: "Teilen", et: "Jaga")),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MaxWidthBox(
          maxWidth: 600,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12 * context.fontSizeFactor),
                Container(width: 40 * context.fontSizeFactor, height: 5 * context.fontSizeFactor, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                SizedBox(height: 24 * context.fontSizeFactor),
                Text(state.translate("Choose Language", "Dooro Luqadda", ar: "اختر اللغة", de: "Sprache wählen", et: "Vali keel"), style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                SizedBox(height: 16 * context.fontSizeFactor),
                _buildLanguageTile(context, state, "English", "en", "🇺🇸"),
                _buildLanguageTile(context, state, "Af-Soomaali", "so", "🇸🇴"),
                _buildLanguageTile(context, state, "العربية", "ar", "🇸🇦"),
                _buildLanguageTile(context, state, "Deutsch", "de", "🇩🇪"),
                _buildLanguageTile(context, state, "Eesti", "et", "🇪🇪"),
                SizedBox(height: 40 * context.fontSizeFactor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppState state, String name, String code, String flag) {
    final isSelected = state.locale.languageCode == code;
    return ListTile(
      onTap: () {
        state.setLanguage(code);
        Navigator.pop(context);
      },
      leading: Text(flag, style: TextStyle(fontSize: 24 * context.fontSizeFactor)),
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 16 * context.fontSizeFactor)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal) : null,
    );
  }

  void _showLinkedBanks(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true, 
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MaxWidthBox(
          maxWidth: 600,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: ListenableBuilder(
              listenable: state,
              builder: (context, _) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(32 * context.fontSizeFactor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      Container(width: 40 * context.fontSizeFactor, height: 5 * context.fontSizeFactor, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                      SizedBox(height: 24 * context.fontSizeFactor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(state.translate("Bank Accounts", "Akoonada Bangiga", ar: "حسابات بنكية", de: "Bankkonten", et: "Pangakontod"), style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => _showAddBankForm(context, state),
                          icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
                        )
                      ],
                    ),
                    SizedBox(height: 20 * context.fontSizeFactor),
                    if (state.linkedBanks.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40 * context.fontSizeFactor),
                        child: Text(state.translate("No linked accounts yet.", "Ma jiraan bangiyo ku xidhan.", ar: "لا توجد حسابات مرتبطة بعد.", de: "Noch keine verknüpften Konten.", et: "Seotud kontosid pole veel."), style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                      )
                    else
                      ...state.linkedBanks.map((bank) => _buildBankTile(context, state, bank)),
                    SizedBox(height: 20 * context.fontSizeFactor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankTile(BuildContext context, AppState state, BankAccount bank) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
      child: Material(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () {}, 
          leading: Icon(Icons.account_balance, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
          title: Text(bank.bankName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
          subtitle: Text(bank.accountNumber, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20 * context.fontSizeFactor),
            onPressed: () => state.removeBank(bank.id),
          ),
        ),
      ),
    );
  }

  void _showAddBankForm(BuildContext context, AppState state) {
    final bankCtrl = TextEditingController();
    final accountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MaxWidthBox(
          maxWidth: 600,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Padding(
                padding: EdgeInsets.all(32.0 * context.fontSizeFactor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40 * context.fontSizeFactor, height: 5 * context.fontSizeFactor, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                    SizedBox(height: 24 * context.fontSizeFactor),
                  Text(state.translate("Link New Bank", "Ku xidh Banki Cusub", ar: "ربط بنك جديد", de: "Neues Bankkonto verknüpfen", et: "Seo uus pank"), style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  _buildEditorField(bankCtrl, state.translate("Bank Name", "Magaca Bangiga", ar: "اسم البنك", de: "Bankname", et: "Panga nimi"), Icons.account_balance_outlined, context: context),
                  _buildEditorField(accountCtrl, state.translate("Account Number", "Lambarka Akoonka", ar: "رقم الحساب", de: "Kontonummer", et: "Kontonumber"), Icons.numbers_rounded, context: context),
                  SizedBox(height: 32 * context.fontSizeFactor),
                  SizedBox(
                    width: double.infinity,
                    height: 56 * context.fontSizeFactor,
                    child: ElevatedButton(
                      onPressed: () {
                        if (bankCtrl.text.isNotEmpty && accountCtrl.text.isNotEmpty) {
                          state.addBank(BankAccount(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            bankName: bankCtrl.text,
                            accountNumber: accountCtrl.text,
                          ));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                        elevation: 0,
                      ),
                      child: Text(state.translate("Link Account", "Ku xidh Akoonka", ar: "ربط الحساب", de: "Konto verknüpfen", et: "Seo konto"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSupportOptions(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MaxWidthBox(
          maxWidth: 600,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(32 * context.fontSizeFactor),
                child: Column(
                  children: [
                    Container(
                      width: 40 * context.fontSizeFactor,
                      height: 5 * context.fontSizeFactor,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                    SizedBox(height: 24 * context.fontSizeFactor),
                  Text(
                    state.translate("Help & Support", "Caawinaad & Taageero", ar: "المساعدة والدعم", de: "Hilfe & Support", et: "Abi ja tugi"),
                    style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 16 * context.fontSizeFactor,
                    crossAxisSpacing: 16 * context.fontSizeFactor,
                    childAspectRatio: 1.1,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSupportCard(
                        context,
                        state.translate("Live Chat", "Wada hadalka", ar: "دردشة مباشرة", de: "Live-Chat", et: "Reaalajas vestlus"),
                        "Support Bot",
                        Icons.chat_bubble_rounded,
                        Colors.blue,
                        () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(
                                userId: 'support_bot',
                                userName: 'Murtaax Support',
                                userAvatar: 'assets/images/logo1.png',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildSupportCard(
                        context,
                        state.translate("Phone Call", "Wicitaan", ar: "اتصال هاتفي", de: "Anruf", et: "Telefonikõne"),
                        "+252 615 000 000",
                        Icons.phone_enabled_rounded,
                        Colors.green,
                        () => _launchUrl('tel:+252615000000'),
                      ),
                      _buildSupportCard(
                        context,
                        state.translate("Email Us", "Email noo soo dir", ar: "أرسل لنا بريدًا إلكترونيًا", de: "E-Mail schreiben", et: "Saada meile e-kiri"),
                        "support@murtaaxpay.com",
                        Icons.email_rounded,
                        Colors.orange,
                        () => _launchUrl('mailto:support@murtaaxpay.com'),
                      ),
                      _buildSupportCard(
                        context,
                        "WhatsApp",
                        "Live Agent",
                        FontAwesomeIcons.whatsapp,
                        const Color(0xFF25D366),
                        () => _launchUrl('https://wa.me/252615000000'),
                      ),
                    ],
                  ),
                  SizedBox(height: 32 * context.fontSizeFactor),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupportCard(BuildContext context, String title, String subtitle, dynamic icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
        child: Padding(
          padding: EdgeInsets.all(16 * context.fontSizeFactor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12 * context.fontSizeFactor),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: icon is IconData 
                    ? Icon(icon, color: color, size: 24 * context.fontSizeFactor)
                    : FaIcon(icon, color: color, size: 24 * context.fontSizeFactor),
              ),
              SizedBox(height: 12 * context.fontSizeFactor),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor), textAlign: TextAlign.center),
              SizedBox(height: 4 * context.fontSizeFactor),
              Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 11 * context.fontSizeFactor), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showLogoutDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) => MaxWidthBox(
        maxWidth: 600,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28 * context.fontSizeFactor)),
          title: Text(
            state.translate("Logout", "Ka Bax", ar: "تسجيل الخروج", de: "Abmelden", et: "Logi välja"),
            style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            state.translate("Are you sure you want to logout?", "Ma hubtaa inaad ka baxayso?",
              ar: "هل أنت متأكد أنك تريد تسجيل الخروج؟", de: "Sind Sie sicher, dass Sie sich abmelden möchten?", et: "Kas olete kindel, et soovite välja logida?"),
            style: TextStyle(fontSize: 14 * context.fontSizeFactor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text(
                state.translate("Cancel", "Iska Daay", ar: "إلغاء", de: "Abbrechen", et: "Tühista"),
                style: TextStyle(fontSize: 14 * context.fontSizeFactor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false),
              child: Text(
                state.translate("Logout", "Ka Bax", ar: "تسجيل الخروج", de: "Abmelden", et: "Logi välja"), 
                style: TextStyle(color: Colors.red, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
