import 'package:flutter/material.dart';
import '../../../core/ac_chat.dart';
import '../../../common/chat_colors.dart';

class AudioMessageBubble extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  const AudioMessageBubble({required this.message, required this.ct});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ct.unreadBadgeBg.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.play_arrow_rounded,
            color: ct.unreadBadgeBg, size: 22),
      ),
      const SizedBox(width: 8),
      // Waveform placeholder
      Row(
        children: List.generate(18, (i) {
          final h = (i % 3 == 0 ? 16.0 : i % 3 == 1 ? 10.0 : 6.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 2.5,
            height: h,
            decoration: BoxDecoration(
              color: ct.unreadBadgeBg.withOpacity(0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
      const SizedBox(width: 8),
      Text(
        message.duration ?? '0:00',
        style: TextStyle(color: ct.subText, fontSize: 12),
      ),
    ]);
  }
}