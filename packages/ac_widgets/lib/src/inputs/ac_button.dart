import 'package:flutter/material.dart';

/// Button visual variants.
enum AcButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
}

/// A button widget supporting loading spinner states, leading/trailing icons, and variants.
class AcButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AcButtonVariant variant;
  final Widget? icon;
  final Widget? trailingIcon;
  final EdgeInsetsGeometry? padding;

  const AcButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AcButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget label = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        child,
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          trailingIcon!,
        ],
      ],
    );

    final VoidCallback? handler = isLoading ? null : onPressed;

    switch (variant) {
      case AcButtonVariant.primary:
        return ElevatedButton(
          onPressed: handler,
          style: ElevatedButton.styleFrom(padding: padding),
          child: label,
        );
      case AcButtonVariant.secondary:
        return FilledButton.tonal(
          onPressed: handler,
          style: FilledButton.styleFrom(padding: padding),
          child: label,
        );
      case AcButtonVariant.outline:
        return OutlinedButton(
          onPressed: handler,
          style: OutlinedButton.styleFrom(padding: padding),
          child: label,
        );
      case AcButtonVariant.text:
        return TextButton(
          onPressed: handler,
          style: TextButton.styleFrom(padding: padding),
          child: label,
        );
      case AcButtonVariant.danger:
        return ElevatedButton(
          onPressed: handler,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: padding,
          ),
          child: label,
        );
      case AcButtonVariant.success:
        return ElevatedButton(
          onPressed: handler,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: padding,
          ),
          child: label,
        );
    }
  }
}
