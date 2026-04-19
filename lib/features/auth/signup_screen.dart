import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'login_screen.dart';
import 'security_pin_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _selectedCountryCode = "+252";
  String _selectedFlag = "🇸🇴";

  final List<Map<String, String>> _countries = [
    {"name": "Somalia", "code": "+252", "flag": "🇸🇴"},
    {"name": "Kenya", "code": "+254", "flag": "🇰🇪"},
    {"name": "Ethiopia", "code": "+251", "flag": "🇪🇹"},
    {"name": "Djibouti", "code": "+253", "flag": "🇩🇯"},
    {"name": "United Kingdom", "code": "+44", "flag": "🇬🇧"},
    {"name": "United States", "code": "+1", "flag": "🇺🇸"},
    {"name": "Canada", "code": "+1", "flag": "🇨🇦"},
    {"name": "Sweden", "code": "+46", "flag": "🇸🇪"},
    {"name": "Norway", "code": "+47", "flag": "🇳🇴"},
    {"name": "UAE", "code": "+971", "flag": "🇦🇪"},
  ];

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.selectProvider,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return ListTile(
                      leading: Text(country["flag"]!, style: const TextStyle(fontSize: 24)),
                      title: Text(country["name"]!),
                      trailing: Text(country["code"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        setState(() {
                          _selectedCountryCode = country["code"]!;
                          _selectedFlag = country["flag"]!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: MaxWidthBox(
            maxWidth: 500,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: context.responsiveValue(mobile: 40.0, tablet: 30.0, desktop: 20.0)),
                          FadeInDown(
                            child: Center(
                              child: Image.asset("assets/images/logo.png", height: 80 * context.fontSizeFactor),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(l10n.createAccount, style: TextStyle(fontSize: 28 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(l10n.joinMurtaaxPayToday, style: TextStyle(color: AppColors.grey, fontSize: 16 * context.fontSizeFactor)),
                          const SizedBox(height: 32),
                          _buildInput(context, l10n.fullName, Icons.person_outline_rounded),
                          _buildInput(context, l10n.emailAddress, Icons.email_outlined),
                          _buildInput(context, l10n.phoneNumber, Icons.phone_android_rounded, isPhone: true),
                          _buildInput(context, l10n.password, Icons.lock_outline_rounded, isPass: true),
                          const Spacer(),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SecurityPinScreen()));
                            },
                             child: Text(l10n.signUp, style: TextStyle(fontSize: 16 * context.fontSizeFactor)),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                              child: Text(
                                l10n.alreadyHaveAccountLogin,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary, 
                                  fontWeight: FontWeight.w600, 
                                  fontSize: 14 * context.fontSizeFactor
                                )
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, String label, IconData icon, {bool isPass = false, bool isPhone = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        obscureText: isPass,
        style: TextStyle(
          fontSize: 16 * context.fontSizeFactor,
          color: theme.textTheme.bodyLarge?.color,
        ),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: isPhone ? "XXXXXXXXX" : null,
          counterText: "",
          labelStyle: const TextStyle(color: AppColors.grey),
          prefixIcon: isPhone 
            ? InkWell(
                onTap: _showCountryPicker,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedFlag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 4),
                      Text(_selectedCountryCode, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: AppColors.grey)),
                      const Icon(Icons.arrow_drop_down, color: AppColors.grey),
                    ],
                  ),
                ),
              )
            : Icon(icon, color: AppColors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
      ),
    );
  }
}
