import 'package:flutter/material.dart';
import '../../../core/ac_chat.dart';

class AudioMessageBubble extends StatefulWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  const AudioMessageBubble({required this.message, required this.ct});

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  int _parseDuration(String? durationStr) {
    if (durationStr == null) return 10;
    final parts = durationStr.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
    return int.tryParse(durationStr) ?? 10;
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = AcChatAudioPlayer();
    final messageId = widget.message.messageId;
    final durationSeconds = _parseDuration(widget.message.duration);

    return ValueListenableBuilder<String?>(
      valueListenable: player.playingNotifier,
      builder: (context, playingId, _) {
        final isCurrentPlaying = playingId == messageId;

        return ValueListenableBuilder<bool>(
          valueListenable: player.isPausedNotifier,
          builder: (context, isPaused, _) {
            final isCurrentPaused = isCurrentPlaying && isPaused;
            final isCurrentActive = isCurrentPlaying || (player.playingMessageId == messageId && isCurrentPaused);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play / Pause Icon Button
                GestureDetector(
                  onTap: () {
                    player.play(messageId, durationSeconds);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.ct.unreadBadgeBg.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      (isCurrentPlaying && !isPaused)
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: widget.ct.unreadBadgeBg,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Interactive & Dynamic Waveform
                ValueListenableBuilder<double>(
                  valueListenable: player.progressNotifier,
                  builder: (context, progress, _) {
                    final currentProgress = isCurrentActive ? progress : 0.0;
                    return Row(
                      children: List.generate(24, (i) {
                        // Generate a pseudo-random waveform look based on index
                        final heights = [
                          6.0, 10.0, 14.0, 8.0, 12.0, 18.0, 10.0, 6.0,
                          14.0, 16.0, 10.0, 8.0, 12.0, 18.0, 14.0, 8.0,
                          6.0, 10.0, 16.0, 12.0, 8.0, 14.0, 10.0, 6.0
                        ];
                        final h = heights[i % heights.length];
                        
                        // Decide if this bar is in the played portion
                        final barProgress = i / 24.0;
                        final isPlayed = barProgress <= currentProgress;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 2.5,
                          height: h,
                          decoration: BoxDecoration(
                            color: isPlayed
                                ? widget.ct.unreadBadgeBg
                                : widget.ct.unreadBadgeBg.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Audio Time Label (Ticking during play, total duration otherwise)
                ValueListenableBuilder<int>(
                  valueListenable: player.elapsedNotifier,
                  builder: (context, elapsed, _) {
                    final displayTime = isCurrentActive
                        ? _formatDuration(elapsed)
                        : (widget.message.duration ?? '0:00');
                    return Text(
                      displayTime,
                      style: TextStyle(color: widget.ct.subText, fontSize: 12),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}