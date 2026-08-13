import 'dart:typed_data';

/// A single dirty region reported by CEF's OnPaint callback.
///
/// All values are in physical (DPR-scaled) pixels, relative to the browser origin.
typedef DirtyRect = ({int x, int y, int width, int height});

/// A single OSR paint frame delivered from the native CEF render handler.
///
/// [pixels] is a copy of the full BGRA pixel buffer (w × h × 4 bytes).
/// [width] and [height] are in physical pixels (already scaled by DPR).
/// [isPopup] is true when CEF is painting a popup / context-menu overlay.
/// [dirtyRects] lists the regions that actually changed this frame.
/// An empty list means CEF did not report specific dirty regions.
class PaintFrame {
  final Uint8List pixels;
  final int width;
  final int height;
  final bool isPopup;
  final List<DirtyRect> dirtyRects;

  const PaintFrame({
    required this.pixels,
    required this.width,
    required this.height,
    required this.isPopup,
    this.dirtyRects = const [],
  });

  int get byteCount => width * height * 4;

  /// True when the entire frame was repainted (no specific dirty rects reported).
  bool get isFullFrame => dirtyRects.isEmpty;
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
