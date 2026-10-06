import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SleepSoundService extends ChangeNotifier {
  static final SleepSoundService _instance = SleepSoundService._internal();
  factory SleepSoundService() => _instance;
  SleepSoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  String? _currentSoundId;
  String? get currentSoundId => _currentSoundId;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  int? _timerMinutesRemaining;
  int? get timerMinutesRemaining => _timerMinutesRemaining;
  Timer? _countdownTimer;

  final List<Map<String, String>> sounds = [
    {
      'id': 'rain',
      'title': 'Heavy Rain',
      'path': 'assets/audio/rain_sleep.wav',
      'icon': 'umbrella',
      'desc': 'Gentle patter on windowpane'
    },
    {
      'id': 'ocean',
      'title': 'Ocean Waves',
      'path': 'assets/audio/ocean_waves.wav',
      'icon': 'water',
      'desc': 'Deep rhythmic ocean surf'
    },
    {
      'id': 'white_noise',
      'title': 'White Noise',
      'path': 'assets/audio/white_noise.wav',
      'icon': 'air',
      'desc': 'Calming ambient sound mask'
    },
  ];

  Future<void> playSound(String id) async {
    final sound = sounds.firstWhere((s) => s['id'] == id, orElse: () => sounds.first);
    if (_currentSoundId == id && _isPlaying) {
      await stopSound();
      return;
    }

    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      String cleanPath = sound['path']!;
      if (cleanPath.startsWith('assets/')) {
        cleanPath = cleanPath.substring('assets/'.length);
      }
      await _player.setVolume(0.8);
      await _player.play(AssetSource(cleanPath));
      _currentSoundId = id;
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing sleep sound: $e');
    }
  }

  Future<void> stopSound() async {
    _countdownTimer?.cancel();
    _timerMinutesRemaining = null;
    await _player.stop();
    _isPlaying = false;
    _currentSoundId = null;
    notifyListeners();
  }

  void setTimer(int minutes) {
    _countdownTimer?.cancel();
    _timerMinutesRemaining = minutes;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_timerMinutesRemaining != null && _timerMinutesRemaining! > 1) {
        _timerMinutesRemaining = _timerMinutesRemaining! - 1;
        notifyListeners();
      } else {
        stopSound();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}
