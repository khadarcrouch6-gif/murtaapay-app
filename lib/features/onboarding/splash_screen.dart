import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Kordhiyey waqtiga (4 seconds) si uu u dareemo deganaan
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 1500),
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.3, // Wax yar ayaan kordhiyey maadaama qoraalkii la saaray
                          ),
                          child: Image.asset(
                            "assets/images/logo.png",
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.account_balance_wallet_rounded, 
                              size: 140, 
                              color: AppColors.primaryDark
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50), // Spacing-ka ayaan xoogaa kordhiyey
                  FadeInUp(
                    duration: const Duration(milliseconds: 1500),
                    child: Text(
                      AppState().translate("Trusted Somali Partner", "Saaxiibka Soomaaliyeed ee lagu kalsoon yahay", ar: "شريك صومالي موثوق", de: "Vertrauenswürdiger Partner"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeIn(
                    delay: const Duration(milliseconds: 2000),
                    duration: const Duration(seconds: 1),
                    child: Text(
                      AppState().translate("Safe • Fast • Reliable", "Ammaan • Degdeg • Lagu kalsoon yahay", ar: "آمن • سريع • موثوق", de: "Sicher • Schnell • Zuverlässig"),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
