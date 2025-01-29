import 'package:audio_service/audio_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  AudioPlayerHandler() {
    // Set initial playback state
    playbackState.add(PlaybackState(
      controls: [MediaControl.stop],
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }

  /// Start TTS playback
  Future<void> startTTS(String text, {String language = "en-US"}) async {
    // Update state to playing
    playbackState.add(PlaybackState(
      controls: [MediaControl.stop],
      playing: true,
      processingState: AudioProcessingState.ready,
    ));

    _isSpeaking = true;
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    await _flutterTts.speak(text);

    // Stop when finished speaking
    _flutterTts.setCompletionHandler(() async {
      _isSpeaking = false;
      stopTTS();
    });
  }

  /// Stop TTS playback
  Future<void> stopTTS() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;

      // Update state to stopped
      playbackState.add(PlaybackState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.idle,
      ));
    }
  }
}