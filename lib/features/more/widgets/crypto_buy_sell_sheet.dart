import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/models/crypto_asset.dart';
import '../../../l10n/app_localizations.dart';

class CryptoBuySellSheet extends StatefulWidget {
  final CryptoAsset asset;
  final bool isBuy;

  const CryptoBuySellSheet({
    super.key,
    required this.asset,
    required this.isBuy,
  });

  @override
  State<CryptoBuySellSheet> createState() => _CryptoBuySellSheetState();
}

class _CryptoBuySellSheetState extends State<CryptoBuySellSheet> {
  String _amountStr = "0";
  bool _isProcessing = false;
  bool _isInputtingFiat = true; // Revolut style: switch between USD and Crypto

  @override
  void initState() {
    super.initState();
    _isInputtingFiat = widget.isBuy;
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == "⌫") {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = "0";
        }
      } else if (key == ".") {
        if (!_amountStr.contains(".")) {
          _amountStr += ".";
        }
      } else {
        if (_amountStr == "0") {
          _amountStr = key;
        } else {
          _amountStr += key;
        }
      }
    });
  }

  void _toggleInputMode() {
    setState(() {
      final amount = double.tryParse(_amountStr) ?? 0;
      if (_isInputtingFiat) {
        // Convert USD to Crypto for the new display
        _amountStr = (amount / widget.asset.price).toStringAsFixed(6);
      } else {
        // Convert Crypto to USD for the new display
        _amountStr = (amount * widget.asset.price).toStringAsFixed(2);
      }
      // Remove trailing zeros and dot if necessary
      if (_amountStr.contains('.')) {
        _amountStr = _amountStr.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      }
      if (_amountStr.isEmpty) _amountStr = "0";
      
      _isInputtingFiat = !_isInputtingFiat;
    });
  }

  Future<void> _processTransaction() async {
    final state = Provider.of<AppState>(context, listen: false);
    final inputAmount = double.tryParse(_amountStr) ?? 0;

    if (inputAmount <= 0) return;

    setState(() => _isProcessing = true);

    try {
      double fiatAmount;
      double cryptoAmount;

      if (_isInputtingFiat) {
        fiatAmount = inputAmount;
        cryptoAmount = fiatAmount / widget.asset.price;
      } else {
        cryptoAmount = inputAmount;
        fiatAmount = cryptoAmount * widget.asset.price;
      }

      await Future.delayed(const Duration(seconds: 1)); // Smoother feel

      if (widget.isBuy) {
        await state.buyCrypto(widget.asset, fiatAmount, cryptoAmount);
      } else {
        await state.sellCrypto(widget.asset, cryptoAmount, fiatAmount);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('insufficient_funds') ? "Insufficient funds in wallet" : e.toString()), 
            backgroundColor: Colors.redAccent
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);
    final inputAmount = double.tryParse(_amountStr) ?? 0;
    
    // Calculate conversion for the sub-text
    String subText = "";
    if (_isInputtingFiat) {
      final cryptoAmount = inputAmount / widget.asset.price;
      subText = "≈ ${cryptoAmount.toStringAsFixed(6)} ${widget.asset.symbol}";
    } else {
      final fiatAmount = inputAmount * widget.asset.price;
      subText = "≈ \$${fiatAmount.toStringAsFixed(2)}";
    }

    final availableLabel = widget.isBuy 
      ? "Balance: \$${state.balance.toStringAsFixed(2)}" 
      : "Available: ${(state.cryptoHoldings[widget.asset.symbol] ?? 0).toStringAsFixed(6)} ${widget.asset.symbol}";

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
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
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
          ),
          Text(
            widget.isBuy ? "${l10n.buy} ${widget.asset.name}" : "${l10n.sell} ${widget.asset.name}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(availableLabel, style: TextStyle(color: theme.hintColor, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _toggleInputMode,
            behavior: HitTestBehavior.opaque,
            child: FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_isInputtingFiat) const Text("\$", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      Flexible(
                        child: Text(
                          _amountStr,
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!_isInputtingFiat) Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(widget.asset.symbol, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.swap_vert_rounded, color: AppColors.accentTeal, size: 28),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subText,
                    style: TextStyle(fontSize: 16, color: theme.hintColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildNumericKeypad(theme),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isProcessing || inputAmount <= 0 ? null : _processTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isBuy ? AppColors.accentTeal : Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                disabledBackgroundColor: theme.dividerColor.withOpacity(0.1),
              ),
              child: _isProcessing
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      widget.isBuy ? "Review Buy" : "Review Sell",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericKeypad(ThemeData theme) {
    final keys = [
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"],
      [".", "0", "⌫"],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            return Expanded(
              child: InkWell(
                onTap: () => _onKeyTap(key),
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
