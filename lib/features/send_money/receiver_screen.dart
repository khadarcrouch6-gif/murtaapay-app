import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/contact_sync_list.dart';
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
  bool _isVerifying = false;
  bool _isFavorite = false;

  // Mock Recent Items
  final List<Map<String, String>> _recentItems = [
    {"name": "Mohamed Ali", "detail": "615 123 456"},
    {"name": "Ahmed Hersi", "detail": "634 987 654"},
  ];

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
    
    // Handle leading 0 for Somalia
    if (cleanPhone.startsWith('0') && cleanPhone.length >= 9) {
      _selectedCountryCode = "+252";
      _selectedFlag = "🇸🇴";
      cleanPhone = cleanPhone.substring(1);
    } else {
      for (var c in _countries) {
        if (cleanPhone.startsWith(c["code"]!)) {
          _selectedCountryCode = c["code"]!;
          _selectedFlag = "🇸🇴";
          cleanPhone = cleanPhone.substring(c["code"]!.length);
          break;
        }
      }
    }
    _idController.text = _applyMask(cleanPhone);
    if (cleanPhone.length >= 7) _verifyReceiver();
  }

  String _applyMask(String text) {
    text = text.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      formatted += text[i];
      if ((i == 2 || i == 5) && i != text.length - 1) {
        formatted += ' ';
      }
    }
    return formatted;
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

  String? _getValidationError(AppLocalizations l10n) {
    if (_idController.text.isEmpty) return null;

    if (widget.method == "Bank Transfer") {
      // Return null to allow any length for bank accounts as requested
      return null;
    } else {
      final phone = _idController.text.replaceAll(' ', '');
      if (phone.length < 7) return l10n.phoneLengthError;
      return null;
    }
  }

  void _verifyReceiver() async {
    final rawId = _idController.text.replaceAll(' ', '');
    // For Bank Transfer, we might need a different length check for auto-verification
    // but the user wants it flexible. Let's trigger verification if length >= 5 for banks
    final minLength = widget.method == "Bank Transfer" ? 5 : 7;
    if (rawId.length < minLength) return;
    
    setState(() => _isVerifying = true);
    
    // Simulate API Call for name lookup
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isVerifying = false;
        // Mocking a name based on the number - in real app, this comes from API
        if (rawId.contains("615")) {
          _nameController.text = "Mohamed Hassan Ali";
        } else if (rawId.contains("634")) {
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            Expanded(
              child: ContactSyncList(
                onContactSelected: (contact, murtaaxName, verifiedId) {
                  if (contact.phones.isNotEmpty || verifiedId != null) {
                    String phone = (verifiedId ?? contact.phones.first.number).replaceAll(RegExp(r'[\s\-\(\)]'), '');
                    
                    // Handle leading 0 for Somalia
                    if (phone.startsWith('0') && phone.length >= 9) {
                       phone = phone.substring(1);
                       setState(() {
                         _selectedCountryCode = "+252";
                         _selectedFlag = "🇸🇴";
                       });
                    } else {
                      for (var c in _countries) {
                        if (phone.startsWith(c["code"]!)) {
                          setState(() {
                            _selectedCountryCode = c["code"]!;
                            _selectedFlag = c["flag"]!;
                          });
                          phone = phone.substring(c["code"]!.length);
                          break;
                        }
                      }
                    }

                    setState(() {
                      _idController.text = _applyMask(phone);
                      _nameController.text = murtaaxName ?? contact.displayName ?? "No Name";
                    });
                    if (phone.length >= 7) _verifyReceiver();
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, String>> _banks = [
    {"name": "IBS Bank", "image": "assets/images/ibs_logo.png"},
    {"name": "Premier Bank", "image": "assets/images/premier_logo.png"},
    {"name": "Salaam Bank", "image": "assets/images/salaam_logo.png"},
    {"name": "Amal Bank", "image": "assets/images/amal_logo.png"},
    {"name": "Dahabshil Bank", "image": "assets/images/dahabshil_logo.png"},
    {"name": "MyBank", "image": "assets/images/mybank_logo.png"},
    {"name": "Amana Bank", "image": "assets/images/amana_logo.png"},
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
              RepaintBoundary(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: Column(
                        children: [
                          // Amount Display in Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "${widget.currencyCode} ${widget.amount}",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
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
                          RepaintBoundary(child: _buildBankDropdown(theme, l10n)),

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
                          hint: widget.method == "Bank Transfer" ? l10n.accountNumber : "XXX XXX XXX",
                          icon: widget.method == "Bank Transfer" ? Icons.account_balance_wallet_rounded : Icons.phone_android_rounded,
                          type: widget.method == "Bank Transfer" ? TextInputType.text : TextInputType.number,
                          theme: theme,
                          errorText: _getValidationError(l10n),
                          suffixWidget: _isVerifying 
                            ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey)))
                            : (widget.method == "Bank Transfer" ? null : IconButton(
                                icon: Icon(Icons.contact_phone_rounded, color: theme.colorScheme.secondary),
                                onPressed: _pickContact,
                              )),
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
                            if (widget.method == "Bank Transfer") {
                               if (val.length >= 8) _verifyReceiver();
                               setState(() {});
                               return;
                            }

                            final rawVal = val.replaceAll(' ', '');
                            _idController.value = TextEditingValue(
                              text: _applyMask(rawVal),
                              selection: TextSelection.collapsed(offset: _applyMask(rawVal).length),
                            );

                            if (rawVal.length >= 7) {
                              _verifyReceiver();
                            }
                            if (widget.method != "Bank Transfer" && _selectedCountryCode == "+252" && rawVal.length >= 2) {
                              if (rawVal.startsWith('61')) {
                                _detectedProvider = l10n.evcPlus;
                              } else if (rawVal.startsWith('65')) {
                                _detectedProvider = l10n.edahab;
                              } else if (rawVal.startsWith('63')) {
                                _detectedProvider = l10n.zaad;
                              } else if (rawVal.startsWith('90')) {
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

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.receiver, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            if (_nameController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(_isFavorite ? Icons.star_rounded : Icons.star_outline_rounded, 
                                  color: _isFavorite ? Colors.amber : Colors.grey),
                                onPressed: () => setState(() => _isFavorite = !_isFavorite),
                              ),
                          ],
                        ),
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

                        if (_recentItems.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(l10n.recent, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                          const SizedBox(height: 10),
                          ..._recentItems.map((item) => _buildRecentItem(theme, item["name"]!, item["detail"]!)),
                        ],
                        
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
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                _banks.firstWhere((b) => b["name"] == _selectedBank, orElse: () => _banks.first)["image"]!,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.account_balance_rounded, color: theme.colorScheme.secondary),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.secondary),
        items: [
          ..._banks.map((bank) => DropdownMenuItem(
            value: bank["name"],
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(bank["image"]!, width: 24, height: 24, errorBuilder: (c, e, s) => const Icon(Icons.account_balance, size: 20)),
                ),
                const SizedBox(width: 12),
                Text(bank["name"]!),
              ],
            ),
          )),
          DropdownMenuItem(
            value: "Add Bank",
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, size: 20),
                const SizedBox(width: 12),
                Text(l10n.addBank),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedBank = value;
              _idController.clear();
              _nameController.clear();
              _bankNameController.clear();
              _isVerifying = false;
              _detectedProvider = null;
            });
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? 36 : 32, 
          height: isActive ? 36 : 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            boxShadow: isActive ? [BoxShadow(color: activeColor.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2)] : null,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 4) : null
          ),
          child: Center(
            child: isCompleted && !isActive 
              ? Icon(Icons.check, color: isHeader ? theme.colorScheme.secondary : Colors.white, size: 18) 
              : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? theme.colorScheme.secondary : Colors.white) : Colors.white, fontSize: 14, fontWeight: FontWeight.w900))
          ),
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
    
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: 3, 
        margin: const EdgeInsets.symmetric(horizontal: 6), 
        decoration: BoxDecoration(
          color: color, 
          borderRadius: BorderRadius.circular(10)
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
    String? prefix,
    Widget? prefixWidget,
    Widget? suffixWidget,
    int? maxLength,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        bool hasFocus = focusNode.hasFocus;
        Color borderColor = errorText != null 
          ? Colors.red.shade700 
          : (hasFocus ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                boxShadow: hasFocus && errorText == null 
                  ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10)] 
                  : null,
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
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 16),
                child: Text(errorText, style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
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
