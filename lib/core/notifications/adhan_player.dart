import 'package:just_audio/just_audio.dart';
import '../debug_log.dart';

class AdhanPlayer {
  static AudioPlayer? _player;

  static Future<void> play({required bool isFajr}) async {
    try {
      await stop();

      _player = AudioPlayer();
      final asset = isFajr
          ? 'assets/audio/adhan_fajr.ogg'
          : 'assets/audio/adhan_standard.ogg';
      await _player!.setAsset(asset);
      _player!.play();

      DebugLog.info('[ADHAN] Playing ${isFajr ? "Fajr" : "standard"} adhan');

      // Auto-stop when complete
      _player!.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          stop();
        }
      });
    } catch (e) {
      DebugLog.info('[ADHAN] Playback error: $e');
    }
  }

  static Future<void> waitForCompletion() async {
    if (_player == null) return;
    try {
      await _player!.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _player?.stop();
      await _player?.dispose();
    } catch (_) {}
    _player = null;
    DebugLog.info('[ADHAN] Stopped');
  }

  static bool get isPlaying => _player?.playing ?? false;
}
