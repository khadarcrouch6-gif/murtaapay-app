import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';

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
    final state = AppState();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie with Error Handling
                  FadeIn(
                    child: SizedBox(
                      height: 200 * context.fontSizeFactor,
                      width: 200 * context.fontSizeFactor,
                      child: Lottie.network(
                        'https://lottie.host/8526543b-178b-497d-9477-ed21c97f4c54/9I3K59R7m3.json',
                        repeat: false,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to static icon if internet fails
                          return Container(
                            height: 110,
                            width: 110,
                            decoration: const BoxDecoration(
                              color: AppColors.accentTeal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  FadeInDown(
                    child: Text(
                      state.translate("Transfer Successful!", "Lacagta waa la diray!", ar: "تم التحويل بنجاح!", de: "Überweisung erfolgreich!"),
                      style: TextStyle(
                        fontSize: 26 * context.fontSizeFactor,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      state.translate(
                        "$amount has been securely sent to $receiverName.",
                        "\$$amount waxaa si ammaan ah loogu diray $receiverName.",
                        ar: "تم إرسال $amount بأمان إلى $receiverName.",
                        de: "$amount wurde sicher an $receiverName gesendet."
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 16 * context.fontSizeFactor,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          DetailRow(label: state.translate("Receiver", "Qaataha", ar: "المستلم", de: "Empfänger"), value: receiverName),
                          DetailRow(label: state.translate("Amount", "Cadadka", ar: "المبلغ", de: "Betrag"), value: "\$$amount"),
                          DetailRow(label: state.translate("Method", "Habka", ar: "الطريقة", de: "Methode"), value: method),
                          DetailRow(label: state.translate("Reference", "Tixraaca", ar: "المرجع", de: "Referenz"), value: "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          child: Text(
                            state.translate("Back to Home", "Ku noqo Home-ka", ar: "العودة إلى الصفحة الرئيسية", de: "Zurück zur Startseite"),
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16 * context.fontSizeFactor,
                            ),
                          ),
                        ),
                      ],
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
