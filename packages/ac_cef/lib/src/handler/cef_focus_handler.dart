import '../cef_browser.dart';

enum CefFocusSource {
  focusSourceNavigation,
  focusSourceSystem,
}

abstract class CefFocusHandler {
  /// Called when the browser component is about to lose focus (e.g., Tab key).
  /// [next] is true if focus is moving to the next component, false for previous.
  void onTakeFocus(CefBrowser browser, bool next);

  /// Called when the browser component is requesting focus.
  /// Return false to allow focus, true to cancel.
  bool onSetFocus(CefBrowser browser, CefFocusSource source);

  /// Called when the browser component has received focus.
  void onGotFocus(CefBrowser browser);
}
