import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/app_state.dart';
import '../../core/models/transaction.dart';
import '../../core/widgets/success_screen.dart';
import '../navigation/main_navigation.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MobileDepositScreen extends StatefulWidget {
  final double amount;

  const MobileDepositScreen({super.key, required this.amount});

  @override
  State<MobileDepositScreen> createState() => _MobileDepositScreenState();
}

class _MobileDepositScreenState extends State<MobileDepositScreen> {
  String? _selectedProvider;
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _providers = [
    {"id": "EVC Plus", "name": "EVC Plus (Hormuud)", "color": const Color(0xFF1B5E20), "prefixes": ["61", "77"]},
    {"id": "e-Dahab", "name": "e-Dahab (Dahabshiil)", "color": const Color(0xFFFBC02D), "prefixes": ["65"]},
    {"id": "Sahal", "name": "Sahal (Golis)", "color": const Color(0xFF0D47A1), "prefixes": ["90"]},
    {"id": "ZAAD", "name": "ZAAD (Telesom)", "color": const Color(0xFFB71C1C), "prefixes": ["63"]},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String val) {
    if (val.length >= 2) {
      for (var provider in _providers) {
        if ((provider['prefixes'] as List<String>).any((p) => val.startsWith(p))) {
          setState(() {
            _selectedProvider = provider['id'];
          });
          return;
        }
      }
    }
  }

  String? _validatePhone(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseFillAllFields;
    }
    if (value.length != 9) {
      return l10n.phoneLengthError;
    }
    
    bool validPrefix = false;
    if (_selectedProvider != null) {
        final provider = _providers.firstWhere((p) => p['id'] == _selectedProvider);
        if ((provider['prefixes'] as List<String>).any((p) => value.startsWith(p))) {
            validPrefix = true;
        }
    } else {
        // If no provider selected, check if it matches any
         validPrefix = _providers.any((p) => (p['prefixes'] as List<String>).any((prefix) => value.startsWith(prefix)));
    }

    if (!validPrefix) {
      return l10n.invalidPrefixError;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedProviderData = _selectedProvider != null 
        ? _providers.firstWhere((p) => p['id'] == _selectedProvider) 
        : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(l10n.mobileMoney, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20 * context.fontSizeFactor, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 600,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24 * context.fontSizeFactor),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.accentTeal.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Text(l10n.amountToDeposit, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                          const SizedBox(height: 8),
                          Text(
                            "\$${widget.amount.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.accentTeal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    child: Text(
                      l10n.selectProvider,
                      style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _providers.length,
                    itemBuilder: (context, index) {
                      final provider = _providers[index];
                      final isSelected = _selectedProvider == provider['id'];
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 50),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedProvider = provider['id']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? (provider['color'] as Color).withOpacity(0.1) : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? (provider['color'] as Color) : theme.dividerColor.withOpacity(0.1),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                provider['id'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? (provider['color'] as Color) : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.phoneNumber,
                          style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          onChanged: _onPhoneChanged,
                          validator: (val) => _validatePhone(val, l10n),
                          maxLength: 9,
                          style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 2),
                          decoration: InputDecoration(
                            hintText: "61XXXXXXX",
                            prefixText: "+252 ",
                            prefixStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: AppColors.accentTeal),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            counterText: "",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: selectedProviderData?['color'] ?? AppColors.accentTeal, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56 * context.fontSizeFactor,
                      child: ElevatedButton(
                        onPressed: _selectedProvider != null ? _showReviewSheet : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedProviderData?['color'] ?? AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.continueLabel,
                          style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold),
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
    );
  }

  void _showReviewSheet() {
    if (!_formKey.currentState!.validate()) return;
    
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = _providers.firstWhere((p) => p['id'] == _selectedProvider);

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
              Text(l10n.reviewDeposit, style: TextStyle(fontSize: 22 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              _reviewRow(l10n.amount, "\$${widget.amount.toStringAsFixed(2)}"),
              const Divider(height: 32),
              _reviewRow(l10n.provider, _selectedProvider!),
              const Divider(height: 32),
              _reviewRow(l10n.phoneNumber, "+252 ${_phoneController.text}"),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56 * context.fontSizeFactor,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _simulateSTKPush();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider['color'],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.confirmAndDeposit, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.grey, fontSize: 15 * context.fontSizeFactor)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor)),
      ],
    );
  }

  void _simulateSTKPush() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = _providers.firstWhere((p) => p['id'] == _selectedProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(color: provider['color'], strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.pushNotificationSent,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.pushNotificationInstructions("\$${widget.amount.toStringAsFixed(2)}"),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.pop(context); // Close dialog

    final state = Provider.of<AppState>(context, listen: false);
    state.addBalance(widget.amount);
    
    // Record the transaction
    state.addTransaction(Transaction(
      id: "DEP-MOB-${DateTime.now().millisecondsSinceEpoch}",
      title: l10n.mobileMoney,
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "+${NumberFormat.simpleCurrency(name: state.currencyCode).format(widget.amount)}",
      numericAmount: widget.amount,
      isNegative: false,
      category: "Deposit",
      status: "Success",
      type: "deposit",
      method: provider['id'],
      referenceId: _phoneController.text,
    ));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.depositSuccessful,
          message: l10n.depositSuccessMessage("\$${widget.amount.toStringAsFixed(2)}"),
          subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)),
          buttonText: l10n.backToHome,
          onPressed: () {
            state.setNavIndex(0);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
              (route) => false,
            );
          },
        ),
      ),
      (route) => false,
    );
  }
}
