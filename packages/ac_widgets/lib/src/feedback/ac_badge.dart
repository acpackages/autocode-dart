import 'package:flutter/material.dart';
import 'ac_alert.dart';

/// A small label, tag, or notification count indicator badge.
class AcBadge extends StatelessWidget {
  final Widget child;
  final AcAlertVariant variant;
  final bool pill;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const AcBadge({
    super.key,
    required this.child,
    this.variant = AcAlertVariant.primary,
    this.pill = true,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  /// Factory constructor to display a numeric count badge.
  factory AcBadge.count({
    Key? key,
    required int count,
    AcAlertVariant variant = AcAlertVariant.danger,
    int maxCount = 99,
  }) {
    final text = count > maxCount ? '$maxCount+' : count.toString();
    return AcBadge(
      key: key,
      variant: variant,
      pill: true,
      child: Text(text),
    );
  }

  Color _getColor(ThemeData theme) {
    switch (variant) {
      case AcAlertVariant.primary:
        return theme.colorScheme.primary;
      case AcAlertVariant.secondary:
        return theme.colorScheme.secondary;
      case AcAlertVariant.success:
        return Colors.green.shade700;
      case AcAlertVariant.danger:
        return Colors.red.shade700;
      case AcAlertVariant.warning:
        return Colors.orange.shade800;
      case AcAlertVariant.info:
        return Colors.cyan.shade700;
      case AcAlertVariant.light:
        return theme.colorScheme.surfaceContainerHighest;
      case AcAlertVariant.dark:
        return theme.colorScheme.inverseSurface;
    }
  }

  Color _getOnColor(ThemeData theme) {
    switch (variant) {
      case AcAlertVariant.light:
        return theme.colorScheme.onSurface;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = _getColor(theme);
    final fg = _getOnColor(theme);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: pill ? BorderRadius.circular(100) : BorderRadius.circular(4),
      ),
      child: DefaultTextStyle(
        style: textStyle ??
            TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
        child: child,
      ),
    );
  }
}
