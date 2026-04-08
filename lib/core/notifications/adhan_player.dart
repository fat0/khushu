import 'package:just_audio/just_audio.dart';
import '../debug_log.dart';

class AdhanPlayer {
  static AudioPlayer? _player;

  static Future<void> play({required bool isFajr}) async {
    try {
      await stop(); // Stop any currently playing adhan

      _player = AudioPlayer();
      final asset = isFajr
          ? 'assets/audio/adhan_fajr.ogg'
          : 'assets/audio/adhan_standard.ogg';
      await _player!.setAsset(asset);
      await _player!.play();

      // Clean up after playback completes
      _player!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          stop();
        }
      });
    } catch (e) {
      DebugLog.info('Adhan playback error: $e');
    }
  }

  static Future<void> stop() async {
    await _player?.stop();
    await _player?.dispose();
    _player = null;
  }
}
