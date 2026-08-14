import '../cef_browser.dart';
import '../cef_frame.dart';

/// Chromium net error codes. Matches JCEF's [org.cef.handler.CefLoadHandler.ErrorCode].
enum CefErrorCode {
  errNone(0),
  errIoPending(-1),
  errFailed(-2),
  errAborted(-3),
  errInvalidArgument(-4),
  errInvalidHandle(-5),
  errFileNotFound(-6),
  errTimedOut(-7),
  errFileTooBig(-8),
  errUnexpected(-9),
  errAccessDenied(-10),
  errNotImplemented(-11),
  errInsufficientResources(-12),
  errOutOfMemory(-13),
  errUploadFileChanged(-14),
  errSocketNotConnected(-15),
  errFileExists(-16),
  errFilePathTooLong(-17),
  errFileNoSpace(-18),
  errFileVirusInfected(-19),
  errBlockedByClient(-20),
  errNetworkChanged(-21),
  errBlockedByAdministrator(-22),
  errSocketIsConnected(-23),
  errBlockedByResponse(-27),
  errCleartextNotPermitted(-29),
  errConnectionClosed(-100),
  errConnectionReset(-101),
  errConnectionRefused(-102),
  errConnectionAborted(-103),
  errConnectionFailed(-104),
  errNameNotResolved(-105),
  errInternetDisconnected(-106),
  errSslProtocolError(-107),
  errAddressInvalid(-108),
  errAddressUnreachable(-109),
  errSslClientAuthCertNeeded(-110),
  errTunnelConnectionFailed(-111),
  errSslVersionOrCipherMismatch(-113),
  errCertCommonNameInvalid(-200),
  errCertDateInvalid(-201),
  errCertAuthorityInvalid(-202),
  errCertContainsErrors(-203),
  errCertNoRevocationMechanism(-204),
  errCertUnableToCheckRevocation(-205),
  errCertRevoked(-206),
  errCertInvalid(-207),
  errCertWeakSignatureAlgorithm(-208),
  unknown(-999);

  final int code;
  const CefErrorCode(this.code);

  static CefErrorCode findByCode(int code) {
    for (var value in CefErrorCode.values) {
      if (value.code == code) return value;
    }
    return CefErrorCode.unknown;
  }
}

/// Implement this interface to handle events related to browser load status.
///
/// Mirrors JCEF's `org.cef.handler.CefLoadHandler` and `CefLoadHandlerAdapter`.
abstract class CefLoadHandler {
  /// Called when the loading state has changed for the browser.
  void onLoadingStateChange(
    CefBrowser browser,
    bool isLoading,
    bool canGoBack,
    bool canGoForward,
  ) {}

  /// Called when a frame starts loading.
  void onLoadStart(
    CefBrowser browser,
    CefFrame frame,
    int transitionType,
  ) {}

  /// Called when a frame finishes loading.
  void onLoadEnd(
    CefBrowser browser,
    CefFrame frame,
    int httpStatusCode,
  ) {}

  /// Called when an error occurs while loading a URL in a frame.
  void onLoadError(
    CefBrowser browser,
    CefFrame frame,
    CefErrorCode errorCode,
    String errorText,
    String failedUrl,
  ) {}
}

/// Convenience alias matching JCEF's adapter class name.
typedef CefLoadHandlerAdapter = CefLoadHandler;
