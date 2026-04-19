import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'payment_screen.dart';

class WalletReceiverScreen extends StatefulWidget {
  final String amount;
  final String method;
  final String currencyCode;
  final String? prefilledName;
  final String? prefilledPhone;

  const WalletReceiverScreen({
    super.key, 
    required this.amount, 
    required this.method, 
    required this.currencyCode,
    this.prefilledName,
    this.prefilledPhone,
  });

  @override
  State<WalletReceiverScreen> createState() => _WalletReceiverScreenState();
}

class _WalletReceiverScreenState extends State<WalletReceiverScreen> {
  final TextEditingController _walletIdController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _verifiedReceiverName = "";
  String? _errorMessage;
  String? _selectedPurpose;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledName != null) {
      _verifiedReceiverName = widget.prefilledName!;
    }
    if (widget.prefilledPhone != null) {
      String phone = widget.prefilledPhone!.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (phone.startsWith('+252')) phone = phone.substring(4);
      else if (phone.startsWith('252')) phone = phone.substring(3);
      _walletIdController.text = phone;
    }
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

  void _lookupWalletId(String value) {
    if (value.length >= 6) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isSearching = true;
        _errorMessage = null;
        _verifiedReceiverName = "";
      });

      final appState = Provider.of<AppState>(context, listen: false);
      appState.verifyWalletId(value).then((name) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            if (name != null) {
              _verifiedReceiverName = name;
            } else {
              _errorMessage = l10n.invalidWalletId;
            }
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            if (error.toString().contains('self_transfer_error')) {
              _errorMessage = l10n.cannotSendToSelf;
            } else {
              _errorMessage = l10n.invalidWalletId;
            }
          });
        }
      });
    } else {
      setState(() {
        _isSearching = false;
        _verifiedReceiverName = "";
        _errorMessage = null;
      });
    }
  }

  void _handleContinue(AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: widget.amount,
          receiverName: _verifiedReceiverName,
          receiverPhone: _walletIdController.text,
          payoutMethod: widget.method,
          currencyCode: widget.currencyCode,
          purpose: _selectedPurpose ?? _getPurposes(l10n).first,
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
        if (fullContact != null) {
          // In Wallet transfer, we might use phone number to find Wallet ID 
          // or if the contact has a custom field for Wallet ID.
          // For now, let's extract the phone and try to use it.
          if (fullContact.phones.isNotEmpty) {
            String phone = fullContact.phones.first.number.replaceAll(RegExp(r'[\s\-\(\)]'), '');
            // Strip common country codes if present to get local number which might be the ID
            if (phone.startsWith('+252')) phone = phone.substring(4);
            else if (phone.startsWith('252')) phone = phone.substring(3);
            
            setState(() {
              _walletIdController.text = phone;
            });
            _lookupWalletId(phone);
          }
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24), onPressed: () => Navigator.pop(context)),
        title: Text(l10n.murtaaxTransfer, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white, letterSpacing: -0.5)),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
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
          Expanded(
            child: Center(
              child: MaxWidthBox(
                maxWidth: 500,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          l10n.enterReceiverWalletId,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.walletIdTransferNotice,
                          style: TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        // Input Field (High Visibility)
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _errorMessage != null ? Colors.red : (_focusNode.hasFocus ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1)), width: 2),
                            boxShadow: _focusNode.hasFocus ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10)] : null,
                          ),
                          child: TextField(
                            controller: _walletIdController,
                            focusNode: _focusNode,
                            onChanged: _lookupWalletId,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                            decoration: InputDecoration(
                              hintText: l10n.enterWalletIdHint,
                              prefixIcon: Icon(Icons.account_circle_outlined, color: _errorMessage != null ? Colors.red : theme.colorScheme.secondary, size: 24),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isSearching)
                                    Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.colorScheme.secondary)))
                                  else
                                    const Icon(Icons.search_rounded),
                                  IconButton(
                                    icon: Icon(Icons.contact_phone_rounded, color: theme.colorScheme.secondary),
                                    onPressed: _pickContact,
                                  ),
                                ],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),

                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                            child: FadeIn(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        if (_verifiedReceiverName.isNotEmpty) ...[
                          FadeIn(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.2), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: theme.colorScheme.secondary,
                                    radius: 18,
                                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.verifiedReceiverLabel, style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w900, fontSize: 11)),
                                        Text(_verifiedReceiverName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(l10n.purposeOfRemittance, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          const SizedBox(height: 12),
                          _buildPurposeDropdown(theme, l10n),
                        ],

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.recentContacts, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                            TextButton(onPressed: () {}, child: Text(l10n.seeAll, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: theme.colorScheme.secondary))),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Horizontal Recents (Bigger)
                        SizedBox(
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildRecentUser(theme, "AR", "Ayaanle", "102234"),
                              _buildRecentUser(theme, "MA", "Mohamed", "204456"),
                              _buildRecentUser(theme, "SH", "Sahra", "309987"),
                              _buildRecentUser(theme, "HM", "Hassan", "401122"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Action Button moved back to body
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _verifiedReceiverName.isNotEmpty ? () => _handleContinue(l10n) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                              disabledForegroundColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.3) : Colors.white70,
                            ),
                            child: Text(l10n.continueToReview, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor)),
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

  Widget _buildRecentUser(ThemeData theme, String initials, String name, String id) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _walletIdController.text = id;
        _lookupWalletId(id);
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Text(initials, style: TextStyle(fontWeight: FontWeight.w900, color: theme.primaryColor, fontSize: 18)),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
            Text(id, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _walletIdController.dispose();
    _focusNode.dispose();
    super.dispose();
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
}
