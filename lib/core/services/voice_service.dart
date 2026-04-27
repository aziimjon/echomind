import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final VoiceService instance = VoiceService._();
  VoiceService._();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    // Request permission first
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint('Microphone permission denied.');
      return false;
    }

    try {
      _isInitialized = await _speech.initialize(
        onError: (val) => debugPrint('STT Error: ${val.errorMsg}'),
        onStatus: (val) => debugPrint('STT Status: $val'),
      );
    } catch (e) {
      debugPrint('STT Init Failed: $e');
      _isInitialized = false;
    }
    return _isInitialized;
  }

  void startListening({
    required Function(String) onResult,
    required VoidCallback onDone,
  }) {
    if (!_isInitialized) return;
    _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) onDone();
      },
      cancelOnError: true,
      partialResults: true,
      listenMode: ListenMode.dictation,
    );
  }

  void stopListening() {
    _speech.stop();
  }

  void cancelListening() {
    _speech.cancel();
  }

  bool get isListening => _speech.isListening;
}
