import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/app_state.dart';

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
    final state = AppState();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Celebratory Background Elements
          Positioned(
            top: -100,
            right: -100,
            child: FadeIn(
              duration: const Duration(seconds: 2),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: FadeIn(
              duration: const Duration(seconds: 3),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ZoomIn(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ElasticIn(
                        delay: const Duration(milliseconds: 400),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 80),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      state.translate("Donation Successful!", "Deeqdu Way Guulaysatay!", ar: "تم التبرع بنجاح!", de: "Spende erfolgreich!"),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "\$${widget.amount.toInt()}",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                      style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium?.color, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 60),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close success screen
                          Navigator.pop(context); // Back to campaigns
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: Text(
                          state.translate("Back to Home", "Ku Noqo Hoyga", ar: "العودة للرئيسية", de: "Zurück zur Startseite"), 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
