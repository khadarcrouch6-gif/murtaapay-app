import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  final TextEditingController _amountController = TextEditingController();
  String _selectedSource = "Main Wallet";
  String? _selectedCardId;
  String _payoutMethod = "Wallet";
  String? _bankName;
  bool _isFeeIncluded = false;

  final List<String> _payoutMethods = ["Wallet", "Mobile Money", "Bank"];
  final List<String> _sourceMethods = ["Main Wallet", "Debit Card", "Mobile Money", "Bank Transfer"];

  @override
  void initState() {
    super.initState();
    _amountController.text = (widget.profile.lastAmount ?? 10.0).toStringAsFixed(2);
    _payoutMethod = widget.profile.payoutMethod ?? 'Wallet';
    _bankName = widget.profile.bankName;
  }

  double _getFee(AppState state) {
    final double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) return 0;
    return state.calculateFeeForSource(
      amount, 
      _selectedSource, 
      cardId: _selectedCardId,
      payoutMethod: _payoutMethod,
    );
  }

  double _getTotalToPay(AppState state) {
    final double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) return 0;
    if (_isFeeIncluded) return amount;
    return amount + _getFee(state);
  }

  void _showReviewDialog(AppState state, AppLocalizations l10n) {
    final double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) return;

    final fee = _getFee(state);
    final total = _getTotalToPay(state);
    final receiveAmount = _isFeeIncluded ? (amount - fee) : amount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmTransfer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewRow(l10n.recipient, widget.profile.name),
            _buildReviewRow("Method", _payoutMethod ?? 'Wallet'),
            if (_bankName != null) _buildReviewRow("Bank", _bankName!),
            _buildReviewRow(l10n.amount, NumberFormat.simpleCurrency(name: state.currencyCode).format(receiveAmount)),
            _buildReviewRow(l10n.fee, NumberFormat.simpleCurrency(name: state.currencyCode).format(fee)),
            const Divider(),
            _buildReviewRow(l10n.total, NumberFormat.simpleCurrency(name: state.currencyCode).format(total), isBold: true),
            const SizedBox(height: 8),
            Text("${l10n.source}: $_selectedSource", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processQuickSend(state, l10n);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppState state, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteGoalConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              state.deleteQuickProfile(widget.profile.id);
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close sheet
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? null : Colors.grey)),
        Text(value, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: FontWeight.bold, color: isTotal ? AppColors.accentTeal : null)),
      ],
    );
  }

  Widget _buildLimitIndicators(AppState state, AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        _buildLimitProgress(l10n.dailyLimit, state.getDailyRemaining(), state.dailyLimit, theme),
        const SizedBox(height: 8),
        _buildLimitProgress(l10n.monthlyLimit, state.getMonthlyRemaining(), state.monthlyLimit, theme),
      ],
    );
  }

  Widget _buildLimitProgress(String label, double remaining, double total, ThemeData theme) {
    double percent = total > 0 ? (total - remaining) / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text("${AppLocalizations.of(context)!.remaining}: \$${remaining.toStringAsFixed(0)}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent, 
            backgroundColor: Colors.grey.withOpacity(0.1), 
            valueColor: AlwaysStoppedAnimation<Color>(percent > 0.9 ? Colors.red : AppColors.accentTeal), 
            minHeight: 4
          ),
        ),
      ],
    );
  }

  Future<void> _processQuickSend(AppState state, AppLocalizations l10n) async {
    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      final double sendAmount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      
      // Logical verifying details (Simulated)
      if (sendAmount > 1000 && _selectedSource == "Main Wallet") {
        // High amount verification
      }

      await state.sendMoney(
        sendAmount, 
        widget.profile.walletId, 
        name: widget.profile.name,
        paymentMethod: _selectedSource,
        cardId: _selectedCardId,
        payoutMethod: _payoutMethod,
      );

      if (!mounted) return;
      
      Navigator.pop(context); // Close sheet
      
      final bool isBank = _payoutMethod == 'Bank';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: isBank ? "Transaction Pending" : l10n.transferSuccessful,
            message: isBank 
              ? "Your transfer of ${NumberFormat.simpleCurrency(name: state.currencyCode).format(sendAmount)} to ${widget.profile.name} is being processed. This usually takes up to 24 hours."
              : l10n.transferSentMessage(
                  NumberFormat.simpleCurrency(name: state.currencyCode).format(sendAmount),
                  widget.profile.name,
                ),
            buttonText: l10n.done,
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      String errorMessage = l10n.transactionFailed;
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    l10n.quickSend,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  right: -8,
                  top: -8,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: l10n.delete,
                    onPressed: () => _showDeleteConfirmation(context, state, l10n),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 35 * context.fontSizeFactor,
              backgroundColor: AppColors.accentTeal.withOpacity(0.1),
              child: ClipOval(
                child: Image(
                  image: widget.profile.avatarUrl != null && widget.profile.avatarUrl!.startsWith('http') 
                    ? NetworkImage(widget.profile.avatarUrl!) 
                    : AssetImage(widget.profile.avatarUrl ?? 'assets/avatars/avatar1.png') as ImageProvider,
                  fit: BoxFit.cover,
                  width: 70 * context.fontSizeFactor,
                  height: 70 * context.fontSizeFactor,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 30, color: AppColors.accentTeal),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.profile.name,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (widget.profile.isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _payoutMethod ?? 'Wallet',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            
            // Payout Method Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Payout Method",
                  style: TextStyle(color: Colors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _payoutMethods.map((method) {
                    bool isSelected = _payoutMethod == method;
                    return GestureDetector(
                      onTap: () => setState(() => _payoutMethod = method),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentTeal.withOpacity(0.1) : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.accentTeal : Colors.grey.withOpacity(0.1)),
                        ),
                        child: Text(
                          method,
                          style: TextStyle(
                            color: isSelected ? AppColors.accentTeal : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Payment Source Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pay From",
                  style: TextStyle(color: Colors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSource,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: "Main Wallet",
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text("${l10n.mainWallet} (${NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)})"),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Mobile Money",
                          child: Row(
                            children: [
                              const Icon(Icons.phone_android_outlined, size: 18),
                              const SizedBox(width: 8),
                              const Text("Mobile Money (External)"),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Bank Transfer",
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_outlined, size: 18),
                              const SizedBox(width: 8),
                              const Text("Bank Account (External)"),
                            ],
                          ),
                        ),
                        ...state.cards.map((card) => DropdownMenuItem(
                          value: "Card ${card.id}",
                          onTap: () => _selectedCardId = card.id,
                          child: Row(
                            children: [
                              const Icon(Icons.credit_card_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text("${card.network.name} ****${card.cardNumber.substring(card.cardNumber.length - 4)} (${NumberFormat.simpleCurrency(name: state.currencyCode).format(card.balance)})"),
                            ],
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedSource = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
                      fontSize: 28,
                    ),
                    decoration: InputDecoration(
                      prefixText: NumberFormat.simpleCurrency(name: state.currencyCode).currencySymbol,
                      border: InputBorder.none,
                      hintText: "0.00",
                    ),
                    inputFormatters: [ThousandsFormatter(decimals: 2)],
                    onChanged: (v) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Deduct Fee Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: AppColors.accentTeal, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.deductFeeFromAmount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(_isFeeIncluded ? l10n.receiverWillReceiveLess : l10n.payFeeSeparately, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isFeeIncluded,
                    onChanged: (v) => setState(() => _isFeeIncluded = v),
                    activeColor: AppColors.accentTeal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Limits and Summary
            if (_amountController.text.isNotEmpty && (double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0) > 0) ...[
              _buildLimitIndicators(state, l10n, theme),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(l10n.transactionFee, NumberFormat.simpleCurrency(name: state.currencyCode).format(_getFee(state))),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      l10n.totalToPay, 
                      NumberFormat.simpleCurrency(name: state.currencyCode).format(_getTotalToPay(state)),
                      isTotal: true,
                    ),
                    if (_payoutMethod == "Bank")
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text(l10n.arrivesIn24h, style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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
                    color: AppColors.primaryDark.withOpacity(0.05),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _showReviewDialog(state, l10n),
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
      ),
    );
  }
}

class ThousandsFormatter extends TextInputFormatter {
  final int decimals;
  ThousandsFormatter({this.decimals = 2});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String cleanText = newValue.text.replaceAll(',', '');
    if (cleanText.split('.').length > 2) return oldValue;
    if (cleanText.contains('.') && decimals == 0) return oldValue;
    if (cleanText.contains('.') && cleanText.split('.')[1].length > decimals) return oldValue;

    List<String> parts = cleanText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    if (integerPart.isEmpty) integerPart = "0";
    final formatter = NumberFormat("#,###");
    try {
      double parsed = double.parse(integerPart);
      String formattedInteger = formatter.format(parsed);
      String finalString = formattedInteger + (decimalPart != null ? ".$decimalPart" : (cleanText.endsWith('.') ? "." : ""));
      return TextEditingValue(text: finalString, selection: TextSelection.collapsed(offset: finalString.length));
    } catch (e) {
      return oldValue;
    }
  }
}

