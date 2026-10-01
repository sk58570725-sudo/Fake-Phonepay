import 'package:audioplayers/audioplayers.dart';

class SoundBox {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> init() async {}

  static Future<void> paymentSuccess({
    required double amount,
    required String receiver,
    bool isDebit = true,
  }) async {
    try {
      await _player.play(AssetSource('phonepe_success.mp3'));
    } catch (_) {}
  }

  static Future<void> speak(String t) async {}
}2
