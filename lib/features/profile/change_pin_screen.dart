import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';

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
              AppState().translate("Your Transaction PIN has been changed successfully.", "PIN-kaaga macaamilka si guul leh ayaa loo beddelay.", ar: "تم تغيير رقم PIN الخاص بالمعاملات بنجاح.", de: "Ihre Transaktions-PIN wurde erfolgreich geändert."),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  AppState().translate("Done", "Dhameeyay", ar: "تم", de: "Fertig"),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppState().translate("Change PIN", "Beddel PIN-ka", ar: "تغيير رقم PIN", de: "PIN ändern"), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppState().translate("Create New PIN", "Abuur PIN Cusub", ar: "إنشاء رقم PIN جديد", de: "Neue PIN erstellen"),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppState().translate("Your new PIN must be 4 digits and different from your previous PIN.", "PIN-kaaga cusub waa inuu ahaadaa 4 god oo ka duwan kii hore.", ar: "يجب أن يتكون رقم PIN الجديد الخاص بك من 4 أرقام ومختلفاً عن رقم PIN السابق.", de: "Ihre neue PIN muss 4-stellig sein und sich von Ihrer vorherigen PIN unterscheiden."),
                style: const TextStyle(fontSize: 14, color: AppColors.grey),
              ),
              const SizedBox(height: 32),
              
              _buildPinField(
                label: AppState().translate("Current PIN", "PIN-ka Hadda", ar: "رقم PIN الحالي", de: "Aktuelle PIN"),
                controller: _oldPinController,
                obscureText: _obscureOld,
                onToggleVisibility: () => setState(() => _obscureOld = !_obscureOld),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppState().translate("Please enter your current PIN", "Fadlan geli PIN-kaagii hore", ar: "يرجى إدخال رقم PIN الحالي", de: "Bitte geben Sie Ihre aktuelle PIN ein");
                  }
                  if (value.length < 4) {
                    return AppState().translate("PIN must be 4 digits", "PIN-ku waa inuu ahaadaa 4 god", ar: "يجب أن يتكون رقم PIN من 4 أرقام", de: "PIN muss 4 Stellen haben");
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              _buildPinField(
                label: AppState().translate("New PIN", "PIN Cusub", ar: "رقم PIN الجديد", de: "Neue PIN"),
                controller: _newPinController,
                obscureText: _obscureNew,
                onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppState().translate("Please enter new PIN", "Fadlan geli PIN cusub", ar: "يرجى إدخال رقم PIN الجديد", de: "Bitte geben Sie eine neue PIN ein");
                  }
                  if (value.length < 4) {
                    return AppState().translate("PIN must be 4 digits", "PIN-ku waa inuu ahaadaa 4 god", ar: "يجب أن يتكون رقم PIN من 4 أرقام", de: "PIN muss 4 Stellen haben");
                  }
                  if (value == _oldPinController.text) {
                    return AppState().translate("Cannot be the same as old", "Kama mid noqon karo kii hore", ar: "لا يمكن أن يكون هو نفسه القديم", de: "Darf nicht mit der alten PIN identisch sein");
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              _buildPinField(
                label: AppState().translate("Confirm New PIN", "Xaqiiji PIN-ka Cusub", ar: "تأكيد رقم PIN الجديد", de: "Neue PIN bestätigen"),
                controller: _confirmPinController,
                obscureText: _obscureConfirm,
                onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppState().translate("Please confirm new PIN", "Fadlan xaqiiji PIN-ka cusub", ar: "يرجى تأكيد رقم PIN الجديد", de: "Bitte bestätigen Sie die neue PIN");
                  }
                  if (value != _newPinController.text) {
                    return AppState().translate("PINs do not match", "PIN-yadu isma le'eka", ar: "أرقام PIN غير متطابقة", de: "PINs stimmen nicht überein");
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    AppState().translate("Save Changes", "Kaydi Isbeddelka", ar: "حفظ التغييرات", de: "Änderungen speichern"),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.number,
          maxLength: 4,
          validator: validator,
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
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

