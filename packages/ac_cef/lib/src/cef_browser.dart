import 'cef_browser_settings.dart';

/// Represents a CEF browser instance.
///
/// Navigation methods are no-ops until [nativeBrowserId] is set by
/// [CefNativeClient] after the C-side `OnAfterCreated` fires.
class CefBrowser {
  final String initialUrl;
  final bool windowless;
  final CefBrowserSettings? settings;

  /// The integer ID assigned by the native bridge after creation.
  /// 0 means the browser has not been created yet.
  int nativeBrowserId = 0;

  bool _isClosing = false;
  bool get isClosing => _isClosing;

  CefBrowser(this.initialUrl, {this.windowless = true, this.settings});

  bool get isCreated => nativeBrowserId > 0;

  @override
  String toString() =>
      'CefBrowser(id=$nativeBrowserId, url=$initialUrl, windowless=$windowless)';
}
