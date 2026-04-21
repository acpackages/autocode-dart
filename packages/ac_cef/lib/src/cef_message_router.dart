import 'cef_browser.dart';

abstract class CefQueryCallback {
  void success(String response);
  void failure(int errorCode, String errorMessage);
}

abstract class CefMessageRouterHandler {
  bool onQuery(
    CefBrowser browser,
    int queryId,
    String request,
    bool persistent,
    CefQueryCallback callback,
  );

  void onQueryCanceled(CefBrowser browser, int queryId);
}

class CefMessageRouterConfig {
  final String jsQueryFunction;
  final String jsCancelFunction;

  CefMessageRouterConfig({
    this.jsQueryFunction = 'cefQuery',
    this.jsCancelFunction = 'cefQueryCancel',
  });
}

abstract class CefMessageRouter {
  void dispose();
  bool addHandler(CefMessageRouterHandler handler, bool first);
  bool removeHandler(CefMessageRouterHandler handler);
  void cancelPending(CefBrowser? browser, CefMessageRouterHandler? handler);

  static CefMessageRouter create([CefMessageRouterConfig? config]) {
    // This will return a native-backed implementation later
    throw UnimplementedError("CefMessageRouter.create() is not yet implemented.");
  }
}
