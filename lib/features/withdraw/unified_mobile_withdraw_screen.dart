import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/widgets/failure_screen.dart';
import '../navigation/main_navigation.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/pin_entry_dialog.dart';
import 'mixins/withdrawal_logic_mixin.dart';

class UnifiedMobileWithdrawScreen extends StatefulWidget {
  final String source; // "Wallet" or "Virtual Card"
  final String? cardId;
  final double? initialAmount;

  const UnifiedMobileWithdrawScreen({
    super.key,
    required this.source,
    this.cardId,
    this.initialAmount,
  });

  @override
  State<UnifiedMobileWithdrawScreen> createState() => _UnifiedMobileWithdrawScreenState();
}

class _UnifiedMobileWithdrawScreenState extends State<UnifiedMobileWithdrawScreen> with WithdrawalLogicMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String? _selectedProvider;
  String? _selectedPurpose;
  String? _detectedName;
  bool _isResolvingName = false;
  Timer? _debounce;

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }
  }

  void _lookupMobileName(String val, AppState state) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Check local cache/recents first via mixin
    final localName = lookupName(val, state);
    if (localName != null) {
      setState(() => _detectedName = localName);
      return;
    }

    if (val.length < 9) {
      setState(() => _detectedName = null);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 800), () async {
      setState(() => _isResolvingName = true);
      try {
        final name = await state.resolveAccountName(val, type: 'mobile');
        if (mounted) {
          setState(() {
            _detectedName = name;
            if (name != null) triggerHapticSuccess();
          });
        }
      } finally {
        if (mounted) setState(() => _isResolvingName = false);
      }
    });
  }

  Future<void> _pickContact(AppLocalizations l10n, AppState state) async {
    if (await Permission.contacts.request().isGranted) {
      final contactId = await FlutterContacts.native.showPicker();
      if (contactId != null) {
        final contact = await FlutterContacts.get(contactId);
        if (contact != null && contact.phones.isNotEmpty) {
          String phone = contact.phones.first.number.replaceAll(RegExp(r'\D'), '');
          if (phone.startsWith('252')) {
            phone = phone.substring(3);
          } else if (phone.startsWith('0')) {
            phone = phone.substring(1);
          }
          
          if (phone.length > 9) phone = phone.substring(phone.length - 9);
          
          setState(() {
            _phoneController.text = phone;
            final provider = detectProvider(phone, l10n);
            if (provider != null) _selectedProvider = provider;
          });
          _lookupMobileName(phone, state);
        }
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context);
    
    final double balance = widget.source == "Wallet" 
        ? state.balance 
        : state.cards.firstWhere((c) => c.id == widget.cardId).balance;

    final double fee = _amount > 0 ? state.calculateFeeForSource(_amount, "Mobile Money", payoutMethod: "Mobile Money") : 0;
    final double totalDeduct = _amount + fee;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.mobileMoney, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.horizontalPadding,
              24 * context.fontSizeFactor,
              context.horizontalPadding,
              context.horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(context, balance, state, l10n),
                SizedBox(height: 16 * context.fontSizeFactor),
                _buildLimitBars(context, state, l10n),
                SizedBox(height: 24 * context.fontSizeFactor),
                FadeInUp(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.selectProvider, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                      SizedBox(height: 12 * context.fontSizeFactor),
                      Wrap(
                        spacing: 12 * context.fontSizeFactor,
                        runSpacing: 8 * context.fontSizeFactor,
                        children: [l10n.evcPlus, l10n.edahab, l10n.zaad, l10n.sahal].map((p) => ChoiceChip(
                          label: Text(p),
                          selected: _selectedProvider == p,
                          onSelected: (val) => setState(() => _selectedProvider = val ? p : null),
                          selectedColor: AppColors.accentTeal.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: _selectedProvider == p ? AppColors.accentTeal : null, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 14 * context.fontSizeFactor
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
                        )).toList(),
                      ),
                      SizedBox(height: 24 * context.fontSizeFactor),
                      _buildRecentItems(context, state, l10n),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _buildInputField(
                        context, 
                        l10n.phoneNumber, 
                        Icons.phone_android_rounded, 
                        _phoneController, 
                        isNumber: true, 
                        hint: "61xxxxxxx",
                        prefix: "+252 ",
                        maxLength: 9,
                        suffix: IconButton(
                          icon: Icon(Icons.contact_phone_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
                          onPressed: () => _pickContact(l10n, state),
                        ),
                        onChanged: (val) {
                          final provider = detectProvider(val, l10n);
                          if (provider != null) _selectedProvider = provider;
                          _lookupMobileName(val, state);
                          setState(() {});
                        },
                      ),
                      _buildErrorOrName(l10n, context),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _buildPurposeDropdown(theme, l10n, context),
                    ],
                  ),
                ),
              ],
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
            child: _buildWithdrawButton(context, l10n, state, balance, totalDeduct),
          ),
        ),
      ),
    );
  }

  Widget _buildLimitBars(BuildContext context, AppState state, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    final currency = state.currencyCode;

    return FadeInDown(
      delay: const Duration(milliseconds: 100),
      child: Column(
        children: [
          _buildLimitProgress(
            context,
            state: state,
            title: state.translate("Daily Limit", "Xadka Maalinta"),
            spent: state.getDailySpent(),
            limit: state.dailyLimit,
            remaining: state.getDailyRemaining(),
            currency: currency,
            theme: theme,
            scale: scale,
          ),
          SizedBox(height: 12 * scale),
          _buildLimitProgress(
            context,
            state: state,
            title: state.translate("Monthly Limit", "Xadka Bisha"),
            spent: (state.monthlyLimit - state.getMonthlyRemaining()),
            limit: state.monthlyLimit,
            remaining: state.getMonthlyRemaining(),
            currency: currency,
            theme: theme,
            scale: scale,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitProgress(
    BuildContext context, {
    required AppState state,
    required String title,
    required double spent,
    required double limit,
    required double remaining,
    required String currency,
    required ThemeData theme,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11 * scale, fontWeight: FontWeight.bold, color: AppColors.grey),
              ),
              Text(
                "${NumberFormat.simpleCurrency(name: currency).format(spent)} / ${NumberFormat.simpleCurrency(name: currency).format(limit)}",
                style: TextStyle(fontSize: 11 * scale, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          ClipRRect(
            borderRadius: BorderRadius.circular(10 * scale),
            child: LinearProgressIndicator(
              value: (spent / limit).clamp(0.0, 1.0),
              backgroundColor: theme.dividerColor.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                (spent / limit) > 0.9 ? Colors.orange : theme.colorScheme.secondary,
              ),
              minHeight: 6 * scale,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            "${state.translate("Remaining", "Hambada")}: ${NumberFormat.simpleCurrency(name: currency).format(remaining)}",
            style: TextStyle(fontSize: 9 * scale, fontWeight: FontWeight.bold, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, AppState state, AppLocalizations l10n) {
    return Center(
      child: MaxWidthBox(
        maxWidth: 600,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24 * context.fontSizeFactor),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.3),
                blurRadius: 20 * context.fontSizeFactor,
                offset: Offset(0, 10 * context.fontSizeFactor),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (widget.source == "Wallet" ? l10n.walletBalance : l10n.virtualCardBalance).toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11 * context.fontSizeFactor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                ),
              ),
              SizedBox(height: 8 * context.fontSizeFactor),
              Text(
                NumberFormat.simpleCurrency(name: state.currencyCode).format(balance),
                style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20 * context.fontSizeFactor),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14 * context.fontSizeFactor)
                ),
                child: Row(
                  children: [
                    Text(r"$", style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8 * context.fontSizeFactor),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                        style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "0.00",
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final double feeRate = state.calculateFeeForSource(100, "Mobile Money") / 100;
                        _amountController.text = (balance / (1 + feeRate)).toStringAsFixed(2);
                        setState(() {});
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor)),
                      child: Text("MAX", style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentItems(BuildContext context, AppState state, AppLocalizations l10n) {
    final recents = state.recentWithdrawals.where((e) => e['type'] == 'mobile').toList();
    final List<Map<String, String>> combined = [...recents];
    for (var profile in state.quickProfiles) {
      if (profile.walletId.length >= 9 && !combined.any((r) => r['detail'] == profile.walletId.replaceAll('252', ''))) {
        combined.add({
          'name': profile.name,
          'detail': profile.walletId.replaceAll('252', ''),
          'provider': profile.lastReceiverMethod ?? '',
        });
      }
    }

    if (combined.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recent, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        SizedBox(height: 8 * context.fontSizeFactor),
        SizedBox(
          height: 52 * context.fontSizeFactor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: combined.length,
            itemBuilder: (context, i) {
              final r = combined[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _phoneController.text = r["detail"]!;
                    if (r["provider"]?.isNotEmpty ?? false) _selectedProvider = r["provider"];
                    _detectedName = r["name"];
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 8 * context.fontSizeFactor),
                  padding: EdgeInsets.symmetric(horizontal: 14 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14 * context.fontSizeFactor),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r["name"]!, style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                      Text(r["detail"]!, style: TextStyle(fontSize: 10 * context.fontSizeFactor, color: AppColors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorOrName(AppLocalizations l10n, BuildContext context) {
    final error = getWithdrawPrefixError(_phoneController.text, _selectedProvider, l10n);
    if (error != null) {
      return Padding(
        padding: EdgeInsets.only(top: 8 * context.fontSizeFactor, left: 4 * context.fontSizeFactor),
        child: Text(error, style: TextStyle(color: Colors.red.shade700, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
      );
    }
    if (_isResolvingName) {
      return Padding(
        padding: EdgeInsets.only(top: 8 * context.fontSizeFactor, left: 12 * context.fontSizeFactor),
        child: SizedBox(
          width: 16 * context.fontSizeFactor,
          height: 16 * context.fontSizeFactor,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentTeal),
        ),
      );
    }
    if (_detectedName != null && _phoneController.text.length >= 6) {
      return Padding(
        padding: EdgeInsets.only(top: 8 * context.fontSizeFactor, left: 12 * context.fontSizeFactor),
        child: Row(
          children: [
            Icon(Icons.person_outline_rounded, size: 16 * context.fontSizeFactor, color: AppColors.accentTeal),
            SizedBox(width: 6 * context.fontSizeFactor),
            Text(_detectedName!, style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPurposeDropdown(ThemeData theme, AppLocalizations l10n, BuildContext context) {
    final purposes = getPurposes(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.purposeOfRemittance, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
        SizedBox(height: 12 * context.fontSizeFactor),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPurpose ?? purposes.first,
            dropdownColor: theme.cardColor,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.info_outline_rounded, color: AppColors.grey, size: 20 * context.fontSizeFactor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
            ),
            items: purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (val) => setState(() => _selectedPurpose = val),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawButton(BuildContext context, AppLocalizations l10n, AppState state, double balance, double totalDeduct) {
    final bool isDailyLimitExceeded = state.getDailySpent() + _amount > state.dailyLimit;
    final bool isMonthlyLimitExceeded = (state.monthlyLimit - state.getMonthlyRemaining()) + _amount > state.monthlyLimit;

    final bool isFormValid = _amount > 0 && 
                           totalDeduct <= balance && 
                           !isDailyLimitExceeded &&
                           !isMonthlyLimitExceeded &&
                           _selectedProvider != null && 
                           _phoneController.text.length == 9 && 
                           getWithdrawPrefixError(_phoneController.text, _selectedProvider, l10n) == null;

    return Center(
      child: MaxWidthBox(
        maxWidth: 500,
        child: Column(
          children: [
            if (isDailyLimitExceeded)
              Padding(
                padding: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
                child: Text(
                  l10n.dailyLimitExceeded(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.dailyLimit)),
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor),
                ),
              ),
                        if (isMonthlyLimitExceeded && !isDailyLimitExceeded)
              Padding(
                padding: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
                child: Text(
                  l10n.monthlyLimitExceeded(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.monthlyLimit)),
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 60 * context.fontSizeFactor,
              child: ElevatedButton(
                onPressed: isFormValid ? () => _showReviewSheet(context, l10n, state) : null,
                style: context.elevatedButtonStyle(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                ).copyWith(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  elevation: WidgetStateProperty.all(8),
                ),
                child: Text(
                  l10n.confirmAndWithdraw,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18 * context.fontSizeFactor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, AppLocalizations l10n, AppState state) {
    final double fee = _amount > 0 ? state.calculateFeeForSource(_amount, "Mobile Money") : 0;
    final double totalDeduct = _amount + fee;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.4,
          maxChildSize: 0.85,
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
                    Container(
                      width: 45 * context.fontSizeFactor, 
                      height: 5 * context.fontSizeFactor, 
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.all(32 * context.fontSizeFactor),
                        children: [
                          Center(
                            child: Text(
                              l10n.reviewWithdrawal, 
                              style: TextStyle(fontSize: 22 * context.fontSizeFactor, fontWeight: FontWeight.bold)
                            )
                          ),
                          SizedBox(height: 24 * context.fontSizeFactor),
                          DetailRow(label: l10n.amount, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount)),
                          DetailRow(label: l10n.method, value: _selectedProvider!),
                          DetailRow(label: l10n.phoneNumber, value: "+252 ${_phoneController.text}"),
                          DetailRow(label: "${l10n.fee} (2.5%, min \$0.10)", value: NumberFormat.simpleCurrency(name: state.currencyCode).format(fee)),
                          DetailRow(label: l10n.totalDeduct, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(totalDeduct), valueColor: AppColors.accentTeal),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(24 * context.fontSizeFactor),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60 * context.fontSizeFactor,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showPinDialog(context, l10n, state);
                            },
                            style: context.elevatedButtonStyle(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                            ).copyWith(
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                              elevation: WidgetStateProperty.all(8),
                            ),
                            child: Text(
                              l10n.confirm,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18 * context.fontSizeFactor,
                                letterSpacing: 1,
                              ),
                            ),
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
      ),
    );
  }


  void _showPinDialog(BuildContext context, AppLocalizations l10n, AppState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PinEntryDialog(
        title: l10n.enterSecurityPin,
        description: l10n.enterTransactionPin,
        isBiometricEnabled: state.biometricEnabled,
        isCardPin: widget.source != "Wallet",
        cardId: widget.cardId,
        onValidate: (pin) async {
          if (pin == "BIOMETRIC_SUCCESS") return true;
          if (widget.source == "Wallet") {
            return state.verifyPin(pin);
          } else {
            return state.verifyCardPin(pin, cardId: widget.cardId);
          }
        },
        onConfirm: (pin) {
          _process(context, l10n, state);
        },
      ),
    );
  }

  void _process(BuildContext context, AppLocalizations l10n, AppState state) async {
    final double fee = _amount > 0 ? state.calculateFeeForSource(_amount, "Mobile Money") : 0;
    final totalDeduct = _amount + fee;
    final theme = Theme.of(context);
    
    // 1. Check Daily Limits
    if (state.getDailySpent() + _amount > state.dailyLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dailyLimitExceeded(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.dailyLimit))),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Check Monthly Limits
    final double spentThisMonth = state.monthlyLimit - state.getMonthlyRemaining();
    if (spentThisMonth + _amount > state.monthlyLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.monthlyLimitExceeded(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.monthlyLimit))),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 3. Check Balance again including fee
    final double currentBalance = widget.source == "Wallet" 
        ? state.balance 
        : state.cards.firstWhere((c) => c.id == widget.cardId).balance;
    
    if (totalDeduct > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.insufficientBalanceWithFee), backgroundColor: Colors.red),
      );
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final scale = context.fontSizeFactor;
        return Center(
          child: Container(
            padding: EdgeInsets.all(32 * scale),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20 * scale,
                  offset: Offset(0, 10 * scale),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.accentTeal, strokeWidth: 3 * scale),
                SizedBox(height: 24 * scale),
                Text(
                  "Finalising transaction..",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * scale,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    try {
      final tx = widget.source == "Wallet"
          ? await state.processWalletWithdrawal(
              amount: _amount,
              fee: fee,
              method: "Mobile Money",
              detail: _phoneController.text,
              provider: _selectedProvider!,
              name: _detectedName ?? l10n.withdrawal,
              type: "mobile",
              status: "Pending",
              purpose: _selectedPurpose ?? l10n.familySupport,
            )
          : await state.processCardWithdrawal(
              cardId: widget.cardId!,
              amount: _amount,
              fee: fee,
              method: "Mobile Money",
              detail: _phoneController.text,
              provider: _selectedProvider!,
              name: _detectedName ?? l10n.withdrawal,
              type: "mobile",
              status: "Pending",
              purpose: _selectedPurpose ?? l10n.familySupport,
            );

      if (!mounted) return;
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop(); 
      triggerHapticSuccess();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: "waa la helay fariintaada na sug 24hrs",
            message: l10n.withdrawalSuccessMessage(NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount)),
            subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)),
            buttonText: l10n.backToHome,
            transactionData: tx.toJson(),
            onPressed: () {
              state.setNavIndex(0);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) => false,
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FailureScreen(
            title: l10n.transactionFailed,
            message: e.toString(),
            buttonText: l10n.tryAgain,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  Widget _buildInputField(BuildContext context, String label, IconData icon, TextEditingController controller, {bool isNumber = false, String? hint, String? prefix, int? maxLength, Widget? suffix, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
        counterText: "",
        prefixIcon: prefix != null 
            ? Padding(
                padding: EdgeInsets.only(left: 12 * context.fontSizeFactor, top: 14 * context.fontSizeFactor), 
                child: Text(prefix, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor))
              )
            : Icon(icon, color: AppColors.grey, size: 20 * context.fontSizeFactor),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 16 * context.fontSizeFactor),
      ),
      onChanged: onChanged,
    );
  }
}
