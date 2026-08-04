import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/step_indicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/bank_account.dart';
import 'review_screen.dart';

class SenderBankScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String payoutMethod;
  final String currencyCode;
  final String purpose;

  const SenderBankScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.currencyCode,
    required this.purpose,
  });

  @override
  State<SenderBankScreen> createState() => _SenderBankScreenState();
}

class _SenderBankScreenState extends State<SenderBankScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final FocusNode _accountFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _bankNameFocus = FocusNode();
  
  String _selectedBank = "IBS Bank";
  String _selectedPurpose = "Family Support";
  String? _resolvedAccountName;
  bool _isVerifying = false;

  final List<String> _purposes = [
    "Family Support",
    "Medical Expenses",
    "Education/Tuition",
    "Business/Investment",
    "Gift/Donation",
    "Purchase of Goods",
    "Other",
  ];
  final List<Map<String, String>> _banks = [
    {"name": "IBS Bank", "image": "assets/images/bank.png"},
    {"name": "Premier Bank", "image": "assets/images/bank.png"},
    {"name": "Salaam Bank", "image": "assets/images/bank.png"},
    {"name": "Amal Bank", "image": "assets/images/bank.png"},
    {"name": "Dahabshil Bank", "image": "assets/images/bank.png"},
    {"name": "MyBank", "image": "assets/images/bank.png"},
    {"name": "Amana Bank", "image": "assets/images/bank.png"},
  ];

  @override
  void dispose() {
    _accountController.dispose();
    _nameController.dispose();
    _bankNameController.dispose();
    _accountFocus.dispose();
    _nameFocus.dispose();
    _bankNameFocus.dispose();
    super.dispose();
  }

  void _handleContinue(AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    
    // Save to beneficiaries if verified
    if (_resolvedAccountName != null && _accountController.text.isNotEmpty) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.saveBeneficiary(BankAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bankName: _selectedBank == "Add Bank" ? _bankNameController.text : _selectedBank,
        accountNumber: _accountController.text,
        accountHolder: _resolvedAccountName!,
      ));
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          amount: widget.amount,
          receiverName: _nameController.text.isEmpty ? (_resolvedAccountName ?? widget.receiverName) : _nameController.text,
          receiverPhone: _accountController.text,
          method: widget.payoutMethod,
          paymentMethod: "Bank Transfer",
          currencyCode: widget.currencyCode,
          purpose: _selectedPurpose,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * scale),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.bankTransfer,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * scale, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // --- HEADER BACKGROUND (Step Indicator) ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30 * scale), bottomRight: Radius.circular(30 * scale)),
              ),
              padding: EdgeInsets.only(bottom: 25 * scale, left: 20 * scale, right: 20 * scale),
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: Column(
                    children: [
                      // Amount & Source Display in Header
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_balance_outlined, color: Colors.white70, size: 16 * scale),
                            SizedBox(width: 8 * scale),
                            Text(
                              "${l10n.bankTransfer}: ${widget.currencyCode} ${widget.amount}",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14 * scale),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      Row(
                        children: [
                          StepIndicator(step: 1, label: l10n.stepAmount, isActive: false, isCompleted: true, isHeader: true),
                          StepLine(isCompleted: true, isHeader: true),
                          StepIndicator(step: 2, label: l10n.stepReceiver, isActive: false, isCompleted: true, isHeader: true),
                          StepLine(isCompleted: true, isHeader: true),
                          StepIndicator(step: 3, label: l10n.stepPayment, isActive: true, isCompleted: false, isHeader: true),
                          StepLine(isCompleted: false, isHeader: true),
                          StepIndicator(step: 4, label: l10n.stepReview, isActive: false, isCompleted: false, isHeader: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Padding(
                      padding: EdgeInsets.all(20.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- RECENT BENEFICIARIES ---
                          _buildRecentBeneficiaries(theme, l10n, scale),
                          
                          SizedBox(height: 24 * scale),
                          Text(l10n.selectBank, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)),
                          SizedBox(height: 12 * scale),
                          _buildBankDropdown(theme, l10n, scale),

                          if (_selectedBank == "Add Bank") ...[
                            SizedBox(height: 20 * scale),
                            Text(l10n.bankName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)),
                            SizedBox(height: 12 * scale),
                            _buildTextField(
                              controller: _bankNameController,
                              focusNode: _bankNameFocus,
                              hint: l10n.enterBankName,
                              icon: Icons.account_balance_rounded,
                              type: TextInputType.text,
                              theme: theme,
                              scale: scale,
                            ),
                          ],

                          SizedBox(height: 20 * scale),
                          Text(l10n.accountNumber, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)),
                          SizedBox(height: 12 * scale),
                          _buildTextField(
                            controller: _accountController,
                            focusNode: _accountFocus,
                            hint: l10n.accountNumber,
                            icon: Icons.account_balance_wallet_rounded,
                            type: TextInputType.number,
                            theme: theme,
                            scale: scale,
                            onChanged: (val) async {
                              if (val.length >= 8) {
                                setState(() {
                                  _isVerifying = true;
                                  _resolvedAccountName = null;
                                });
                                final name = await Provider.of<AppState>(context, listen: false).resolveAccountName(val, type: 'bank');
                                if (mounted) {
                                  setState(() {
                                    _isVerifying = false;
                                    _resolvedAccountName = name;
                                    if (name != null) {
                                      _nameController.text = name;
                                      HapticFeedback.lightImpact();
                                    }
                                  });
                                }
                              } else {
                                setState(() {
                                  _resolvedAccountName = null;
                                  _isVerifying = false;
                                });
                              }
                            },
                          ),

                          if (_isVerifying)
                            Padding(
                              padding: EdgeInsets.only(top: 8 * scale, left: 16 * scale),
                              child: Row(
                                children: [
                                  SizedBox(width: 12 * scale, height: 12 * scale, child: const CircularProgressIndicator(strokeWidth: 2)),
                                  SizedBox(width: 8 * scale),
                                  Text(l10n.verifyingAccount, style: TextStyle(fontSize: 12 * scale, color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),

                          if (_resolvedAccountName != null)
                            Padding(
                              padding: EdgeInsets.only(top: 8 * scale, left: 16 * scale),
                              child: FadeIn(
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 14 * scale),
                                    SizedBox(width: 4 * scale),
                                    Text(_resolvedAccountName!, style: TextStyle(fontSize: 12 * scale, color: Colors.green, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),

                          SizedBox(height: 20 * scale),
                          Text(l10n.accountName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)),
                          SizedBox(height: 12 * scale),
                          _buildTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            hint: l10n.accountName,
                            icon: Icons.person_rounded,
                            type: TextInputType.name,
                            theme: theme,
                            scale: scale,
                          ),

                          SizedBox(height: 20 * scale),
                          Text(l10n.purposeOfRemittance, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)),
                          SizedBox(height: 12 * scale),
                          _buildPurposeDropdown(theme, scale),

                          // Delivery Info Tag
                          SizedBox(height: 24 * scale),
                          Container(
                            padding: EdgeInsets.all(16 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bolt_rounded, color: AppColors.accentTeal, size: 20 * scale),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Instant Transfer",
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * scale, color: AppColors.accentTeal),
                                      ),
                                      Text(
                                        "Funds will arrive at the destination account instantly.",
                                        style: TextStyle(fontSize: 12 * scale, color: AppColors.accentTeal.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32 * scale),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 56 * scale,
                            child: ElevatedButton(
                              onPressed: (_accountController.text.isNotEmpty && _nameController.text.isNotEmpty && (_selectedBank != "Add Bank" || _bankNameController.text.isNotEmpty))
                                  ? () => _handleContinue(l10n) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
                                elevation: 4,
                                shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  l10n.confirmPaymentAmount(NumberFormat.simpleCurrency(name: widget.currencyCode).format(Provider.of<AppState>(context, listen: false).calculateTotalForSource(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0, "Bank Transfer"))),
                                  style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30 * scale),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    required double scale,
    void Function(String)? onChanged,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        bool hasFocus = focusNode.hasFocus;
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24 * scale),
            border: Border.all(
              color: hasFocus ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: hasFocus ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10 * scale)] : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: type,
            onChanged: (v) {
              if (v.isNotEmpty) HapticFeedback.selectionClick();
              if (onChanged != null) onChanged(v);
              setState(() {});
            },
            style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: theme.colorScheme.secondary, size: 24 * scale),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16 * scale),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankDropdown(ThemeData theme, AppLocalizations l10n, double scale) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedBank,
        dropdownColor: theme.colorScheme.surface,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w900, fontSize: 16 * scale),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_balance_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 16 * scale),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
        items: [
          ..._banks.map((bank) => DropdownMenuItem(
            value: bank["name"],
            child: Text(bank["name"]!),
          )),
          DropdownMenuItem(
            value: "Add Bank",
            child: Text(l10n.addBank),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedBank = value;
              // Reset verification if bank changes
              _resolvedAccountName = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildPurposeDropdown(ThemeData theme, double scale) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedPurpose,
        dropdownColor: theme.colorScheme.surface,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w900, fontSize: 16 * scale),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.info_outline_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 16 * scale),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
        items: _purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) => setState(() => _selectedPurpose = v!),
      ),
    );
  }

  Widget _buildRecentBeneficiaries(ThemeData theme, AppLocalizations l10n, double scale) {
    final state = Provider.of<AppState>(context);
    if (state.savedBeneficiaries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentTransfers,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * scale, color: AppColors.grey),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100 * scale,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.savedBeneficiaries.length,
            itemBuilder: (context, index) {
              final b = state.savedBeneficiaries[index];
              return FadeInRight(
                delay: Duration(milliseconds: index * 100),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedBank = b.bankName;
                      _accountController.text = b.accountNumber;
                      _nameController.text = b.accountHolder ?? "";
                      _resolvedAccountName = b.accountHolder;
                    });
                  },
                  child: Container(
                    width: 80 * scale,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28 * scale,
                          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          child: Text(
                            (b.accountHolder ?? "U").substring(0, 1).toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary, fontSize: 18 * scale),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.accountHolder ?? "User",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11 * scale, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          b.bankName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(fontSize: 9 * scale, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
