import 'package:flutter/material.dart';
import '../feedback/ac_alert.dart';

/// Spinner animation types.
enum AcSpinnerType {
  border,
  grow,
}

/// A loading indicator spinner widget.
class AcSpinner extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final AcAlertVariant variant;
  final AcSpinnerType type;

  const AcSpinner({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 2.5,
    this.color,
    this.variant = AcAlertVariant.primary,
    this.type = AcSpinnerType.border,
  });

  Color _resolveColor(ThemeData theme) {
    if (color != null) return color!;
    switch (variant) {
      case AcAlertVariant.primary:
        return theme.colorScheme.primary;
      case AcAlertVariant.secondary:
        return theme.colorScheme.secondary;
      case AcAlertVariant.success:
        return Colors.green;
      case AcAlertVariant.danger:
        return Colors.red;
      case AcAlertVariant.warning:
        return Colors.orange;
      case AcAlertVariant.info:
        return Colors.cyan;
      case AcAlertVariant.light:
        return Colors.white;
      case AcAlertVariant.dark:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _resolveColor(Theme.of(context));

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );
  }
}
