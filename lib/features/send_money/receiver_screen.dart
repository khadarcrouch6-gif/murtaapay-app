import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/contact_sync_list.dart';
import '../../core/widgets/step_indicator.dart';
import '../../l10n/app_localizations.dart';
import 'payment_screen.dart';

class ReceiverScreen extends StatefulWidget {
  final String amount;
  final String method;
  final String currencyCode;
  final String senderSource;
  final String? cardId;
  final String? prefilledName;
  final String? prefilledPhone;

  const ReceiverScreen({
    super.key, 
    required this.amount, 
    required this.method, 
    required this.currencyCode,
    required this.senderSource,
    this.cardId,
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

    final phone = _idController.text.replaceAll(' ', '');
    if (phone.length < 7) return l10n.phoneLengthError;

    // Validation for Somali Mobile Money Prefixes
    if (_selectedCountryCode == "+252" && phone.length >= 2) {
      bool isInvalid = false;
      if (widget.method == "EVC Plus" && !(phone.startsWith('61') || phone.startsWith('77'))) {
        isInvalid = true;
      } else if (widget.method == "ZAAD Service" && !phone.startsWith('63')) {
        isInvalid = true;
      } else if (widget.method == "e-Dahab" && !phone.startsWith('65')) {
        isInvalid = true;
      } else if (widget.method == "Sahal" && !phone.startsWith('90')) {
        isInvalid = true;
      }
      
      if (isInvalid) {
        return "Shirkaddani ma laha lambarkan";
      }
    }
    return null;
  }

  void _verifyReceiver() async {
    final rawId = _idController.text.replaceAll(' ', '');
    if (rawId.length < 7) return;
    
    setState(() => _isVerifying = true);
    
    final state = Provider.of<AppState>(context, listen: false);
    
    // Simulate API Call delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      final name = await state.resolveAccountName(rawId, type: 'mobile');
      setState(() {
        _isVerifying = false;
        if (name != null) {
          _nameController.text = name;
        } else {
          // If not found in mocks, we can leave it or set a placeholder
          // _nameController.text = "Unknown Receiver";
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
    String finalMethod = _detectedProvider ?? widget.method;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              Expanded(
                child: PaymentScreen(
                  amount: widget.amount,
                  receiverName: _nameController.text,
                  receiverPhone: "$_selectedCountryCode ${_idController.text}",
                  payoutMethod: finalMethod,
                  paymentMethod: widget.senderSource,
                  cardId: widget.cardId,
                  currencyCode: widget.currencyCode,
                  purpose: _selectedPurpose ?? _getPurposes(l10n).first,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * context.fontSizeFactor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.receiverDetails,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22 * context.fontSizeFactor,
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
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30 * context.fontSizeFactor), bottomRight: Radius.circular(30 * context.fontSizeFactor)),
                  ),
                  padding: EdgeInsets.only(bottom: 25 * context.fontSizeFactor, left: 20 * context.fontSizeFactor, right: 20 * context.fontSizeFactor),
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: Column(
                        children: [
                          // Amount Display in Header
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(widget.senderSource == "Main Wallet" ? Icons.account_balance_wallet_outlined : Icons.credit_card_outlined, color: Colors.white70, size: 16 * context.fontSizeFactor),
                                SizedBox(width: 8 * context.fontSizeFactor),
                                Text(
                                  "${widget.senderSource}: ${widget.currencyCode} ${widget.amount}",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14 * context.fontSizeFactor),
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
              ),
              Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: Padding(
                    padding: EdgeInsets.all(20.0 * context.fontSizeFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16 * context.fontSizeFactor),
                        
                        Text(
                          l10n.enterReceiverPhone,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor),
                        ),
                        SizedBox(height: 12 * context.fontSizeFactor),
                        
                        _buildTextField(
                          controller: _idController,
                          focusNode: _idFocus,
                          hint: "XXX XXX XXX",
                          icon: Icons.phone_android_rounded,
                          type: TextInputType.number,
                          theme: theme,
                          errorText: _getValidationError(l10n),
                          suffixWidget: _isVerifying 
                            ? Padding(padding: EdgeInsets.all(12 * context.fontSizeFactor), child: SizedBox(width: 20 * context.fontSizeFactor, height: 20 * context.fontSizeFactor, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.grey)))
                            : IconButton(
                                icon: Icon(Icons.contact_phone_rounded, color: theme.colorScheme.secondary, size: 24 * context.fontSizeFactor),
                                onPressed: _pickContact,
                              ),
                          prefixWidget: InkWell(
                            onTap: _showCountryPicker,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_selectedFlag, style: TextStyle(fontSize: 20 * context.fontSizeFactor)),
                                  SizedBox(width: 4 * context.fontSizeFactor),
                                  Text(_selectedCountryCode, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor)),
                                  Icon(Icons.arrow_drop_down, size: 20 * context.fontSizeFactor),
                                  Container(width: 1 * context.fontSizeFactor, height: 24 * context.fontSizeFactor, color: theme.dividerColor.withValues(alpha: 0.2), margin: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor)),
                                ],
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final rawVal = val.replaceAll(' ', '');
                            _idController.value = TextEditingValue(
                              text: _applyMask(rawVal),
                              selection: TextSelection.collapsed(offset: _applyMask(rawVal).length),
                            );

                            if (rawVal.length >= 7) {
                              _verifyReceiver();
                            }
                            if (_selectedCountryCode == "+252" && rawVal.length >= 2) {
                              if (rawVal.startsWith('61') || rawVal.startsWith('77')) {
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
                        if (_detectedProvider != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8 * context.fontSizeFactor, left: 16 * context.fontSizeFactor),
                            child: Row(
                              children: [
                                Icon(Icons.verified_user_rounded, color: theme.colorScheme.secondary, size: 14 * context.fontSizeFactor),
                                SizedBox(width: 4 * context.fontSizeFactor),
                                Text(
                                  _detectedProvider!,
                                  style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                        if (_nameController.text.isNotEmpty || _isVerifying) ...[
                          SizedBox(height: 24 * context.fontSizeFactor),
                          FadeInDown(
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              padding: EdgeInsets.all(16 * context.fontSizeFactor),
                              decoration: BoxDecoration(
                                color: _isVerifying ? Colors.grey[100] : theme.colorScheme.secondary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                                border: Border.all(color: _isVerifying ? Colors.grey[300]! : theme.colorScheme.secondary.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10 * context.fontSizeFactor),
                                    decoration: BoxDecoration(
                                      color: _isVerifying ? Colors.grey[300] : theme.colorScheme.secondary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isVerifying ? Icons.sync : Icons.verified_user_rounded,
                                      color: _isVerifying ? Colors.grey[600] : theme.colorScheme.secondary,
                                      size: 20 * context.fontSizeFactor,
                                    ),
                                  ),
                                  SizedBox(width: 16 * context.fontSizeFactor),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isVerifying ? l10n.searching : l10n.verifiedReceiverLabel,
                                          style: TextStyle(
                                            color: _isVerifying ? Colors.grey[600] : theme.colorScheme.secondary,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12 * context.fontSizeFactor,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        SizedBox(height: 2 * context.fontSizeFactor),
                                        Text(
                                          _isVerifying ? l10n.checkingName : _nameController.text,
                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: 20 * context.fontSizeFactor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.fullName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor)),
                            if (_nameController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(_isFavorite ? Icons.star_rounded : Icons.star_outline_rounded, 
                                  color: _isFavorite ? Colors.amber : Colors.grey, size: 24 * context.fontSizeFactor),
                                onPressed: () => setState(() => _isFavorite = !_isFavorite),
                              ),
                          ],
                        ),
                        SizedBox(height: 12 * context.fontSizeFactor),
                        _buildTextField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          hint: l10n.fullName,
                          icon: Icons.person_rounded,
                          type: TextInputType.name,
                          theme: theme,
                        ),

                        SizedBox(height: 20 * context.fontSizeFactor),
                        Text(l10n.purposeOfRemittance, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor)),
                        SizedBox(height: 12 * context.fontSizeFactor),
                        _buildPurposeDropdown(theme, l10n),

                        if (_recentItems.isNotEmpty) ...[
                          SizedBox(height: 24 * context.fontSizeFactor),
                          Text(l10n.recent, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17 * context.fontSizeFactor)),
                          SizedBox(height: 10 * context.fontSizeFactor),
                          ..._recentItems.map((item) => _buildRecentItem(theme, item["name"]!, item["detail"]!)),
                        ],
                        
                        SizedBox(height: 30 * context.fontSizeFactor),
                        
                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 56 * context.fontSizeFactor,
                          child: ElevatedButton(
                            onPressed: (_idController.text.isNotEmpty && _nameController.text.isNotEmpty && _idController.text.length >= 7)
                                ? () => _handleContinue(l10n) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                              elevation: 4,
                              shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                            ),
                            child: Text(
                              l10n.continueToReview,
                              style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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

  Widget _buildPurposeDropdown(ThemeData theme, AppLocalizations l10n) {
    final purposes = _getPurposes(l10n);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 2 * context.fontSizeFactor,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedPurpose ?? purposes.first,
        dropdownColor: theme.colorScheme.surface,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.info_outline_rounded, color: theme.colorScheme.secondary, size: 24 * context.fontSizeFactor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor, horizontal: 16 * context.fontSizeFactor),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.secondary, size: 24 * context.fontSizeFactor),
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
                borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                border: Border.all(
                  color: borderColor,
                  width: 2 * context.fontSizeFactor,
                ),
                boxShadow: hasFocus && errorText == null 
                  ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10 * context.fontSizeFactor)] 
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
                style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.w900),
                decoration: InputDecoration(
                  hintText: hint,
                  counterText: "",
                  prefixIcon: prefixWidget ?? (prefix != null
                    ? Padding(
                        padding: EdgeInsets.only(left: 16 * context.fontSizeFactor, top: 15 * context.fontSizeFactor),
                        child: Text(prefix, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor)),
                      )
                    : Icon(icon, color: theme.colorScheme.secondary, size: 24 * context.fontSizeFactor)),
                  suffixIcon: suffixWidget,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
                ),
              ),
            ),
            if (errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 8 * context.fontSizeFactor, left: 16 * context.fontSizeFactor),
                child: Text(errorText, style: TextStyle(color: Colors.red.shade700, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecentItem(ThemeData theme, String name, String detail) {
    return Container(
      margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20 * context.fontSizeFactor), border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5 * context.fontSizeFactor)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          child: Text(name[0], style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor)),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * context.fontSizeFactor)),
        subtitle: Text(detail, style: TextStyle(fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16 * context.fontSizeFactor, color: Colors.grey),
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
