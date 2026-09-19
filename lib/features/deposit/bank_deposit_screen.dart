import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/app_state.dart';
import '../../core/models/transaction.dart' as model;
import '../../core/models/bank_account.dart';
import '../../core/widgets/success_screen.dart';
import '../navigation/main_navigation.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/widgets/pin_entry_dialog.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../withdraw/mixins/withdrawal_logic_mixin.dart';
import '../../core/api_service.dart';

class BankDepositScreen extends StatefulWidget {
  final double amount;

  const BankDepositScreen({super.key, required this.amount});

  @override
  State<BankDepositScreen> createState() => _BankDepositScreenState();
}

class _BankDepositScreenState extends State<BankDepositScreen> with WithdrawalLogicMixin {
  int _selectedCategoryIndex = 0; // 0 for Local, 1 for International
  int _selectedLocalBankIndex = 0; // Index for predefined Somali banks
  bool _isReceiptAttached = false;
  File? _receiptImage;
  final ImagePicker _picker = ImagePicker();
  bool _saveAccount = false;
  
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _swiftController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _somaliBanksList = [
    {
      'name': 'Salaam Somali Bank',
      'account': '1020304050',
      'holder': 'MurtaaPay LLC',
    },
    {
      'name': 'Premier Bank',
      'account': '5060708090',
      'holder': 'MurtaaPay LLC',
    },
    {
      'name': 'IBS Bank',
      'account': '123456789012',
      'holder': 'MurtaaPay LLC',
    },
  ];

