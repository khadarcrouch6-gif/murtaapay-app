import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/contact_sync_list.dart';
import '../../core/widgets/step_indicator.dart';
import '../../l10n/app_localizations.dart';
import 'payment_screen.dart';

class WalletReceiverScreen extends StatefulWidget {
  final String amount;
  final String method;
  final String currencyCode;
  final String senderSource;
  final String? cardId;
  final String? prefilledName;
  final String? prefilledPhone;

  const WalletReceiverScreen({
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
          paymentMethod: widget.senderSource,
          cardId: widget.cardId,
          currencyCode: widget.currencyCode,
          purpose: _selectedPurpose ?? _getPurposes(l10n).first,
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
                  if (contact.phones.isNotEmpty) {
                    String phone = contact.phones.first.number.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                    if (phone.startsWith('+252')) {
                      phone = phone.substring(4);
                    } else if (phone.startsWith('252')) {
                      phone = phone.substring(3);
                    }
                    
                    setState(() {
                      _walletIdController.text = phone;
                      if (murtaaxName != null) {
                        _verifiedReceiverName = murtaaxName;
                        _errorMessage = null;
                      } else {
                        _lookupWalletId(phone);
                      }
                    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final purposes = _getPurposes(l10n);
    final scale = context.fontSizeFactor;
    _selectedPurpose ??= purposes.first;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * scale), onPressed: () => Navigator.pop(context)),
        title: Text(l10n.murtaaxTransfer, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 22 * scale, color: Colors.white, letterSpacing: -0.5)),
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
                          Icon(widget.senderSource == "Main Wallet" ? Icons.account_balance_wallet_outlined : Icons.credit_card_outlined, color: Colors.white70, size: 16 * scale),
                          SizedBox(width: 8 * scale),
                          Text(
                            "${widget.senderSource}: ${widget.currencyCode} ${widget.amount}",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14 * scale),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
          Expanded(
            child: Center(
              child: MaxWidthBox(
                maxWidth: 500,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.0 * scale, vertical: 10 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16 * scale),
                        Text(
                          l10n.enterReceiverWalletId,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          l10n.walletIdTransferNotice,
                          style: TextStyle(color: AppColors.grey, fontSize: 12 * scale, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16 * scale),
                        
                        // Input Field (High Visibility)
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20 * scale),
                            border: Border.all(color: _errorMessage != null ? Colors.red : (_focusNode.hasFocus ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1)), width: 2 * scale),
                            boxShadow: _focusNode.hasFocus ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10 * scale)] : null,
                          ),
                          child: TextField(
                            controller: _walletIdController,
                            focusNode: _focusNode,
                            onChanged: _lookupWalletId,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                            decoration: InputDecoration(
                              hintText: l10n.enterWalletIdHint,
                              prefixIcon: Icon(Icons.account_circle_outlined, color: _errorMessage != null ? Colors.red : theme.colorScheme.secondary, size: 24 * scale),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isSearching)
                                    Padding(padding: EdgeInsets.all(12 * scale), child: SizedBox(width: 18 * scale, height: 18 * scale, child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.colorScheme.secondary)))
                                  else
                                    Icon(Icons.search_rounded, size: 24 * scale),
                                  IconButton(
                                    icon: Icon(Icons.contact_phone_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
                                    onPressed: _pickContact,
                                  ),
                                ],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14 * scale),
                            ),
                          ),
                        ),

                        if (_errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.0 * scale, left: 12.0 * scale),
                            child: FadeIn(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red, fontSize: 13 * scale, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                        if (_verifiedReceiverName.isNotEmpty || _isSearching) ...[
                          SizedBox(height: 24 * scale),
                          FadeInDown(
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              padding: EdgeInsets.all(16 * scale),
                              decoration: BoxDecoration(
                                color: _isSearching ? Colors.grey[100] : theme.colorScheme.secondary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20 * scale),
                                border: Border.all(color: _isSearching ? Colors.grey[300]! : theme.colorScheme.secondary.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10 * scale),
                                    decoration: BoxDecoration(
                                      color: _isSearching ? Colors.grey[300] : theme.colorScheme.secondary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isSearching ? Icons.sync : Icons.verified_user_rounded,
                                      color: _isSearching ? Colors.grey[600] : theme.colorScheme.secondary,
                                      size: 20 * scale,
                                    ),
                                  ),
                                  SizedBox(width: 16 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isSearching ? l10n.searching : l10n.verifiedReceiverLabel,
                                          style: TextStyle(
                                            color: _isSearching ? Colors.grey[600] : theme.colorScheme.secondary,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12 * scale,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        SizedBox(height: 2 * scale),
                                        Text(
                                          _isSearching ? "Checking wallet ID..." : _verifiedReceiverName,
                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20 * scale),
                          Text(l10n.purposeOfRemittance, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)),
                          SizedBox(height: 12 * scale),
                          _buildPurposeDropdown(theme, l10n, scale),
                        ],

                        SizedBox(height: 24 * scale),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.recentContacts, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17 * scale)),
                            TextButton(onPressed: () {}, child: Text(l10n.seeAll, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * scale, color: theme.colorScheme.secondary))),
                          ],
                        ),
                        SizedBox(height: 8 * scale),

                        // Horizontal Recents (Bigger)
                        SizedBox(
                          height: 110 * scale,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildRecentUser(theme, "AR", "Ayaanle", "102234", scale),
                              _buildRecentUser(theme, "MA", "Mohamed", "204456", scale),
                              _buildRecentUser(theme, "SH", "Sahra", "309987", scale),
                              _buildRecentUser(theme, "HM", "Hassan", "401122", scale),
                            ],
                          ),
                        ),

                        SizedBox(height: 30 * scale),

                        // Action Button moved back to body
                        SizedBox(
                          width: double.infinity,
                          height: 56 * scale,
                          child: ElevatedButton(
                            onPressed: _verifiedReceiverName.isNotEmpty ? () => _handleContinue(l10n) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
                              elevation: 4,
                              shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                              disabledForegroundColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.3) : Colors.white70,
                            ),
                            child: Text(l10n.continueToReview, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ),
                        ),
                        SizedBox(height: 24 * scale),
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

  Widget _buildRecentUser(ThemeData theme, String initials, String name, String id, double scale) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _walletIdController.text = id;
        _lookupWalletId(id);
      },
      child: Container(
        width: 90 * scale,
        margin: EdgeInsets.only(right: 16 * scale),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32 * scale,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Text(initials, style: TextStyle(fontWeight: FontWeight.w900, color: theme.primaryColor, fontSize: 18 * scale)),
            ),
            SizedBox(height: 10 * scale),
            Text(name, style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
            Text(id, style: TextStyle(fontSize: 11 * scale, fontWeight: FontWeight.bold, color: Colors.grey[600])),
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

  Widget _buildPurposeDropdown(ThemeData theme, AppLocalizations l10n, double scale) {
    final purposes = _getPurposes(l10n);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 2 * scale,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedPurpose ?? purposes.first,
        dropdownColor: theme.colorScheme.surface,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w900, fontSize: 16 * scale),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.info_outline_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 16 * scale),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
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
