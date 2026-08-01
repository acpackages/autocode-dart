import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../core/ac_chat.dart';

class AudioRecordingBottomSheet extends StatefulWidget {
  final AcChatTheme ct;
  final ValueChanged<int> onCompleted;

  const AudioRecordingBottomSheet({
    super.key,
    required this.ct,
    required this.onCompleted,
  });

  @override
  State<AudioRecordingBottomSheet> createState() => _AudioRecordingBottomSheetState();
}

class _AudioRecordingBottomSheetState extends State<AudioRecordingBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _secondsTimer;
  int _secondsElapsed = 0;
  late final RecorderController _recorderController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _recorderController = RecorderController()
      ..updateFrequency = const Duration(milliseconds: 50);

    _startRecording();

    _secondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorderController.checkPermission();
    if (hasPermission) {
      await _recorderController.record();
    }
  }

  @override
  void dispose() {
    _secondsTimer?.cancel();
    _pulseController.dispose();
    _recorderController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.ct;

    return Container(
      decoration: BoxDecoration(
        color: ct.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: ct.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ct.subText.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Pulsing recording indicator and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4 * _pulseController.value),
                          blurRadius: 6,
                          spreadRadius: 3 * _pulseController.value,
                        )
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Recording Voice Message',
                style: TextStyle(
                  color: ct.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recording Time Elapsed
          Text(
            _formatTime(_secondsElapsed),
            style: TextStyle(
              color: ct.text,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          // Waveform
          AudioWaveforms(
            enableGesture: false,
            size: Size(MediaQuery.of(context).size.width * 0.6, 40.0),
            recorderController: _recorderController,
            waveStyle: WaveStyle(
              waveColor: ct.activeTabColor,
              spacing: 6.0,
              showMiddleLine: false,
              extendWaveform: true,
            ),
          ),
          const SizedBox(height: 24),

          // Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Discard / Cancel Button
              GestureDetector(
                onTap: () async {
                  await _recorderController.stop();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ct.inputBar,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: ct.messageDestructive,
                    size: 26,
                  ),
                ),
              ),

              // Done / Send Button
              GestureDetector(
                onTap: () async {
                  await _recorderController.stop();
                  if (_secondsElapsed > 0) {
                    widget.onCompleted(_secondsElapsed);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ct.activeTabColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
