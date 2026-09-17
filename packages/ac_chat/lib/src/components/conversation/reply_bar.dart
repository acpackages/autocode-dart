import 'package:flutter/material.dart';
import 'package:ac_chat_core/ac_chat_core.dart';
import '../ac_chat.dart';

class ReplyBar extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  final VoidCallback onCancel;

  const ReplyBar({
    super.key,
    required this.message,
    required this.ct,
    required this.onCancel,
  });

  Future<String> _getSenderName(AcChatApi api) async {
    if (message.senderId == api.userId) return 'You';
    final sender = await api.getUserById(userId: message.senderId);
    return sender?.name ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    AcChatApi api = AcChatApiProvider.getApi(context);
    return FutureBuilder<String>(
      future: _getSenderName(api),
      builder: (context, snapshot) {
        final senderName = snapshot.data ?? '...';
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
      },
    );
  }
}