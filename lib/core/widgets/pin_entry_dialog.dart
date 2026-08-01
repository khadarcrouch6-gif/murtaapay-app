import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../app_colors.dart';
import '../app_state.dart';
import '../responsive_utils.dart';

class PinEntryDialog extends StatefulWidget {
  final String title;
  final String description;
  final Function(String) onConfirm;
  final bool isCardPin;
  final String? cardId;

  const PinEntryDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onConfirm,
    this.isCardPin = false,
    this.cardId,
  });

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final TextEditingController _pinController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isObscured = true;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    if (mounted) {
      setState(() => _biometricsAvailable = canCheck);
    }
  }

  Future<void> _authenticateBiometrically() async {
    final state = AppState();
    if (!state.biometricEnabled) return;
    
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: widget.description,
        biometricOnly: true,
      );
      if (authenticated && mounted) {
        String pinToConfirm = "";
        
        if (widget.isCardPin) {
          pinToConfirm = "1122";
        } else {
          pinToConfirm = "1234";
        }
        
        Navigator.pop(context);
        widget.onConfirm(pinToConfirm);
      }
    } catch (e) {
      debugPrint("Biometric error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();
    final showBiometrics = _biometricsAvailable && state.biometricEnabled;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: _isObscured,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: "",
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  Navigator.pop(context);
                  widget.onConfirm(value);
                }
              },
            ),
            if (showBiometrics) ...[
              const SizedBox(height: 16),
              Text(
                state.translate("Or use Biometrics", "Ama u isticmaal Biometrics", ar: "أو استخدم المقاييس الحيوية"),
                style: TextStyle(color: AppColors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: _authenticateBiometrically,
                icon: const Icon(Icons.fingerprint_rounded, size: 48, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              state.translate("Cancel", "Ka laabo", ar: "إلغاء"),
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
