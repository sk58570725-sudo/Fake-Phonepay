import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundBox {
  static final FlutterTts _tts = FlutterTts();
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> init() async {
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
  }

  static Future<void> paymentSuccess({
    required double amount,
    required String receiver,
    bool isDebit = true,
  }) async {
    try {
      await _player.play(AssetSource('phonepe_success.mp3'));
      await Future.delayed(const Duration(milliseconds: 900));
    } catch (_) {}

    final amt = _formatAmount(amount);
    final text = isDebit
        ? 'PhonePe par $amt rupaye bheje gaye.'
        : 'PhonePe par $amt rupaye prapt hue.';
    await _tts.speak(text);
  }

  static String _formatAmount(double a) {
    if (a >= 100000) {
      final lakh = a / 100000;
      final s = lakh.truncateToDouble() == lakh
          ? lakh.toInt().toString()
          : lakh.toStringAsFixed(1);
      return '$s lakh';
    }
    if (a == a.truncateToDouble()) return a.toInt().toString();
    return a.toStringAsFixed(2);
  }

  static Future<void> speak(String t) => _tts.speak(t);
}
