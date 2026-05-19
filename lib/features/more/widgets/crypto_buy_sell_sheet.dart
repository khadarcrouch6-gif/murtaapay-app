import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/models/crypto_asset.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';

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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('insufficient_funds') ? l10n.insufficientBalance : e.toString()), 
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
      ? "${l10n.balance}: \$${state.balance.toStringAsFixed(2)}" 
      : "${l10n.active}: ${(state.cryptoHoldings[widget.asset.symbol] ?? 0).toStringAsFixed(6)} ${widget.asset.symbol}";

    return MaxWidthBox(
      maxWidth: 600,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24 * context.fontSizeFactor, 
          20 * context.fontSizeFactor, 
          24 * context.fontSizeFactor, 
          (MediaQuery.of(context).padding.bottom + 20) * context.fontSizeFactor
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40 * context.fontSizeFactor,
              height: 4 * context.fontSizeFactor,
              margin: EdgeInsets.only(bottom: 20 * context.fontSizeFactor),
              decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2 * context.fontSizeFactor)),
            ),
            Text(
              widget.isBuy ? "${l10n.buy} ${widget.asset.name}" : "${l10n.sell} ${widget.asset.name}",
              style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12 * context.fontSizeFactor),
            Text(availableLabel, style: TextStyle(color: theme.hintColor, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
            SizedBox(height: 32 * context.fontSizeFactor),
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
                        if (_isInputtingFiat) Text("\$", style: TextStyle(fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                        Flexible(
                          child: Text(
                            _amountStr,
                            style: TextStyle(fontSize: 48 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!_isInputtingFiat) Padding(
                          padding: EdgeInsets.only(left: 8.0 * context.fontSizeFactor),
                          child: Text(widget.asset.symbol, style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 8 * context.fontSizeFactor),
                        Icon(Icons.swap_vert_rounded, color: AppColors.accentTeal, size: 28 * context.fontSizeFactor),
                      ],
                    ),
                    SizedBox(height: 8 * context.fontSizeFactor),
                    Text(
                      subText,
                      style: TextStyle(fontSize: 16 * context.fontSizeFactor, color: theme.hintColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40 * context.fontSizeFactor),
            _buildNumericKeypad(theme),
            SizedBox(height: 32 * context.fontSizeFactor),
            SizedBox(
              width: double.infinity,
              height: 60 * context.fontSizeFactor,
              child: ElevatedButton(
                onPressed: _isProcessing || inputAmount <= 0 ? null : _processTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isBuy ? AppColors.accentTeal : Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
                  elevation: 0,
                  disabledBackgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                ),
                child: _isProcessing
                    ? SizedBox(height: 24 * context.fontSizeFactor, width: 24 * context.fontSizeFactor, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        widget.isBuy ? "${l10n.confirm} ${l10n.buy}" : "${l10n.confirm} ${l10n.sell}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
                      ),
              ),
            ),
          ],
        ),
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
                borderRadius: BorderRadius.circular(40 * context.fontSizeFactor),
                child: Container(
                  height: 60 * context.fontSizeFactor,
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
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
