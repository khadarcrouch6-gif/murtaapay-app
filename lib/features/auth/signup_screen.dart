import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
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
                  Text("Create Account", style: TextStyle(fontSize: 28 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Join MurtaaxPay today and start sending money safely.", style: TextStyle(color: AppColors.grey, fontSize: 16 * context.fontSizeFactor)),
                  const SizedBox(height: 32),
                  _buildInput(context, "Full Name", Icons.person_outline_rounded),
                  _buildInput(context, "Email Address", Icons.email_outlined),
                  _buildInput(context, "Phone Number", Icons.phone_android_rounded, isPhone: true),
                  _buildInput(context, "Password", Icons.lock_outline_rounded, isPass: true),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SecurityPinScreen()));
                    },
                    child: Text("Sign Up", style: TextStyle(fontSize: 16 * context.fontSizeFactor)),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                      child: Text(
                        "Already have an account? Login", 
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary, 
                          fontWeight: FontWeight.w600, 
                          fontSize: 14 * context.fontSizeFactor
                        )
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
