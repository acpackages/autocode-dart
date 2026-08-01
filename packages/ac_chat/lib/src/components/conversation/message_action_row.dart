import 'package:flutter/material.dart';

import '../../common/chat_colors.dart';

class MessageActionRow extends StatelessWidget {
  final AcChatTheme ct;
  final bool isDark;
  final List<MessageAction> items;
  const MessageActionRow(
      {required this.ct, required this.isDark, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((a) => _ActionChip(action: a, ct: ct))
            .toList(),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final MessageAction action;
  final AcChatTheme ct;
  const _ActionChip({required this.action, required this.ct});

  @override
  Widget build(BuildContext context) {
    final color = action.color ?? ct.text;
    return GestureDetector(
      onTap: action.onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ct.subText.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(action.icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(action.label,
            style: TextStyle(color: color, fontSize: 11)),
      ]),
    );
  }
}

class MessageAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const MessageAction(
      {required this.icon,
        required this.label,
        required this.onTap,
        this.color});
}