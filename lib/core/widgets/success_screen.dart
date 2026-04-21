import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'receipt_view.dart';
import '../app_colors.dart';
import '../responsive_utils.dart';
import '../../l10n/app_localizations.dart';

class SuccessScreen extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final String? subMessage; 
  final Map<String, dynamic>? transactionData;
  final VoidCallback? onPressed;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    this.subMessage,
    this.transactionData,
    this.onPressed,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playSuccessSound();
  }

  Future<void> _playSuccessSound() async {
    await HapticFeedback.lightImpact();
    await _audioPlayer.play(AssetSource('sounds/success.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: MaxWidthBox(
          maxWidth: 500,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  child: Container(
                    height: 110 * context.fontSizeFactor,
                    width: 110 * context.fontSizeFactor,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF11998E).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 65 * context.fontSizeFactor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24 * context.fontSizeFactor,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 16 * context.fontSizeFactor,
                    height: 1.5,
                  ),
                ),
                if (widget.subMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.subMessage!,
                      style: const TextStyle(
                        color: AppColors.accentTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                if (widget.transactionData != null) ...[
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => ReceiptView.show(context, widget.transactionData!),
                    icon: const Icon(Icons.receipt_long_rounded, color: AppColors.accentTeal),
                    label: Text(
                      AppLocalizations.of(context)?.viewReceipt ?? "View Receipt",
                      style: const TextStyle(
                        color: AppColors.accentTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onPressed ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      padding: EdgeInsets.symmetric(
                        vertical: 16 * context.fontSizeFactor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.buttonText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * context.fontSizeFactor,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
