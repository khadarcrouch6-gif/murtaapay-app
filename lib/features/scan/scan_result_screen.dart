import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/models/transaction.dart';
import 'package:provider/provider.dart';

class ScanResultScreen extends StatefulWidget {
  final String data;
  const ScanResultScreen({super.key, required this.data});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _isLoading = true;
  late String _receiverName;
  late String _amount;
  late String _receiverId;

  @override
  void initState() {
    super.initState();
    _parseData();
  }

  void _parseData() {
    // Simulated smart parsing
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_isDisposed) return;
      setState(() {
        // Mocking logic based on scanned data
        if (widget.data.contains("murtaax:")) {
          final parts = widget.data.replaceFirst("murtaax:", "").split("?");
          _receiverId = parts[0];
          _receiverName = "Warsame Hassan"; // Mock name
          _amount = parts.length > 1 ? parts[1].replaceFirst("val=", "") : "0.00";
        } else {
          _receiverId = widget.data.length > 8 ? widget.data.substring(0, 8) : widget.data;
          _receiverName = "Unknown Receiver";
          _amount = "0.00";
        }
        _isLoading = false;
      });
    });
  }

  bool _isDisposed = false;
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.paymentMethod),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? _buildLoadingState()
        : _buildResultContent(context, l10n, theme),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.accentTeal),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.processing, // "Processing..."
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return FadeIn(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Success Icon & Title
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 64),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.receiverDetails,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // 2. Details Card
            _buildDetailCard(l10n),

            const SizedBox(height: 48),

            // 3. Action Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final state = Provider.of<AppState>(context, listen: false);
                  final double? amountValue = double.tryParse(_amount);
                  
                  if (amountValue != null && amountValue > 0) {
                    if (state.hasSufficientBalance(amountValue)) {
                      state.deductBalance(amountValue);

                      state.addTransaction(Transaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _receiverName,
                        date: DateFormat('MMM dd').format(DateTime.now()),
                        amount: "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(amountValue)}",
                        isNegative: true,
                        category: "Payment",
                        status: "Success",
                        type: "payment",
                        method: "Scan & Pay",
                      ));

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessScreen(
                            title: l10n.paymentSuccessful,
                            message: l10n.paymentSuccessMessage(NumberFormat.simpleCurrency(name: state.currencyCode).format(amountValue), _receiverName),
                            subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)),
                            buttonText: l10n.backToHome,
                            onPressed: () {
                              Navigator.of(context).popUntil((route) => route.settings.name == 'SendAmountScreen' || route.isFirst);
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.insufficientBalance)),
                      );
                    }
                  } else if (_amount == "0.00" || _amount == "Flexible") {
                    // If flexible, we might need an amount input, but for now let's just mock a $10 payment if it's "Flexible"
                    const flexibleAmount = 10.0;
                    if (state.hasSufficientBalance(flexibleAmount)) {
                       state.deductBalance(flexibleAmount);

                       state.addTransaction(Transaction(
                         id: DateTime.now().millisecondsSinceEpoch.toString(),
                         title: _receiverName,
                         date: DateFormat('MMM dd').format(DateTime.now()),
                         amount: "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(flexibleAmount)}",
                         isNegative: true,
                         category: "Payment",
                         status: "Success",
                         type: "payment",
                         method: "Scan & Pay",
                       ));

                       Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessScreen(
                            title: l10n.paymentSuccessful,
                            message: l10n.paymentSuccessMessage(NumberFormat.simpleCurrency(name: state.currencyCode).format(flexibleAmount), _receiverName),
                            subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance)),
                            buttonText: l10n.backToHome,
                            onPressed: () {
                              Navigator.of(context).popUntil((route) => route.settings.name == 'SendAmountScreen' || route.isFirst);
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.insufficientBalance)),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.invalidAmount)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(l10n.payNow, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          DetailRow(label: l10n.receiver, value: _receiverName),
          DetailRow(label: l10n.walletId, value: _receiverId),
          DetailRow(
            label: l10n.amount, 
            value: _amount == "0.00" ? "Flexible" : "\$$_amount",
            valueColor: AppColors.accentTeal,
          ),
        ],
      ),
    );
  }

  // _buildInfoRow removed as it's replaced by DetailRow
}
