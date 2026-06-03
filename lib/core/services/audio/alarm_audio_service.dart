import 'package:audioplayers/audioplayers.dart';

abstract class AlarmAudioService {
  Future<void> playLoop(String assetPath);
  Future<void> stop();
  Future<void> dispose();
}

class AudioplayersAlarmAudioService implements AlarmAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> playLoop(String assetPath) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource(assetPath));
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  @override
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
