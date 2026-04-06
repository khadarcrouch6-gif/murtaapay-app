import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/app_colors.dart';
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZoomIn(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 80),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  state.translate("Donation Successful!", "Deeqdu Way Guulaysatay!", ar: "تم التبرع بنجاح!", de: "Spende erfolgreich!"),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  state.translate(
                    "Thank you for your donation of \$${widget.amount.toInt()}. It will make a big difference in the lives of those in need.",
                    "Waad ku mahadsan tahay deeqdaada \$${widget.amount.toInt()}. Waxay wax weyn ka tari doontaa nolosha dadka u baahan.",
                    ar: "شكراً لتبرعك بمبلغ \$${widget.amount.toInt()}. سيحدث فرقاً كبيراً في حياة المحتاجين.",
                    de: "Vielen Dank für Ihre Spende von \$${widget.amount.toInt()}. Sie wird einen großen Unterschied im Leben der Bedürftigen machen.",
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium?.color, height: 1.5),
                ),
              ),
              const SizedBox(height: 60),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close success screen
                      Navigator.pop(context); // Back to campaigns
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(state.translate("Back to Home", "Ku Noqo Hoyga", ar: "العودة للرئيسية", de: "Zurück zur Startseite"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
