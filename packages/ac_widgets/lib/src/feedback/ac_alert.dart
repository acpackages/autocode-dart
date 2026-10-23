import 'package:flutter/material.dart';

/// Supported visual variants for [AcAlert].
enum AcAlertVariant {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  light,
  dark,
}

/// An inline banner/alert notification widget with optional icon and dismiss button.
class AcAlert extends StatefulWidget {
  final Widget child;
  final Widget? title;
  final Widget? icon;
  final AcAlertVariant variant;
  final bool dismissible;
  final VoidCallback? onDismissed;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const AcAlert({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.variant = AcAlertVariant.primary,
    this.dismissible = false,
    this.onDismissed,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius,
  });

  @override
  State<AcAlert> createState() => _AcAlertState();
}

class _AcAlertState extends State<AcAlert> with SingleTickerProviderStateMixin {
  bool _dismissed = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.value = 1.0;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void dismiss() {
    if (_dismissed) return;
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _dismissed = true;
        });
        widget.onDismissed?.call();
      }
    });
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (widget.variant) {
      case AcAlertVariant.primary:
        return theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
      case AcAlertVariant.secondary:
        return theme.colorScheme.secondaryContainer.withValues(alpha: 0.5);
      case AcAlertVariant.success:
        return Colors.green.withValues(alpha: 0.15);
      case AcAlertVariant.danger:
        return Colors.red.withValues(alpha: 0.15);
      case AcAlertVariant.warning:
        return Colors.orange.withValues(alpha: 0.15);
      case AcAlertVariant.info:
        return Colors.cyan.withValues(alpha: 0.15);
      case AcAlertVariant.light:
        return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      case AcAlertVariant.dark:
        return theme.colorScheme.inverseSurface.withValues(alpha: 0.15);
    }
  }

  Color _getBorderColor(ThemeData theme) {
    switch (widget.variant) {
      case AcAlertVariant.primary:
        return theme.colorScheme.primary.withValues(alpha: 0.4);
      case AcAlertVariant.secondary:
        return theme.colorScheme.secondary.withValues(alpha: 0.4);
      case AcAlertVariant.success:
        return Colors.green.withValues(alpha: 0.4);
      case AcAlertVariant.danger:
        return Colors.red.withValues(alpha: 0.4);
      case AcAlertVariant.warning:
        return Colors.orange.withValues(alpha: 0.4);
      case AcAlertVariant.info:
        return Colors.cyan.withValues(alpha: 0.4);
      case AcAlertVariant.light:
        return theme.dividerColor;
      case AcAlertVariant.dark:
        return theme.colorScheme.inverseSurface.withValues(alpha: 0.5);
    }
  }

  Color _getContentColor(ThemeData theme) {
    switch (widget.variant) {
      case AcAlertVariant.primary:
        return theme.colorScheme.primary;
      case AcAlertVariant.secondary:
        return theme.colorScheme.secondary;
      case AcAlertVariant.success:
        return Colors.green.shade800;
      case AcAlertVariant.danger:
        return Colors.red.shade800;
      case AcAlertVariant.warning:
        return Colors.orange.shade900;
      case AcAlertVariant.info:
        return Colors.cyan.shade900;
      case AcAlertVariant.light:
        return theme.colorScheme.onSurface;
      case AcAlertVariant.dark:
        return theme.colorScheme.onSurface;
    }
  }

  IconData _getDefaultIcon() {
    switch (widget.variant) {
      case AcAlertVariant.primary:
      case AcAlertVariant.info:
        return Icons.info_outline;
      case AcAlertVariant.success:
        return Icons.check_circle_outline;
      case AcAlertVariant.warning:
        return Icons.warning_amber_rounded;
      case AcAlertVariant.danger:
        return Icons.error_outline;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final bg = _getBackgroundColor(theme);
    final border = _getBorderColor(theme);
    final fg = _getContentColor(theme);

    return SizeTransition(
      sizeFactor: _fadeAnim,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.icon ?? Icon(_getDefaultIcon(), color: fg, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null) ...[
                      DefaultTextStyle(
                        style: theme.textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: fg,
                        ),
                        child: widget.title!,
                      ),
                      const SizedBox(height: 4),
                    ],
                    DefaultTextStyle(
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      child: widget.child,
                    ),
                  ],
                ),
              ),
              if (widget.dismissible) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: dismiss,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 16, color: fg),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
