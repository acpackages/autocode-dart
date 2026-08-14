import '../cef_browser.dart';
import '../cef_frame.dart';
import '../network/cef_request.dart';
import 'cef_load_handler.dart';

enum CefTerminationStatus {
  tsAbnormalTermination,
  tsProcessWasKilled,
  tsProcessCrashed,
  tsProcessOom,
  tsLaunchFailed,
  tsIntegrityFailure,
}

abstract class CefCallback {
  void onContinue(bool success);
  void cancel();
}

abstract class CefAuthCallback {
  void onContinue(String username, String password);
  void cancel();
}

/// Implement this interface to handle events related to browser requests.
///
/// Mirrors JCEF's `org.cef.handler.CefRequestHandler` and `CefRequestHandlerAdapter`.
abstract class CefRequestHandler {
  /// Called before browser navigation. Return true to cancel navigation.
  bool onBeforeBrowse(
    CefBrowser browser,
    CefFrame frame,
    CefRequest request,
    bool userGesture,
    bool isRedirect,
  ) => false;

  /// Called before a resource is loaded. Return true to cancel load.
  bool onBeforeResourceLoad(
    CefBrowser browser,
    CefFrame frame,
    CefRequest request,
  ) => false;

  /// Called when the browser opens a URL from a tab. Return true to cancel.
  bool onOpenURLFromTab(
    CefBrowser browser,
    CefFrame frame,
    String targetUrl,
    bool userGesture,
  ) => false;

  /// Called when authentication credentials are requested. Return true if handled.
  bool getAuthCredentials(
    CefBrowser browser,
    String originUrl,
    bool isProxy,
    String host,
    int port,
    String realm,
    String scheme,
    CefAuthCallback callback,
  ) => false;

  /// Called on SSL/TLS certificate errors. Return true to handle asynchronously.
  bool onCertificateError(
    CefBrowser browser,
    CefErrorCode certError,
    String requestUrl,
    CefCallback callback,
  ) => false;

  /// Called when a render process terminates unexpectedly.
  void onRenderProcessTerminated(
    CefBrowser browser,
    CefTerminationStatus status,
    int errorCode,
    String errorString,
  ) {}
}

/// Convenience alias matching JCEF's adapter class name.
typedef CefRequestHandlerAdapter = CefRequestHandler;
