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
import '../../core/models/quick_profile.dart';
import 'review_screen.dart';

class MobileMoneyScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String payoutMethod;
  final String currencyCode;
  final String purpose;

  const MobileMoneyScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.currencyCode,
    required this.purpose,
  });

  @override
  State<MobileMoneyScreen> createState() => _MobileMoneyScreenState();
}

class _MobileMoneyScreenState extends State<MobileMoneyScreen> {
  String? _selectedProvider;
  String? _resolvedAccountName;
  bool _isVerifying = false;
  bool _isMerchantMode = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _merchantFocus = FocusNode();
  final FocusNode _pinFocus = FocusNode();

  final List<Map<String, dynamic>> _providers = [
    {"id": "EVC-Plus", "name": "EVC-Plus", "desc": "Hormuud Telecom", "color": const Color(0xFF1B5E20), "icon": Icons.phone_android_rounded},
    {"id": "e-Dahab", "name": "e-Dahab", "desc": "Dahabshiil", "color": const Color(0xFFFBC02D), "icon": Icons.account_balance_wallet_rounded},
    {"id": "Sahal", "name": "Sahal", "desc": "Golis Telecom", "color": const Color(0xFF0D47A1), "icon": Icons.phonelink_ring_rounded},
    {"id": "ZAAD", "name": "ZAAD", "desc": "Telesom", "color": const Color(0xFFB71C1C), "icon": Icons.flash_on_rounded},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _merchantController.dispose();
    _pinController.dispose();
    _phoneFocus.dispose();
    _merchantFocus.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final identifier = _isMerchantMode ? _merchantController.text : _phoneController.text;
    if (_selectedProvider == null || identifier.isEmpty) return;
    
    HapticFeedback.mediumImpact();

    // Save to quick profiles if verified
    if (_resolvedAccountName != null && !_isMerchantMode) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.saveQuickProfile(QuickProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _resolvedAccountName!,
        walletId: identifier,
        lastReceiverMethod: 'Mobile',
      ));
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          amount: widget.amount,
          receiverName: _resolvedAccountName ?? (_isMerchantMode ? "Merchant" : widget.receiverName),
          receiverPhone: _isMerchantMode ? identifier : widget.receiverPhone,
          method: widget.payoutMethod,
          paymentMethod: "Mobile Money ($_selectedProvider - $identifier)",
          currencyCode: widget.currencyCode,
          purpose: widget.purpose,
        ),
      ),
    );
  }

  String? _getPrefixError(AppLocalizations l10n) {
    if (_phoneController.text.isEmpty || _selectedProvider == null) return null;
    final val = _phoneController.text;
    if (val.length < 2) return null;

    bool isInvalid = false;
    if (_selectedProvider == l10n.evcPlus && !(val.startsWith('61') || val.startsWith('77'))) {
      isInvalid = true;
    } else if (_selectedProvider == l10n.waafi && !(val.startsWith('61') || val.startsWith('62'))) {
      isInvalid = true;
    } else if (_selectedProvider == l10n.edahab && !val.startsWith('65')) {
      isInvalid = true;
    } else if (_selectedProvider == l10n.zaad && !val.startsWith('63')) {
      isInvalid = true;
    } else if (_selectedProvider == l10n.sahal && !val.startsWith('90')) {
      isInvalid = true;
    }

    if (isInvalid) {
      return "Shirkaddani ma laha lambarkan";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scale = context.fontSizeFactor;
    final prefixError = _getPrefixError(l10n);

    final providerList = [
      {"id": l10n.evcPlus, "name": l10n.evcPlus, "desc": "Hormuud Telecom", "color": const Color(0xFF1B5E20), "icon": Icons.phone_android_rounded},
      {"id": l10n.waafi, "name": l10n.waafi, "desc": "Salaam Somali Bank", "color": const Color(0xFF009688), "icon": Icons.account_balance_rounded},
      {"id": l10n.edahab, "name": l10n.edahab, "desc": "Dahabshiil", "color": const Color(0xFFFBC02D), "icon": Icons.account_balance_wallet_rounded},
      {"id": l10n.sahal, "name": l10n.sahal, "desc": "Golis Telecom", "color": const Color(0xFF0D47A1), "icon": Icons.phonelink_ring_rounded},
      {"id": l10n.zaad, "name": l10n.zaad, "desc": "Telesom", "color": const Color(0xFFB71C1C), "icon": Icons.flash_on_rounded},
    ];

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
          l10n.mobileMoney,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * scale, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
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
                            Icon(Icons.phone_android_outlined, color: Colors.white70, size: 16 * scale),
                            SizedBox(width: 8 * scale),
                            Text(
                              "${l10n.mobileMoney}: ${widget.currencyCode} ${widget.amount}",
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
                padding: EdgeInsets.all(20 * scale),
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.selectProvider, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)),
                        SizedBox(height: 16 * scale),
                        
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12 * scale,
                            mainAxisSpacing: 12 * scale,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: providerList.length,
                          itemBuilder: (context, index) {
                            final provider = providerList[index];
                            bool isSelected = _selectedProvider == provider["id"];
                            return FadeInUp(
                              delay: Duration(milliseconds: index * 100),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedProvider = provider["id"] as String);
                                  HapticFeedback.selectionClick();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20 * scale),
                                    border: Border.all(
                                      color: isSelected ? provider["color"] as Color : theme.dividerColor.withValues(alpha: 0.1),
                                      width: 2.5,
                                    ),
                                    boxShadow: isSelected 
                                      ? [BoxShadow(color: (provider["color"] as Color).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]
                                      : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(provider["icon"] as IconData, color: isSelected ? provider["color"] as Color : AppColors.grey, size: 30 * scale),
                                      SizedBox(height: 8 * scale),
                                      Text(provider["name"] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16 * scale)),
                                      Text(provider["desc"] as String, style: TextStyle(color: AppColors.grey, fontSize: 10 * scale, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 32 * scale),
                        _buildRecentBeneficiaries(theme, l10n, scale),
                        SizedBox(height: 32 * scale),
                        
                        // Payment Mode Toggle
                        Container(
                          padding: EdgeInsets.all(4 * scale),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16 * scale),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _isMerchantMode = false;
                                    _resolvedAccountName = null;
                                  }),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12 * scale),
                                    decoration: BoxDecoration(
                                      color: !_isMerchantMode ? theme.colorScheme.secondary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                    child: Center(
                                      child: Text(
                                        l10n.personalPayment,
                                        style: TextStyle(
                                          color: !_isMerchantMode ? Colors.white : AppColors.grey,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14 * scale,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _isMerchantMode = true;
                                    _resolvedAccountName = null;
                                  }),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12 * scale),
                                    decoration: BoxDecoration(
                                      color: _isMerchantMode ? theme.colorScheme.secondary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                    child: Center(
                                      child: Text(
                                        l10n.merchantPayment,
                                        style: TextStyle(
                                          color: _isMerchantMode ? Colors.white : AppColors.grey,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14 * scale,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32 * scale),
                        Text(
                          _isMerchantMode ? l10n.tillNumber : l10n.phoneNumber,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)
                        ),
                        SizedBox(height: 12 * scale),
                        
                        if (!_isMerchantMode)
                          _buildTextField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            hint: "61xxxxxxx",
                            icon: Icons.phone_android_rounded,
                            theme: theme,
                            prefix: "+252 ",
                            maxLength: 9,
                            errorText: prefixError,
                            scale: scale,
                            onChanged: (val) async {
                              if (val.length == 9 && _getPrefixError(l10n) == null) {
                                 setState(() {
                                   _isVerifying = true;
                                   _resolvedAccountName = null;
                                 });
                                 final name = await Provider.of<AppState>(context, listen: false).resolveAccountName(val, type: 'mobile');
                                 if (mounted) {
                                   setState(() {
                                     _isVerifying = false;
                                     _resolvedAccountName = name;
                                     if (name != null) HapticFeedback.lightImpact();
                                   });
                                 }
                              } else {
                                setState(() {
                                  _resolvedAccountName = null;
                                  _isVerifying = false;
                                });
                              }
                              setState(() {});
                            },
                          )
                        else
                          _buildTextField(
                            controller: _merchantController,
                            focusNode: _merchantFocus,
                            hint: l10n.enterMerchantTill,
                            icon: Icons.store_rounded,
                            theme: theme,
                            maxLength: 7,
                            scale: scale,
                            onChanged: (val) async {
                              if (val.length >= 5) {
                                 setState(() {
                                   _isVerifying = true;
                                   _resolvedAccountName = null;
                                 });
                                 final name = await Provider.of<AppState>(context, listen: false).resolveAccountName(val, type: 'merchant');
                                 if (mounted) {
                                   setState(() {
                                     _isVerifying = false;
                                     _resolvedAccountName = name;
                                     if (name != null) HapticFeedback.lightImpact();
                                   });
                                 }
                              } else {
                                setState(() {
                                  _resolvedAccountName = null;
                                  _isVerifying = false;
                                });
                              }
                              setState(() {});
                            },
                          ),
                        if (_isVerifying)
                          Padding(
                            padding: EdgeInsets.only(top: 8 * scale, left: 16 * scale),
                            child: Row(
                              children: [
                                SizedBox(width: 12 * scale, height: 12 * scale, child: CircularProgressIndicator(strokeWidth: 2 * scale)),
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
                                  Text(
                                    _isMerchantMode ? "${l10n.merchantResolved}: $_resolvedAccountName" : _resolvedAccountName!,
                                    style: TextStyle(fontSize: 12 * scale, color: Colors.green, fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!_isMerchantMode && _phoneController.text.isNotEmpty && _phoneController.text.length < 9)
                          Padding(
                            padding: EdgeInsets.only(top: 8 * scale, left: 16 * scale),
                            child: Text(l10n.phoneLengthError, style: TextStyle(color: Colors.red.shade700, fontSize: 12 * scale, fontWeight: FontWeight.bold)),
                          ),

                        SizedBox(height: 40 * scale),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56 * scale,
                          child: ElevatedButton(
                            onPressed: (_selectedProvider != null && 
                              ((!_isMerchantMode && _phoneController.text.length == 9 && prefixError == null) ||
                               (_isMerchantMode && _merchantController.text.length >= 5 && _resolvedAccountName != null))) 
                              ? _handleContinue : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
                              elevation: 4,
                              disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.confirmPaymentAmount(NumberFormat.simpleCurrency(name: widget.currencyCode).format(Provider.of<AppState>(context, listen: false).calculateTotalForSource(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0, "Mobile Money"))),
                                style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildRecentBeneficiaries(ThemeData theme, AppLocalizations l10n, double scale) {
    final state = Provider.of<AppState>(context);
    if (state.quickProfiles.isEmpty) return const SizedBox.shrink();

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
            itemCount: state.quickProfiles.length,
            itemBuilder: (context, index) {
              final profile = state.quickProfiles[index];
              return FadeInRight(
                delay: Duration(milliseconds: index * 100),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    String phone = profile.walletId;
                    if (phone.startsWith('+252')) phone = phone.substring(4);
                    if (phone.startsWith('252')) phone = phone.substring(3);
                    
                    setState(() {
                      _isMerchantMode = false;
                      _phoneController.text = phone;
                      _resolvedAccountName = profile.name;
                      
                      // Auto-select provider based on prefix
                      if (phone.startsWith('61') || phone.startsWith('77')) {
                        // Default to EVC, user can switch to Waafi if needed
                        _selectedProvider = l10n.evcPlus;
                      } else if (phone.startsWith('62')) {
                        _selectedProvider = l10n.waafi;
                      } else if (phone.startsWith('65')) {
                        _selectedProvider = l10n.edahab;
                      } else if (phone.startsWith('63')) {
                        _selectedProvider = l10n.zaad;
                      } else if (phone.startsWith('90')) {
                        _selectedProvider = l10n.sahal;
                      }
                    });
                  },
                  child: Container(
                    width: 80 * scale,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        if (profile.avatarUrl != null)
                          CircleAvatar(
                            radius: 28 * scale,
                            backgroundImage: NetworkImage(profile.avatarUrl!),
                          )
                        else
                          CircleAvatar(
                            radius: 28 * scale,
                            backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                            child: Text(
                              profile.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary, fontSize: 18 * scale),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          profile.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required TextEditingController controller, 
    required FocusNode focusNode, 
    required String hint, 
    required IconData icon, 
    required ThemeData theme,
    required double scale,
    bool isPin = false,
    String? prefix,
    int? maxLength,
    String? errorText,
    void Function(String)? onChanged,
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
                borderRadius: BorderRadius.circular(24 * scale),
                border: Border.all(
                  color: errorText != null 
                    ? Colors.red 
                    : (hasFocus ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1)), 
                  width: 1.5
                ),
                boxShadow: hasFocus && errorText == null ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10 * scale)] : null,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                obscureText: isPin,
                maxLength: maxLength,
                onChanged: (v) {
                  if (v.isNotEmpty) HapticFeedback.selectionClick();
                  if (onChanged != null) onChanged(v);
                  setState(() {});
                },
                style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900),
                decoration: InputDecoration(
                  hintText: hint,
                  counterText: "",
                  prefixIcon: prefix != null
                    ? Padding(
                        padding: EdgeInsets.only(left: 16 * scale, top: 15 * scale),
                        child: Text(prefix, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * scale)),
                      )
                    : Icon(icon, color: theme.colorScheme.secondary, size: 24 * scale),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16 * scale),
                ),
              ),
            ),
            if (errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 8 * scale, left: 16 * scale),
                child: Text(errorText, style: TextStyle(color: Colors.red.shade700, fontSize: 12 * scale, fontWeight: FontWeight.bold)),
              ),
          ],
        );
      },
    );
  }

}
