import 'dart:async';
import 'package:flutter/foundation.dart';

/// Pluggable interface for concrete audio engines (e.g. just_audio, audioplayers).
abstract class AcChatAudioDriver {
  Future<void> play({
    required String filePathOrUrl,
    required void Function({required double progress, required int elapsedSeconds}) onProgress,
    required void Function() onCompleted,
  });
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
}

/// Unified audio playback controller for `ac_chat` voice notes with strictly named parameters.
class AcChatAudioPlayer {
  static final AcChatAudioPlayer _instance = AcChatAudioPlayer._internal();
  factory AcChatAudioPlayer() => _instance;
  AcChatAudioPlayer._internal();

  AcChatAudioDriver? _driver;
  void setDriver({required AcChatAudioDriver driver}) {
    _driver = driver;
  }

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

  void play({
    required String messageId,
    required int durationInSeconds,
    String? filePathOrUrl,
  }) {
    if (_playingMessageId == messageId) {
      if (_isPaused) {
        resume();
      } else {
        pause();
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

    if (_driver != null && filePathOrUrl != null && filePathOrUrl.isNotEmpty) {
      _driver!.play(
        filePathOrUrl: filePathOrUrl,
        onProgress: ({required double progress, required int elapsedSeconds}) {
          _progress = progress;
          _elapsedSeconds = elapsedSeconds;
          _updateNotifiers();
        },
        onCompleted: () {
          stop();
        },
      );
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final startTick = (_progress * _totalDurationSeconds * 10).round();
    int currentTick = startTick;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentTick++;
      final totalTicks = _totalDurationSeconds * 10;
      if (totalTicks <= 0 || currentTick >= totalTicks) {
        stop();
        return;
      }

      _progress = currentTick / totalTicks;
      _elapsedSeconds = (currentTick / 10).floor();
      _updateNotifiers();
    });
  }

  void pause() {
    _driver?.pause();
    _timer?.cancel();
    _timer = null;
    _isPaused = true;
    _updateNotifiers();
  }

  void resume() {
    _driver?.resume();
    _isPaused = false;
    _updateNotifiers();
    if (_driver == null) {
      _startTimer();
    }
  }

  void stop() {
    _driver?.stop();
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