  @override
  void dispose() {
    _bankNameController.dispose();
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.bankTransfer, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * context.fontSizeFactor, letterSpacing: -0.5)),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8 * context.fontSizeFactor),
            decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16 * context.fontSizeFactor, color: theme.iconTheme.color),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Center(
                      child: MaxWidthBox(
                        maxWidth: 500,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(28 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accentTeal, Color(0xFF00796B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32 * context.fontSizeFactor),
                            boxShadow: [
                              BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, 10 * context.fontSizeFactor)),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(l10n.amountToDeposit, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
                              SizedBox(height: 12 * context.fontSizeFactor),
                              Text(
                                NumberFormat.simpleCurrency(name: "USD").format(widget.amount),
                                style: TextStyle(fontSize: 40 * context.fontSizeFactor, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32 * context.fontSizeFactor),
                  
                  // Category Selector
                  FadeInUp(
                    child: Center(
                      child: MaxWidthBox(
                        maxWidth: 600,
                        child: Container(
                          padding: EdgeInsets.all(6 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              _categoryButton(0, state.translate("Local Bank", "Bankiga Maxalliga ah"), Icons.account_balance_rounded),
                              _categoryButton(1, state.translate("International", "Caalami"), Icons.public_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24 * context.fontSizeFactor),

                  // Professional Somali Bank Choice Layout
                  if (_selectedCategoryIndex == 0) ...[
                    FadeInUp(
                      child: Padding(
                        padding: EdgeInsets.only(left: 4 * context.fontSizeFactor, bottom: 12 * context.fontSizeFactor),
                        child: Text(
                          state.translate("Select Somali Bank", "Dooro Bankiga Soomaaliga"),
                          style: TextStyle(fontSize: 15 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color),
                        ),
                      ),
                    ),
                    FadeInUp(
                      child: SizedBox(
                        height: 64 * context.fontSizeFactor,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _somaliBanksList.length,
                          itemBuilder: (context, index) {
                            final bank = _somaliBanksList[index];
                            final isSelected = _selectedLocalBankIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedLocalBankIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
                                padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 10 * context.fontSizeFactor),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.cardColor,
                                  borderRadius: BorderRadius.circular(18 * context.fontSizeFactor),
                                  border: Border.all(
                                    color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.account_balance_rounded, color: isSelected ? AppColors.accentTeal : AppColors.grey, size: 20 * context.fontSizeFactor),
                                    SizedBox(width: 10 * context.fontSizeFactor),
                                    Text(
                                      bank['name']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppColors.accentTeal : theme.textTheme.bodyLarge?.color,
                                        fontSize: 14 * context.fontSizeFactor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    _buildCompanyBankCard(state),
                    SizedBox(height: 24 * context.fontSizeFactor),
                  ],
                  
                  FadeInUp(
                    child: Container(
                      padding: EdgeInsets.all(24 * context.fontSizeFactor),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(32 * context.fontSizeFactor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12 * context.fontSizeFactor),
                                decoration: BoxDecoration(
                                  color: AppColors.accentTeal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                                ),
                                child: Icon(_selectedCategoryIndex == 0 ? Icons.person_outline_rounded : Icons.public_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
                              ),
                              SizedBox(width: 16 * context.fontSizeFactor),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedCategoryIndex == 0 ? state.translate("Your Transfer Details", "Faahfaahinta Wareejintaada") : state.translate("International Wire Details", "Faahfaahinta Xawaaladda Caalamiga ah"),
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17 * context.fontSizeFactor),
                                    ),
                                    Text(
                                      state.translate("Secure Bank Verification", "Xaqiijinta Amniga Bankiga"),
                                      style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24 * context.fontSizeFactor),
                          if (_selectedCategoryIndex == 1) ...[
                            _inputField(state.translate("Bank Name", "Magaca Bankiga"), Icons.account_balance_rounded, controller: _bankNameController, validator: (v) => v!.isEmpty ? "Enter bank name" : null),
                            SizedBox(height: 16 * context.fontSizeFactor),
                          ],
                          _inputField(
                            _selectedCategoryIndex == 0 ? state.translate("Sender Full Name", "Magaca Buuxa ee Soo Diraha") : state.translate("Account Holder Name", "Magaca Leh Akoonka"), 
                            Icons.person_rounded, 
                            controller: _accountNameController, 
                            validator: (v) => v!.isEmpty ? "Enter name" : null
                          ),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          _inputField(
                            _selectedCategoryIndex == 0 ? state.translate("Sender Account / Phone Number", "Akoonka ama Taleefanka Soo Diraha") : state.translate("Account Number", "Lambarka Akoonka"), 
                            Icons.numbers_rounded, 
                            controller: _accountNumberController, 
                            isNumber: true, 
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Enter account/phone number";
                              if (_selectedCategoryIndex == 0) {
                                final bankName = _somaliBanksList[_selectedLocalBankIndex]['name'];
                                if (bankName == 'Salaam Somali Bank' && v.length != 10) {
                                  return "Salaam Somali Bank account must be 10 digits";
                                } else if (bankName == 'Premier Bank' && v.length != 10) {
                                  return "Premier Bank account must be 10 digits";
                                } else if (bankName == 'IBS Bank' && v.length != 12) {
                                  return "IBS Bank account must be 12 digits";
                                }
                              }
                              return null;
                            }
                          ),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          _inputField(
                            _selectedCategoryIndex == 0 ? state.translate("Transaction Reference ID / TxID", "Tixraaca Wareejinta (TxID)") : state.translate("SWIFT / BIC Code", "Koodhka SWIFT / BIC"), 
                            _selectedCategoryIndex == 0 ? Icons.gavel_rounded : Icons.language_rounded, 
                            controller: _swiftController, 
                            validator: (v) => v!.isEmpty ? (_selectedCategoryIndex == 0 ? "Enter reference ID" : "Enter SWIFT code") : null
                          ),
                          SizedBox(height: 24 * context.fontSizeFactor),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _saveAccount,
                                    activeColor: AppColors.accentTeal,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    onChanged: (val) => setState(() => _saveAccount = val ?? false),
                                  ),
                                ),
                                SizedBox(width: 12 * context.fontSizeFactor),
                                Expanded(
                                  child: Text(
                                    state.translate("Save this account for future deposits", "Kaydi akoonkan mustaqbalka"), 
                                    style: TextStyle(fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.bold)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24 * context.fontSizeFactor),
                  
                  FadeInUp(
                    child: GestureDetector(
                      onTap: _pickReceipt,
                      child: Container(
                        padding: EdgeInsets.all(20 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: _isReceiptAttached ? AppColors.accentTeal.withValues(alpha: 0.05) : theme.cardColor,
                          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
                          border: Border.all(color: _isReceiptAttached ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            if (_isReceiptAttached && _receiptImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                                child: Image.file(_receiptImage!, width: 48 * context.fontSizeFactor, height: 48 * context.fontSizeFactor, fit: BoxFit.cover),
                              )
                            else
                              Icon(Icons.add_a_photo_rounded, color: AppColors.grey),
                            SizedBox(width: 16 * context.fontSizeFactor),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isReceiptAttached ? state.translate("Receipt Attached ✓", "Rasiidka waa la lifaaqay ✓") : state.translate("Upload Transfer Receipt", "Soo Geli Sawirka Rasiidka"),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                                  ),
                                  Text(
                                    _isReceiptAttached ? state.translate("Tap to change", "Taabo si aad u bedesho") : state.translate("Mandatory for manual verification", "Waa qasab xaqiijinta rasiidka"),
                                    style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 120 * context.fontSizeFactor),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 12 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: MaxWidthBox(
            maxWidth: 800,
            child: ElevatedButton(
              onPressed: _validateAndSubmit,
              style: context.elevatedButtonStyle(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.confirmAndSubmit),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyBankCard(AppState state) {
    final bank = _somaliBanksList[_selectedLocalBankIndex];
    final theme = Theme.of(context);
    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: AppColors.accentTeal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
          border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user_rounded, color: AppColors.accentTeal, size: 18 * context.fontSizeFactor),
                SizedBox(width: 8 * context.fontSizeFactor),
                Expanded(
                  child: Text(
                    state.translate("Official MurtaaPay Deposit Account", "Akoonka Rasmiga ah ee MurtaaPay"),
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.accentTeal, fontSize: 13 * context.fontSizeFactor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * context.fontSizeFactor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank['name']!,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color),
                      ),
                      SizedBox(height: 6 * context.fontSizeFactor),
                      Text(
                        "${state.translate("Account:", "Akoonka:")} ${bank['account']}",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor, color: AppColors.primaryDark),
                      ),
                      SizedBox(height: 4 * context.fontSizeFactor),
                      Text(
                        "${state.translate("Name:", "Magaca:")} ${bank['holder']}",
                        style: TextStyle(fontSize: 13 * context.fontSizeFactor, color: AppColors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(10 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.copy_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: bank['account']!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.translate("Account number copied to clipboard!", "Akoonka waa la koobiyeeyay!")),
                        backgroundColor: AppColors.accentTeal,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickReceipt() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _receiptImage = File(image.path);
        _isReceiptAttached = true;
      });
    }
  }

  void _validateAndSubmit() {
    final state = Provider.of<AppState>(context, listen: false);
    if (_selectedCategoryIndex == 0) {
      _bankNameController.text = _somaliBanksList[_selectedLocalBankIndex]['name']!;
    }
    if (_formKey.currentState!.validate()) {
      if (!_isReceiptAttached) {
        final message = state.translate("Please upload a receipt screenshot", "Fadlan soo geli sawirka rasiidka");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          key: const Key('receipt_error_snackbar'),
          content: Text(message)
        ));
        return;
      }
      _showConfirmationSheet();
    }
  }

  Widget _categoryButton(int index, String label, IconData icon) {
    final isSelected = _selectedCategoryIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategoryIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.grey, size: 18 * context.fontSizeFactor),
              SizedBox(width: 8 * context.fontSizeFactor),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * context.fontSizeFactor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, IconData icon, {required TextEditingController controller, bool isNumber = false, String? Function(String?)? validator}) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontSize: 15 * context.fontSizeFactor, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20 * context.fontSizeFactor, color: AppColors.grey),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide.none),
        labelStyle: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor),
      ),
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
        child: DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.5,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) => Center(
            child: MaxWidthBox(
              maxWidth: 600,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36 * context.fontSizeFactor)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 12 * context.fontSizeFactor),
                    Container(width: 40 * context.fontSizeFactor, height: 5 * context.fontSizeFactor, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10 * context.fontSizeFactor))),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.all(28 * context.fontSizeFactor),
                        children: [
                          Icon(Icons.account_balance_rounded, color: AppColors.accentTeal, size: 48 * context.fontSizeFactor),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          Text(state.translate("Confirm Deposit Request", "Xaqiijinta Codsiga Lacag Dhigashada"), style: TextStyle(fontSize: 22 * context.fontSizeFactor, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          SizedBox(height: 24 * context.fontSizeFactor),
                          Container(
                            padding: EdgeInsets.all(20 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
                            ),
                            child: Column(
                              children: [
                                _summaryRow(state.translate("Bank", "Bankiga"), _selectedCategoryIndex == 0 ? _somaliBanksList[_selectedLocalBankIndex]['name']! : _bankNameController.text),
                                _summaryRow(state.translate("Sender Name", "Magaca Buuxa"), _accountNameController.text),
                                _summaryRow(state.translate("Sender Account", "Akoonka"), _accountNumberController.text),
                                if (_swiftController.text.isNotEmpty)
                                  _summaryRow(_selectedCategoryIndex == 0 ? state.translate("Reference ID", "Tixraaca") : "SWIFT Code", _swiftController.text),
                                Divider(height: 24 * context.fontSizeFactor),
                                _summaryRow(state.translate("Deposit Amount", "Cadadka Lacagta"), NumberFormat.simpleCurrency(name: "USD").format(widget.amount)),
                                _summaryRow(state.translate("Fee", "Khidmadda"), NumberFormat.simpleCurrency(name: "USD").format(fee)),
                                Divider(height: 24 * context.fontSizeFactor),
                                _summaryRow(state.translate("Total to Verify", "Warta Guud"), NumberFormat.simpleCurrency(name: "USD").format(total), isTotal: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(24 * context.fontSizeFactor),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showPinDialog();
                          },
                          style: context.elevatedButtonStyle(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white),
                          child: Text(l10n.confirmAndSubmit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPinDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => PinEntryDialog(
        title: l10n.enterPin,
        description: l10n.enterPinToContinue,
        onConfirm: (pin) {
          _processBankDeposit();
        },
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * context.fontSizeFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? AppColors.textPrimary : AppColors.grey, fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isTotal ? 18 : 14, color: isTotal ? AppColors.accentTeal : AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _processBankDeposit() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context, listen: false);

    if (_selectedCategoryIndex == 0) {
      _bankNameController.text = _somaliBanksList[_selectedLocalBankIndex]['name']!;
    }

    final List<String> steps = [
      state.translate("Verifying deposit details...", "Cusboonaysiinta macluumaadka..."),
      state.translate("Processing receipt upload...", "Gelinaya rasiidka sawirka..."),
      "Finalising transaction..",
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final scale = context.fontSizeFactor;
        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40 * scale),
            padding: EdgeInsets.all(36 * scale),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(30 * scale),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 15)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90 * scale,
                      height: 90 * scale,
                      child: CircularProgressIndicator(
                        color: AppColors.accentTeal,
                        strokeWidth: 4 * scale,
                        backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                      ),
                    ),
                    Icon(Icons.shield_rounded, color: AppColors.accentTeal, size: 36 * scale),
                  ],
                ),
                SizedBox(height: 32 * scale),
                _DepositStepText(steps: steps),
                SizedBox(height: 14 * scale),
                Text(
                  l10n.pleaseWait,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8 * scale,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));

    String? receiptUrl;
    if (_isReceiptAttached && _receiptImage != null) {
      receiptUrl = await ApiService.uploadReceipt(_receiptImage!);
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog

    if (_saveAccount) {
      await state.addBank(BankAccount(
        id: "BANK-${DateTime.now().millisecondsSinceEpoch}",
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        accountHolder: _accountNameController.text,
      ));
    }

    final tx = model.Transaction(
      id: "DEP-BNK-${DateTime.now().millisecondsSinceEpoch}",
      title: "${_bankNameController.text} Deposit",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "+${NumberFormat.simpleCurrency(name: state.currencyCode).format(widget.amount)}",
      numericAmount: widget.amount,
      isNegative: false,
      category: "Deposit",
      status: "Pending",
      type: "deposit",
      method: _bankNameController.text,
      referenceId: _swiftController.text.isNotEmpty ? _swiftController.text : "REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      purpose: receiptUrl != null ? "Receipt: $receiptUrl" : null,
    );

    state.addTransaction(tx);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: "waa la helay fariintaada na sug 24hrs",
          message: "Your deposit of \$${widget.amount.toStringAsFixed(2)} via ${_bankNameController.text} has been received and is currently under review.",
          subtitle: state.translate("Verification Process", "Habka Xaqiijinta"),
          subMessage: state.translate(
            "Our team will verify the transaction receipt and update your balance. This process typically takes up to 24 hours. You will receive a notification once completed.",
            "Kooxdayadu waxay xaqiijin doonaan rasiidka lacag bixinta waxayna cusboonaysiin doonaan dheelitirnaantaada. Habkani wuxuu qaadanayaa ilaa 24 saacadow."
          ),
          buttonText: l10n.backToHome,
          transactionData: tx.toJson(),
          onPressed: () {
            state.setNavIndex(0);
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false);
          },
        ),
      ),
      (route) => false,
    );
  }
}

class _DepositStepText extends StatefulWidget {
  final List<String> steps;
  const _DepositStepText({required this.steps});

  @override
  State<_DepositStepText> createState() => _DepositStepTextState();
}

class _DepositStepTextState extends State<_DepositStepText> {
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          if (_currentStep < widget.steps.length - 1) {
            _currentStep++;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    
    return FadeInUp(
      key: ValueKey(_currentStep),
      duration: const Duration(milliseconds: 400),
      child: Text(
        widget.steps[_currentStep],
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.textTheme.titleLarge?.color,
          fontSize: 18 * scale,
        ),
      ),
    );
  }
}
