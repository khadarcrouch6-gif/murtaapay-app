import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _savePin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pop(context); // close loading
        _showSuccessDialog();
      });
    }
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: AppColors.accentTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Success!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.pinChangedSuccess,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // return to profile
                },
                style: context.elevatedButtonStyle(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  l10n.done,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.changePin, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.createNewPin,
                style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.newPinDescription,
                style: TextStyle(fontSize: 14 * context.fontSizeFactor, color: AppColors.grey),
              ),
              SizedBox(height: 32 * context.fontSizeFactor),
              
              _buildPinField(
                context: context,
                label: l10n.currentPin,
                controller: _oldPinController,
                obscureText: _obscureOld,
                onToggleVisibility: () => setState(() => _obscureOld = !_obscureOld),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterCurrentPin;
                  }
                  if (value.length < 4) {
                    return l10n.pinMustBe4Digits;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20 * context.fontSizeFactor),
              
              _buildPinField(
                context: context,
                label: l10n.newPin,
                controller: _newPinController,
                obscureText: _obscureNew,
                onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterNewPin;
                  }
                  if (value.length < 4) {
                    return l10n.pinMustBe4Digits;
                  }
                  if (value == _oldPinController.text) {
                    return l10n.cannotBeSameAsOld;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20 * context.fontSizeFactor),
              
              _buildPinField(
                context: context,
                label: l10n.confirmNewPin,
                controller: _confirmPinController,
                obscureText: _obscureConfirm,
                onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseConfirmNewPin;
                  }
                  if (value != _newPinController.text) {
                    return l10n.pinsDoNotMatch;
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 48 * context.fontSizeFactor),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePin,
                  style: context.elevatedButtonStyle(
                    backgroundColor: AppColors.accentTeal,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    l10n.saveChanges,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.number,
          maxLength: 4,
          validator: validator,
          style: TextStyle(fontSize: 16 * context.fontSizeFactor),
          decoration: InputDecoration(
            counterText: "",
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.accentTeal),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.grey,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
              borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }
}


