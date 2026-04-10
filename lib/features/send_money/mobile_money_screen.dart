import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'review_screen.dart';

class MobileMoneyScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String payoutMethod;
  final String currencyCode;

  const MobileMoneyScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.currencyCode,
  });

  @override
  State<MobileMoneyScreen> createState() => _MobileMoneyScreenState();
}

class _MobileMoneyScreenState extends State<MobileMoneyScreen> {
  String? _selectedProvider;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
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
    _pinController.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_selectedProvider == null || _phoneController.text.isEmpty || _pinController.text.isEmpty) return;
    
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          amount: widget.amount,
          receiverName: widget.receiverName,
          receiverPhone: widget.receiverPhone,
          method: widget.payoutMethod,
          paymentMethod: "Mobile Money ($_selectedProvider - ${_phoneController.text})",
          currencyCode: widget.currencyCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          l10n.mobileMoney,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
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
                        _buildStepIndicator(context, 2, l10n.stepReceiver, false, true, isHeader: true),
                        _buildStepLine(context, true, isHeader: true),
                        _buildStepIndicator(context, 3, l10n.stepPayment, true, false, isHeader: true),
                        _buildStepLine(context, false, isHeader: true),
                        _buildStepIndicator(context, 4, l10n.stepReview, false, false, isHeader: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.selectProvider, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 16),
                        
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: _providers.length,
                          itemBuilder: (context, index) {
                            final provider = _providers[index];
                            bool isSelected = _selectedProvider == provider["id"];
                            return FadeInUp(
                              delay: Duration(milliseconds: index * 100),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedProvider = provider["id"]),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? provider["color"] : theme.dividerColor.withValues(alpha: 0.1),
                                      width: 2.5,
                                    ),
                                    boxShadow: isSelected 
                                      ? [BoxShadow(color: provider["color"].withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]
                                      : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(provider["icon"], color: isSelected ? provider["color"] : AppColors.grey, size: 30),
                                      const SizedBox(height: 8),
                                      Text(provider["name"], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                      Text(provider["desc"], style: const TextStyle(color: AppColors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),
                        Text(l10n.phoneNumber, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          hint: l10n.enterNumberToCharge,
                          icon: Icons.phone_android_rounded,
                          theme: theme,
                        ),

                        const SizedBox(height: 20),
                        Text(l10n.servicePin, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _pinController,
                          focusNode: _pinFocus,
                          hint: l10n.enterPin,
                          icon: Icons.lock_outline_rounded,
                          theme: theme,
                          isPin: true,
                        ),

                        const SizedBox(height: 40),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_selectedProvider != null && _phoneController.text.isNotEmpty && _pinController.text.isNotEmpty) ? _handleContinue : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.confirmPaymentAmount(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0)),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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

  Widget _buildTextField({
    required TextEditingController controller, 
    required FocusNode focusNode, 
    required String hint, 
    required IconData icon, 
    required ThemeData theme,
    bool isPin = false,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        bool hasFocus = focusNode.hasFocus;
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: hasFocus ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1), width: 2),
            boxShadow: hasFocus ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.08), blurRadius: 10)] : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            obscureText: isPin,
            onChanged: (v) => setState(() {}),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: theme.colorScheme.secondary, size: 24),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
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
}
