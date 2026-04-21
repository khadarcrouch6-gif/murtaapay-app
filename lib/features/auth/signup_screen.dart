import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/countries.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
                    AppLocalizations.of(context)!.selectProvider,
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
                          _buildPhoneInput(context, l10n.phoneNumber),
                          _buildInput(context, l10n.password, Icons.lock_outline_rounded, isPass: true),
                          const Spacer(),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpScreen(
                                    phoneNumber: "${_selectedCountry.code}${_phoneController.text}",
                                    isLogin: false,
                                  ),
                                ),
                              );
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

  Widget _buildPhoneInput(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _phoneController,
        onChanged: (v) => setState(() {}),
        maxLength: _selectedCountry.maxLength,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
        ],
        style: TextStyle(
          fontSize: 16 * context.fontSizeFactor,
          color: theme.textTheme.bodyLarge?.color,
        ),
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: label,
          hintText: "XXXXXXXXX",
          counterText: "",
          labelStyle: const TextStyle(color: AppColors.grey),
          prefixIcon: InkWell(
            onTap: _showCountryPicker,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
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
          fillColor: theme.colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, String label, IconData icon, {bool isPass = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        obscureText: isPass,
        style: TextStyle(
          fontSize: 16 * context.fontSizeFactor,
          color: theme.textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey),
          prefixIcon: Icon(icon, color: AppColors.grey),
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
