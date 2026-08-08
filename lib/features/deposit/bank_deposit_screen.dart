import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/app_state.dart';
import '../../core/models/transaction.dart';
import '../../core/models/bank_account.dart';
import '../../core/widgets/success_screen.dart';
import '../navigation/main_navigation.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/services.dart';

class BankDepositScreen extends StatefulWidget {
  final double amount;

  const BankDepositScreen({super.key, required this.amount});

  @override
  State<BankDepositScreen> createState() => _BankDepositScreenState();
}

class _BankDepositScreenState extends State<BankDepositScreen> {
  int _selectedCategoryIndex = 0; // 0 for Local, 1 for International
  String? _selectedBank;
  bool _isReceiptAttached = false;
  bool _saveAccount = false;
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _swiftController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _localBanks = [
    {"name": "Premier Bank", "accountNumber": "1022334455", "accountName": "MURTAPAY SOLUTIONS", "color": const Color(0xFF01579B), "logo": Icons.account_balance},
    {"name": "IBS Bank", "accountNumber": "9988776655", "accountName": "MURTAPAY SOLUTIONS", "color": const Color(0xFFC62828), "logo": Icons.account_balance},
    {"name": "Salaam Bank", "accountNumber": "4455667788", "accountName": "MURTAPAY SOLUTIONS", "color": const Color(0xFF2E7D32), "logo": Icons.account_balance},
    {"name": "Amal Bank", "accountNumber": "1122334455", "accountName": "MURTAPAY SOLUTIONS", "color": const Color(0xFFEF6C00), "logo": Icons.account_balance},
    {"name": "MyBank", "accountNumber": "5566778899", "accountName": "MURTAPAY SOLUTIONS", "color": const Color(0xFF4527A0), "logo": Icons.account_balance},
  ];

  final List<Map<String, dynamic>> _internationalBanks = [
    {"name": "Chase Bank", "country": "USA", "color": const Color(0xFF11407D), "logo": Icons.public},
    {"name": "HSBC", "country": "UK", "color": const Color(0xFFDB0011), "logo": Icons.public},
    {"name": "Barclays", "country": "UK", "color": const Color(0xFF00AEEF), "logo": Icons.public},
    {"name": "Standard Chartered", "country": "UAE", "color": const Color(0xFF009B4D), "logo": Icons.public},
    {"name": "Revolut", "country": "Global", "color": const Color(0xFF000000), "logo": Icons.account_balance_wallet},
  ];

  void _onBankSelected(Map<String, dynamic> bank) {
    setState(() {
      _selectedBank = bank['name'];
      if (_selectedCategoryIndex == 0) {
        _accountNumberController.text = bank['accountNumber'];
        _accountNameController.text = bank['accountName'];
      }
    });
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _swiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context, listen: false);
    final fee = state.calculateFeeForSource(widget.amount, _selectedCategoryIndex == 0 ? "Bank Transfer" : "International Bank");
    final total = widget.amount + fee;

