import '../cef_browser.dart';
import '../cef_frame.dart';
import '../cef_menu_model.dart';

abstract class CefRunContextMenuCallback {
  void onContinue(int commandId, int eventFlags);
  void cancel();
}

abstract class CefContextMenuHandler {
  void onBeforeContextMenu(
    CefBrowser browser,
    CefFrame frame,
    CefContextMenuParams params,
    CefMenuModel model,
  );

  bool runContextMenu(
    CefBrowser browser,
    CefFrame frame,
    CefContextMenuParams params,
    CefMenuModel model,
    CefRunContextMenuCallback callback,
  );

  bool onContextMenuCommand(
    CefBrowser browser,
    CefFrame frame,
    CefContextMenuParams params,
    int commandId,
    int eventFlags,
  );

  void onContextMenuDismissed(
    CefBrowser browser,
    CefFrame frame,
  );
}
