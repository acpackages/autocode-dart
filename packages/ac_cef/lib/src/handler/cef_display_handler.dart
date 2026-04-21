import '../cef_browser.dart';
import '../cef_frame.dart';
import '../cef_settings.dart';

abstract class CefDisplayHandler {
  void onAddressChange(CefBrowser browser, CefFrame frame, String url);

  void onTitleChange(CefBrowser browser, String title);

  void onFullscreenModeChange(CefBrowser browser, bool fullscreen);

  bool onTooltip(CefBrowser browser, String text);

  void onStatusMessage(CefBrowser browser, String value);

  bool onConsoleMessage(
    CefBrowser browser,
    CefLogSeverity level,
    String message,
    String source,
    int line,
  );

  bool onCursorChange(CefBrowser browser, int cursorType);
}
