import 'dart:async';
import 'cef_browser_settings.dart';
import 'native/cef_native_client.dart';

/// Represents a CEF browser instance.
///
/// Mirrors JCEF's `org.cef.browser.CefBrowser`.
/// Direct navigation and inspection methods delegate to [nativeClient] once
/// [nativeBrowserId] is assigned.
class CefBrowser {
  final String initialUrl;
  final bool windowless;
  final CefBrowserSettings? settings;

  /// The integer ID assigned by the native bridge after creation.
  /// 0 means the browser has not been created yet.
  int nativeBrowserId = 0;

  /// Reference to the managing [CefNativeClient], if attached.
  CefNativeClient? nativeClient;

  bool _isClosing = false;
  bool get isClosing => _isClosing;

  CefBrowser(this.initialUrl, {this.windowless = true, this.settings, this.nativeClient});

  bool get isCreated => nativeBrowserId > 0;

  int getIdentifier() => nativeBrowserId;

  void loadUrl(String url) => nativeClient?.loadUrl(nativeBrowserId, url);

  void goBack() => nativeClient?.goBack(nativeBrowserId);

  void goForward() => nativeClient?.goForward(nativeBrowserId);

  void reload() => nativeClient?.reload(nativeBrowserId);

  void reloadIgnoreCache() => nativeClient?.reloadIgnoreCache(nativeBrowserId);

  void stopLoad() => nativeClient?.stopLoad(nativeBrowserId);

  void close({bool force = false}) {
    _isClosing = true;
    nativeClient?.closeBrowser(nativeBrowserId, force: force);
  }

  void executeJavaScript(String code, [String? url, int line = 0]) =>
      nativeClient?.executeJavaScript(nativeBrowserId, code);

  Future<String> evalJavaScript(String expression) =>
      nativeClient?.evalJavaScript(nativeBrowserId, expression) ?? Future.value('');

  void setZoomLevel(double level) => nativeClient?.setZoomLevel(nativeBrowserId, level);

  double getZoomLevel() => nativeClient?.getZoomLevel(nativeBrowserId) ?? 0.0;

  bool canGoBack() => nativeClient?.canGoBack(nativeBrowserId) ?? false;

  bool canGoForward() => nativeClient?.canGoForward(nativeBrowserId) ?? false;

  bool isLoading() => nativeClient?.isLoading(nativeBrowserId) ?? false;

  String getUrl() => nativeClient?.getUrl(nativeBrowserId) ?? '';

  String getTitle() => nativeClient?.getTitle(nativeBrowserId) ?? '';

  void setFocus(bool focus) => nativeClient?.setFocus(nativeBrowserId, focus);

  void wasHidden(bool hidden) => nativeClient?.wasHidden(nativeBrowserId, hidden);

  void find(String searchText, {
    bool forward = true,
    bool matchCase = false,
    bool findNext = false,
  }) =>
      nativeClient?.find(nativeBrowserId, searchText,
          forward: forward, matchCase: matchCase, findNext: findNext);

  void stopFind({bool clearSelection = true}) =>
      nativeClient?.stopFind(nativeBrowserId, clearSelection: clearSelection);

  Future<String> getSource() =>
      nativeClient?.getSource(nativeBrowserId) ?? Future.value('');

  Future<String> getText() =>
      nativeClient?.getText(nativeBrowserId) ?? Future.value('');

  void loadRequest(String url, {
    String method = 'GET',
    String? body,
    Map<String, String>? headers,
  }) =>
      nativeClient?.loadRequest(nativeBrowserId, url,
          method: method, body: body, headers: headers);

  @override
  String toString() =>
      'CefBrowser(id=$nativeBrowserId, url=$initialUrl, windowless=$windowless)';
}
