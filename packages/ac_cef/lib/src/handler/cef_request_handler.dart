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

abstract class CefRequestHandler {
  bool onBeforeBrowse(
    CefBrowser browser,
    CefFrame frame,
    CefRequest request,
    bool userGesture,
    bool isRedirect,
  );

  bool onOpenURLFromTab(
    CefBrowser browser,
    CefFrame frame,
    String targetUrl,
    bool userGesture,
  );

  bool getAuthCredentials(
    CefBrowser browser,
    String originUrl,
    bool isProxy,
    String host,
    int port,
    String realm,
    String scheme,
    CefAuthCallback callback,
  );

  bool onCertificateError(
    CefBrowser browser,
    CefErrorCode certError,
    String requestUrl,
    CefCallback callback,
  );

  void onRenderProcessTerminated(
    CefBrowser browser,
    CefTerminationStatus status,
    int errorCode,
    String errorString,
  );
}
