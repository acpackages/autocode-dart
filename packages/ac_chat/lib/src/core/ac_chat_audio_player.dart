import 'dart:async';
import 'package:flutter/foundation.dart';

class AcChatAudioPlayer {
  static final AcChatAudioPlayer _instance = AcChatAudioPlayer._internal();
  factory AcChatAudioPlayer() => _instance;
  AcChatAudioPlayer._internal();

  String? _playingMessageId;
  String? get playingMessageId => _playingMessageId;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  double _progress = 0.0;
  double get progress => _progress;

  int _elapsedSeconds = 0;
  int get elapsedSeconds => _elapsedSeconds;

  int _totalDurationSeconds = 0;

  Timer? _timer;
  final ValueNotifier<String?> playingNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<int> elapsedNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isPausedNotifier = ValueNotifier<bool>(false);

  void play(String messageId, int durationInSeconds) {
    if (_playingMessageId == messageId) {
      if (_isPaused) {
        _resume();
      } else {
        _pause();
      }
      return;
    }

    stop();

    _playingMessageId = messageId;
    _totalDurationSeconds = durationInSeconds;
    _progress = 0.0;
    _elapsedSeconds = 0;
    _isPaused = false;

    _updateNotifiers();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final startTick = (_progress * _totalDurationSeconds * 10).round();
    int currentTick = startTick;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentTick++;
      final totalTicks = _totalDurationSeconds * 10;
      if (currentTick >= totalTicks) {
        stop();
        return;
      }

      _progress = currentTick / totalTicks;
      _elapsedSeconds = (currentTick / 10).floor();
      
      progressNotifier.value = _progress;
      elapsedNotifier.value = _elapsedSeconds;
    });
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    _isPaused = true;
    _updateNotifiers();
  }

  void _resume() {
    _isPaused = false;
    _updateNotifiers();
    _startTimer();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _playingMessageId = null;
    _isPaused = false;
    _progress = 0.0;
    _elapsedSeconds = 0;
    _totalDurationSeconds = 0;

    _updateNotifiers();
  }

  void _updateNotifiers() {
    playingNotifier.value = _playingMessageId;
    progressNotifier.value = _progress;
    elapsedNotifier.value = _elapsedSeconds;
    isPausedNotifier.value = _isPaused;
  }
}
