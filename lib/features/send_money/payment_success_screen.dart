import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String amount;
  final String receiverName;
  final String method;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: MaxWidthBox(
            maxWidth: 500,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Lottie with Error Handling
                    FadeIn(
                      child: SizedBox(
                        height: 220,
                        width: 220,
                        child: Lottie.network(
                          'https://lottie.host/8526543b-178b-497d-9477-ed21c97f4c54/9I3K59R7m3.json',
                          repeat: false,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 120,
                              decoration: const BoxDecoration(
                                color: AppColors.accentTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 70),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    FadeInDown(
                      child: Text(
                        l10n.transferSuccessful,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: theme.textTheme.bodyLarge?.color,
                          letterSpacing: -1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          l10n.transferSentMessage(amount, receiverName),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildCompactRow(context, l10n.receiver, receiverName),
                            const Divider(height: 24),
                            _buildCompactRow(context, l10n.amount, "\$amount"),
                            const Divider(height: 24),
                            _buildCompactRow(context, l10n.method, method),
                            const Divider(height: 24),
                            _buildCompactRow(context, l10n.reference, "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Back to Home Button (Original Position inside scroll)
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: AppColors.accentTeal.withValues(alpha: 0.3),
                          ),
                          child: Text(
                            l10n.backToHome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w900, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
