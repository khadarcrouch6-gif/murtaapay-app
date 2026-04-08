import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'review_screen.dart';

class BankScreen extends StatefulWidget {
  final String amount;
  final String method;
  const BankScreen({super.key, required this.amount, required this.method});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _accountFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  
  String _selectedBank = "IBS Bank";
  final List<String> _banks = ["IBS Bank", "Premier Bank", "Salaam Bank", "Amal Bank", "Dahabshil Bank"];

  @override
  void dispose() {
    _accountController.dispose();
    _nameController.dispose();
    _accountFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _handleContinue(AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          amount: widget.amount,
          receiverName: _nameController.text,
          receiverPhone: _accountController.text, // Using as account number
          method: "${widget.method} ($_selectedBank)",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : AppColors.accentTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Bank Details",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- HEADER BACKGROUND ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark ? AppColors.primaryDark : AppColors.accentTeal,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          _buildStepIndicator(1, "Amount", false, true, isHeader: true),
                          _buildStepLine(true, isHeader: true),
                          _buildStepIndicator(2, "Bank", true, false, isHeader: true),
                          _buildStepLine(false, isHeader: true),
                          _buildStepIndicator(3, "Review", false, false, isHeader: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text("Select Bank", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 12),
                        
                        // Bank Dropdown/Picker
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedBank,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.accentTeal),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: theme.textTheme.bodyLarge?.color),
                              onChanged: (String? newValue) {
                                if (newValue != null) setState(() => _selectedBank = newValue);
                              },
                              items: _banks.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text("Account Number", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _accountController,
                          focusNode: _accountFocus,
                          hint: "Enter Account Number",
                          icon: Icons.account_balance_wallet_rounded,
                          type: TextInputType.number,
                          theme: theme,
                        ),

                        const SizedBox(height: 20),
                        const Text("Account Name", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          hint: "Enter Full Name",
                          icon: Icons.person_rounded,
                          type: TextInputType.name,
                          theme: theme,
                        ),

                        const SizedBox(height: 40),
                        
                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_accountController.text.isNotEmpty && _nameController.text.isNotEmpty) 
                                ? () => _handleContinue(l10n) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: AppColors.accentTeal.withValues(alpha: 0.3),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: const Text(
                              "Continue to Review",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required TextInputType type,
    required ThemeData theme,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        bool hasFocus = focusNode.hasFocus;
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasFocus ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: hasFocus ? [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.08), blurRadius: 10)] : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: type,
            onChanged: (v) => setState(() {}),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 24),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    Color activeColor = isHeader ? Colors.white : AppColors.accentTeal;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!;
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? AppColors.accentTeal : Colors.grey);

    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 4) : null
          ),
          child: Center(child: isCompleted && !isActive ? Icon(Icons.check, color: isHeader ? AppColors.accentTeal : Colors.white, size: 18) : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? AppColors.accentTeal : Colors.white) : Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted, {bool isHeader = false}) { 
    Color color = isHeader 
      ? (isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.3)) 
      : (isCompleted ? AppColors.accentTeal : Colors.grey[200]!);
    return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)))); 
  }
}
