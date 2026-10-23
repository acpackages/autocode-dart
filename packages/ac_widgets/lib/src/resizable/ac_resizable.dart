import 'package:flutter/material.dart';

/// Resize handles supported by [AcResizable].
enum AcResizeHandleDirection {
  right,
  bottom,
  bottomRight,
}

/// A container widget that can be resized interactively via drag handles.
class AcResizable extends StatefulWidget {
  final Widget child;
  final double initialWidth;
  final double initialHeight;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;
  final ValueChanged<Size>? onResized;

  const AcResizable({
    super.key,
    required this.child,
    this.initialWidth = 200,
    this.initialHeight = 200,
    this.minWidth = 50,
    this.maxWidth = double.infinity,
    this.minHeight = 50,
    this.maxHeight = double.infinity,
    this.onResized,
  });

  @override
  State<AcResizable> createState() => _AcResizableState();
}

class _AcResizableState extends State<AcResizable> {
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
    _height = widget.initialHeight;
  }

  void _onPan(DragUpdateDetails details, AcResizeHandleDirection dir) {
    setState(() {
      if (dir == AcResizeHandleDirection.right || dir == AcResizeHandleDirection.bottomRight) {
        _width = (_width + details.delta.dx).clamp(widget.minWidth, widget.maxWidth);
      }
      if (dir == AcResizeHandleDirection.bottom || dir == AcResizeHandleDirection.bottomRight) {
        _height = (_height + details.delta.dy).clamp(widget.minHeight, widget.maxHeight);
      }
    });
    widget.onResized?.call(Size(_width, _height));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: widget.child),

          // Right handle
          Positioned(
            top: 0,
            bottom: 8,
            right: 0,
            width: 8,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (d) => _onPan(d, AcResizeHandleDirection.right),
              ),
            ),
          ),

          // Bottom handle
          Positioned(
            left: 0,
            right: 8,
            bottom: 0,
            height: 8,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeUpDown,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (d) => _onPan(d, AcResizeHandleDirection.bottom),
              ),
            ),
          ),

          // Bottom-Right handle
          Positioned(
            right: 0,
            bottom: 0,
            width: 12,
            height: 12,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeDownRight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (d) => _onPan(d, AcResizeHandleDirection.bottomRight),
                child: CustomPaint(
                  painter: _CornerHandlePainter(color: theme.dividerColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerHandlePainter extends CustomPainter {
  final Color color;
  const _CornerHandlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(size.width, size.height - 4), Offset(size.width - 4, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - 8), Offset(size.width - 8, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerHandlePainter oldDelegate) => oldDelegate.color != color;
}
