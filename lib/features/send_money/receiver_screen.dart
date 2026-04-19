import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'payment_screen.dart';

class ReceiverScreen extends StatefulWidget {
  final String amount;
  final String method;
  final String currencyCode;
  final String? prefilledName;
  final String? prefilledPhone;

  const ReceiverScreen({
    super.key, 
    required this.amount, 
    required this.method, 
    required this.currencyCode,
    this.prefilledName,
    this.prefilledPhone,
  });

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final FocusNode _idFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _bankNameFocus = FocusNode();
  
  String _selectedCountryCode = "+252";
  String _selectedFlag = "🇸🇴";
  String? _detectedProvider;
  String _selectedBank = "IBS Bank";
  String? _selectedPurpose;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledName != null) {
      _nameController.text = widget.prefilledName!;
    }
    if (widget.prefilledPhone != null) {
      _processPrefilledPhone(widget.prefilledPhone!);
    }
  }

  void _processPrefilledPhone(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    for (var c in _countries) {
      if (cleanPhone.startsWith(c["code"]!)) {
        _selectedCountryCode = c["code"]!;
        _selectedFlag = c["flag"]!;
        cleanPhone = cleanPhone.substring(c["code"]!.length);
        break;
      } else if (cleanPhone.startsWith(c["code"]!.substring(1))) {
        _selectedCountryCode = c["code"]!;
        _selectedFlag = c["flag"]!;
        cleanPhone = cleanPhone.substring(c["code"]!.length - 1);
        break;
      }
    }
    _idController.text = cleanPhone;
  }

  List<String> _getPurposes(AppLocalizations l10n) => [
    l10n.familySupport,
    l10n.educationTuition,
    l10n.medicalExpenses,
    l10n.businessTransaction,
    l10n.propertyRent,
    l10n.gift,
    l10n.other,
  ];

  void _verifyReceiver() async {
    if (_idController.text.length < 7) return;
    
    // Simulate API Call for name lookup
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        // Mocking a name based on the number - in real app, this comes from API
        if (_idController.text.contains("615")) {
          _nameController.text = "Mohamed Hassan Ali";
        } else if (_idController.text.contains("634")) {
          _nameController.text = "Ahmed Ismail Hersi";
        } else {
          _nameController.text = "Abdirahman Osman";
        }
      });
      HapticFeedback.lightImpact();
    }
  }

  final List<Map<String, String>> _countries = [
    {"name": "Somalia", "code": "+252", "flag": "🇸🇴"},
    {"name": "Kenya", "code": "+254", "flag": "🇰🇪"},
    {"name": "Ethiopia", "code": "+251", "flag": "🇪🇹"},
    {"name": "Djibouti", "code": "+253", "flag": "🇩🇯"},
    {"name": "United Kingdom", "code": "+44", "flag": "🇬🇧"},
    {"name": "United States", "code": "+1", "flag": "🇺🇸"},
    {"name": "Canada", "code": "+1", "flag": "🇨🇦"},
    {"name": "Sweden", "code": "+46", "flag": "🇸🇪"},
    {"name": "UAE", "code": "+971", "flag": "🇦🇪"},
  ];

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Country", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final c = _countries[index];
                  return ListTile(
                    leading: Text(c["flag"]!, style: const TextStyle(fontSize: 24)),
                    title: Text(c["name"]!),
                    trailing: Text(c["code"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      setState(() {
                        _selectedCountryCode = c["code"]!;
                        _selectedFlag = c["flag"]!;
                        _idController.clear();
                        _detectedProvider = null;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _pickContact() async {
    final l10n = AppLocalizations.of(context)!;
    final status = await Permission.contacts.request();
    
    if (status.isGranted) {
      final contactId = await FlutterContacts.native.showPicker();
      if (contactId != null) {
        final fullContact = await FlutterContacts.get(contactId);
        if (fullContact != null && fullContact.phones.isNotEmpty) {
          String phone = fullContact.phones.first.number.replaceAll(RegExp(r'[\s\-\(\)]'), '');
            
          // Clean phone number from country code if it matches current selection or any other
          for (var c in _countries) {
            if (phone.startsWith(c["code"]!)) {
              setState(() {
                _selectedCountryCode = c["code"]!;
                _selectedFlag = c["flag"]!;
              });
              phone = phone.substring(c["code"]!.length);
              break;
            } else if (phone.startsWith(c["code"]!.substring(1))) {
              setState(() {
                _selectedCountryCode = c["code"]!;
                _selectedFlag = c["flag"]!;
              });
              phone = phone.substring(c["code"]!.length - 1);
              break;
            }
          }

          setState(() {
            _idController.text = phone;
            _nameController.text = fullContact.displayName ?? '';
          });
          
          // Trigger provider detection
          _idFocus.requestFocus();
          _idFocus.unfocus();
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.contact),
            content: Text(l10n.contactPermissionRequired),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: Text(l10n.openSettings),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contactPermissionRequired)),
        );
      }
    }
  }

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
    _idController.dispose();
    _nameController.dispose();
    _bankNameController.dispose();
    _idFocus.dispose();
    _nameFocus.dispose();
    _bankNameFocus.dispose();
    super.dispose();
  }

  void _handleContinue(AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    String bankInfo = _selectedBank == "Add Bank" ? _bankNameController.text : _selectedBank;
    String finalMethod = widget.method == "Bank Transfer" 
        ? "${widget.method} ($bankInfo)" 
        : (_detectedProvider ?? widget.method);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: widget.amount,
          receiverName: _nameController.text,
          receiverPhone: "$_selectedCountryCode ${_idController.text}",
          payoutMethod: finalMethod,
          currencyCode: widget.currencyCode,
          purpose: _selectedPurpose ?? _getPurposes(l10n).first,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final purposes = _getPurposes(l10n);
    _selectedPurpose ??= purposes.first;
    
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
          l10n.receiverDetails,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildStepIndicator(context, 1, l10n.stepAmount, false, true, isHeader: true),
                          _buildStepLine(context, true, isHeader: true),
                          _buildStepIndicator(context, 2, l10n.stepReceiver, true, false, isHeader: true),
                          _buildStepLine(context, false, isHeader: true),
                          _buildStepIndicator(context, 3, l10n.stepPayment, false, false, isHeader: true),
                          _buildStepLine(context, false, isHeader: true),
                          _buildStepIndicator(context, 4, l10n.stepReview, false, false, isHeader: true),
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
                        if (widget.method == "Bank Transfer") ...[
                          Text(l10n.selectBank, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          const SizedBox(height: 12),
                          _buildBankDropdown(theme, l10n),

                          if (_selectedBank == "Add Bank") ...[
                            const SizedBox(height: 20),
                            Text(l10n.bankName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _bankNameController,
                              focusNode: _bankNameFocus,
                              hint: l10n.enterBankName,
                              icon: Icons.account_balance_rounded,
                              type: TextInputType.text,
                              theme: theme,
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                        
                        Text(
                          widget.method == "Bank Transfer" ? l10n.accountNumber : l10n.enterReceiverPhone,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _idController,
                          focusNode: _idFocus,
                          hint: widget.method == "Bank Transfer" ? l10n.accountNumber : "XXXXXXXXX",
                          icon: widget.method == "Bank Transfer" ? Icons.account_balance_wallet_rounded : Icons.phone_android_rounded,
                          type: TextInputType.number,
                          theme: theme,
                          suffixWidget: widget.method == "Bank Transfer" ? null : IconButton(
                            icon: Icon(Icons.contact_phone_rounded, color: theme.colorScheme.secondary),
                            onPressed: _pickContact,
                          ),
                          prefixWidget: widget.method == "Bank Transfer" ? null : InkWell(
                            onTap: _showCountryPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_selectedFlag, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 4),
                                  Text(_selectedCountryCode, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  const Icon(Icons.arrow_drop_down, size: 20),
                                  Container(width: 1, height: 24, color: theme.dividerColor.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 8)),
                                ],
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.length >= 7) {
                              _verifyReceiver();
                            }
                            if (widget.method != "Bank Transfer" && _selectedCountryCode == "+252" && val.length >= 2) {
                              if (val.startsWith('61')) {
                                _detectedProvider = l10n.evcPlus;
                              } else if (val.startsWith('65')) {
                                _detectedProvider = l10n.edahab;
                              } else if (val.startsWith('63')) {
                                _detectedProvider = l10n.zaad;
                              } else if (val.startsWith('90')) {
                                _detectedProvider = l10n.sahal;
                              } else {
                                _detectedProvider = null;
                              }
                            } else {
                              _detectedProvider = null;
                            }
                            setState(() {});
                          },
                        ),
                        if (widget.method != "Bank Transfer" && _detectedProvider != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 16),
                            child: Row(
                              children: [
                                Icon(Icons.verified_user_rounded, color: theme.colorScheme.secondary, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _detectedProvider!,
                                  style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        if (widget.method != "Bank Transfer" && _idController.text.isNotEmpty && _idController.text.length < 9)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 16),
                            child: Text(l10n.phoneLengthError, style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),

                        const SizedBox(height: 20),
                        Text(l10n.receiver, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          hint: l10n.receiver,
                          icon: Icons.person_rounded,
                          type: TextInputType.name,
                          theme: theme,
                        ),

                        const SizedBox(height: 20),
                        Text(l10n.purposeOfRemittance, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 12),
                        _buildPurposeDropdown(theme, l10n),

                        const SizedBox(height: 24),
                        Text(l10n.recent, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                        const SizedBox(height: 10),
                        _buildRecentItem(theme, "Mohamed Ali", "615 123 456"),
                        _buildRecentItem(theme, "Ahmed Hersi", "634 987 654"),
                        
                        const SizedBox(height: 30),
                        
                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_idController.text.isNotEmpty && _nameController.text.isNotEmpty && (widget.method != "Bank Transfer" || (_selectedBank != "Add Bank" || _bankNameController.text.isNotEmpty)) && (widget.method == "Bank Transfer" || _idController.text.length >= 7))
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

  Widget _buildBankDropdown(ThemeData theme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedBank,
        dropdownColor: theme.colorScheme.surface,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w900, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_balance_rounded, color: theme.colorScheme.secondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.secondary),
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
            setState(() => _selectedBank = value);
          }
        },
      ),
    );
  }

  Widget _buildPurposeDropdown(ThemeData theme, AppLocalizations l10n) {
    final purposes = _getPurposes(l10n);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedPurpose ?? purposes.first,
        dropdownColor: theme.colorScheme.surface,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w900, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.info_outline_rounded, color: theme.colorScheme.secondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.secondary),
        items: purposes.map((p) => DropdownMenuItem(
          value: p,
          child: Text(p),
        )).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedPurpose = value);
          }
        },
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    final theme = Theme.of(context);
    Color activeColor = isHeader ? Colors.white : theme.colorScheme.secondary;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!);
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? theme.colorScheme.secondary : Colors.grey);

    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 4) : null
          ),
          child: Center(child: isCompleted && !isActive ? Icon(Icons.check, color: isHeader ? theme.colorScheme.secondary : Colors.white, size: 18) : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? theme.colorScheme.secondary : Colors.white) : Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildStepLine(BuildContext context, bool isCompleted, {bool isHeader = false}) { 
    final theme = Theme.of(context);
    Color color = isHeader 
      ? (isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.3)) 
      : (isCompleted ? theme.colorScheme.secondary : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!));
    return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)))); 
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required TextInputType type,
    required ThemeData theme,
    String? prefix,
    Widget? prefixWidget,
    Widget? suffixWidget,
    int? maxLength,
    void Function(String)? onChanged,
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
            maxLength: maxLength,
            onChanged: (v) {
              if (onChanged != null) onChanged(v);
              setState(() {});
            },
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: hint,
              counterText: "",
              prefixIcon: prefixWidget ?? (prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, top: 15),
                    child: Text(prefix, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  )
                : Icon(icon, color: theme.colorScheme.secondary, size: 24)),
              suffixIcon: suffixWidget,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentItem(ThemeData theme, String name, String detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          child: Text(name[0], style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w900)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        subtitle: Text(detail, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: () {
          setState(() {
            _idController.text = detail;
            _nameController.text = name;
          });
        },
      ),
    );
  }
}
