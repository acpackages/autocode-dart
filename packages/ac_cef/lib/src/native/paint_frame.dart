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

// ─── Popup events ─────────────────────────────────────────────────────────────

/// Base class for events delivered on [CefNativeClient.popupEvents].
///
/// Use pattern-matching on [CefPopupShowEvent] and [CefPopupSizeEvent].
sealed class CefPopupEvent {}

/// CEF is showing (show=true) or hiding (show=false) a popup/context-menu.
final class CefPopupShowEvent extends CefPopupEvent {
  final bool show;
  CefPopupShowEvent(this.show);
}

/// CEF has set the popup rect in browser-local pixel coordinates.
///
/// [x],[y] are the top-left offset from the browser origin.
/// [width],[height] are the popup dimensions.
/// All values are in physical (scaled) pixels.
final class CefPopupSizeEvent extends CefPopupEvent {
  final int x, y, width, height;
  CefPopupSizeEvent(this.x, this.y, this.width, this.height);
}
