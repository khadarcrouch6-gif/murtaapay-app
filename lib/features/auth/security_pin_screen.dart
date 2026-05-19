import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_auth_helper.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
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
  bool _isError = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _authenticate() async {
    bool authenticated = await AppAuthHelper.authenticateWithBiometrics();
    if (authenticated) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
        (route) => false,
      );
    }
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
        _isError = false;
      });
    }
    
    if (_pin.length == 4) {
      final state = Provider.of<AppState>(context, listen: false);
      if (state.verifyPin(_pin)) {
        HapticFeedback.mediumImpact();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        });
      } else {
        HapticFeedback.vibrate();
        setState(() {
          _pin = "";
          _isError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.translate("PIN-kaagu waa khalad. Fadlan isku day markale.", "Incorrect PIN. Please try again.")),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
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
                    widget.isConfirming 
                      ? l10n.confirmYourPin 
                      : l10n.enterSecurityPin,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 22 * context.fontSizeFactor),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.toKeepYourMoneySafe, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                  const SizedBox(height: 60),
                  
                  // PIN Dots
                  ShakeX(
                    animate: _isError,
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        bool isFilled = index < _pin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          height: 20 * context.fontSizeFactor, width: 20 * context.fontSizeFactor,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled 
                              ? (_isError ? Colors.redAccent : AppColors.accentTeal) 
                              : theme.colorScheme.surface,
                            border: Border.all(
                              color: _isError 
                                ? Colors.redAccent.withValues(alpha: 0.2) 
                                : AppColors.accentTeal.withValues(alpha: 0.2)
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  if (!widget.isConfirming)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        height: 48 * context.fontSizeFactor,
                        child: TextButton.icon(
                          onPressed: _authenticate,
                          icon: Icon(Icons.fingerprint_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
                          label: Text(l10n.useFaceIdFingerprint, style: TextStyle(color: AppColors.accentTeal, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 300 * context.fontSizeFactor,
                      maxHeight: 400 * context.fontSizeFactor,
                    ),
                    child: _buildKeyboard(context, theme),
                  ),
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

