import '../cef_browser.dart';

enum CefFocusSource {
  focusSourceNavigation,
  focusSourceSystem,
}

/// Implement this interface to handle focus events.
///
/// Mirrors JCEF's `org.cef.handler.CefFocusHandler` and `CefFocusHandlerAdapter`.
abstract class CefFocusHandler {
  /// Called when the browser component is about to lose focus (e.g., Tab key).
  /// [next] is true if focus is moving to the next component, false for previous.
  void onTakeFocus(CefBrowser browser, bool next) {}

  /// Called when the browser component is requesting focus.
  /// Return false to allow focus, true to cancel.
  bool onSetFocus(CefBrowser browser, CefFocusSource source) => false;

  /// Called when the browser component has received focus.
  void onGotFocus(CefBrowser browser) {}
}

/// Convenience alias matching JCEF's adapter class name.
typedef CefFocusHandlerAdapter = CefFocusHandler;
