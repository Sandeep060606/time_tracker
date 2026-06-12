import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../utils/app_constants.dart';

class QrScannerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _lastCode;
  DateTime? _lastScanAt;

  bool isDuplicate(String code) {
    final now = DateTime.now();
    final duplicate =
        _lastCode == code &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!).inSeconds < 3;
    if (!duplicate) {
      _lastCode = code;
      _lastScanAt = now;
    }
    return duplicate;
  }

  Future<void> successFeedback() async {
    await HapticFeedback.mediumImpact();
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(AppConstants.successSoundAsset));
  }

  Future<void> dispose() => _audioPlayer.dispose();
}
