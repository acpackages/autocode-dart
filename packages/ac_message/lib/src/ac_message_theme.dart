import 'package:flutter/material.dart';
import 'ac_message_type.dart';

class AcMessageTheme {
  static Color getColor(AcMessageType type) {
    switch (type) {
      case AcMessageType.success:
        return Colors.green;
      case AcMessageType.error:
        return Colors.red;
      case AcMessageType.warning:
        return Colors.orange;
      case AcMessageType.info:
        return Colors.blue;
      case AcMessageType.question:
        return Colors.purple;
      case AcMessageType.none:
        return Colors.transparent;
    }
  }

  static IconData getIcon(AcMessageType type) {
    switch (type) {
      case AcMessageType.success:
        return Icons.check_circle_outline;
      case AcMessageType.error:
        return Icons.error_outline;
      case AcMessageType.warning:
        return Icons.warning_amber_outlined;
      case AcMessageType.info:
        return Icons.info_outline;
      case AcMessageType.question:
        return Icons.help_outline;
      case AcMessageType.none:
        return Icons.info_outline; // Default
    }
  }
}
