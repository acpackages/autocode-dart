import 'dart:typed_data';

/// A single OSR paint frame delivered from the native CEF render handler.
///
/// [pixels] is a copy of the BGRA pixel buffer.
/// [width] and [height] are in physical pixels (already scaled by DPR).
/// [isPopup] is true when CEF is painting a popup / context-menu overlay.
class PaintFrame {
  final Uint8List pixels;
  final int width;
  final int height;
  final bool isPopup;

  const PaintFrame({
    required this.pixels,
    required this.width,
    required this.height,
    required this.isPopup,
  });

  int get byteCount => width * height * 4;
}
