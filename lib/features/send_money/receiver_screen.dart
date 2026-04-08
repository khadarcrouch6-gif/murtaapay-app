import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'review_screen.dart';
import 'payment_screen.dart';

class ReceiverScreen extends StatefulWidget {
  final String amount;
  final String method;
  const ReceiverScreen({super.key, required this.amount, required this.method});

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  final TextEditingController _idController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _verifiedName = "";
  bool _isSearching = false;

  void _lookupName(String value) {
    if (value.length >= 7) {
      setState(() => _isSearching = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _verifiedName = value.startsWith("61") || value.startsWith("061") ? "Mohamed Hassan Ali" : "Hassan Mohamed Abdi";
          });
        }
      });
    } else {
      setState(() {
        _verifiedName = "";
        _isSearching = false;
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
          receiverName: _verifiedName.isNotEmpty ? _verifiedName : "Receiver",
          receiverPhone: _idController.text,
          payoutMethod: widget.method,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : AppColors.accentTeal,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER BACKGROUND ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? AppColors.primaryDark : AppColors.accentTeal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        _buildStepIndicator(1, "Amount", false, true, isHeader: true),
                        _buildStepLine(true, isHeader: true),
                        _buildStepIndicator(2, "Receiver", true, false, isHeader: true),
                        _buildStepLine(false, isHeader: true),
                        _buildStepIndicator(3, "Review", false, false, isHeader: true),
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
                      Text(
                        l10n.enterReceiverPhone,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      
                      // Input Field (High Visibility)
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _focusNode.hasFocus ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1),
                            width: 2,
                          ),
                          boxShadow: _focusNode.hasFocus 
                            ? [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.08), blurRadius: 10)] 
                            : null,
                        ),
                        child: TextField(
                          controller: _idController,
                          focusNode: _focusNode,
                          onChanged: _lookupName,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
                          decoration: InputDecoration(
                            hintText: l10n.phoneNumber,
                            prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.accentTeal, size: 24),
                            suffixIcon: _isSearching 
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  ),
                                )
                              : const Icon(Icons.search_rounded),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      
                      if (_verifiedName.isNotEmpty)
                        FadeIn(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: AppColors.accentTeal, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.receiver, style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w900, fontSize: 11)),
                                      Text(_verifiedName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

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
                          onPressed: _idController.text.isNotEmpty && !_isSearching ? () => _handleContinue(l10n) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: AppColors.accentTeal.withValues(alpha: 0.3),
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: Text(
                            l10n.continueToReview,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    Color activeColor = isHeader ? Colors.white : AppColors.accentTeal;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!;
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? AppColors.accentTeal : Colors.grey);

    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 4) : null
          ),
          child: Center(child: isCompleted && !isActive ? Icon(Icons.check, color: isHeader ? AppColors.accentTeal : Colors.white, size: 18) : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? AppColors.accentTeal : Colors.white) : Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted, {bool isHeader = false}) { 
    Color color = isHeader 
      ? (isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.3)) 
      : (isCompleted ? AppColors.accentTeal : Colors.grey[200]!);
    return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)))); 
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
            _lookupName(_idController.text);
          });
        },
      ),
    );
  }
}
