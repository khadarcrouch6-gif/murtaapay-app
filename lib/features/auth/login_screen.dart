import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'security_pin_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        AppState().translate("Welcome Back", "Ku soo dhawaaw", ar: "مرحباً بعودتك", de: "Willkommen zurück"),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28 * context.fontSizeFactor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        AppState().translate("Enter your phone number to continue", "Gali lambarkaaga taleefanka si aad u sii wadato", ar: "أدخل رقم هاتفك للمتابعة", de: "Geben Sie Ihre Telefonnummer ein, um fortzufahren"),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey, fontSize: 16 * context.fontSizeFactor),
                      ),
                    ),
                    const SizedBox(height: 48),
                    FadeInUp(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: 16 * context.fontSizeFactor,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: AppState().translate("Phone Number", "Lambarka Taleefanka", ar: "رقم الهاتف", de: "Telefonnummer"),
                          hintStyle: const TextStyle(color: AppColors.grey),
                          prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppColors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SecurityPinScreen()),
                          );
                        },
                        child: Text(AppState().translate("Continue", "Sii wad", ar: "متابعة", de: "Weiter"), style: TextStyle(fontSize: 16 * context.fontSizeFactor)),
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
                          AppState().translate("Don't have an account? Sign Up", "Miyaadan lahayn akoon? Is qor", ar: "ليس لديك حساب؟ سجل الآن", de: "Haben Sie noch kein Konto? Registrieren"),
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

