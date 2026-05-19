import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../../core/responsive_utils.dart';
import '../../core/app_state.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SuccessDonationScreen extends StatefulWidget {
  final double amount;
  const SuccessDonationScreen({super.key, required this.amount});

  @override
  State<SuccessDonationScreen> createState() => _SuccessDonationScreenState();
}

class _SuccessDonationScreenState extends State<SuccessDonationScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playSuccessSound();
  }

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    final scale = context.fontSizeFactor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Celebratory Background Elements
          Positioned(
            top: -100 * scale,
            right: -100 * scale,
            child: FadeIn(
              duration: const Duration(seconds: 2),
              child: Container(
                width: 300 * scale,
                height: 300 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50 * scale,
            left: -50 * scale,
            child: FadeIn(
              duration: const Duration(seconds: 3),
              child: Container(
                width: 200 * scale,
                height: 200 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Center(
            child: MaxWidthBox(
              maxWidth: 600,
              child: Padding(
                padding: EdgeInsets.all(32.0 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        width: 140 * scale,
                        height: 140 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              blurRadius: 30 * scale,
                              spreadRadius: 10 * scale,
                            ),
                          ],
                        ),
                        child: ElasticIn(
                          delay: const Duration(milliseconds: 400),
                          child: Icon(Icons.check_rounded, color: Colors.white, size: 80 * scale),
                        ),
                      ),
                    ),
                    SizedBox(height: 48 * scale),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        state.translate("Donation Successful!", "Deeqdu Way Guulaysatay!", ar: "تم التبرع بنجاح!", de: "Spende erfolgreich!"),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28 * scale, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        child: Text(
                          "\$${widget.amount.toInt()}",
                          style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        state.translate(
                          "Thank you for your donation. It will make a big difference in the lives of those in need.",
                          "Waad ku mahadsan tahay deeqdaada. Waxay wax weyn ka tari doontaa nolosha dadka u baahan.",
                          ar: "شكراً لتبرعك. سيحدث فرقاً كبيراً في حياة المحتاجين.",
                          de: "Vielen Dank für Ihre Spende. Sie wird einen großen Unterschied im Leben der Bedürftigen machen.",
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16 * scale, color: theme.textTheme.bodyMedium?.color, height: 1.6),
                      ),
                    ),
                    SizedBox(height: 60 * scale),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60 * scale,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close success screen
                            Navigator.pop(context); // Back to campaigns
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * scale)),
                            elevation: 0,
                          ),
                          child: Text(
                            state.translate("Back to Home", "Ku Noqo Hoyga", ar: "العودة للرئيسية", de: "Zurück zur Startseite"), 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * scale),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
