import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/models/bank_account.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/step_indicator.dart';
import 'payment_screen.dart';
import 'package:provider/provider.dart';

import '../../core/api_service.dart';

class BankScreen extends StatefulWidget {
  final String amount;
  final String method;
  final String currencyCode;
  final String senderSource;
  final String? prefilledName;
  final String? prefilledAccount;

  const BankScreen({
    super.key, 
    required this.amount, 
    required this.method, 
    required this.currencyCode,
    required this.senderSource,
    this.prefilledName,
    this.prefilledAccount,
  });

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _swiftController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  
  final FocusNode _accountFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _bankNameFocus = FocusNode();
  final FocusNode _swiftFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();
  
  String _selectedBank = "IBS Bank";
  String _selectedSource = "Main Wallet";
  String _selectedPurpose = "Family Support";
  String _selectedFundSource = "Salary";
  
  bool _saveBeneficiary = false;
  bool _isVerifyingName = false;
  bool _isInternational = false;
  String? _verifiedName;
  double? _fxRate;
  bool _isLoadingFx = false;

  final List<String> _purposes = ["Family Support", "Education", "Medical", "Business", "Investment", "Gift", "Other"];
  final List<String> _fundSources = ["Salary", "Savings", "Business Profit", "Sale of Asset", "Gift", "Other"];

  final List<Map<String, String>> _banks = [
    {"name": "IBS Bank", "image": "assets/images/bank.png"},
    {"name": "Premier Bank", "image": "assets/images/bank.png"},
    {"name": "Salaam Bank", "image": "assets/images/bank.png"},
    {"name": "Amal Bank", "image": "assets/images/bank.png"},
    {"name": "Dahabshil Bank", "image": "assets/images/bank.png"},
    {"name": "MyBank", "image": "assets/images/bank.png"},
    {"name": "Amana Bank", "image": "assets/images/bank.png"},
  ];

  final List<Map<String, String>> _recentRecipients = [
    {"name": "Ahmed Ali", "account": "10223499", "bank": "IBS Bank"},
    {"name": "Fartun Omar", "account": "55678902", "bank": "Premier Bank"},
    {"name": "Mohamed Ibrahim", "account": "88902341", "bank": "Salaam Bank"},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.senderSource;
    if (widget.prefilledName != null) _nameController.text = widget.prefilledName!;
    if (widget.prefilledAccount != null) _accountController.text = widget.prefilledAccount!;
    
    _accountController.addListener(_onAccountChanged);
  }

  void _onAccountChanged() {
    String text = _accountController.text;
    if (text.length >= 8 && !_isVerifyingName && _nameController.text.isEmpty) {
      _verifyAccountName();
    }
  }

  Future<void> _verifyAccountName() async {
    setState(() => _isVerifyingName = true);
    
    final bankInfo = _selectedBank == "Add Bank" ? _bankNameController.text : _selectedBank;
    final name = await ApiService.verifyBankAccount(bankInfo, _accountController.text);
    
    if (mounted) {
      setState(() {
        _isVerifyingName = false;
        if (name != null) {
          _verifiedName = name;
          _nameController.text = name;
        }
      });
    }
  }

  Future<void> _fetchFxRate() async {
    if (!_isInternational) return;
    setState(() => _isLoadingFx = true);
    final data = await ApiService.getFxRates();
    if (mounted) {
      setState(() {
        _isLoadingFx = false;
        if (data != null && data.containsKey('rate')) {
          _fxRate = (data['rate'] as num).toDouble();
        }
      });
    }
  }

  double _calculateFee() {
    double amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
    final state = Provider.of<AppState>(context, listen: false);
    // Use the centralized logic with payoutMethod context
    double fee = state.calculateFeeForSource(amountVal, _selectedSource, payoutMethod: "Bank Transfer");
    return fee;
  }

