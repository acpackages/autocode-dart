import 'package:ac_extensions/ac_extensions.dart';
import 'package:flutter/material.dart';
import '../../common/chat_colors.dart';

class DateSeparator extends StatefulWidget {
  final DateTime date;
  final AcChatTheme ct;
  final ValueChanged<BuildContext>? onMounted;
  final ValueChanged<BuildContext>? onUnmounted;

  const DateSeparator({
    super.key,
    required this.date,
    required this.ct,
    this.onMounted,
    this.onUnmounted,
  });

  @override
  State<DateSeparator> createState() => _DateSeparatorState();
}

class _DateSeparatorState extends State<DateSeparator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onMounted?.call(context);
      }
    });
  }

  @override
  void dispose() {
    widget.onUnmounted?.call(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (widget.date.year == now.year && widget.date.month == now.month &&
        widget.date.day == now.day) {
      label = 'Today';
    } else if (widget.date.year == now.year && widget.date.month == now.month &&
        widget.date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = widget.date.format('MMMM d, y');
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: widget.ct.dateChip.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: widget.ct.black.withOpacity(0.1), blurRadius: 2)
          ],
        ),
        child: Text(label,
            style: TextStyle(
                color: widget.ct.subText, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}