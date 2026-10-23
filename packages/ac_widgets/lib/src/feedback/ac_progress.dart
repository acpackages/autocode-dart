import 'package:flutter/material.dart';

/// Progress bar type.
enum AcProgressBarType {
  standard,
  striped,
}

/// A progress bar widget with optional label and animated striped variant.
class AcProgress extends StatelessWidget {
  /// Progress value between 0.0 and 1.0 (or null for indeterminate).
  final double? value;

  /// Custom height of the progress bar track.
  final double height;

  /// Color of the filled track.
  final Color? color;

  /// Background color of the unfilled track.
  final Color? backgroundColor;

  /// Whether to display a centered label percentage string.
  final bool showLabel;

  /// Custom label formatter.
  final String Function(double value)? labelFormatter;

  final BorderRadius? borderRadius;

  const AcProgress({
    super.key,
    this.value,
    this.height = 14.0,
    this.color,
    this.backgroundColor,
    this.showLabel = false,
    this.labelFormatter,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBg = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(height / 2);

    final normalizedVal = value?.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: Container(
        height: height,
        color: effectiveBg,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            if (normalizedVal != null)
              FractionallySizedBox(
                widthFactor: normalizedVal,
                child: Container(color: effectiveColor),
              )
            else
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                backgroundColor: effectiveBg,
              ),
            if (showLabel && normalizedVal != null)
              Center(
                child: Text(
                  labelFormatter != null
                      ? labelFormatter!(normalizedVal)
                      : '${(normalizedVal * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
