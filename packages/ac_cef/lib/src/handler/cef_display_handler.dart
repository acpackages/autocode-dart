import '../cef_browser.dart';
import '../cef_frame.dart';
import '../cef_settings.dart';

/// Implement this interface to handle events related to browser display state.
///
/// Mirrors JCEF's `org.cef.handler.CefDisplayHandler` and `CefDisplayHandlerAdapter`.
abstract class CefDisplayHandler {
  /// Browser address changed.
  void onAddressChange(CefBrowser browser, CefFrame frame, String url) {}

  /// Browser title changed.
  void onTitleChange(CefBrowser browser, String title) {}

  /// Browser loading progress changed (value between 0.0 and 1.0).
  void onLoadingProgressChange(CefBrowser browser, double progress) {}

  /// Browser fullscreen mode changed.
  void onFullscreenModeChange(CefBrowser browser, bool fullscreen) {}

  /// About to display a tooltip. Return true to handle display yourself.
  bool onTooltip(CefBrowser browser, String text) => false;

  /// Received a status message.
  void onStatusMessage(CefBrowser browser, String value) {}

  /// Display a console message. Return true to stop the message from being output.
  bool onConsoleMessage(
    CefBrowser browser,
    CefLogSeverity level,
    String message,
    String source,
    int line,
  ) => false;

  /// Handle cursor changes. Return true if handled.
  bool onCursorChange(CefBrowser browser, int cursorType) => false;

  /// Favicon URL list changed.
  void onFaviconUrlChange(CefBrowser browser, List<String> iconUrls) {}
}

/// Convenience alias matching JCEF's adapter class name.
typedef CefDisplayHandlerAdapter = CefDisplayHandler;
