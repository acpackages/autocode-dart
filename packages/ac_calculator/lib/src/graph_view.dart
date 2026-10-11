import 'package:flutter/widgets.dart';
import 'calculator_theme.dart';
import 'expression_evaluator.dart';

/// Interactive 2D Graph View with zoom, pan, grid, axes, and multiple plotted equations
class AcGraphView extends StatefulWidget {
  final List<String> expressions;
  final AcCalculatorTheme theme;

  const AcGraphView({
    super.key,
    required this.expressions,
    required this.theme,
  });

  @override
  State<AcGraphView> createState() => _AcGraphViewState();
}

class _AcGraphViewState extends State<AcGraphView> {
  // Center of view in mathematical coordinates
  double _centerX = 0.0;
  double _centerY = 0.0;

  // Zoom: units visible across half-width
  double _scale = 10.0; // [-10, 10] initially

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          if (details.scale != 1.0) {
            _scale = (_scale / details.scale).clamp(0.5, 500.0);
          }
          // Pan
          final dx = details.focalPointDelta.dx;
          final dy = details.focalPointDelta.dy;
          _centerX -= dx * (_scale / 150.0);
          _centerY += dy * (_scale / 150.0);
        });
      },
      child: ClipRect(
        child: CustomPaint(
          size: Size.infinite,
          painter: _GraphPainter(
            expressions: widget.expressions,
            theme: widget.theme,
            centerX: _centerX,
            centerY: _centerY,
            scale: _scale,
          ),
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<String> expressions;
  final AcCalculatorTheme theme;
  final double centerX;
  final double centerY;
  final double scale;

  _GraphPainter({
    required this.expressions,
    required this.theme,
    required this.centerX,
    required this.centerY,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw background
    final bgPaint = Paint()..color = theme.graphBackgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (size.width <= 0 || size.height <= 0) return;

    // Coordinate mapping
    // Screen (0, 0) is top-left
    // Center mathematical (centerX, centerY) is at (size.width / 2, size.height / 2)
    final originX = size.width / 2 - (centerX / scale) * (size.width / 2);
    final originY = size.height / 2 + (centerY / scale) * (size.height / 2);

    final pixelsPerUnitX = (size.width / 2) / scale;
    final pixelsPerUnitY = (size.height / 2) / scale;

    // 2. Draw Grid & Axes
    final gridPaint =
        Paint()
          ..color = theme.graphGridColor
          ..strokeWidth = 1.0;

    final axisPaint =
        Paint()
          ..color = theme.graphAxisColor
          ..strokeWidth = 1.5;

    // Grid step calculation (e.g. 1, 2, 5, 10, etc.)
    double step = 1.0;
    if (scale > 50) step = 10.0;
    if (scale > 200) step = 50.0;
    if (scale < 3) step = 0.5;
    if (scale < 1) step = 0.1;

    // Vertical grid lines
    final minX = centerX - scale;
    final maxX = centerX + scale;
    final firstGridX = (minX / step).floor() * step;
    for (double x = firstGridX; x <= maxX + step; x += step) {
      final screenX = originX + x * pixelsPerUnitX;
      canvas.drawLine(
        Offset(screenX, 0),
        Offset(screenX, size.height),
        gridPaint,
      );
    }

    // Horizontal grid lines
    final minY = centerY - scale * (size.height / size.width);
    final maxY = centerY + scale * (size.height / size.width);
    final firstGridY = (minY / step).floor() * step;
    for (double y = firstGridY; y <= maxY + step; y += step) {
      final screenY = originY - y * pixelsPerUnitY;
      canvas.drawLine(
        Offset(0, screenY),
        Offset(size.width, screenY),
        gridPaint,
      );
    }

    // Main Axes
    canvas.drawLine(Offset(0, originY), Offset(size.width, originY), axisPaint);
    canvas.drawLine(
      Offset(originX, 0),
      Offset(originX, size.height),
      axisPaint,
    );

    // 3. Plot Expressions
    for (int idx = 0; idx < expressions.length; idx++) {
      final expr = expressions[idx].trim();
      if (expr.isEmpty) continue;

      // Extract expression after "y =" if present
      String cleanExpr = expr;
      if (cleanExpr.startsWith('y=') ||
          cleanExpr.startsWith('y =') ||
          cleanExpr.startsWith('f(x)=')) {
        cleanExpr = cleanExpr.split('=').sublist(1).join('=').trim();
      }

      final lineColor =
          theme.graphLineColors[idx % theme.graphLineColors.length];
      final linePaint =
          Paint()
            ..color = lineColor
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;

      final path = Path();
      bool firstPoint = true;

      // Sample along width in screen pixels
      final evaluator = MathExpressionEvaluator();
      for (double px = 0; px <= size.width; px += 2.0) {
        final mathX = (px - originX) / pixelsPerUnitX;
        evaluator.variables['x'] = mathX;
        try {
          final mathY = evaluator.evaluate(cleanExpr);
          if (mathY.isNaN || mathY.isInfinite) {
            firstPoint = true;
            continue;
          }

          final screenY = originY - mathY * pixelsPerUnitY;
          // Avoid runaway coordinates
          if (screenY < -size.height * 2 || screenY > size.height * 3) {
            firstPoint = true;
            continue;
          }

          if (firstPoint) {
            path.moveTo(px, screenY);
            firstPoint = false;
          } else {
            path.lineTo(px, screenY);
          }
        } catch (_) {
          firstPoint = true;
        }
      }

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.centerY != centerY ||
        oldDelegate.scale != scale ||
        oldDelegate.expressions != expressions ||
        oldDelegate.theme != theme;
  }
}
