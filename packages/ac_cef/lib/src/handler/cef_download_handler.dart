import '../cef_browser.dart';

abstract class CefDownloadItem {
  bool isValid();
  bool isInProgress();
  bool isComplete();
  bool isCanceled();
  int getCurrentSpeed();
  int getPercentComplete();
  int getTotalBytes();
  int getReceivedBytes();
  DateTime getStartTime();
  DateTime getEndTime();
  String getFullPath();
  int getId();
  String getURL();
  String getSuggestedFileName();
  String getContentDisposition();
  String getMimeType();
}

abstract class CefBeforeDownloadCallback {
  void onContinue(String downloadPath, bool showDialog);
}

abstract class CefDownloadItemCallback {
  void cancel();
  void pause();
  void resume();
}

/// Implement this interface to handle file downloads.
///
/// Mirrors JCEF's `org.cef.handler.CefDownloadHandler` and `CefDownloadHandlerAdapter`.
abstract class CefDownloadHandler {
  /// Called before a download begins. Return true to handle download.
  bool onBeforeDownload(
    CefBrowser browser,
    CefDownloadItem downloadItem,
    String suggestedName,
    CefBeforeDownloadCallback callback,
  ) => false;

  /// Called when a download's status or progress information has been updated.
  void onDownloadUpdated(
    CefBrowser browser,
    CefDownloadItem downloadItem,
    CefDownloadItemCallback callback,
  ) {}
}

/// Convenience alias matching JCEF's adapter class name.
typedef CefDownloadHandlerAdapter = CefDownloadHandler;
