import '../cef_browser.dart';

enum CefJSDialogType {
  jsDialogTypeAlert,
  jsDialogTypeConfirm,
  jsDialogTypePrompt,
}

abstract class CefJSDialogCallback {
  void onContinue(bool success, String userInput);
}

/// Implement this interface to handle JavaScript dialog requests.
///
/// Mirrors JCEF's `org.cef.handler.CefJSDialogHandler` and `CefJSDialogHandlerAdapter`.
abstract class CefJSDialogHandler {
  /// Called to run a JavaScript dialog (alert, confirm, prompt). Return true to handle.
  bool onJSDialog(
    CefBrowser browser,
    String originUrl,
    CefJSDialogType dialogType,
    String messageText,
    String defaultPromptText,
    CefJSDialogCallback callback,
  ) => false;

  /// Called before unloading a page. Return true to handle dialog.
  bool onBeforeUnloadDialog(
    CefBrowser browser,
    String messageText,
    bool isReload,
    CefJSDialogCallback callback,
  ) => false;

  /// Called to cancel any pending dialogs.
  void onResetDialogState(CefBrowser browser) {}

  /// Called when the dialog is closed.
  void onDialogClosed(CefBrowser browser) {}
}

/// Convenience alias matching JCEF's adapter class name.
typedef CefJSDialogHandlerAdapter = CefJSDialogHandler;
