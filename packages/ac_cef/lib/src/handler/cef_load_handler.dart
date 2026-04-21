import '../cef_browser.dart';
import '../cef_frame.dart';

enum CefErrorCode {
  errNone(0),
  errFailed(-2),
  errAborted(-3),
  // Add others as needed or use a raw code
  unknown(-1);

  final int code;
  const CefErrorCode(this.code);

  static CefErrorCode findByCode(int code) {
    for (var value in CefErrorCode.values) {
      if (value.code == code) return value;
    }
    return CefErrorCode.unknown;
  }
}

abstract class CefLoadHandler {
  void onLoadingStateChange(
    CefBrowser browser,
    bool isLoading,
    bool canGoBack,
    bool canGoForward,
  );

  void onLoadStart(
    CefBrowser browser,
    CefFrame frame,
    int transitionType,
  );

  void onLoadEnd(
    CefBrowser browser,
    CefFrame frame,
    int httpStatusCode,
  );

  void onLoadError(
    CefBrowser browser,
    CefFrame frame,
    CefErrorCode errorCode,
    String errorText,
    String failedUrl,
  );
}
