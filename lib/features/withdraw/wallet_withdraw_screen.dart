import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/widgets/failure_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/models/transaction.dart' as model;
import 'package:responsive_framework/responsive_framework.dart';

class WalletWithdrawScreen extends StatefulWidget {
  const WalletWithdrawScreen({super.key});

  @override
  State<WalletWithdrawScreen> createState() => _WalletWithdrawScreenState();
}

class _WalletWithdrawScreenState extends State<WalletWithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _field1Controller = TextEditingController(); // Phone / Account Number
  final TextEditingController _field2Controller = TextEditingController(); // Account Name
  final TextEditingController _field3Controller = TextEditingController(); // Custom Bank Name
  
  String? _selectedMethodId;
  String? _selectedProvider;
  String? _selectedPurpose;
  String? _detectedName;

  List<String> _getPurposes(AppLocalizations l10n) => [
    l10n.familySupport,
    l10n.educationTuition,
    l10n.medicalExpenses,
    l10n.businessTransaction,
    l10n.propertyRent,
    l10n.gift,
    l10n.other,
  ];

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "mobile",
      "icon": Icons.phone_android_rounded,
      "gradient": [AppColors.accentTeal, Color(0xFF0D9488)],
    },
    {
      "id": "bank",
      "icon": Icons.account_balance_rounded,
      "gradient": [Color(0xFF6366F1), Color(0xFF4F46E5)],
    },
  ];

  // Constants for Logic Gaps
  static const double _minWithdraw = 1.0;
  static const double _maxWithdraw = 2000.0;
  static const double _feePercentage = 0.01; // 1%
  static const double _minFee = 0.10;

  double get _amount => double.tryParse(_amountController.text) ?? 0;
  double get _fee => _amount > 0 ? (_amount * _feePercentage < _minFee ? _minFee : _amount * _feePercentage) : 0;
  double get _totalDeduct => _amount + _fee;

  @override
  void dispose() {
    _amountController.dispose();
    _field1Controller.dispose();
    _field2Controller.dispose();
    _field3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.withdrawMoney, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Wallet Balance Card
                FadeInDown(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.walletBalance.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11 * context.fontSizeFactor,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance),
                                    style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.bold)
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Amount Input
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(r"$", style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
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
                                            suffixIcon: TextButton(
                                              onPressed: () {
                                                // Calculate max possible withdraw amount considering fee
                                                // Amount + (Amount * 0.01) = Balance
                                                // Amount * 1.01 = Balance
                                                // Amount = Balance / 1.01
                                                double maxAmount = state.balance / (1 + _feePercentage);
                                                _amountController.text = maxAmount.toStringAsFixed(2);
                                                setState(() {});
                                              },
                                              child: Text("MAX", style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [50, 200, 500, 1000, 2000].map((amt) => GestureDetector(
                                    onTap: () {
                                      _amountController.text = amt.toString();
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        "\$$amt",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12 * context.fontSizeFactor),
                                      ),
                                    ),
                                  )).toList(),
                                ),
                                if (_amount > 0) ...[
                                  const SizedBox(height: 12),
                                  DetailRow(
                                    label: l10n.feeLabel,
                                    value: NumberFormat.simpleCurrency(name: state.currencyCode).format(_fee),
                                    labelColor: Colors.white70,
                                    valueColor: Colors.white,
                                    isBold: false,
                                  ),
                                  DetailRow(
                                    label: l10n.totalDeduct,
                                    value: NumberFormat.simpleCurrency(name: state.currencyCode).format(_totalDeduct),
                                    labelColor: Colors.white70,
                                    valueColor: AppColors.accentTeal,
                                    isBold: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Limits Info Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: Column(
                              children: [
                                _buildLimitHeadroom(
                                  l10n.dailyLimit, 
                                  state.getDailyRemaining(), 
                                  AppState.dailyLimit,
                                  state.currencyCode,
                                  theme,
                                ),
                                const SizedBox(height: 12),
                                _buildLimitHeadroom(
                                  l10n.monthlyLimit, 
                                  state.getMonthlyRemaining(), 
                                  AppState.monthlyLimit,
                                  state.currencyCode,
                                  theme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  child: Text(l10n.withdrawalMethod, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                
                ...List.generate(_methods.length, (index) {
                  final method = _methods[index];
                  final isAmountValid = (double.tryParse(_amountController.text) ?? 0) > 0 && 
                                       (double.tryParse(_amountController.text) ?? 0) <= state.balance;
                  final isSelected = _selectedMethodId == method["id"];

                  return FadeInUp(
                    delay: Duration(milliseconds: index * 80),
                    child: Opacity(
                      opacity: isAmountValid ? 1.0 : 0.6,
                      child: GestureDetector(
                        onTap: isAmountValid ? () {
                          setState(() {
                            _selectedMethodId = method["id"];
                            _selectedProvider = null; // Clear provider on method switch
                            _field1Controller.clear();
                            _field2Controller.clear();
                          });
                        } : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: EdgeInsets.all(18 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.accentTeal : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50 * context.fontSizeFactor, height: 50 * context.fontSizeFactor,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: (method["gradient"] as List<Color>),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: AdaptiveIcon(
                                    method["icon"],
                                    color: Colors.white,
                                    size: 24 * context.fontSizeFactor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getMethodTitle(method["id"], l10n), 
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                                    ),
                                    Text(
                                      _getMethodDesc(method["id"], l10n), 
                                      style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor)
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal)
                              else
                                Icon(Icons.arrow_forward_ios_rounded, size: 16 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.4)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                if (_selectedMethodId != null) ...[
                  const SizedBox(height: 24),
                  FadeInUp(child: _buildDetailsForm(context, l10n, state)),
                ],
    
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsForm(BuildContext context, AppLocalizations l10n, AppState state) {
    final theme = Theme.of(context);
    final recents = state.recentWithdrawals.where((e) => e['type'] == _selectedMethodId).toList();

    if (_selectedMethodId == "mobile") {
      // Combine recents and quick profiles for mobile
      final List<Map<String, String>> combinedRecents = [...recents];
      for (var profile in state.quickProfiles) {
        // Simple check: if it looks like a phone number (e.g., starts with 252 or 61/63/etc)
        if (profile.walletId.length >= 9 && !combinedRecents.any((r) => r['detail'] == profile.walletId.replaceAll('252', ''))) {
          combinedRecents.add({
            'name': profile.name,
            'detail': profile.walletId.replaceAll('252', ''),
            'provider': profile.lastReceiverMethod ?? '',
          });
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.selectProvider, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [l10n.evcPlus, l10n.edahab, l10n.zaad, l10n.sahal].map((p) => ChoiceChip(
              label: Text(p),
              selected: _selectedProvider == p,
              onSelected: (val) => setState(() => _selectedProvider = val ? p : null),
              selectedColor: AppColors.accentTeal.withValues(alpha: 0.2),
              labelStyle: TextStyle(color: _selectedProvider == p ? AppColors.accentTeal : null, fontWeight: FontWeight.bold),
            )).toList(),
          ),
          const SizedBox(height: 16),
          if (combinedRecents.isNotEmpty) ...[
             Text(l10n.recent, style: TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
             SizedBox(
               height: 44,
               child: ListView.builder(
                 scrollDirection: Axis.horizontal,
                 itemCount: combinedRecents.length,
                 itemBuilder: (context, i) {
                   final r = combinedRecents[i];
                   return GestureDetector(
                     onTap: () {
                        setState(() {
                          _field1Controller.text = r["detail"]!;
                          if (r["provider"] != null && r["provider"]!.isNotEmpty) {
                            _selectedProvider = r["provider"];
                          }
                          _detectedName = r["name"];
                        });
                        // Trigger prefix logic manually
                        _handlePhoneInput(r["detail"]!, l10n, state);
                     },
                     child: Container(
                       margin: const EdgeInsets.only(right: 8),
                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                       decoration: BoxDecoration(
                         color: theme.colorScheme.surface, 
                         borderRadius: BorderRadius.circular(14), 
                         border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                       ),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(r["name"]!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                           Text(r["detail"]!, style: TextStyle(fontSize: 10, color: AppColors.grey)),
                         ],
                       ),
                     ),
                   );
                 },
               ),
             ),
             const SizedBox(height: 16),
          ],
          _withdrawInputField(
            context, 
            l10n.phoneNumber, 
            Icons.phone_android_rounded, 
            _field1Controller, 
            isNumber: true, 
            hint: "61xxxxxxx",
            prefix: "+252 ",
            maxLength: 9,
            onChanged: (val) => _handlePhoneInput(val, l10n, state),
          ),
          if (_detectedName != null && _field1Controller.text.length >= 6)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: FadeIn(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.accentTeal),
                    const SizedBox(width: 6),
                    Text(
                      _detectedName!,
                      style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          if (_field1Controller.text.isNotEmpty && _field1Controller.text.length < 9 && _detectedName == null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(l10n.phoneLengthError, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
            ),
          const SizedBox(height: 16),
          _buildPurposeDropdown(theme, l10n),
          const SizedBox(height: 24),
          _buildWithdrawButton(context, l10n, state),
        ],
      );
    } else if (_selectedMethodId == "bank") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recents.isNotEmpty) ...[
             Text(l10n.recent, style: TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
             SizedBox(
               height: 40,
               child: ListView.builder(
                 scrollDirection: Axis.horizontal,
                 itemCount: recents.length,
                 itemBuilder: (context, i) {
                   final r = recents[i];
                   return GestureDetector(
                     onTap: () => setState(() {
                       _field1Controller.text = r["detail"]!;
                       _field2Controller.text = r["name"]!;
                       _selectedProvider = r["provider"];
                     }),
                     child: Container(
                       margin: const EdgeInsets.only(right: 8),
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1))),
                       child: Text("${r["name"]} - ${r["provider"]}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                     ),
                   );
                 },
               ),
             ),
             const SizedBox(height: 16),
          ],
          Text(l10n.selectBank, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showBankPicker(context, l10n),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: AppColors.accentTeal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedProvider == l10n.otherBank ? l10n.otherBank : (_selectedProvider ?? l10n.selectBank),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedProvider == null ? AppColors.grey : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedProvider == l10n.otherBank) ...[
            _withdrawInputField(context, l10n.bankName, Icons.account_balance_outlined, _field3Controller, hint: "Enter bank name"),
            const SizedBox(height: 16),
          ],
          _withdrawInputField(context, l10n.accountNumber, Icons.numbers, _field1Controller, isNumber: true, hint: "123456789"),
          const SizedBox(height: 16),
          _withdrawInputField(context, l10n.accountName, Icons.person, _field2Controller, hint: l10n.fullName),
          const SizedBox(height: 16),
          _buildPurposeDropdown(theme, l10n),
          const SizedBox(height: 24),
          _buildWithdrawButton(context, l10n, state),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _showBankPicker(BuildContext context, AppLocalizations l10n) {
    final List<Map<String, dynamic>> banks = [
      {"name": "IBS Bank", "color": const Color(0xFFC62828)},
      {"name": "Premier Bank", "color": const Color(0xFF01579B)},
      {"name": "Salaam Bank", "color": const Color(0xFF2E7D32)},
      {"name": "Amal Bank", "color": const Color(0xFFEF6C00)},
      {"name": "MyBank", "color": const Color(0xFF4527A0)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text(l10n.selectBank, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: banks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == banks.length) {
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded, color: AppColors.accentTeal, size: 20),
                        ),
                        title: Text(l10n.otherBank, style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          setState(() {
                            _selectedProvider = l10n.otherBank;
                            _field1Controller.clear();
                            _field2Controller.clear();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }
                    final bank = banks[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: (bank["color"] as Color).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.account_balance_rounded, color: bank["color"], size: 20),
                      ),
                      title: Text(bank["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        setState(() {
                          _selectedProvider = bank["name"];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }


  Widget _buildWithdrawButton(BuildContext context, AppLocalizations l10n, AppState state) {
    bool isFormValid = false;
    String? error;

    if (_amount < _minWithdraw) {
      error = l10n.minAmountError(NumberFormat.simpleCurrency(name: state.currencyCode).format(_minWithdraw));
    } else if (_amount > _maxWithdraw) {
      error = l10n.maxAmountError(NumberFormat.simpleCurrency(name: state.currencyCode).format(_maxWithdraw));
    } else if (_totalDeduct > state.balance) {
      error = l10n.insufficientBalanceWithFee;
    } else {
      if (_selectedMethodId == "mobile") {
        isFormValid = _selectedProvider != null && _field1Controller.text.length == 9;
      } else if (_selectedMethodId == "bank") {
        if (_selectedProvider == l10n.otherBank) {
          isFormValid = _field3Controller.text.isNotEmpty && _field1Controller.text.isNotEmpty && _field2Controller.text.isNotEmpty;
        } else {
          isFormValid = _selectedProvider != null && _field1Controller.text.isNotEmpty && _field2Controller.text.isNotEmpty;
        }
      }
    }

    return Column(
      children: [
        if (error != null && _amount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(error, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
          ),
        SizedBox(
          width: double.infinity,
          height: 56 * context.fontSizeFactor,
          child: ElevatedButton(
            onPressed: isFormValid ? () => _showReviewSheet(context, l10n, state) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(l10n.confirmAndWithdraw, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  void _showReviewSheet(BuildContext context, AppLocalizations l10n, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Text(l10n.reviewWithdrawal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    DetailRow(label: l10n.amount, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount)),
                    DetailRow(
                      label: l10n.method, 
                      value: _selectedMethodId == "mobile" 
                        ? (_selectedProvider ?? _getMethodTitle(_selectedMethodId!, l10n)) 
                        : (_selectedProvider == l10n.otherBank ? _field3Controller.text : (_selectedProvider ?? _getMethodTitle(_selectedMethodId!, l10n)))
                    ),
                    if (_selectedMethodId == "bank") ...[
                      DetailRow(label: l10n.accountNumber, value: _field1Controller.text),
                      DetailRow(label: l10n.accountName, value: _field2Controller.text),
                    ],
                    if (_selectedMethodId == "mobile") ...[
                      DetailRow(label: l10n.phoneNumber, value: "+252 ${_field1Controller.text}"),
                    ],
                    DetailRow(label: l10n.feeLabel, value: NumberFormat.simpleCurrency(name: state.currencyCode).format(_fee)),
                    DetailRow(
                      label: l10n.totalDeduct, 
                      value: NumberFormat.simpleCurrency(name: state.currencyCode).format(_totalDeduct),
                      valueColor: AppColors.accentTeal,
                    ),
                    DetailRow(label: l10n.purpose, value: _selectedPurpose ?? l10n.familySupport),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPinDialog(this.context, l10n, state);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinDialog(BuildContext context, AppLocalizations l10n, AppState state) {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.enterSecurityPin, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterTransactionPin, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                Navigator.pop(context);
                _processWithdrawal(this.context, l10n, state);
              }
            },
            child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
          ),
        ],
      ),
    );
  }

  void _processWithdrawal(BuildContext context, AppLocalizations l10n, AppState state) async {
    final double amountToDeduct = _totalDeduct;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const CircularProgressIndicator(color: AppColors.accentTeal),
          ),
        ),
      ),
    );

    // Simulate Network/Processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    try {
      String finalName = _selectedMethodId == "mobile" ? l10n.withdrawal : _field2Controller.text;
      
      // If bank transfer, identify receiver by purpose in the ledger title
      if (_selectedMethodId == "bank") {
        finalName = "${_field2Controller.text} (${_selectedPurpose ?? l10n.familySupport})";
      }

      await state.processWalletWithdrawal(
        amount: _amount,
        fee: _fee,
        method: _selectedMethodId == "mobile" ? "Mobile Money" : (_selectedProvider ?? l10n.bankTransfer),
        detail: _field1Controller.text,
        provider: (_selectedMethodId == "bank" && _selectedProvider == l10n.otherBank) 
            ? _field3Controller.text 
            : (_selectedProvider ?? ""),
        name: _selectedMethodId == "mobile" && _detectedName != null ? _detectedName! : finalName,
        type: _selectedMethodId!,
        purpose: _selectedPurpose ?? l10n.familySupport,
      );
      
      if (!context.mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: l10n.withdrawalRequested,
            message: l10n.withdrawalSuccessMessage(NumberFormat.simpleCurrency(name: state.currencyCode).format(_amount)),
            subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)),
            buttonText: l10n.backToHome,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      String errorMsg = l10n.transactionFailedMessage;
      if (e.toString().contains('daily_limit_exceeded')) {
        errorMsg = state.translate("Daily transaction limit exceeded.", "Xadiga xawaaladda maalinlaha ah waa laga gudbay.");
      } else if (e.toString().contains('monthly_limit_exceeded')) {
        errorMsg = state.translate("Monthly transaction limit exceeded.", "Xadiga xawaaladda bishii waa laga gudbay.");
      } else if (e.toString().contains('insufficient_funds')) {
        errorMsg = l10n.insufficientBalance;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FailureScreen(
            title: l10n.transactionFailed,
            message: errorMsg,
            buttonText: l10n.tryAgain,
            onPressed: () => Navigator.of(context).pop(), 
          ),
        ),
      );
    }
  }

  String _getMethodTitle(String id, AppLocalizations l10n) {
    switch (id) {
      case "mobile": return l10n.mobileMoney;
      case "bank": return l10n.bankTransfer;
      default: return "";
    }
  }

  void _handlePhoneInput(String val, AppLocalizations l10n, AppState state) {
    // 1. Auto-select Provider logic
    if (val.length >= 2) {
      if (val.startsWith('61')) {
        _selectedProvider = l10n.evcPlus;
      } else if (val.startsWith('65')) {
        _selectedProvider = l10n.edahab;
      } else if (val.startsWith('63')) {
        _selectedProvider = l10n.zaad;
      } else if (val.startsWith('90')) {
        _selectedProvider = l10n.sahal;
      }
    } else {
      _selectedProvider = null;
    }

    // 2. Name Lookup logic
    _detectedName = null;
    if (val.length >= 6) {
      // Check in quick profiles
      final profile = state.quickProfiles.where((p) => p.walletId.contains(val)).firstOrNull;
      if (profile != null) {
        _detectedName = profile.name;
      } else {
        // Check in recent withdrawals
        final recent = state.recentWithdrawals.where((r) => r['detail'] == val).firstOrNull;
        if (recent != null) {
          _detectedName = recent['name'];
        }
      }
    }
    setState(() {});
  }

  String _getMethodDesc(String id, AppLocalizations l10n) {
    switch (id) {
      case "mobile": return l10n.mobileMoneyDesc;
      case "bank": return l10n.localBankTransfer;
      default: return "";
    }
  }

  Widget _buildLimitHeadroom(String label, double remaining, double limit, String currency, ThemeData theme) {
    final double percent = (remaining / limit).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey)),
            Text(
              "${NumberFormat.simpleCurrency(name: currency).format(remaining)} left",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: percent < 0.2 ? Colors.orange : AppColors.accentTeal),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: AppColors.grey.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              percent < 0.2 ? Colors.orange : AppColors.accentTeal,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeDropdown(ThemeData theme, AppLocalizations l10n) {
    final purposes = _getPurposes(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.purposeOfRemittance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedPurpose ?? purposes.first,
            dropdownColor: theme.colorScheme.surface,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600, fontSize: 15),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.info_outline_rounded, color: AppColors.grey, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey),
            items: purposes.map((p) => DropdownMenuItem(
              value: p,
              child: Text(p),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPurpose = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _withdrawInputField(BuildContext context, String label, IconData icon, TextEditingController controller, {bool isNumber = false, String? hint, String? prefix, int? maxLength, Function(String)? onChanged}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: "",
        prefixIcon: prefix != null 
          ? Padding(
              padding: const EdgeInsets.only(left: 12, top: 14), 
              child: Text(prefix, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
          : Icon(icon, color: AppColors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
      ),
      onChanged: (val) {
        if (onChanged != null) {
          onChanged(val);
        }
        final l10n = AppLocalizations.of(context)!;
        if (prefix != null) {
          if (val.length >= 2) {
            if (val.startsWith('61')) {
              _selectedProvider = l10n.evcPlus;
            } else if (val.startsWith('65')) {
              _selectedProvider = l10n.edahab;
            } else if (val.startsWith('63')) {
              _selectedProvider = l10n.zaad;
            } else if (val.startsWith('90')) {
              _selectedProvider = l10n.sahal;
            }
          } else if (val.length < 2) {
             _selectedProvider = null;
          }
        }
        setState(() {});
      },
    );
  }
}
