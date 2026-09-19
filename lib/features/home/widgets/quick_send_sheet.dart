import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/app_auth_helper.dart';
import '../../../core/responsive_utils.dart';
import '../../../core/models/quick_profile.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
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
  final TextEditingController _sourceDetailController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedSource = "Main Wallet";
  String? _selectedCardId;
  String _payoutMethod = "Wallet";
  String? _bankName;
  bool _isFeeIncluded = false;
  bool _isSourceInitialized = false;

  final List<String> _payoutMethods = ["Wallet", "Mobile Money", "Bank"];
  final List<String> _sourceMethods = ["Main Wallet", "Debit Card", "Mobile Money", "Bank Transfer"];

  bool _isVerifyingSource = false;
  String? _sourceVerificationMessage;
  
  // New verification state
  bool _isVerifying = false;
  String? _detectedProvider;
  String? _verifiedAccountName;
  bool _isSourceDetailsValid = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = (widget.profile.lastAmount ?? 10.0).toStringAsFixed(2);
    _payoutMethod = widget.profile.payoutMethod ?? 'Wallet';
    _bankName = widget.profile.bankName;
    
    // Set default source based on last used, if available
    if (widget.profile.lastSenderMethod != null) {
      _selectedSource = widget.profile.lastSenderMethod!;
      // Handle card selection if it was a card
      if (_selectedSource.startsWith("Card ")) {
        _selectedCardId = _selectedSource.substring(5);
      }
    }
    _isSourceDetailsValid = (_selectedSource == "Main Wallet" || _selectedSource.startsWith("Card "));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceDetailController.dispose();
    _cardNameController.dispose();
    _cardCvvController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSourceDetailChanged(String value, AppState state) async {
    if (_selectedSource == "Mobile Money") {
      _detectMobileProvider(value);
      if (value.length >= 7) {
        _verifyAccount(value, "mobile", state);
      } else {
        setState(() {
          _verifiedAccountName = null;
          _isSourceDetailsValid = false;
        });
      }
    } else if (_selectedSource == "Bank Transfer") {
      // IBS: 12, Salaam: 10, Premier: 10
      int maxLength = 12; 
      if (value.startsWith('10') || value.startsWith('50')) maxLength = 10;
      
      if (value.length == maxLength) {
        _verifyAccount(value, "bank", state);
      } else {
        setState(() {
          _verifiedAccountName = null;
          _detectedProvider = null;
          _isSourceDetailsValid = false;
        });
      }
    } else if (_selectedSource == "Debit Card") {
      setState(() {
        _isSourceDetailsValid = value.length == 16 && 
            _cardNameController.text.isNotEmpty && 
            _cardCvvController.text.length >= 3;
      });
    } else if (_selectedSource == "Main Wallet" || _selectedSource.startsWith("Card ")) {
      setState(() {
        _isSourceDetailsValid = true;
      });
    }
  }

  void _detectMobileProvider(String phone) {
    String? provider;
    if (phone.startsWith('61')) provider = 'Hormuud (EVC Plus)';
    else if (phone.startsWith('62')) provider = 'Somnet';
    else if (phone.startsWith('63')) provider = 'Telesom (Zaad)';
    else if (phone.startsWith('65')) provider = 'Sahal';
    else if (phone.startsWith('77')) provider = 'e-Dahab';
    
    setState(() {
      _detectedProvider = provider;
    });
  }

  Future<void> _verifyAccount(String id, String type, AppState state) async {
    setState(() => _isVerifying = true);
    final details = await state.resolveAccountDetails(id, type: type);
    setState(() {
      _isVerifying = false;
      if (details != null) {
        _verifiedAccountName = details['name'];
        if (type == 'bank') _detectedProvider = details['bank'];
        _isSourceDetailsValid = true;
      } else {
        _verifiedAccountName = null;
        _isSourceDetailsValid = false;
      }
    });
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
            if (_noteController.text.isNotEmpty) _buildReviewRow("Note", _noteController.text),
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
              _showPinDialog(state, l10n);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showPinDialog(AppState state, AppLocalizations l10n) {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Gali PIN-kaaga"),
            if (state.biometricEnabled)
              IconButton(
                icon: const Icon(Icons.fingerprint, color: AppColors.accentTeal),
                onPressed: () async {
                  final authenticated = await AppAuthHelper.authenticateWithBiometrics();
                  if (authenticated) {
                    Navigator.pop(context);
                    _processQuickSend(state, l10n);
                  }
                },
              ),
          ],
        ),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: const TextStyle(letterSpacing: 20, fontSize: 24, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(hintText: "****", counterText: ""),
          onChanged: (value) {
            if (value.length == 4) {
              if (state.verifyPin(value)) {
                Navigator.pop(context);
                _processQuickSend(state, l10n);
              } else {
                pinController.clear();
                HapticFeedback.vibrate();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PIN-ku waa khalad"), backgroundColor: Colors.redAccent),
                );
              }
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
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

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: (isTotal ? 16 : 14) * context.fontSizeFactor, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? null : Colors.grey)),
        Text(value, style: TextStyle(fontSize: (isTotal ? 16 : 14) * context.fontSizeFactor, fontWeight: FontWeight.bold, color: isTotal ? AppColors.accentTeal : null)),
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
            backgroundColor: Colors.grey.withValues(alpha: 0.1), 
            valueColor: AlwaysStoppedAnimation<Color>(percent > 0.9 ? Colors.red : AppColors.accentTeal), 
            minHeight: 4
          ),
        ),
      ],
    );
  }

  Future<void> _processQuickSend(AppState state, AppLocalizations l10n) async {
    setState(() {
      _isProcessing = true;
      _isVerifyingSource = true;
      _sourceVerificationMessage = "Verifying ${_selectedSource}...";
    });
    HapticFeedback.heavyImpact();

    try {
      final double sendAmount =
          double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      final String sourceDetail = _sourceDetailController.text.trim();

      // Professional Validation & Logic
      if (_selectedSource == "Mobile Money") {
        if (sourceDetail.length < 7) throw Exception('invalid_phone');
        setState(() => _sourceVerificationMessage = "Verifying Mobile Number...");
        await Future.delayed(const Duration(seconds: 1));
        setState(() => _sourceVerificationMessage = "Sending STK Push notification...");
        await Future.delayed(const Duration(seconds: 2));
      } else if (_selectedSource == "Main Wallet") {
        setState(() => _sourceVerificationMessage = "Checking Identity & Balance...");
        await Future.delayed(const Duration(seconds: 1));
      } else if (_selectedSource == "Debit Card" || _selectedSource.startsWith("Card")) {
        if (_selectedSource == "Debit Card" && sourceDetail.length < 16) throw Exception('invalid_card');
        setState(() => _sourceVerificationMessage = "Authenticating with 3D Secure...");
        await Future.delayed(const Duration(seconds: 2));
      } else if (_selectedSource == "Bank Transfer") {
        if (sourceDetail.isEmpty) throw Exception('invalid_bank_account');
        setState(() => _sourceVerificationMessage = "Verifying Bank Account...");
        await Future.delayed(const Duration(seconds: 1));
        setState(() => _sourceVerificationMessage = "Connecting to clearing house...");
        await Future.delayed(const Duration(seconds: 1));
      }

      setState(() {
        _isVerifyingSource = false;
        _sourceVerificationMessage = null;
      });

      final transaction = await state.sendMoney(
        sendAmount,
        widget.profile.walletId,
        widget.profile.name,
        _selectedSource,
        _selectedCardId,
        _payoutMethod,
        _noteController.text.isEmpty ? "Transfer" : _noteController.text,
      );

      // Update the profile with last used details for better "Quick" experience
      final updatedProfile = widget.profile.copyWith(
        lastAmount: sendAmount,
        lastSenderMethod: _selectedSource,
        lastTransactionDate: DateTime.now(),
        transactionCount: widget.profile.transactionCount + 1,
      );
      await state.saveQuickProfile(updatedProfile);

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
            verificationStatus: widget.profile.verificationStatus,
            transactionData: transaction?.toJson(),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isVerifyingSource = false;
      });
      String errorMessage = l10n.transactionFailed;
      String errStr = e.toString();
      
      if (errStr.contains('insufficient_funds')) {
        errorMessage = l10n.insufficientBalance;
      } else if (errStr.contains('limit_exceeded')) {
        errorMessage = "Transaction limit exceeded";
      } else if (errStr.contains('invalid_phone')) {
        errorMessage = "Fadlan geli lambar mobile oo sax ah";
      } else if (errStr.contains('invalid_card')) {
        errorMessage = "Card number-ka aad gelisay ma saxan dega";
      } else if (errStr.contains('invalid_bank_account')) {
        errorMessage = "Fadlan geli account number-ka bangiga";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildVerificationBadge(QuickProfile profile) {
    if (profile.verificationStatus == 'verified' || profile.isVerified) {
      return const Icon(Icons.verified, color: Colors.white, size: 24);
    }
    
    if (profile.verificationStatus == 'pending') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text(
              "Pending".toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    
    if (profile.verificationStatus == 'failed') {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
        child: const Icon(Icons.close, color: Colors.white, size: 14),
      );
    }
    
    return const SizedBox.shrink();
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
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    "Send Money",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: (theme.textTheme.titleLarge?.fontSize ?? 20) * context.fontSizeFactor,
                    ),
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
            const SizedBox(height: 20),
            
            // Receiver Card - PART TWO: SHOW RECEIVER NAME AND SAVED METHOD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryDark.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: ClipOval(
                      child: Image(
                        image: widget.profile.avatarUrl != null && widget.profile.avatarUrl!.startsWith('http') 
                          ? NetworkImage(widget.profile.avatarUrl!) 
                          : AssetImage(widget.profile.avatarUrl ?? 'assets/avatars/avatar1.png') as ImageProvider,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.profile.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              widget.profile.payoutMethod == 'Bank' ? Icons.account_balance : (widget.profile.payoutMethod == 'Mobile' ? Icons.phone_android : Icons.account_balance_wallet),
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.profile.payoutMethod}${widget.profile.bankName != null ? ' - ${widget.profile.bankName}' : ''}",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          widget.profile.walletId,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _buildVerificationBadge(widget.profile),
                ],
              ),
            ),
            if (widget.profile.payoutMethod == 'Bank')
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Fiiro gaar ah: Xawaaladaha bangiga waxay qaataan ilaa 24 saacadood.",
                        style: TextStyle(color: Colors.orange.shade800, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            
            // Amount Input
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
                      fontSize: 28 * context.fontSizeFactor,
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
            const SizedBox(height: 20),

            // Pay From Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pay From (Sender Details)",
                  style: TextStyle(color: Colors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: Builder(
                      builder: (context) {
                        final cardSourceIds = state.cards.map((c) => "Card ${c.id}").toList();
                        final availableSources = ["Main Wallet", "Mobile Money", "Bank Transfer", "Debit Card", ...cardSourceIds];
                        
                        // Ensure _selectedSource is valid, otherwise fallback to "Main Wallet"
                        if (!availableSources.contains(_selectedSource)) {
                          _selectedSource = "Main Wallet";
                          _selectedCardId = null;
                        }

                        return DropdownButton<String>(
                          value: _selectedSource,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: "Main Wallet",
                              child: Row(
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined, size: 18 * context.fontSizeFactor),
                                  const SizedBox(width: 8),
                                  Text("${l10n.mainWallet} (${NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)})"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: "Mobile Money",
                              child: Row(
                                children: [
                                  Icon(Icons.phone_android_outlined, size: 18 * context.fontSizeFactor),
                                  const SizedBox(width: 8),
                                  const Text("Mobile Money"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: "Bank Transfer",
                              child: Row(
                                children: [
                                  Icon(Icons.account_balance_outlined, size: 18 * context.fontSizeFactor),
                                  const SizedBox(width: 8),
                                  const Text("Bank Account"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: "Debit Card",
                              child: Row(
                                children: [
                                  Icon(Icons.credit_card_rounded, size: 18 * context.fontSizeFactor),
                                  const SizedBox(width: 8),
                                  const Text("New Debit Card"),
                                ],
                              ),
                            ),
                            ...state.cards.map((card) => DropdownMenuItem(
                              value: "Card ${card.id}",
                              onTap: () => _selectedCardId = card.id,
                              child: Row(
                                children: [
                                  Icon(Icons.credit_card_outlined, size: 18 * context.fontSizeFactor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${card.network.name} ****${card.cardNumber.substring(card.cardNumber.length - 4)}",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    " (${NumberFormat.simpleCurrency(name: state.currencyCode).format(card.balance)})",
                                    style: TextStyle(color: AppColors.accentTeal, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() {
                              _selectedSource = value;
                              _sourceDetailController.clear();
                              _cardNameController.clear();
                              _cardCvvController.clear();
                              _verifiedAccountName = null;
                              _detectedProvider = null;
                              _isSourceDetailsValid = (value == "Main Wallet" || value.startsWith("Card "));
                            });
                          },
                        );
                      }
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dynamic Source Details
            if (_selectedSource == "Mobile Money") ...[
              TextFormField(
                controller: _sourceDetailController,
                keyboardType: TextInputType.phone,
                onChanged: (v) => _onSourceDetailChanged(v, state),
                decoration: InputDecoration(
                  labelText: "Your Phone Number (STK Push)",
                  hintText: "e.g. 65xxxxxxx",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone_android),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_detectedProvider != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_detectedProvider!, style: TextStyle(color: AppColors.accentTeal, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                        ),
                      if (_isVerifying)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(width: 16 * context.fontSizeFactor, height: 16 * context.fontSizeFactor, child: const CircularProgressIndicator(strokeWidth: 2)),
                        )
                      else if (_verifiedAccountName != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 20 * context.fontSizeFactor),
                        ),
                    ],
                  ),
                ),
              ),
              if (_verifiedAccountName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 14 * context.fontSizeFactor, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(_verifiedAccountName!, style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ] else if (_selectedSource == "Bank Transfer") ...[
              TextFormField(
                controller: _sourceDetailController,
                keyboardType: TextInputType.number,
                onChanged: (v) => _onSourceDetailChanged(v, state),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Dynamic length limit based on bank prefix
                    int maxLength = 12;
                    if (newValue.text.startsWith('10') || newValue.text.startsWith('50')) {
                      maxLength = 10;
                    }
                    if (newValue.text.length > maxLength) return oldValue;
                    return newValue;
                  }),
                ],
                decoration: InputDecoration(
                  labelText: "Your Bank Account Number",
                  hintText: "Enter account to deduct from",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.account_balance),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isVerifying)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(width: 16 * context.fontSizeFactor, height: 16 * context.fontSizeFactor, child: const CircularProgressIndicator(strokeWidth: 2)),
                        )
                      else if (_verifiedAccountName != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 20 * context.fontSizeFactor),
                        ),
                    ],
                  ),
                ),
              ),
              if (_verifiedAccountName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, size: 14 * context.fontSizeFactor, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("$_verifiedAccountName (${_detectedProvider ?? 'Bank'})", 
                        style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ] else if (_selectedSource == "Debit Card") ...[
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _sourceDetailController,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _onSourceDetailChanged(v, state),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                          decoration: const InputDecoration(
                            labelText: "Card Number",
                            hintText: "xxxx xxxx xxxx xxxx",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.credit_card),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _cardNameController,
                          onChanged: (v) => _onSourceDetailChanged(_sourceDetailController.text, state),
                          decoration: const InputDecoration(
                            labelText: "Name",
                            hintText: "Holder",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _cardCvvController,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _onSourceDetailChanged(_sourceDetailController.text, state),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                          decoration: const InputDecoration(
                            labelText: "CVV",
                            hintText: "xxx",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isSourceDetailsValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16 * context.fontSizeFactor),
                          const SizedBox(width: 4),
                          Text("Card details ready", style: TextStyle(color: Colors.green, fontSize: 11 * context.fontSizeFactor)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Transaction Note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: "Note (Optional)",
                hintText: "What is this for?",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.notes_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            // Deduct Fee Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.deductFeeFromAmount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
                        Text(_isFeeIncluded ? l10n.receiverWillReceiveLess : l10n.payFeeSeparately, style: TextStyle(fontSize: 10 * context.fontSizeFactor, color: Colors.grey)),
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
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(context, l10n.transactionFee, NumberFormat.simpleCurrency(name: state.currencyCode).format(_getFee(state))),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      context,
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
                            Icon(Icons.access_time_filled_rounded, size: 14 * context.fontSizeFactor, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text(l10n.arrivesIn24h, style: TextStyle(fontSize: 11 * context.fontSizeFactor, color: Colors.orange, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56 * context.fontSizeFactor,
              child: ElevatedButton(
                onPressed: (_isProcessing || !_isSourceDetailsValid) ? null : () => _showReviewDialog(state, l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isProcessing
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            height: 20 * context.fontSizeFactor,
                            width: 20 * context.fontSizeFactor,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)),
                        if (_sourceVerificationMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_sourceVerificationMessage!,
                                style: TextStyle(fontSize: 10 * context.fontSizeFactor)),
                          ),
                      ],
                    )
                  : Text(
                      l10n.send,
                      style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
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