  @override
  void dispose() {
    _accountController.dispose();
    _nameController.dispose();
    _bankNameController.dispose();
    _swiftController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _accountFocus.dispose();
    _nameFocus.dispose();
    _bankNameFocus.dispose();
    _swiftFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  void _handleContinue(AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    final state = Provider.of<AppState>(context, listen: false);
    final amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
    final fee = _calculateFee();
    final total = amountVal + fee;

    // Daily Limit check
    if (total > state.getDailyRemaining()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Daily limit exceeded. Remaining: \$${state.getDailyRemaining().toStringAsFixed(2)}"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Balance check
    double available = 0;
    if (_selectedSource == "Main Wallet") available = state.balance;
    else if (_selectedSource == "Card") available = state.cardBalance;
    else if (_selectedSource == "Savings") available = state.savingsBalance;

    if (total > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Insufficient funds in $_selectedSource"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String bankInfo = _selectedBank == "Add Bank" ? _bankNameController.text : _selectedBank;
    
    // International Validations
    if (_isInternational) {
      final swift = _swiftController.text.trim();
      if (swift.isEmpty || (swift.length != 8 && swift.length != 11)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid 8 or 11 character SWIFT/BIC code"), backgroundColor: Colors.red),
        );
        return;
      }
      
      if (_addressController.text.isEmpty || _cityController.text.isEmpty || _countryController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Full address details are required for international transfers"), backgroundColor: Colors.red),
        );
        return;
      }
    }

    // Final check for receiver name
    final String receiverName = _nameController.text.isNotEmpty ? _nameController.text : (_verifiedName ?? "");

    if (_saveBeneficiary) {
      state.saveBeneficiary(BankAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bankName: bankInfo,
        accountNumber: _accountController.text,
        accountHolder: receiverName,
      ));
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: widget.amount,
          receiverName: receiverName,
          receiverPhone: _accountController.text,
          payoutMethod: "Bank Transfer",
          paymentMethod: _selectedSource,
          currencyCode: widget.currencyCode,
          purpose: _selectedPurpose,
          sourceOfFunds: _selectedFundSource,
          address: _isInternational ? _addressController.text : null,
          city: _isInternational ? _cityController.text : null,
          country: _isInternational ? _countryController.text : null,
          swiftCode: _isInternational ? _swiftController.text : null,
        ),
      ),
    );
  }

  void _showBankPicker(AppLocalizations l10n, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BankPickerSheet(
        banks: _banks,
        onSelect: (bank) {
          setState(() {
            _selectedBank = bank;
            if (bank != "Add Bank") _bankNameController.clear();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context);
    final savedBeneficiaries = state.savedBeneficiaries;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.bankTransfer,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22 * context.fontSizeFactor,
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
              // --- HEADER ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30 * context.fontSizeFactor), bottomRight: Radius.circular(30 * context.fontSizeFactor)),
                ),
                padding: EdgeInsets.only(
                  bottom: 25 * context.fontSizeFactor, 
                  left: 20 * context.fontSizeFactor, 
                  right: 20 * context.fontSizeFactor
                ),
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * context.fontSizeFactor, 
                            vertical: 8 * context.fontSizeFactor
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.senderSource == "Main Wallet" 
                                  ? Icons.account_balance_wallet_outlined 
                                  : Icons.credit_card_outlined, 
                                color: Colors.white70, 
                                size: 16 * context.fontSizeFactor
                              ),
                              SizedBox(width: 8 * context.fontSizeFactor),
                              Text(
                                "${widget.senderSource}: ${widget.currencyCode} ${widget.amount}",
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 14 * context.fontSizeFactor
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20 * context.fontSizeFactor),
                        Row(
                          children: [
                            StepIndicator(step: 1, label: l10n.stepAmount, isActive: false, isCompleted: true, isHeader: true),
                            StepLine(isCompleted: true, isHeader: true),
                            StepIndicator(step: 2, label: l10n.stepReceiver, isActive: true, isCompleted: false, isHeader: true),
                            StepLine(isCompleted: false, isHeader: true),
                            StepIndicator(step: 3, label: l10n.stepPayment, isActive: false, isCompleted: false, isHeader: true),
                            StepLine(isCompleted: false, isHeader: true),
                            StepIndicator(step: 4, label: l10n.stepReview, isActive: false, isCompleted: false, isHeader: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: Padding(
                    padding: EdgeInsets.all(20.0 * context.fontSizeFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- RECENT RECIPIENTS ---
                        Text(
                          l10n.recentTransfers, 
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 16 * context.fontSizeFactor, 
                            color: Colors.grey
                          )
                        ),
                        SizedBox(height: 12 * context.fontSizeFactor),
                        SizedBox(
                          height: 100 * context.fontSizeFactor,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: savedBeneficiaries.length,
                            itemBuilder: (context, index) {
                              final person = savedBeneficiaries[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _nameController.text = person.accountHolder ?? '';
                                    _accountController.text = person.accountNumber;
                                    _selectedBank = person.bankName;
                                  });
                                },
                                child: Container(
                                  width: 80 * context.fontSizeFactor,
                                  margin: EdgeInsets.only(right: 16 * context.fontSizeFactor),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 28 * context.fontSizeFactor,
                                        backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                        child: Text(
                                          person.accountHolder?[0] ?? '?', 
                                          style: TextStyle(
                                            color: theme.colorScheme.secondary, 
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 20 * context.fontSizeFactor
                                          )
                                        ),
                                      ),
                                      SizedBox(height: 8 * context.fontSizeFactor),
                                      Text(
                                        person.accountHolder?.split(' ')[0] ?? '', 
                                        style: TextStyle(
                                          fontSize: 12 * context.fontSizeFactor, 
                                          fontWeight: FontWeight.bold
                                        ), 
                                        overflow: TextOverflow.ellipsis
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 24 * context.fontSizeFactor),
                        
                        // --- INTERNATIONAL TOGGLE ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.internationalTransfer, 
                              style: TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 16 * context.fontSizeFactor
                              )
                            ),
                            Switch.adaptive(
                              value: _isInternational,
                              activeColor: theme.colorScheme.secondary,
                              onChanged: (v) {
                                setState(() {
                                  _isInternational = v;
                                  if (v) _fetchFxRate();
                                });
                              },
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16 * context.fontSizeFactor),

                        // --- BANK SELECTOR ---
                        Text(
                          l10n.selectBank, 
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 14 * context.fontSizeFactor, 
                            color: Colors.grey
                          )
                        ),
                        SizedBox(height: 8 * context.fontSizeFactor),
                        GestureDetector(
                          onTap: () => _showBankPicker(l10n, theme),
                          child: Container(
                            padding: EdgeInsets.all(16 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 2),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_rounded, color: theme.colorScheme.secondary, size: 24 * context.fontSizeFactor),
                                SizedBox(width: 12 * context.fontSizeFactor),
                                Expanded(
                                  child: Text(
                                    _selectedBank, 
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900, 
                                      fontSize: 16 * context.fontSizeFactor
                                    )
                                  )
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.secondary, size: 24 * context.fontSizeFactor),
                              ],
                            ),
                          ),
                        ),

                        if (_selectedBank == "Add Bank") ...[
                          SizedBox(height: 16 * context.fontSizeFactor),
                          _buildTextField(
                            controller: _bankNameController,
                            focusNode: _bankNameFocus,
                            hint: l10n.bankName,
                            icon: Icons.edit_note_rounded,
                            theme: theme,
                          ),
                        ],

                        SizedBox(height: 16 * context.fontSizeFactor),

                        // --- ACCOUNT NUMBER ---
                        _buildTextField(
                          controller: _accountController,
                          focusNode: _accountFocus,
                          hint: l10n.accountNumber,
                          icon: Icons.account_balance_wallet_rounded,
                          type: TextInputType.number,
                          theme: theme,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
                        ),

                        SizedBox(height: 16 * context.fontSizeFactor),

                        // --- RECEIVER NAME ---
                        _buildTextField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          hint: l10n.receiver,
                          icon: Icons.person_rounded,
                          theme: theme,
                          suffix: _isVerifyingName 
                            ? SizedBox(
                                width: 20 * context.fontSizeFactor, 
                                height: 20 * context.fontSizeFactor, 
                                child: const CircularProgressIndicator(strokeWidth: 2)
                              ) 
                            : null,
                        ),

                        if (_verifiedName != null && _nameController.text.isNotEmpty && _verifiedName != _nameController.text)
                          Padding(
                            padding: EdgeInsets.only(top: 8 * context.fontSizeFactor),
                            child: Container(
                              padding: EdgeInsets.all(12 * context.fontSizeFactor),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20 * context.fontSizeFactor),
                                  SizedBox(width: 12 * context.fontSizeFactor),
                                  Expanded(
                                    child: Text(
                                      "Verification Warning: The name you entered differs from the account holder name returned by the bank: '$_verifiedName'",
                                      style: TextStyle(
                                        color: Colors.orange, 
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 12 * context.fontSizeFactor
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (_isInternational) ...[
                          SizedBox(height: 16 * context.fontSizeFactor),
                          _buildTextField(
                            controller: _swiftController,
                            focusNode: _swiftFocus,
                            hint: l10n.swiftCode,
                            icon: Icons.public_rounded,
                            theme: theme,
                          ),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          _buildTextField(
                            controller: _addressController,
                            focusNode: _addressFocus,
                            hint: l10n.address,
                            icon: Icons.home_rounded,
                            theme: theme,
                          ),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _cityController,
                                  focusNode: _cityFocus,
                                  hint: l10n.city,
                                  icon: Icons.location_city_rounded,
                                  theme: theme,
                                ),
                              ),
                              SizedBox(width: 12 * context.fontSizeFactor),
                              Expanded(
                                child: _buildTextField(
                                  controller: _countryController,
                                  focusNode: _countryFocus,
                                  hint: l10n.country,
                                  icon: Icons.public_rounded,
                                  theme: theme,
                                ),
                              ),
                            ],
                          ),
                        ],

                        SizedBox(height: 24 * context.fontSizeFactor),
                        Text(
                          l10n.selectPaymentMethod, 
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 14 * context.fontSizeFactor, 
                            color: Colors.grey
                          )
                        ),
                        SizedBox(height: 8 * context.fontSizeFactor),
                        _buildDropdown(
                          value: _selectedSource,
                          items: ["Main Wallet", "Card", "Savings"],
                          icon: Icons.account_balance_wallet_rounded,
                          onChanged: (v) => setState(() => _selectedSource = v!),
                          theme: theme,
                        ),

                        SizedBox(height: 16 * context.fontSizeFactor),
                        Text(
                          l10n.purposeOfRemittance, 
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 14 * context.fontSizeFactor, 
                            color: Colors.grey
                          )
                        ),
                        SizedBox(height: 8 * context.fontSizeFactor),
                        _buildDropdown(
                          value: _selectedPurpose,
                          items: _purposes,
                          icon: Icons.info_outline_rounded,
                          onChanged: (v) => setState(() => _selectedPurpose = v!),
                          theme: theme,
                        ),

                        SizedBox(height: 16 * context.fontSizeFactor),
                        Text(
                          "Source of Funds", 
                          style: TextStyle(
                            fontWeight: FontWeight.w900, 
                            fontSize: 14 * context.fontSizeFactor, 
                            color: Colors.grey
                          )
                        ),
                        SizedBox(height: 8 * context.fontSizeFactor),
                        _buildDropdown(
                          value: _selectedFundSource,
                          items: _fundSources,
                          icon: Icons.source_rounded,
                          onChanged: (v) => setState(() => _selectedFundSource = v!),
                          theme: theme,
                        ),

                        SizedBox(height: 24 * context.fontSizeFactor),

                        // --- TRANSFER SUMMARY (FEE/FX) ---
                        Container(
                          padding: EdgeInsets.all(16 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                            border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final feePer100 = state.calculateFeeForSource(100.0, _selectedSource, payoutMethod: "Bank Transfer");
                                      final feePercent = ((feePer100 / 100.0) * 100).toStringAsFixed(1);
                                      return Expanded(
                                        child: Text(
                                          l10n.feeRateDynamic(feePercent, feePer100.toStringAsFixed(2)),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 14 * context.fontSizeFactor,
                                            color: Colors.grey
                                          )
                                        ),
                                      );
                                    }
                                  ),
                                  Text(
                                    "\$${_calculateFee().toStringAsFixed(2)}", 
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14 * context.fontSizeFactor
                                    )
                                  ),
                                ],
                              ),
                              if (_isInternational) ...[
                                Divider(height: 24 * context.fontSizeFactor),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "FX Rate", 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 14 * context.fontSizeFactor,
                                        color: Colors.grey
                                      )
                                    ),
                                    _isLoadingFx 
                                      ? SizedBox(
                                          width: 12 * context.fontSizeFactor, 
                                          height: 12 * context.fontSizeFactor, 
                                          child: const CircularProgressIndicator(strokeWidth: 2)
                                        )
                                      : Text(
                                          _fxRate != null 
                                            ? "1 USD = ${_fxRate!.toStringAsFixed(4)} ${widget.currencyCode}" 
                                            : "Fetching...", 
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14 * context.fontSizeFactor
                                          )
                                        ),
                                  ],
                                ),
                              ],
                              Divider(height: 24 * context.fontSizeFactor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total to Pay", 
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16 * context.fontSizeFactor
                                    )
                                  ),
                                  Text(
                                    "\$${state.calculateTotalForSource(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0, _selectedSource, payoutMethod: "Bank Transfer").toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900, 
                                      fontSize: 18 * context.fontSizeFactor, 
                                      color: theme.colorScheme.secondary
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20 * context.fontSizeFactor),

                        // --- SAVE BENEFICIARY ---
                        Row(
                          children: [
                            Checkbox(
                              value: _saveBeneficiary,
                              activeColor: theme.colorScheme.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4 * context.fontSizeFactor)),
                              onChanged: (v) => setState(() => _saveBeneficiary = v!),
                            ),
                            Text(
                              l10n.saveBeneficiary, 
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14 * context.fontSizeFactor
                              )
                            ),
                          ],
                        ),

                        SizedBox(height: 32 * context.fontSizeFactor),
                        
                        // --- CONTINUE BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          height: 56 * context.fontSizeFactor,
                          child: ElevatedButton(
                            onPressed: (_accountController.text.length >= 8 && _nameController.text.isNotEmpty) 
                                ? () => _handleContinue(l10n) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                              elevation: 4,
                              shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                            ),
                            child: Text(
                              l10n.continueToReview,
                              style: TextStyle(
                                fontSize: 18 * context.fontSizeFactor, 
                                fontWeight: FontWeight.w900, 
                                letterSpacing: 0.5
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30 * context.fontSizeFactor),
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
    required ThemeData theme,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? formatters,
    Widget? suffix,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        bool hasFocus = focusNode.hasFocus;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                border: Border.all(
                  color: hasFocus ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: hasFocus ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10 * context.fontSizeFactor)] : null,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: type,
                inputFormatters: formatters,
                onChanged: (v) => setState(() {}),
                style: TextStyle(
                  fontSize: 18 * context.fontSizeFactor, 
                  fontWeight: FontWeight.w900
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: Icon(
                    icon, 
                    color: theme.colorScheme.secondary, 
                    size: 24 * context.fontSizeFactor
                  ),
                  suffixIcon: suffix != null 
                    ? Padding(
                        padding: EdgeInsets.all(12 * context.fontSizeFactor), 
                        child: suffix
                      ) 
                    : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded, 
            color: theme.colorScheme.secondary,
            size: 24 * context.fontSizeFactor,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(
                    icon, 
                    color: theme.colorScheme.secondary, 
                    size: 20 * context.fontSizeFactor
                  ),
                  SizedBox(width: 12 * context.fontSizeFactor),
                  Text(
                    item, 
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16 * context.fontSizeFactor
                    )
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BankPickerSheet extends StatefulWidget {
  final List<Map<String, String>> banks;
  final Function(String) onSelect;

  const _BankPickerSheet({required this.banks, required this.onSelect});

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  late List<Map<String, String>> filteredBanks;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredBanks = widget.banks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30 * context.fontSizeFactor)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12 * context.fontSizeFactor),
          Container(
            width: 40 * context.fontSizeFactor, 
            height: 4 * context.fontSizeFactor, 
            decoration: BoxDecoration(
              color: Colors.grey[400], 
              borderRadius: BorderRadius.circular(10 * context.fontSizeFactor)
            )
          ),
          SizedBox(height: 20 * context.fontSizeFactor),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor),
            child: TextField(
              onChanged: (v) {
                setState(() {
                  searchQuery = v;
                  filteredBanks = widget.banks.where((b) => b['name']!.toLowerCase().contains(v.toLowerCase())).toList();
                });
              },
              style: TextStyle(fontSize: 16 * context.fontSizeFactor),
              decoration: InputDecoration(
                hintText: l10n.selectBank,
                prefixIcon: Icon(Icons.search, size: 24 * context.fontSizeFactor),
                filled: true,
                fillColor: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15 * context.fontSizeFactor), 
                  borderSide: BorderSide.none
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
              ),
            ),
          ),
          SizedBox(height: 10 * context.fontSizeFactor),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBanks.length + 1,
              itemBuilder: (context, index) {
                if (index == filteredBanks.length) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      child: Icon(Icons.add, color: theme.colorScheme.secondary, size: 24 * context.fontSizeFactor)
                    ),
                    title: Text(
                      l10n.addBank, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * context.fontSizeFactor
                      )
                    ),
                    onTap: () {
                      widget.onSelect("Add Bank");
                      Navigator.pop(context);
                    },
                  );
                }
                final bank = filteredBanks[index];
                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: Colors.grey[100], 
                      borderRadius: BorderRadius.circular(10 * context.fontSizeFactor)
                    ),
                    child: Image.asset(
                      bank['image']!, 
                      width: 24 * context.fontSizeFactor, 
                      height: 24 * context.fontSizeFactor
                    ),
                  ),
                  title: Text(
                    bank['name']!, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * context.fontSizeFactor
                    )
                  ),
                  trailing: Icon(Icons.chevron_right, size: 24 * context.fontSizeFactor),
                  onTap: () {
                    widget.onSelect(bank['name']!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
