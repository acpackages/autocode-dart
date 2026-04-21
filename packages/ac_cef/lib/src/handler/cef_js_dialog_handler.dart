import '../cef_browser.dart';

enum CefJSDialogType {
  jsDialogTypeAlert,
  jsDialogTypeConfirm,
  jsDialogTypePrompt,
}

abstract class CefJSDialogCallback {
  void onContinue(bool success, String userInput);
}

abstract class CefJSDialogHandler {
  bool onJSDialog(
    CefBrowser browser,
    String originUrl,
    CefJSDialogType dialogType,
    String messageText,
    String defaultPromptText,
    CefJSDialogCallback callback,
  );

  bool onBeforeUnloadDialog(
    CefBrowser browser,
    String messageText,
    bool isReload,
    CefJSDialogCallback callback,
  );

  void onResetDialogState(CefBrowser browser);

  void onDialogClosed(CefBrowser browser);
}