    final selectedBankData = _selectedBank != null 
        ? (_selectedCategoryIndex == 0 
            ? _localBanks.firstWhere((b) => b['name'] == _selectedBank)
            : _internationalBanks.firstWhere((b) => b['name'] == _selectedBank))
        : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.bankTransfer, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * context.fontSizeFactor, letterSpacing: -0.5)),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16 * context.fontSizeFactor, color: theme.iconTheme.color),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 600,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24 * context.fontSizeFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentTeal, Color(0xFF00796B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(color: AppColors.accentTeal.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(l10n.amountToDeposit, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Text(
                          NumberFormat.simpleCurrency(name: "USD").format(widget.amount),
                          style: TextStyle(fontSize: 40 * context.fontSizeFactor, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Category Selector
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        _categoryButton(0, "Local Banks", Icons.account_balance_rounded),
                        _categoryButton(1, "International", Icons.public_rounded),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                FadeInUp(
                  child: Text(
                    _selectedCategoryIndex == 0 ? "Select Somali Bank" : "Select International Bank",
                    style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Bank List
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.isMobile ? 2 : 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _selectedCategoryIndex == 0 ? _localBanks.length : _internationalBanks.length,
                  itemBuilder: (context, index) {
                    final bank = _selectedCategoryIndex == 0 ? _localBanks[index] : _internationalBanks[index];
                    final isSelected = _selectedBank == bank['name'];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 50),
                      child: GestureDetector(
                        onTap: () => _onBankSelected(bank),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? (bank['color'] as Color).withOpacity(0.05) : theme.cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? (bank['color'] as Color) : theme.dividerColor.withOpacity(0.05),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (bank['color'] as Color).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(bank['logo'], color: bank['color'], size: 28),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                bank['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13 * context.fontSizeFactor),
                              ),
                              if (bank['country'] != null)
                                Text(
                                  bank['country'],
                                  style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                if (_selectedBank != null) ...[
                  const SizedBox(height: 40),
                  FadeInUp(
                    child: _selectedCategoryIndex == 0 
                      ? _buildLocalBankDetails(selectedBankData!)
                      : _buildInternationalBankFlow(selectedBankData!),
                  ),
                ],
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _selectedBank != null ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FadeInUp(
            child: SizedBox(
              width: double.infinity,
              height: 60 * context.fontSizeFactor,
              child: ElevatedButton(
                onPressed: _showConfirmationSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: AppColors.primaryDark.withOpacity(0.3),
                ),
                child: Text(
                  _selectedCategoryIndex == 0 ? l10n.iHaveSentTheMoney : "Link & Process Deposit",
                  style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ),
      ) : null,
    );
  }

  Widget _categoryButton(int index, String label, IconData icon) {
    final isSelected = _selectedCategoryIndex == index;
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedCategoryIndex = index;
          _selectedBank = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.grey, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocalBankDetails(Map<String, dynamic> bank) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: (bank['color'] as Color).withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: (bank['color'] as Color).withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.info_outline_rounded, color: bank['color'], size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.depositToOurAccount, style: TextStyle(color: bank['color'], fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 24),
              _infoRow(context, l10n.accountName, _accountNameController.text),
              const Divider(height: 32),
              _infoRow(context, l10n.accountNumber, _accountNumberController.text, canCopy: true),
              const Divider(height: 32),
              _infoRow(context, l10n.reference, "WALLET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}", canCopy: true),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.bankReferenceNote,
                        style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            // Simulate image picking
            setState(() => _isReceiptAttached = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Receipt attached successfully!")),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isReceiptAttached ? AppColors.accentTeal.withOpacity(0.05) : theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isReceiptAttached ? AppColors.accentTeal : theme.dividerColor.withOpacity(0.1),
                style: _isReceiptAttached ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isReceiptAttached ? AppColors.accentTeal : AppColors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isReceiptAttached ? Icons.check_rounded : Icons.add_a_photo_rounded,
                    color: _isReceiptAttached ? Colors.white : AppColors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isReceiptAttached ? "Receipt Attached" : "Upload Transfer Receipt",
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15 * context.fontSizeFactor),
                      ),
                      Text(
                        _isReceiptAttached ? "Screenshot_20240321.png" : "Please attach a screenshot of the transaction",
                        style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor),
                      ),
                    ],
                  ),
                ),
                if (_isReceiptAttached)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.red),
                    onPressed: () => setState(() => _isReceiptAttached = false),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInternationalBankFlow(Map<String, dynamic> bank) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: (bank['color'] as Color).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Link your ${bank['name']} account",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Text(
            "Transfer funds instantly and securely from your international account. Fees may apply.",
            style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor),
          ),
          const SizedBox(height: 32),
          _inputField("Account Number / IBAN", Icons.numbers_rounded, controller: _accountNumberController),
          const SizedBox(height: 16),
          _inputField("SWIFT / BIC Code", Icons.account_balance_rounded, controller: _swiftController),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _saveAccount,
                activeColor: AppColors.accentTeal,
                onChanged: (val) => setState(() => _saveAccount = val ?? false),
              ),
              Text(
                "Save this account for future use",
                style: TextStyle(fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.security_rounded, color: AppColors.accentTeal, size: 16),
              const SizedBox(width: 8),
              Text(
                "Secured by MurtaaxPay Encryption",
                style: TextStyle(color: AppColors.accentTeal, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, IconData icon, {TextEditingController? controller}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.grey),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        labelStyle: TextStyle(color: AppColors.grey, fontSize: 13),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value, {bool canCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
          ],
        ),
        if (canCopy)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.accentTeal),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
            },
          ),
      ],
    );
  }

  void _showConfirmationSheet() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context, listen: false);
    final fee = state.calculateFeeForSource(widget.amount, _selectedCategoryIndex == 0 ? "Bank Transfer" : "International Bank");
    final total = widget.amount + fee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Icon(Icons.check_circle_outline_rounded, color: AppColors.accentTeal, size: 48 * context.fontSizeFactor),
              const SizedBox(height: 16),
              Text(l10n.confirmTransfer, style: TextStyle(fontSize: 22 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    _summaryRow("Amount", NumberFormat.simpleCurrency(name: "USD").format(widget.amount)),
                    const Divider(height: 24),
                    _summaryRow("Service Fee", NumberFormat.simpleCurrency(name: "USD").format(fee)),
                    const Divider(height: 24),
                    _summaryRow("Total to Pay", NumberFormat.simpleCurrency(name: "USD").format(total), isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56 * context.fontSizeFactor,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _processBankDeposit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.confirmAndSubmit, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? AppColors.textPrimary : AppColors.grey, fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isTotal ? 18 : 14, color: isTotal ? AppColors.accentTeal : AppColors.textPrimary)),
      ],
    );
  }

  void _processBankDeposit() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(24)),
          child: const CircularProgressIndicator(color: AppColors.accentTeal),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context);

    final state = Provider.of<AppState>(context, listen: false);
    
    // logic based on category
    if (_selectedCategoryIndex == 0) {
      // Local Bank: Directly add balance (simulating instant verification for some local banks)
      state.addBalance(widget.amount);
    } else {
      // International Bank: Show a message that it's pending review or link verification
      // If "Save Account" was checked, save it to linked banks
      if (_saveAccount && _accountNumberController.text.isNotEmpty) {
        state.addBank(BankAccount(
          id: "BANK-${DateTime.now().millisecondsSinceEpoch}",
          bankName: _selectedBank!,
          accountNumber: _accountNumberController.text,
        ));
      }
      
      // In this mock, we still add it but could change status to "Pending"
      // state.addBalance(widget.amount); // For international, maybe don't add balance yet if it's truly pending
    }

    // Record the transaction
    state.addTransaction(Transaction(
      id: "DEP-BNK-${DateTime.now().millisecondsSinceEpoch}",
      title: l10n.bankTransfer,
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "+${NumberFormat.simpleCurrency(name: state.currencyCode).format(widget.amount)}",
      numericAmount: widget.amount,
      isNegative: false,
      category: "Deposit",
      status: _selectedCategoryIndex == 0 ? "Success" : "Pending",
      type: "deposit",
      method: _selectedBank!,
      referenceId: "WALLET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
    ));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: _selectedCategoryIndex == 0 ? l10n.transferNoted : "Deposit Initiated",
          message: _selectedCategoryIndex == 0 
              ? l10n.transferNotedMessage("\$${widget.amount.toStringAsFixed(2)}")
              : "Your international deposit from $_selectedBank is being processed.",
          subMessage: _selectedCategoryIndex == 0 
              ? l10n.takes30to60Minutes 
              : "International transfers typically take 1-3 business days. You can track this in your history.",
          buttonText: l10n.backToHome,
          onPressed: () {
            state.setNavIndex(0);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainNavigation()),
              (route) => false,
            );
          },
        ),
      ),
      (route) => false,
    );
  }
}
