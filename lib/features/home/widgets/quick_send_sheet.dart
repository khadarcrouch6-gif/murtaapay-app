import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/responsive_utils.dart';
import '../../../core/models/quick_profile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/success_screen.dart';

class QuickSendSheet extends StatefulWidget {
  final QuickProfile profile;

  const QuickSendSheet({super.key, required this.profile});

  static Future<void> show(BuildContext context, QuickProfile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickSendSheet(profile: profile),
    );
  }

  @override
  State<QuickSendSheet> createState() => _QuickSendSheetState();
}

class _QuickSendSheetState extends State<QuickSendSheet> {
  bool _isProcessing = false;
  late double _amount;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amount = widget.profile.lastAmount ?? 10.0;
    _amountController.text = _amount.toStringAsFixed(2);
  }

  Future<void> _processQuickSend(AppState state, AppLocalizations l10n) async {
    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      final double sendAmount = double.tryParse(_amountController.text) ?? _amount;
      
      await state.sendMoney(
        sendAmount, 
        widget.profile.walletId, 
        name: widget.profile.name
      );

      if (!mounted) return;
      
      Navigator.pop(context); // Close sheet
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: l10n.transferSuccess,
            message: "${l10n.youHaveSent} ${NumberFormat.simpleCurrency(name: state.currencyCode).format(sendAmount)} ${l10n.to} ${widget.profile.name}",
            onFinish: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      String errorMessage = l10n.transferFailed;
      if (e.toString().contains('insufficient_funds')) {
        errorMessage = l10n.insufficientBalance;
      } else if (e.toString().contains('limit_exceeded')) {
        errorMessage = "Transaction limit exceeded";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            l10n.quickSend,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 40 * context.fontSizeFactor,
            backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
            child: ClipOval(
              child: Image(
                image: widget.profile.avatarUrl != null && widget.profile.avatarUrl!.startsWith('http') 
                  ? NetworkImage(widget.profile.avatarUrl!) 
                  : AssetImage(widget.profile.avatarUrl ?? 'assets/avatars/avatar1.png') as ImageProvider,
                fit: BoxFit.cover,
                width: 80 * context.fontSizeFactor,
                height: 80 * context.fontSizeFactor,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 40, color: AppColors.accentTeal),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.profile.name,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            widget.profile.walletId,
            style: TextStyle(color: Colors.grey, fontSize: 13 * context.fontSizeFactor),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Text(
                  l10n.amount,
                  style: TextStyle(color: Colors.grey, fontSize: 12 * context.fontSizeFactor),
                ),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                  decoration: InputDecoration(
                    prefixText: NumberFormat.simpleCurrency(name: state.currencyCode).currencySymbol,
                    border: InputBorder.none,
                    hintText: "0.00",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [5, 10, 20, 50].map((val) => GestureDetector(
              onTap: () {
                _amountController.text = val.toStringAsFixed(2);
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "\$$val",
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _processQuickSend(state, l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    l10n.send,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
