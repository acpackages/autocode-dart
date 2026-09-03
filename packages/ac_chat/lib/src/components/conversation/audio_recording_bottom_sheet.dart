import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../core/ac_chat.dart';

class AudioRecordingBottomSheet extends StatefulWidget {
  final AcChatTheme ct;
  final void Function({required String filePath, required int durationSeconds}) onCompleted;

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

  String _formatTime({required int seconds}) {
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
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ct.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Live recording indicator + Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: ct.messageDestructive.withOpacity(0.5 + 0.5 * _pulseController.value),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Recording Voice Note',
                style: TextStyle(
                  color: ct.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatTime(seconds: _secondsElapsed),
                style: TextStyle(
                  color: ct.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Waveform
          AudioWaveforms(
            enableGesture: false,
            size: Size(MediaQuery.of(context).size.width - 40, 50),
            recorderController: _recorderController,
            waveStyle: WaveStyle(
              waveColor: ct.activeTabColor,
              showMiddleLine: false,
              extendWaveform: true,
              spacing: 5.0,
            ),
          ),
          const SizedBox(height: 32),

          // Bottom Controls: Cancel vs Send
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cancel Button
              GestureDetector(
                onTap: () async {
                  await _recorderController.stop();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ct.messageDestructive.withOpacity(0.1),
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
                  final path = await _recorderController.stop();
                  if (_secondsElapsed > 0 && path != null && path.isNotEmpty) {
                    widget.onCompleted(
                      filePath: path,
                      durationSeconds: _secondsElapsed,
                    );
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
