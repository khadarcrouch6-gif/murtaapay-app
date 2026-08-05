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
  String? _resolvedAccountName;
  bool _isVerifying = false;
  bool _shouldSaveBank = true;
  bool _isBankLinked = false;

  final List<Map<String, dynamic>> _banks = [
    {"name": "IBS Bank", "image": "assets/images/bank.png", "length": 8},
    {"name": "Premier Bank", "image": "assets/images/bank.png", "length": 12},
    {"name": "Salaam Bank", "image": "assets/images/bank.png", "length": 10},
    {"name": "Amal Bank", "image": "assets/images/bank.png", "length": 10},
    {"name": "Dahabshil Bank", "image": "assets/images/bank.png", "length": 9},
    {"name": "MyBank", "image": "assets/images/bank.png", "length": 10},
    {"name": "Amana Bank", "image": "assets/images/bank.png", "length": 10},
    {"name": "LHV Pank", "image": "assets/images/bank.png", "length": 8},
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

  Future<void> _linkBankAccount() async {
    final String accountNumber = _accountController.text.trim();
    int? requiredLength;
    bool lengthValid = false;

    if (_selectedBank == "Add Bank") {
      lengthValid = accountNumber.length >= 8;
    } else {
      final selectedBankData = _banks.firstWhere((b) => b["name"] == _selectedBank, orElse: () => _banks.first);
      requiredLength = selectedBankData["length"];
      lengthValid = accountNumber.length == requiredLength;
    }

    if (!lengthValid) {
      if (_selectedBank == "Add Bank") {
        _showErrorSnackBar("Please enter a valid account number (min 8 digits)");
      } else {
        _showErrorSnackBar("Invalid length: $_selectedBank accounts must be exactly $requiredLength digits.");
      }
      return;
    }
    
    setState(() => _isVerifying = true);
    HapticFeedback.mediumImpact();
    
    // Simulate Secure OAuth Connection to Bank API
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Inquiry from AppState (Mocking Database)
    final String? verifiedName = await appState.resolveAccountName(
      accountNumber, 
      type: 'bank', 
      bankName: _selectedBank == "Add Bank" ? _bankNameController.text : _selectedBank
    );
    
    if (mounted) {
      if (verifiedName != null) {
        setState(() {
          _isVerifying = false;
          _isBankLinked = true;
          _resolvedAccountName = verifiedName;
          _nameController.text = verifiedName;
        });
        HapticFeedback.heavyImpact();
        _showLinkingSuccess(verifiedName);
      } else {
        setState(() => _isVerifying = false);
        _showErrorSnackBar("Account verification failed. No matching record found for this bank.");
      }
    }
  }

  void _showLinkingSuccess(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text("Account Ownership Verified: $name")),
          ],
        ),
        backgroundColor: AppColors.accentTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _handleContinue(AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    final appState = Provider.of<AppState>(context, listen: false);
    
    final bankName = _selectedBank == "Add Bank" ? _bankNameController.text : _selectedBank;
    final accountNumber = _accountController.text;
    final accountHolder = _nameController.text;

    if (!_isBankLinked) {
      _showErrorSnackBar("Please verify and link your bank account first.");
      return;
    }

    // Save to Sender's Banks if toggle is on
    if (_shouldSaveBank) {
      final alreadyExists = appState.linkedBanks.any((b) => b.accountNumber == accountNumber && b.bankName == bankName);
      if (!alreadyExists) {
        appState.addBank(BankAccount(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bankName: bankName,
          accountNumber: accountNumber,
          accountHolder: accountHolder,
        ));
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          amount: widget.amount,
          receiverName: widget.receiverName,
          receiverPhone: widget.receiverPhone,
          method: widget.payoutMethod,
          paymentMethod: "Bank Transfer",
          currencyCode: widget.currencyCode,
          purpose: widget.purpose,
          sourceOfFunds: "$bankName ($accountNumber)",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    final appState = Provider.of<AppState>(context);

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
                          _buildSenderBanks(theme, l10n, scale),
                          
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
                            hint: "Enter Account Number",
                            icon: Icons.account_balance_wallet_rounded,
                            type: TextInputType.number,
                            theme: theme,
                            scale: scale,
                            onChanged: (val) {
                              if (_isBankLinked) {
                                setState(() {
                                  _isBankLinked = false;
                                  _resolvedAccountName = null;
                                  _nameController.clear();
                                });
                              }
                            },
                            suffixIcon: _isBankLinked 
                                ? Icon(Icons.verified_rounded, color: AppColors.accentTeal, size: 22 * scale)
                                : null,
                          ),

                          if (!_isBankLinked) ...[
                            SizedBox(height: 16 * scale),
                            FadeInUp(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52 * scale,
                                    child: OutlinedButton.icon(
                                      onPressed: _isVerifying ? null : _linkBankAccount,
                                      icon: _isVerifying 
                                          ? SizedBox(width: 18 * scale, height: 18 * scale, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.secondary))
                                          : Icon(Icons.link_rounded, size: 20 * scale),
                                      label: Text(
                                        _isVerifying ? "Verifying Ownership..." : "Verify & Link Account",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * scale),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 12 * scale),
                                        side: BorderSide(color: theme.colorScheme.secondary, width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12 * scale),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.security_rounded, size: 14 * scale, color: AppColors.accentTeal),
                                      SizedBox(width: 8 * scale),
                                      Text(
                                        "Secure OAuth verification via MurtaaxShield",
                                        style: TextStyle(fontSize: 11 * scale, color: AppColors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (_isBankLinked) ...[
                            SizedBox(height: 20 * scale),
                            Text(l10n.accountName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)),
                            SizedBox(height: 12 * scale),
                            FadeInDown(
                              child: _buildTextField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                hint: l10n.accountName,
                                icon: Icons.person_rounded,
                                type: TextInputType.name,
                                theme: theme,
                                scale: scale,
                                enabled: false,
                              ),
                            ),
                          ],

                          SizedBox(height: 20 * scale),
                          Row(
                            children: [
                              SizedBox(
                                height: 24 * scale,
                                width: 24 * scale,
                                child: Checkbox(
                                  value: _shouldSaveBank,
                                  onChanged: (v) => setState(() => _shouldSaveBank = v ?? false),
                                  activeColor: theme.colorScheme.secondary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6 * scale)),
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              GestureDetector(
                                onTap: () => setState(() => _shouldSaveBank = !_shouldSaveBank),
                                child: Text(
                                  appState.translate("Save this bank for future use", "Kaydi bangigan si aad mar kale u isticmaasho"),
                                  style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold, color: AppColors.grey),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24 * scale),
                          Container(
                            padding: EdgeInsets.all(16 * scale),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded, color: Colors.orange, size: 20 * scale),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appState.translate("Bank Processing Time", "Xilliga Shaqada Bangiga"),
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * scale, color: Colors.orange[800]),
                                      ),
                                      Text(
                                        appState.translate(
                                          "Bank transfers are processed within 24 hours. Please ensure details are correct.",
                                          "Xawaaladaha bangiga waxaa lagu farsameeyaa 24 saac gudahood. Fadlan hubi in xogtu sax tahay."
                                        ),
                                        style: TextStyle(fontSize: 12 * scale, color: Colors.orange[900]?.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
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
                              onPressed: (_isBankLinked && (_selectedBank != "Add Bank" || _bankNameController.text.isNotEmpty))
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
                                  l10n.confirmPaymentAmount(NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.calculateTotalForSource(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0, "Bank Transfer"))),
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
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        bool hasFocus = focusNode.hasFocus;
        return Container(
          decoration: BoxDecoration(
            color: enabled ? theme.colorScheme.surface : theme.dividerColor.withValues(alpha: 0.05),
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
            enabled: enabled,
            onChanged: (v) {
              if (v.isNotEmpty) HapticFeedback.selectionClick();
              if (onChanged != null) onChanged(v);
              setState(() {});
            },
            style: TextStyle(
              fontSize: 18 * scale, 
              fontWeight: FontWeight.w900,
              color: enabled ? null : AppColors.grey,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: enabled ? theme.colorScheme.secondary : AppColors.grey, size: 24 * scale),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16 * scale, horizontal: suffixIcon != null ? 0 : 16 * scale),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankDropdown(ThemeData theme, AppLocalizations l10n, double scale) {
    final state = Provider.of<AppState>(context, listen: false);
    
    // Collect all unique bank names from supported list and linked banks
    final Set<String> allBankNames = {
      ..._banks.map((bank) => bank["name"]!),
      ...state.linkedBanks.map((bank) => bank.bankName),
    };
    
    // Ensure the current selection is in the set (unless it's "Add Bank" which we add at the end)
    if (_selectedBank != "Add Bank") {
      allBankNames.add(_selectedBank);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
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
          ...allBankNames.map((name) => DropdownMenuItem(
            value: name, 
            child: Text(name, overflow: TextOverflow.ellipsis),
          )),
          DropdownMenuItem(value: "Add Bank", child: Text(l10n.addBank)),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedBank = value;
              
              // If selecting an existing linked bank from dropdown, auto-fill details
              final linkedBank = state.linkedBanks.where((b) => b.bankName == value).firstOrNull;
              if (linkedBank != null) {
                _accountController.text = linkedBank.accountNumber;
                _nameController.text = linkedBank.accountHolder ?? "";
                _isBankLinked = true;
                _resolvedAccountName = linkedBank.accountHolder;
              } else {
                _isBankLinked = false;
                _resolvedAccountName = null;
                _accountController.clear();
                _nameController.clear();
                
                // Clear validation when bank changes
                _accountFocus.unfocus();
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildSenderBanks(ThemeData theme, AppLocalizations l10n, double scale) {
    final state = Provider.of<AppState>(context);
    if (state.linkedBanks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.translate("Sender's Banks", "Bangiyadaadii Hore"),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * scale, color: AppColors.grey),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100 * scale,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.linkedBanks.length,
            itemBuilder: (context, index) {
              final b = state.linkedBanks[index];
              return FadeInRight(
                delay: Duration(milliseconds: index * 100),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedBank = b.bankName;
                      _accountController.text = b.accountNumber;
                      _nameController.text = b.accountHolder ?? "";
                      _isBankLinked = true;
                      _resolvedAccountName = b.accountHolder;
                    });
                  },
                  child: Container(
                    width: 90 * scale,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28 * scale,
                          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          child: Icon(Icons.account_balance_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.bankName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11 * scale, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          b.accountNumber,
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
