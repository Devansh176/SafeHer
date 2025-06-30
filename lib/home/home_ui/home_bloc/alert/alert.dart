import 'package:audioplayers/audioplayers.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:vibration/vibration.dart';

AudioPlayer? _player;
double _originalVolume = 0.5;

Future<void> playAlertSound() async {
  final volumeController = VolumeController.instance;
  volumeController.showSystemUI = true;

  _originalVolume = await volumeController.getVolume();
  await volumeController.setVolume(0.5);

  _player = AudioPlayer();
  await _player!.play(AssetSource('sounds/alert.mp3'));

  // Vibrate (optional)
  if (await Vibration.hasVibrator()) {
    Vibration.vibrate(duration: 1000);
  }
}

Future<void> stopAlertSound() async {
  if (_player != null) {
    await _player!.stop();
    _player = null;

    // Restore original volume
    final volumeController = VolumeController.instance;
    await volumeController.setVolume(_originalVolume);
  }
}
