import 'package:flutter/material.dart';
import '../../common/chat_colors.dart';

class ConversationBackground extends StatelessWidget {
  final AcChatTheme ct;
  const ConversationBackground({required this.ct});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WallpaperPainter(ct),
    );
  }
}

class _WallpaperPainter extends CustomPainter {
  final AcChatTheme ct;
  _WallpaperPainter(this.ct);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = ct.wallpaper;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = bg);

    final dotColor = ct.text.withOpacity(0.04);
    final paint = Paint()..color = dotColor;

    const spacing = 28.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_WallpaperPainter old) => old.ct != ct;
}