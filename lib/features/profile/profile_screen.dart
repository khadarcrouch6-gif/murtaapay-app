import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../onboarding/splash_screen.dart';
import '../auth/kyc_screen.dart';
import '../more/refer_earn_screen.dart';
import '../more/vouchers_screen.dart';

import '../chat/chat_screen.dart';
import 'terms_screen.dart';
import 'security_center_screen.dart';

import '../../core/models/bank_account.dart';
import '../../core/widgets/adaptive_icon.dart';

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
  String _userDob = "1994-05-12";
  String _userNationality = "Somali";
  String _userIdNumber = "MS-8829102";
  String _userOccupation = "Software Entrepreneur";
  
  // Structured Address
  String _userStreet = "123 Wadada Makka Al-Mukarama";
  String _userCity = "Mogadishu";
  String _userPostalCode = "10001";
  String _userCountry = "Somalia";


  final String _profileImageUrl = 'https://i.pravatar.cc/300';
  final String _coverImageUrl = 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800';

  // Key for QR sharing
  final GlobalKey _qrKey = GlobalKey();

  // Stats Mock Data
  final int _loyaltyPoints = 1250;
  final String _accountLevel = "Elite Silver";
  final double _totalSavings = 450.00;

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ResponsiveBreakpoints.of(context).equals(TABLET)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu_rounded, color: theme.iconTheme.color),
              ),
            )
          : null,
      body: ListenableBuilder(
        listenable: state,
        builder: (context, child) {
          return Center(
            child: MaxWidthBox(
              maxWidth: 800,
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    context.horizontalPadding,
                    20 * context.fontSizeFactor,
                    context.horizontalPadding,
                    120,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildProfileHeader(context, theme, state),
                      const SizedBox(height: 20),
                      
                      _buildProfileCompleteness(context, state, theme),
                      const SizedBox(height: 24),
                      
                      _buildUserStats(context, state, theme),
                      const SizedBox(height: 32),
                      
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _buildSectionTitle(state.translate("Account Settings", "Habaynta Koontada", ar: "إعدادات الحساب", de: "Kontoeinstellungen", et: "Konto seaded"), context),
                                          _buildProfileOption(
                                            context, 
                                            state.translate("Personal Information", "Xogta Shakhsiga", ar: "معلومات شخصية", de: "Persönliche Angaben", et: "Isikuandmed"), 
                                            FontAwesomeIcons.user, 
                                            () => _showPersonalInfoEditor(context, state)
                                          ),
                                          _buildProfileOption(
                                            context, 
                                            state.translate("Identity Verification (KYC)", "Xaqiijinta Aqoonsiga", ar: "تحقق الهوية (KYC)", de: "Identitätsprüfung", et: "Isikutuvastus (KYC)"), 
                                            Icons.verified_user_rounded, 
                                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KYCScreen())),
                                            trailing: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                                              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                              child: Text(
                                                state.translate("Verified", "La Hubiyay", ar: "موثق", de: "Verifiziert", et: "Kinnitatud"),
                                                style: TextStyle(color: Colors.green, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          _buildProfileOption(
                                            context, 
                                            state.translate("Security & PIN", "Amniga & PIN", ar: "الأمان وكلمة السر", de: "Sicherheit & PIN", et: "Turvalisus ja PIN"), 
                                            FontAwesomeIcons.shieldHalved, 
                                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityCenterScreen()))
                                          ),
                                          _buildProfileOption(
                                            context, 
                                            state.translate("My QR Code", "Sawirkayga QR-ka", ar: "رمزي الخاص", de: "Mein QR-Code", et: "Minu QR-kood"), 
                                            Icons.qr_code_rounded, 
                                            () => _showMyQRCode(context, state)
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 24 * context.fontSizeFactor),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _buildSectionTitle(state.translate("Financial", "Maaliyadda", ar: "المالية", de: "Finanzen", et: "Finantid"), context),
                                          _buildProfileOption(
                                            context, 
                                            state.translate("Linked Bank Accounts", "Bangiyada ku Xidhan", ar: "حسابات بنكية مرتبطة", de: "Verknüpfte Bankkonten", et: "Seotud pangakontod"), 
                                            FontAwesomeIcons.buildingColumns, 
                                            () => _showLinkedBanks(context, state)
                                          ),
                                          SizedBox(height: 12 * context.fontSizeFactor),
                                          _buildSectionTitle(state.translate("Account Limits", "Xadka Akoonka", ar: "حدود الحساب", de: "Kontolimits", et: "Konto piirangud"), context),
                                          _buildAccountLimits(context, state, theme),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24 * context.fontSizeFactor),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _buildSectionTitle(state.translate("Preferences", "Dookhyada", ar: "التفضيلات", de: "Präferenzen", et: "Eelistused"), context),
                                          _buildSettingSwitch(
                                            context,
                                            state.translate("Dark Mode", "Habka Habeenkii", ar: "الوضع الليلي", de: "Dunkler Modus", et: "Tume režiim"), 
                                            state.themeMode == ThemeMode.dark, 
                                            Icons.dark_mode_rounded, 
                                            (v) => state.toggleTheme(v)
                                          ),
                                          _buildProfileOption(
                                            context, 
                                            "${state.translate("Language", "Luqadda", ar: "اللغة", de: "Sprache", et: "Keel")}: ${_getLanguageName(state.locale.languageCode)}", 
                                            Icons.language_rounded, 
                                            () => _showLanguagePicker(context, state)
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 24 * context.fontSizeFactor),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _buildSectionTitle(state.translate("Others", "Kuwa kale", ar: "آخرون", de: "Andere", et: "Muu"), context),
                                          _buildProfileOption(
                                            context, 
                                            state.translate("Refer & Earn", "Tixraac & Guulayso", ar: "دعوة الأصدقاء", de: "Empfehlen & Verdienen", et: "Soovita ja teeni"), 
                                            FontAwesomeIcons.userPlus, 
                                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferEarnScreen()))
                                          ),
                                          _buildProfileOption(
                                            context, 
                                            state.translate("Vouchers", "Vouchers", ar: "قسائم", de: "Gutscheine", et: "Voucherid"),
                                            Icons.confirmation_number_rounded, 
                                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VouchersScreen()))
                                          ),
                                          _buildProfileOption(
                                            context, 
                                            state.translate("Help & Support", "Caawinaad & Taageero", ar: "المساعدة والدعم", de: "Hilfe & Support", et: "Abi ja tugi"), 
                                            FontAwesomeIcons.headset, 
                                            () => _showSupportOptions(context, state)
                                          ),
                                          _buildProfileOption(
                                            context, 
                                            state.translate("Terms & Privacy", "Shuruudaha & Qawaaniinta", ar: "الشروط والخصوصية", de: "Bedingungen & Datenschutz", et: "Tingimused ja privaatsus"), 
                                            Icons.policy_rounded, 
                                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsScreen()))
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          
                          return Column(
                            children: [
                              _buildSectionTitle(state.translate("Account Settings", "Habaynta Koontada", ar: "إعدادات الحساب", de: "Kontoeinstellungen", et: "Konto seaded"), context),
                              
                              _buildProfileOption(
                                context, 
                                state.translate("Personal Information", "Xogta Shakhsiga", ar: "معلومات شخصية", de: "Persönliche Angaben", et: "Isikuandmed"), 
                                FontAwesomeIcons.user, 
                                () => _showPersonalInfoEditor(context, state)
                              ),
                              
                              _buildProfileOption(
                                context, 
                                state.translate("Identity Verification (KYC)", "Xaqiijinta Aqoonsiga", ar: "تحقق الهوية (KYC)", de: "Identitätsprüfung", et: "Isikutuvastus (KYC)"), 
                                Icons.verified_user_rounded, 
                                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KYCScreen())),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    state.translate("Verified", "La Hubiyay", ar: "موثق", de: "Verifiziert", et: "Kinnitatud"),
                                    style: TextStyle(color: Colors.green, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              
                              _buildProfileOption(
                                context, 
                                state.translate("Security & PIN", "Amniga & PIN", ar: "الأمان وكلمة السر", de: "Sicherheit & PIN", et: "Turvalisus ja PIN"), 
                                FontAwesomeIcons.shieldHalved, 
                                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityCenterScreen()))
                              ),

                              SizedBox(height: 24 * context.fontSizeFactor),
                              _buildSectionTitle(state.translate("Financial", "Maaliyadda", ar: "المالية", de: "Finanzen", et: "Finantid"), context),
                              
                              _buildProfileOption(
                                context, 
                                state.translate("Linked Bank Accounts", "Bangiyada ku Xidhan", ar: "حسابات بنكية مرتبطة", de: "Verknüpfte Bankkonten", et: "Seotud pangakontod"), 
                                FontAwesomeIcons.buildingColumns, 
                                () => _showLinkedBanks(context, state)
                              ),

                              SizedBox(height: 24 * context.fontSizeFactor),
                              _buildSectionTitle(state.translate("Account Limits", "Xadka Akoonka", ar: "حدود الحساب", de: "Kontolimits", et: "Konto piirangud"), context),
                              _buildAccountLimits(context, state, theme),

                              SizedBox(height: 24 * context.fontSizeFactor),
                              _buildSectionTitle(state.translate("Preferences", "Dookhyada", ar: "التفضيلات", de: "Präferenzen", et: "Eelistused"), context),
                              
                              _buildSettingSwitch(
                                context,
                                state.translate("Dark Mode", "Habka Habeenkii", ar: "الوضع الليلي", de: "Dunkler Modus", et: "Tume režiim"), 
                                state.themeMode == ThemeMode.dark, 
                                Icons.dark_mode_rounded, 
                                (v) => state.toggleTheme(v)
                              ),
                              
                              _buildProfileOption(
                                context, 
                                "${state.translate("Language", "Luqadda", ar: "اللغة", de: "Sprache", et: "Keel")}: ${_getLanguageName(state.locale.languageCode)}", 
                                Icons.language_rounded, 
                                () => _showLanguagePicker(context, state)
                              ),

                              SizedBox(height: 24 * context.fontSizeFactor),
                              _buildSectionTitle(state.translate("Others", "Kuwa kale", ar: "آخرون", de: "Andere", et: "Muu"), context),
                              
                              _buildProfileOption(
                                context, 
                                state.translate("Refer & Earn", "Tixraac & Guulayso", ar: "دعوة الأصدقاء", de: "Empfehlen & Verdienen", et: "Soovita ja teeni"), 
                                FontAwesomeIcons.userPlus, 
                                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferEarnScreen()))
                              ),
                              _buildProfileOption(
                                context, 
                                state.translate("Vouchers", "Waatsharrada", ar: "قسائم", de: "Gutscheine", et: "Voucherid"),
                                Icons.confirmation_number_rounded, 
                                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VouchersScreen()))
                              ),
                              
                              _buildProfileOption(
                                context, 
                                state.translate("Help & Support", "Caawinaad & Taageero", ar: "المساعدة والدعم", de: "Hilfe & Support", et: "Abi ja tugi"), 
                                FontAwesomeIcons.headset, 
                                () => _showSupportOptions(context, state)
                              ),
                              
                              _buildProfileOption(
                                context, 
                                state.translate("Terms & Privacy", "Shuruudaha & Qawaaniinta", ar: "الشروط والخصوصية", de: "Bedingungen & Datenschutz", et: "Tingimused ja privaatsus"), 
                                Icons.policy_rounded, 
                                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsScreen()))
                              ),
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      _buildProfileOption(
                        context, 
                        state.translate("Logout", "Ka Bax", ar: "تسجيل الخروج", de: "Abmelden", et: "Logi välja"), 
                        FontAwesomeIcons.rightFromBracket, 
                        () => _showLogoutDialog(context, state), 
                        isLogout: true
                      ),

                      SizedBox(height: 40 * context.fontSizeFactor),
                      _buildAppFooter(state, context),
                      SizedBox(height: 20 * context.fontSizeFactor),
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

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 4, bottom: 12 * context.fontSizeFactor),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12 * context.fontSizeFactor,
          fontWeight: FontWeight.w800,
          color: AppColors.accentTeal,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme, AppState state) {
    final coverHeight = 160 * context.fontSizeFactor;
    final profileSize = 100 * context.fontSizeFactor;
    
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Cover Image with Fallback
              Container(
                height: coverHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: AppColors.primaryDark.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _coverImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primaryDark, AppColors.accentTeal],
                            ),
                          ),
                          child: Icon(Icons.landscape_rounded, color: Colors.white.withValues(alpha: 0.2), size: 64),
                        ),
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Profile Image with Fallback
              Positioned(
                top: coverHeight - (profileSize / 2),
                child: Hero(
                  tag: 'profile_pic',
                  child: Stack(
                    children: [
                      Container(
                        height: profileSize,
                        width: profileSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            _profileImageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: AppColors.accentTeal,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.accentTeal,
                              child: Center(
                                child: Text(
                                  _userName.isNotEmpty ? _userName[0].toUpperCase() : "?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: profileSize * 0.4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.accentTeal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: (profileSize / 2) + 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _userName, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24 * context.fontSizeFactor, letterSpacing: -0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.verified_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
            ],
          ),
          SizedBox(height: 4 * context.fontSizeFactor),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_userEmail, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 14 * context.fontSizeFactor)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showMyQRCode(context, state),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.qr_code_2_rounded, color: AppColors.accentTeal, size: 16 * context.fontSizeFactor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, AppState state, ThemeData theme) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                _loyaltyPoints.toString(),
                state.translate("Points", "Dhibcaha", ar: "نقاط", de: "Punkte", et: "Punktid"),
                FontAwesomeIcons.gem,
              ),
              const VerticalDivider(thickness: 1, color: AppColors.grey, indent: 10, endIndent: 10),
              _buildStatItem(
                context,
                _accountLevel,
                state.translate("Level", "Darajo", ar: "المستوى", de: "Level", et: "Tase"),
                FontAwesomeIcons.award,
              ),
              const VerticalDivider(thickness: 1, color: AppColors.grey, indent: 10, endIndent: 10),
              _buildStatItem(
                context,
                "\$${_totalSavings.toStringAsFixed(0)}",
                state.translate("Savings", "Kaydka", ar: "مدخرات", de: "Ersparnisse", et: "Säästud"),
                FontAwesomeIcons.piggyBank,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, dynamic icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: Column(
        children: [
          AdaptiveIcon(icon, color: AppColors.accentTeal, size: 14 * context.fontSizeFactor),
          SizedBox(height: 4 * context.fontSizeFactor),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value, 
              style: TextStyle(
                fontWeight: FontWeight.w800, 
                fontSize: 14 * context.fontSizeFactor, 
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ),
          SizedBox(height: 2 * context.fontSizeFactor),
          Text(
            label, 
            style: TextStyle(color: AppColors.grey, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndShareQRCode(AppState state) async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/murtaaxpay_qr.png').create();
      await imagePath.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: state.translate(
          "Scan my QR code on MurtaaxPay to send me money! ID: ${state.walletId}",
          "Scan-gareey QR code-kayga MurtaaxPay si aad lacag iigu soo dirto! ID: ${state.walletId}",
          ar: "امسح رمز الاستجابة السريعة الخاص بي على MurtaaxPay لإرسال الأموال إلي! المعرف: ${state.walletId}",
          de: "Scannen Sie meinen QR-Code auf MurtaaxPay, um mir Geld zu senden! ID: ${state.walletId}",
          et: "Skanni minu MurtaaxPay QR-koodi, et mulle raha saata! ID: ${state.walletId}"
        ),
      );
    } catch (e) {
      debugPrint("Error sharing QR code: $e");
    }
  }

  void _showMyQRCode(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 32),
                Text(
                  state.translate("My QR Code", "Sawirkayga QR-ka", ar: "رمزي الخاص", de: "Mein QR-Code", et: "Minu QR-kood"),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _userName,
                  style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                // QR Container
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: state.walletId,
                      version: QrVersions.auto,
                      size: 200.0,
                      foregroundColor: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "ID: ${state.walletId}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _captureAndShareQRCode(state),
                      icon: const Icon(Icons.share_rounded, color: Colors.white),
                      label: Text(
                        state.translate("Share QR Code", "Share gareey QR-ka", ar: "مشاركة الرمز", de: "QR-Code teilen", et: "Jaga QR-koodi"),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    state.translate(
                      "Share my QR code to receive payments instantly.", 
                      "La wadaag sawirkaaga QR-ka si aad lacag u hesho.",
                      ar: "شارك رمز الاستجابة السريعة الخاص بك لتلقi المدفوعات فورًا.",
                      de: "Teile meinen QR-Code, um Zahlungen sofort zu erhalten.",
                      et: "Jaga oma QR-koodi, et makseid kohe kätte saada."
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPersonalInfoEditor(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    final phoneCtrl = TextEditingController(text: _userPhone);
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
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            ),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 12),
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
                              setState(() {
                                _userName = nameCtrl.text;
                                _userEmail = emailCtrl.text;
                                _userPhone = phoneCtrl.text;
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                            child: Text(
                              state.translate("Save Changes", "Keydi Isbeddelka", ar: "حفظ التغييرات", de: "Änderungen speichern", et: "Salvesta muudatused"), 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                            ),
                          ),
                        ),
                        SizedBox(height: 40 * context.fontSizeFactor),
                      ],
                    ),
                  ),
                ),
              ],
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
          labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor, color: AppColors.grey),
          prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), 
            borderSide: BorderSide(color: isDark == true ? Colors.white10 : Colors.grey.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), 
            borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
          ),
          filled: true,
          fillColor: isDark == true ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 16 * context.fontSizeFactor),
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, String title, dynamic icon, VoidCallback onTap, {bool isLogout = false, Widget? trailing}) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02), 
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 16 * context.fontSizeFactor),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: (isLogout ? Colors.red : AppColors.accentTeal).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: icon is IconData 
                    ? Icon(icon, color: isLogout ? Colors.red : AppColors.accentTeal, size: 18 * context.fontSizeFactor)
                    : FaIcon(icon, color: isLogout ? Colors.red : AppColors.accentTeal, size: 18 * context.fontSizeFactor),
                ),
                SizedBox(width: 16 * context.fontSizeFactor),
                Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15 * context.fontSizeFactor, color: isLogout ? Colors.red : null))),
                trailing ?? const SizedBox.shrink(),
                if (!isLogout) Icon(Icons.chevron_right_rounded, color: Colors.grey.withValues(alpha: 0.4), size: 24 * context.fontSizeFactor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(BuildContext context, String title, bool value, IconData icon, Function(bool) onChanged) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
      padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02), 
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * context.fontSizeFactor),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accentTeal, size: 18 * context.fontSizeFactor),
          ),
          SizedBox(width: 16 * context.fontSizeFactor),
          Expanded(
            child: Text(
              title, 
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15 * context.fontSizeFactor)
            )
          ),
          Switch.adaptive(
            value: value, 
            onChanged: onChanged,
            activeTrackColor: AppColors.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompleteness(BuildContext context, AppState state, ThemeData theme) {
    const double completion = 0.85;
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: EdgeInsets.all(20 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accentTeal.withValues(alpha: 0.1), theme.colorScheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                SizedBox(width: 8 * context.fontSizeFactor),
                Expanded(
                  child: Text(
                    "${state.translate("Profile", "Profile-kaagu", ar: "الملف الشخصي", de: "Profil", et: "Profiil")} ${(completion * 100).toInt()}% ${state.translate("Complete", "waa diyaar", ar: "مكتml", de: "Vollständig", et: "valmis")}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KYCScreen())),
                  child: Text(
                    state.translate("Complete Now", "Dhameey Hadda", ar: "أكمل الآن", de: "Jetzt ergänzen", et: "Lõpeta kohe"),
                    style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8 * context.fontSizeFactor),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: completion,
                backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                minHeight: 8 * context.fontSizeFactor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountLimits(BuildContext context, AppState state, ThemeData theme) {
    return Column(
      children: [
        _buildLimitItem(
          context,
          state.translate("Daily Transfer Limit", "Xadka Dirista Maalinlaha", ar: "حد التحويل اليومي", de: "Tägliches Überweisungslimit", et: "Päevane ülekandelimiit"),
          1250.00,
          5000.00,
          Icons.swap_horiz_rounded,
        ),
        const SizedBox(height: 12),
        _buildLimitItem(
          context,
          state.translate("Monthly Withdrawal Limit", "Xadka Bangiga ee Bishii", ar: "حد السحب الشهري", de: "Monatliches Auszahlungslimit", et: "Kuune väljamakselimiit"),
          4500.00,
          25000.00,
          Icons.account_balance_wallet_rounded,
        ),
      ],
    );
  }

  Widget _buildLimitItem(BuildContext context, String title, double used, double total, IconData icon) {
    final theme = Theme.of(context);
    final double percent = used / total;
    
    return Container(
      padding: EdgeInsets.all(16 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * context.fontSizeFactor),
                decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.accentTeal, size: 18 * context.fontSizeFactor),
              ),
              SizedBox(width: 12 * context.fontSizeFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
                    SizedBox(height: 2 * context.fontSizeFactor),
                    Text(
                      "\$${used.toStringAsFixed(0)} / \$${total.toStringAsFixed(0)}",
                      style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor),
                    ),
                  ],
                ),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12 * context.fontSizeFactor, color: AppColors.accentTeal),
              ),
            ],
          ),
          SizedBox(height: 12 * context.fontSizeFactor),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
              minHeight: 4 * context.fontSizeFactor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppFooter(AppState state, BuildContext context) {
    return Column(
      children: [
        Text(
          "MurtaaxPay v2.1.0",
          style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
        ),
      ],
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32 * context.fontSizeFactor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  Text(
                    state.translate("Select Language", "Dooro Luqadda", ar: "اختر اللغة", de: "Sprache auswählen", et: "Vali keel"), 
                    style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  ...languages.map((lang) {
                    final isSelected = state.locale.languageCode == lang["code"];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8 * context.fontSizeFactor),
                      child: Material(
                        color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "https://flagcdn.com/w80/${lang["country"]}.png",
                              width: 32 * context.fontSizeFactor,
                              height: 24 * context.fontSizeFactor,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.flag_rounded, size: 24 * context.fontSizeFactor),
                            ),
                          ),
                          title: Text(lang["native"]!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                          trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor) : null,
                          onTap: () {
                            state.setLanguage(lang["code"]!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20 * context.fontSizeFactor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLinkedBanks(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context, 
      useRootNavigator: true, 
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: ListenableBuilder(
            listenable: state,
            builder: (context, _) => SingleChildScrollView(
              padding: EdgeInsets.all(32 * context.fontSizeFactor),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
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
        );
      }
    );
  }

  Widget _buildBankTile(BuildContext context, AppState state, BankAccount bank) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
      child: Material(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
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
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
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
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.accentTeal : AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(state.translate("Link Account", "Ku xidh Akoonka", ar: "ربط الحساب", de: "Konto verknüpfen", et: "Seo konto"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
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

  void _showSupportOptions(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    state.translate("Help & Support", "Caawinaad & Taageero", ar: "المساعدة والدعم", de: "Hilfe & Support", et: "Abi ja tugi"),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
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
                              builder: (context) => ChatScreen(
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
                        () => _launchUrl("tel:+252615000000"),
                      ),
                      _buildSupportCard(
                        context,
                        state.translate("Email", "Email", ar: "البريد الإلكتروني", de: "E-Mail", et: "E-post"),
                        "support@murtaax.com",
                        Icons.email_rounded,
                        Colors.orange,
                        () => _launchUrl("mailto:support@murtaaxpay.com"),
                      ),
                      _buildSupportCard(
                        context,
                        state.translate("FAQ", "Su'aalaha", ar: "الأسئلة الشائعة", de: "FAQ", et: "KKK"),
                        "Help Center",
                        Icons.help_center_rounded,
                        AppColors.accentTeal,
                        () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupportCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  )
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 10), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(state.translate("Logout", "Ka Bax", ar: "تسجيل الخروج", de: "Abmelden", et: "Logi välja")),
        content: Text(state.translate("Are you sure you want to logout?", "Ma hubtaa inaad ka baxayso?",
            ar: "هل أنت متأكد أنك تريد تسجيل الخروج؟", de: "Sind Sie sicher, dass Sie sich abmelden möchten?", et: "Kas olete kindel, et soovite välja logida?")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(state.translate("Cancel", "Iska Daay", ar: "إلغاء", de: "Abbrechen", et: "Tühista"))),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false),
            child: Text(state.translate("Logout", "Ka Bax", ar: "تسجيل الخروج", de: "Abmelden", et: "Logi välja"), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

