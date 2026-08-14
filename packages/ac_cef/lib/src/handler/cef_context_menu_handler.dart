import '../cef_browser.dart';
import '../cef_frame.dart';
import '../cef_menu_model.dart';

abstract class CefRunContextMenuCallback {
  void onContinue(int commandId, int eventFlags);
  void cancel();
}

/// Implement this interface to handle context menu events.
///
/// Mirrors JCEF's `org.cef.handler.CefContextMenuHandler` and `CefContextMenuHandlerAdapter`.
abstract class CefContextMenuHandler {
  /// Called before a context menu is displayed. Modify [model] to add/remove items.
  void onBeforeContextMenu(
    CefBrowser browser,
    CefFrame frame,
    CefContextMenuParams params,
    CefMenuModel model,
  ) {}

  /// Called to display a custom context menu. Return true to suppress default menu.
  bool runContextMenu(
    CefBrowser browser,
    CefFrame frame,
    CefContextMenuParams params,
    CefMenuModel model,
    CefRunContextMenuCallback callback,
  ) => false;

  /// Called when a context menu item is selected. Return true if handled.
  bool onContextMenuCommand(
    CefBrowser browser,
    CefFrame frame,
    CefContextMenuParams params,
    int commandId,
    int eventFlags,
  ) => false;

  /// Called when the context menu is dismissed.
  void onContextMenuDismissed(
    CefBrowser browser,
    CefFrame frame,
  ) {}
}

/// Convenience alias matching JCEF's adapter class name.
typedef CefContextMenuHandlerAdapter = CefContextMenuHandler;
