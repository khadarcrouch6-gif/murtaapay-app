import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_auth_helper.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../navigation/main_navigation.dart';

class SecurityPinScreen extends StatefulWidget {
  final bool isConfirming;
  const SecurityPinScreen({super.key, this.isConfirming = false});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  String _pin = "";

  @override
  void initState() {
    super.initState();
    // Fingerprint auto-start waa laga saaray halkan si uusan qofka ugu soo boodin
  }

  Future<void> _authenticate() async {
    bool authenticated = await AppAuthHelper.authenticateWithBiometrics();
    if (authenticated) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() => _pin += number);
    }
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: MaxWidthBox(
            maxWidth: 500,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: context.responsiveValue(mobile: 60.0, tablet: 40.0, desktop: 20.0)),
                  FadeInDown(
                    child: Icon(Icons.lock_outline_rounded, size: 60 * context.fontSizeFactor, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.isConfirming ? "Confirm your PIN" : "Enter Security PIN",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 22 * context.fontSizeFactor),
                  ),
                  const SizedBox(height: 12),
                  Text("To keep your money safe", style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                  const SizedBox(height: 60),
                  
                  // PIN Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      bool isFilled = index < _pin.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        height: 20 * context.fontSizeFactor, width: 20 * context.fontSizeFactor,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? AppColors.accentTeal : theme.colorScheme.surface,
                          border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2)),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  if (!widget.isConfirming)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: TextButton.icon(
                        onPressed: _authenticate, // Hadda halkan ayuu ka bilaabanayaa marka la taabto
                        icon: Icon(Icons.fingerprint_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
                        label: Text("Use FaceID / Fingerprint", style: TextStyle(color: AppColors.accentTeal, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 20),
                  
                  _buildKeyboard(context, theme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveValue(mobile: 40.0, tablet: 80.0, desktop: 40.0)),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "DEL"].map((val) {
            if (val == "") return const SizedBox();
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (val == "DEL") {
                    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
                  } else {
                    _onNumberPressed(val);
                  }
                },
                child: Center(
                  child: val == "DEL" 
                    ? Icon(Icons.backspace_outlined, color: theme.textTheme.bodyLarge?.color, size: 24 * context.fontSizeFactor)
                    : Text(val, style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

