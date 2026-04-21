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

abstract class CefDownloadHandler {
  bool onBeforeDownload(
    CefBrowser browser,
    CefDownloadItem downloadItem,
    String suggestedName,
    CefBeforeDownloadCallback callback,
  );

  void onDownloadUpdated(
    CefBrowser browser,
    CefDownloadItem downloadItem,
    CefDownloadItemCallback callback,
  );
}
