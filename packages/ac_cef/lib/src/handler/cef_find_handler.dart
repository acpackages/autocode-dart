import '../cef_browser.dart';

/// Axis-aligned rectangle in physical pixels (used by find-result selection).
class CefRect {
  final double left;
  final double top;
  final double width;
  final double height;

  const CefRect(this.left, this.top, this.width, this.height);

  @override
  String toString() => 'CefRect($left, $top, $width x $height)';
}

/// Result of a find-in-page search tick delivered by [CefFindHandler.onFindResult].
class CefFindResult {
  /// Identifier matching the one passed to [CefNativeClient.find].
  /// Currently always 0 since ac_cef uses a single implicit search session.
  final int identifier;

  /// Total number of matches found so far.
  final int count;

  /// 1-based index of the currently highlighted match.  0 if none is active.
  final int activeMatchOrdinal;

  /// Bounding rect of the active match in physical pixels.
  final CefRect selectionRect;

  /// Whether this is the final update for the current search pass.
  final bool finalUpdate;

  const CefFindResult({
    required this.identifier,
    required this.count,
    required this.activeMatchOrdinal,
    required this.selectionRect,
    required this.finalUpdate,
  });

  @override
  String toString() => 'CefFindResult(count=$count, '
      'active=$activeMatchOrdinal, final=$finalUpdate, '
      'rect=$selectionRect)';
}

/// Interface for receiving find-in-page results from the browser.
///
/// Mirrors JCEF's `org.cef.handler.CefFindHandler` and `CefFindHandlerAdapter`.
abstract class CefFindHandler {
  /// Called each time CEF reports a match update.
  void onFindResult(CefBrowser browser, CefFindResult result) {}
}

/// Convenience alias matching JCEF's adapter class name.
typedef CefFindHandlerAdapter = CefFindHandler;
