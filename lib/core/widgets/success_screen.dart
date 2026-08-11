import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:lottie/lottie.dart';
import 'receipt_view.dart';
import '../app_colors.dart';
import '../responsive_utils.dart';
import '../../l10n/app_localizations.dart';

class SuccessScreen extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final String? subMessage; 
  final String? subtitle;
  final Map<String, dynamic>? transactionData;
  final VoidCallback? onPressed;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    this.subMessage,
    this.subtitle,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.onPressed != null) {
          widget.onPressed!();
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
              vertical: 32 * context.fontSizeFactor,
            ),
            child: MaxWidthBox(
              maxWidth: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    child: SizedBox(
                      height: 200 * context.fontSizeFactor,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Lottie.network(
                            'https://assets10.lottiefiles.com/packages/lf20_cyn8dgca.json',
                            repeat: false,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.check_circle_outline,
                                color: AppColors.accentTeal.withOpacity(0.2),
                                size: 150 * context.fontSizeFactor,
                              );
                            },
                          ),
                          Container(
                            height: 100 * context.fontSizeFactor,
                            width: 100 * context.fontSizeFactor,
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
                                  blurRadius: 20 * context.fontSizeFactor,
                                  offset: Offset(0, 10 * context.fontSizeFactor),
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 60 * context.fontSizeFactor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24 * context.fontSizeFactor,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  if (widget.message.isNotEmpty) ...[
                    SizedBox(height: 12 * context.fontSizeFactor),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (widget.subtitle != null) ...[
                    SizedBox(height: 12 * context.fontSizeFactor),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (widget.subMessage != null) ...[
                    SizedBox(height: 16 * context.fontSizeFactor),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * context.fontSizeFactor,
                        vertical: 8 * context.fontSizeFactor,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                      ),
                      child: Text(
                        widget.subMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.accentTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 14 * context.fontSizeFactor,
                        ),
                      ),
                    ),
                  ],
                  if (widget.transactionData != null) ...[
                    SizedBox(height: 24 * context.fontSizeFactor),
                    TextButton.icon(
                      onPressed: () => ReceiptView.show(context, widget.transactionData!),
                      icon: Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.accentTeal,
                        size: 20 * context.fontSizeFactor,
                      ),
                      label: Text(
                        AppLocalizations.of(context)?.viewReceipt ?? "View Receipt",
                        style: TextStyle(
                          color: AppColors.accentTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 14 * context.fontSizeFactor,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 48 * context.fontSizeFactor),
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
                          borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                        ),
                      ),
                      child: FittedBox(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
