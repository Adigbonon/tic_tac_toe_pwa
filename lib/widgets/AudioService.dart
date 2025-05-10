import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String path) async {
    await _player.stop(); // Stoppe un son précédent éventuel
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.play(AssetSource(path));
  }

  static Future<void> loop(String path) async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(path));
  }

  static Future<void> stop() async {
    await _player.stop();
  }
}
