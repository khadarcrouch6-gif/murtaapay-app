import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../app_colors.dart';
import '../app_state.dart';
import '../responsive_utils.dart';

class PinEntryDialog extends StatefulWidget {
  final String title;
  final String description;
  final String? confirmationTitle;
  final String? confirmationDescription;
  final Function(String) onConfirm;

  final Future<bool> Function(String)? onValidate;
  final bool isCardPin;
  final String? cardId;
  final bool isBiometricEnabled;
  final VoidCallback? onBiometricAuth;
  final bool isSetup;

  const PinEntryDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmationTitle,
    this.confirmationDescription,
    required this.onConfirm,
    this.onValidate,
    this.isCardPin = false,
    this.cardId,
    this.isBiometricEnabled = false,
    this.onBiometricAuth,
    this.isSetup = false,
  });

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LocalAuthentication _auth = LocalAuthentication();
  bool _biometricsAvailable = false;
  AnimationController? _shakeController;
  String? _firstPin;
  bool _isConfirming = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    // Auto-focus on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    if (kIsWeb) {
      if (mounted) {
        setState(() => _biometricsAvailable = false);
      }
      return;
    }
    try {
      final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!mounted) {
        return;
      }
      
      setState(() => _biometricsAvailable = canCheck);
      
      // Automatically trigger biometrics if available and enabled
      final state = Provider.of<AppState>(context, listen: false);
      final isEnabled = widget.isBiometricEnabled || (widget.isCardPin ? state.cardBiometricEnabled : state.biometricEnabled);
      if (canCheck && isEnabled && !widget.isSetup) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _authenticateBiometrically();
          }
        });
      }
    } on PlatformException catch (e) {
      debugPrint("Biometric check failed: ${e.code} - ${e.message}");
      if (mounted) {
        setState(() => _biometricsAvailable = false);
      }
    } catch (e) {
      debugPrint("Error checking biometrics: $e");
      if (mounted) {
        setState(() => _biometricsAvailable = false);
      }
    }
  }

  Future<void> _authenticateBiometrically() async {
    if (kIsWeb) {
      return;
    }
    if (widget.onBiometricAuth != null) {
      widget.onBiometricAuth!();
      return;
    }

    final state = Provider.of<AppState>(context, listen: false);
    final isEnabled = widget.isBiometricEnabled || (widget.isCardPin ? state.cardBiometricEnabled : state.biometricEnabled);
    if (!isEnabled) {
      return;
    }

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: widget.description.isEmpty ? widget.title : widget.description,
      );
      
      if (authenticated && mounted) {
        HapticFeedback.mediumImpact();
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }
        widget.onConfirm("BIOMETRIC_SUCCESS");
      }
    } on PlatformException catch (e) {
      debugPrint("Biometric auth error: ${e.code} - ${e.message}");
      if (e.code == 'NotAvailable') {
        _handleError("Biometrics not available or permissions denied.");
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        _handleError("Biometrics locked. Please use your PIN.");
      } else {
        _handleError("Biometric authentication failed.");
      }
    } catch (e) {
      _handleError("Biometric authentication error occurred.");
    }
  }

  void shake() {
    _shakeController?.forward(from: 0);
    HapticFeedback.vibrate();
  }

  void _handleError(String message) {
    shake();
    setState(() {
      _errorMessage = message;
      _pinController.clear();
    });
    // Clear error after some time or on next input
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEnabled = widget.isBiometricEnabled || (widget.isCardPin ? state.cardBiometricEnabled : state.biometricEnabled);
    final showBiometrics = _biometricsAvailable && isEnabled;
    final scale = context.fontSizeFactor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ZoomIn(
        duration: const Duration(milliseconds: 300),
        child: MaxWidthBox(
          maxWidth: 450,
          child: Container(
            padding: EdgeInsets.all(28 * scale),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(32 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30 * scale,
                  offset: Offset(0, 10 * scale),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pull Handle Indicator
                Container(
                  width: 40 * scale,
                  height: 4 * scale,
                  margin: EdgeInsets.only(bottom: 24 * scale),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  _isConfirming ? (widget.confirmationTitle ?? widget.title) : widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * scale, letterSpacing: -0.5 * scale),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  _isConfirming ? (widget.confirmationDescription ?? widget.description) : widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey, fontSize: 14 * scale, height: 1.4),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 8 * scale),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent, fontSize: 13 * scale, fontWeight: FontWeight.bold),
                  ),
                ],
                SizedBox(height: 32 * scale),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _pinController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        autofocus: true,
                        onChanged: (value) async {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _errorMessage = null;
                          });
                          if (value.length == 4) {
                            HapticFeedback.mediumImpact();
                            final navigator = Navigator.of(context);
                            
                            // Handle validation if provided
                            if (widget.onValidate != null && !widget.isSetup) {
                              final isValid = await widget.onValidate!(value);
                              if (!isValid) {
                                _handleError(l10n.incorrectPin);
                                return;
                              }
                            }

                            if (widget.isSetup) {
                              if (!_isConfirming) {
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  if (mounted) {
                                    setState(() {
                                      _firstPin = value;
                                      _isConfirming = true;
                                    });
                                    _pinController.clear();
                                  }
                                });
                              } else {
                                if (value == _firstPin) {
                                  Future.delayed(const Duration(milliseconds: 200), () {
                                    if (mounted) {
                                      if (navigator.canPop()) {
                                        navigator.pop();
                                      }
                                      widget.onConfirm(value);
                                    }
                                  });
                                } else {
                                  _handleError(l10n.pinsDoNotMatch);
                                }
                              }
                            } else {
                            Future.delayed(const Duration(milliseconds: 200), () {
                              if (mounted) {
                                if (navigator.canPop()) {
                                  navigator.pop();
                                }
                                widget.onConfirm(value);
                              }
                            });
                            }
                          }
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _focusNode.requestFocus();
                        SystemChannels.textInput.invokeMethod('TextInput.show');
                      },
                      child: ShakeX(
                        manualTrigger: true,
                        controller: (c) => _shakeController = c,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            bool isFilled = _pinController.text.length > index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 54 * scale,
                              height: 64 * scale,
                              margin: EdgeInsets.symmetric(horizontal: 8 * scale),
                              decoration: BoxDecoration(
                                color: isFilled ? theme.colorScheme.primary.withValues(alpha: 0.08) : theme.cardColor,
                                borderRadius: BorderRadius.circular(16 * scale),
                                border: Border.all(
                                  color: isFilled ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.1),
                                  width: 2 * scale,
                                ),
                                boxShadow: isFilled ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    blurRadius: 10 * scale,
                                    spreadRadius: -2 * scale,
                                  )
                                ] : [],
                              ),
                              child: Center(
                                child: isFilled
                                    ? ZoomIn(
                                        duration: const Duration(milliseconds: 200),
                                        child: Container(
                                          width: 14 * scale,
                                          height: 14 * scale,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showBiometrics) ...[
                  SizedBox(height: 24 * scale),
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.dividerColor.withValues(alpha: 0.1))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                        child: Text(
                          l10n.orUseBiometrics,
                          style: TextStyle(color: AppColors.grey, fontSize: 12 * scale, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: Divider(color: theme.dividerColor.withValues(alpha: 0.1))),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  GestureDetector(
                    onTap: _authenticateBiometrically,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          showBiometrics ? Icons.fingerprint_rounded : Icons.lock_outline_rounded,
                          size: 42 * scale,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 24 * scale),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  style: context.textButtonStyle(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
