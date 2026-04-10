import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'review_screen.dart';

class SenderBankScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String payoutMethod;
  final String currencyCode;

  const SenderBankScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.currencyCode,
  });

  @override
  State<SenderBankScreen> createState() => _SenderBankScreenState();
}

class _SenderBankScreenState extends State<SenderBankScreen> {
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
          receiverName: widget.receiverName,
          receiverPhone: widget.receiverPhone,
          method: widget.payoutMethod,
          paymentMethod: "Bank Transfer ($_selectedBank - ${_nameController.text})",
          currencyCode: widget.currencyCode,
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
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bank Transfer (Sender)",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
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
                  color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                padding: const EdgeInsets.only(bottom: 20),
                child: const Center(
                   child: Text("Provide your bank details to send money", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
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
                        Text(l10n.selectBank, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 12),
                        
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
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.secondary),
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
                          hint: "Your Account Number",
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
                          hint: "Your Full Name as per Bank",
                          icon: Icons.person_rounded,
                          type: TextInputType.name,
                          theme: theme,
                        ),

                        const SizedBox(height: 40),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_accountController.text.isNotEmpty && _nameController.text.isNotEmpty) 
                                ? () => _handleContinue(l10n) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                            ),
                            child: Text(
                              l10n.continueToReview,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
              color: hasFocus ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: hasFocus ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10)] : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: type,
            onChanged: (v) => setState(() {}),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: theme.colorScheme.secondary, size: 24),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
    );
  }
}
