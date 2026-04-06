import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'login_screen.dart';
import 'security_pin_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                          Text(AppState().translate("Create Account", "Sameeyso Akoon", ar: "إنشاء حساب", de: "Konto erstellen"), style: TextStyle(fontSize: 28 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(AppState().translate("Join MurtaaxPay today and start sending money safely.", "Ku soo biir MurtaaxPay maanta oo bilow inaad lacag si ammaan ah u dirto.", ar: "انضم إلى MurtaaxPay اليوم وابدأ في إرسال الأموال بأمان.", de: "Treten Sie MurtaaxPay heute bei und beginnen Sie sicher Geld zu senden."), style: TextStyle(color: AppColors.grey, fontSize: 16 * context.fontSizeFactor)),
                          const SizedBox(height: 32),
                          _buildInput(context, AppState().translate("Full Name", "Magaca oo dhammaystiran", ar: "الاسم الكامل", de: "Vollständiger Name"), Icons.person_outline_rounded),
                          _buildInput(context, AppState().translate("Email Address", "Boostada qoraalka", ar: "عنوان البريد الإلكتروني", de: "E-Mail-Adresse"), Icons.email_outlined),
                          _buildInput(context, AppState().translate("Phone Number", "Lambarka taleefanka", ar: "رقم الهاتف", de: "Telefonnummer"), Icons.phone_android_rounded, isPhone: true),
                          _buildInput(context, AppState().translate("Password", "Erayga sirta ah", ar: "كلمة المرور", de: "Passwort"), Icons.lock_outline_rounded, isPass: true),
                          const Spacer(),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SecurityPinScreen()));
                            },
                             child: Text(AppState().translate("Sign Up", "Is qor", ar: "سجل الآن", de: "Registrieren"), style: TextStyle(fontSize: 16 * context.fontSizeFactor)),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                              child: Text(
                                AppState().translate("Already have an account? Login", "Miyaad hore u lahabd akoon? Soo gal", ar: "لديك حساب بالفعل؟ تسجيل الدخول", de: "Haben Sie bereits ein Konto? Login"), 
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
