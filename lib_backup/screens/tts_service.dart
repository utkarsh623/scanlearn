import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _flutterTts.setStartHandler(() {
      print("TTS started");
    });

    _flutterTts.setCompletionHandler(() {
      print("TTS completed");
    });

    _flutterTts.setCancelHandler(() {
      print("TTS cancelled");
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS error: $msg");
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> setLanguage(String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }
}
