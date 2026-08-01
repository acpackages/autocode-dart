import 'package:flutter/material.dart';
import '../../core/ac_chat.dart';
import '../../common/chat_colors.dart';

class ReplyBar extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  final VoidCallback onCancel;

  const ReplyBar(
      {required this.message, required this.ct, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final api = AcChatApiProvider.of(context);
    final senderName =
    message.senderId == api.getCurrentUser().userId
        ? 'You'
        : api.getUserById(message.senderId)?.name ??
        'Unknown';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: ct.inputBar,
      child: Row(children: [
        Container(
          width: 3,
          height: 40,
          decoration: BoxDecoration(
            color: ct.unreadBadgeBg,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(senderName,
                    style: TextStyle(
                        color: ct.unreadBadgeBg,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text(
                  message.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: ct.subText, fontSize: 12),
                ),
              ]),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: ct.subText, size: 18),
          onPressed: onCancel,
        ),
      ]),
    );
  }
}