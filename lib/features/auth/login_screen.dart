import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/countries.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Country _selectedCountry = countries.firstWhere((c) => c.code == "+252");
  List<Country> _filteredCountries = countries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCountries);
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = countries
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.code.contains(query))
          .toList();
    });
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.selectProvider, // Reusing localized string for "Select"
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search country or code...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (v) {
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        return ListTile(
                          leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                          title: Text(country.name),
                          trailing: Text(country.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {
                            setState(() {
                              _selectedCountry = country;
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
          }
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: MaxWidthBox(
            maxWidth: 500,
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
                            maxLength: _selectedCountry.maxLength,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
                            ],
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
                                      Text(_selectedCountry.flag, style: const TextStyle(fontSize: 20)),
                                      const SizedBox(width: 4),
                                      Text(_selectedCountry.code, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: AppColors.grey)),
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(
                                phoneNumber: "${_selectedCountry.code}${_phoneController.text}",
                                isLogin: true,
                              ),
                            ),
                          );
                        } : null,
                        child: Text(l10n.continueLabel, style: TextStyle(fontSize: 16 * context.fontSizeFactor)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
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
