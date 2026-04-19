import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'security_pin_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
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
                AppLocalizations.of(context)!.selectProvider, // Reusing localized string for "Select"
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
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: MaxWidthBox(
            maxWidth: 500, // Login forms should be compact
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.responsiveValue(mobile: 60.0, tablet: 40.0, desktop: 20.0)),
                    FadeInDown(
                      child: Center(
                        child: Image.asset(
                          "assets/images/logo.png",
                          height: 120 * context.fontSizeFactor,
                          errorBuilder: (context, error, stackTrace) => Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.lock_person_rounded, color: AppColors.primaryDark, size: 40 * context.fontSizeFactor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        l10n.welcomeBack,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28 * context.fontSizeFactor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        l10n.enterPhoneNumberToContinue,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey, fontSize: 16 * context.fontSizeFactor),
                      ),
                    ),
                    const SizedBox(height: 48),
                    FadeInUp(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _phoneController,
                            onChanged: (v) => setState(() {}),
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontSize: 16 * context.fontSizeFactor,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            decoration: InputDecoration(
                              hintText: "XXXXXXXXX",
                              counterText: "",
                              hintStyle: const TextStyle(color: AppColors.grey),
                              prefixIcon: InkWell(
                                onTap: _showCountryPicker,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 8, top: 1),
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
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                        ),
                        onPressed: _phoneController.text.length >= 7 ? () {
                          // Allow at least 7 digits for international numbers
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SecurityPinScreen()),
                          );
                        } : null,
                        child: Text(l10n.continueLabel, style: TextStyle(fontSize: 16 * context.fontSizeFactor)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          l10n.dontHaveAccountSignUp,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14 * context.fontSizeFactor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

