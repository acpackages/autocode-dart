import '../cef_browser.dart';
import '../cef_frame.dart';

abstract class CefLifeSpanHandler {
  /// Called on the IO thread before a new popup window is created.
  /// Return true to cancel creation of the popup window.
  bool onBeforePopup(
    CefBrowser browser,
    CefFrame frame,
    String targetUrl,
    String targetFrameName,
  );

  /// Called when a new browser window is created.
  void onAfterCreated(CefBrowser browser);

  /// Called after a browser's native parent window has changed.
  void onAfterParentChanged(CefBrowser browser);

  /// Called when a browser has received a request to close.
  /// Return false to proceed with default close handling.
  bool doClose(CefBrowser browser);

  /// Called just before a browser is destroyed. Release all references.
  void onBeforeClose(CefBrowser browser);
}
