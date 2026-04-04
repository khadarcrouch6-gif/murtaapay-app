import 'package:audioplayers/audioplayers.dart';

class AppUtils {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playSuccessSound() async {
    try {
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }
}
