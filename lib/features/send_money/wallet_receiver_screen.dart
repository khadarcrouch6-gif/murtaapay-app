import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'payment_screen.dart';

class WalletReceiverScreen extends StatefulWidget {
  final String amount;
  final String method;
  final String currencyCode;
  const WalletReceiverScreen({super.key, required this.amount, required this.method, required this.currencyCode});

  @override
  State<WalletReceiverScreen> createState() => _WalletReceiverScreenState();
}

class _WalletReceiverScreenState extends State<WalletReceiverScreen> {
  final TextEditingController _walletIdController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _verifiedReceiverName = "";
  bool _isSearching = false;

  void _lookupWalletId(String value) {
    if (value.length >= 4) {
      setState(() => _isSearching = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _verifiedReceiverName = _mockLookup(value);
          });
        }
      });
    } else {
      setState(() {
        _isSearching = false;
        _verifiedReceiverName = "";
      });
    }
  }

  String _mockLookup(String id) {
    if (id.startsWith("10")) return "Ayaanle Rayaale";
    if (id.startsWith("20")) return "Mohamed Abdi Ali";
    if (id.startsWith("30")) return "Sahra Hassan Duale";
    return "Murtaax User #$id";
  }

  void _handleContinue() {
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
                            border: Border.all(color: _focusNode.hasFocus ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1), width: 2),
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
                              prefixIcon: Icon(Icons.account_circle_outlined, color: theme.colorScheme.secondary, size: 24),
                              suffixIcon: _isSearching 
                                ? Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.colorScheme.secondary)))
                                : const Icon(Icons.search_rounded),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (_verifiedReceiverName.isNotEmpty)
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
                            onPressed: _verifiedReceiverName.isNotEmpty ? () => _handleContinue() : null,
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
}
