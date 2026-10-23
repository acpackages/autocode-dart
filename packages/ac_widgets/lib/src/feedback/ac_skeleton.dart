import 'package:flutter/material.dart';

/// Shimmer loading skeleton placeholder widget for content loading states.
class AcSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const AcSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  /// Factory for a text line skeleton placeholder.
  factory AcSkeleton.text({
    Key? key,
    double width = double.infinity,
    double height = 14.0,
  }) {
    return AcSkeleton(
      key: key,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Factory for a circular skeleton placeholder (avatars, icons).
  factory AcSkeleton.circle({
    Key? key,
    required double size,
  }) {
    return AcSkeleton(
      key: key,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  /// Factory for a rectangular box skeleton placeholder (cards, images).
  factory AcSkeleton.box({
    Key? key,
    double width = double.infinity,
    double height = 120.0,
    double radius = 8.0,
  }) {
    return AcSkeleton(
      key: key,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  @override
  State<AcSkeleton> createState() => _AcSkeletonState();
}

class _AcSkeletonState extends State<AcSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = widget.baseColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final highlight = widget.highlightColor ?? theme.colorScheme.surface.withValues(alpha: 0.8);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}
