import 'package:ac_extensions/ac_extensions.dart';
import 'package:flutter/material.dart';
import '../../common/chat_colors.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;
  final AcChatTheme ct;
  const DateSeparator({required this.date, required this.ct});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year && date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year && date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = date.format('MMMM d, y');
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: ct.dateChip.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: ct.black.withOpacity(0.1), blurRadius: 2)
          ],
        ),
        child: Text(label,
            style: TextStyle(
                color: ct.subText, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}