import 'cef_browser.dart';
import 'cef_browser_settings.dart';
import 'cef_frame.dart';
import 'cef_menu_model.dart';
import 'cef_settings.dart';
import 'handler/cef_context_menu_handler.dart';
import 'handler/cef_display_handler.dart';
import 'handler/cef_download_handler.dart';
import 'handler/cef_focus_handler.dart';
import 'handler/cef_js_dialog_handler.dart';
import 'handler/cef_keyboard_handler.dart';
import 'handler/cef_life_span_handler.dart';
import 'handler/cef_load_handler.dart';
import 'handler/cef_request_handler.dart';

/// The central client that owns browsers and routes all handler callbacks.
///
/// Mirrors JCEF's [org.cef.CefClient]. Register handlers using the
/// [addXxxHandler] methods, then call [createBrowser] to instantiate a browser.
///
/// Example:
/// ```dart
/// final client = CefClient();
/// client.addLoadHandler(MyLoadHandler());
/// client.addDisplayHandler(MyDisplayHandler());
/// final browser = client.createBrowser('https://flutter.dev');
/// ```
class CefClient {
  // ─── Handler registrations ───────────────────────────────────────────────

  CefContextMenuHandler? _contextMenuHandler;
  CefDisplayHandler? _displayHandler;
  CefDownloadHandler? _downloadHandler;
  CefFocusHandler? _focusHandler;
  CefJSDialogHandler? _jsDialogHandler;
  CefKeyboardHandler? _keyboardHandler;
  CefLoadHandler? _loadHandler;
  CefRequestHandler? _requestHandler;

  /// LifeSpan supports multiple handlers (mirrors JCEF list behaviour).
  final List<CefLifeSpanHandler> _lifeSpanHandlers = [];

  bool _isDisposed = false;

  // ─── Handler add/remove API ───────────────────────────────────────────────

  /// Register a handler for context menu events.
  CefClient addContextMenuHandler(CefContextMenuHandler handler) {
    _contextMenuHandler = handler;
    return this;
  }

  void removeContextMenuHandler() => _contextMenuHandler = null;

  /// Register a handler for display/UI events (title, address, cursor…).
  CefClient addDisplayHandler(CefDisplayHandler handler) {
    _displayHandler = handler;
    return this;
  }

  void removeDisplayHandler() => _displayHandler = null;

  /// Register a handler for file download events.
  CefClient addDownloadHandler(CefDownloadHandler handler) {
    _downloadHandler = handler;
    return this;
  }

  void removeDownloadHandler() => _downloadHandler = null;

  /// Register a handler for focus events.
  CefClient addFocusHandler(CefFocusHandler handler) {
    _focusHandler = handler;
    return this;
  }

  void removeFocusHandler() => _focusHandler = null;

  /// Register a handler for JavaScript alert/confirm/prompt dialogs.
  CefClient addJSDialogHandler(CefJSDialogHandler handler) {
    _jsDialogHandler = handler;
    return this;
  }

  void removeJSDialogHandler() => _jsDialogHandler = null;

  /// Register a handler for keyboard events.
  CefClient addKeyboardHandler(CefKeyboardHandler handler) {
    _keyboardHandler = handler;
    return this;
  }

  void removeKeyboardHandler() => _keyboardHandler = null;

  /// Register a handler for load state events.
  CefClient addLoadHandler(CefLoadHandler handler) {
    _loadHandler = handler;
    return this;
  }

  void removeLoadHandler() => _loadHandler = null;

  /// Register a handler for navigation/request events.
  CefClient addRequestHandler(CefRequestHandler handler) {
    _requestHandler = handler;
    return this;
  }

  void removeRequestHandler() => _requestHandler = null;

  /// Add a life-span handler (multiple handlers are supported).
  CefClient addLifeSpanHandler(CefLifeSpanHandler handler) {
    _lifeSpanHandlers.add(handler);
    return this;
  }

  void removeLifeSpanHandler(CefLifeSpanHandler handler) =>
      _lifeSpanHandlers.remove(handler);

  void removeAllLifeSpanHandlers() => _lifeSpanHandlers.clear();

  // ─── Browser creation ─────────────────────────────────────────────────────

  /// Create a new browser window for the given [url].
  ///
  /// [windowless] — if true, uses Off-Screen Rendering (OSR).
  /// [settings] — optional per-browser settings (frame rate, etc.).
  CefBrowser createBrowser(
    String url, {
    bool windowless = true,
    bool isTransparent = false,
    CefBrowserSettings? settings,
  }) {
    if (_isDisposed) {
      throw StateError('Cannot create browser: CefClient is disposed.');
    }
    final browser = CefBrowser(
      url,
      windowless: windowless,
      settings: settings,
    );
    // TODO: Invoke native CefBrowserHost::CreateBrowser via FFI here.
    return browser;
  }

  // ─── Internal callback dispatch (called from native layer via FFI) ─────────

  // ── LifeSpanHandler ──────────────────────────────────────────────────────

  bool dispatchOnBeforePopup(
      CefBrowser browser, CefFrame frame, String url, String frameName) {
    bool result = false;
    for (final h in _lifeSpanHandlers) {
      result |= h.onBeforePopup(browser, frame, url, frameName);
    }
    return result;
  }

  void dispatchOnAfterCreated(CefBrowser browser) {
    for (final h in _lifeSpanHandlers) {
      h.onAfterCreated(browser);
    }
  }

  void dispatchOnAfterParentChanged(CefBrowser browser) {
    for (final h in _lifeSpanHandlers) {
      h.onAfterParentChanged(browser);
    }
  }

  bool dispatchDoClose(CefBrowser browser) {
    bool result = false;
    for (final h in _lifeSpanHandlers) {
      result |= h.doClose(browser);
    }
    return result;
  }

  void dispatchOnBeforeClose(CefBrowser browser) {
    for (final h in _lifeSpanHandlers) {
      h.onBeforeClose(browser);
    }
  }

  // ── LoadHandler ──────────────────────────────────────────────────────────

  void dispatchOnLoadingStateChange(
      CefBrowser browser, bool isLoading, bool canGoBack, bool canGoForward) {
    _loadHandler?.onLoadingStateChange(
        browser, isLoading, canGoBack, canGoForward);
  }

  void dispatchOnLoadStart(
      CefBrowser browser, CefFrame frame, int transitionType) {
    _loadHandler?.onLoadStart(browser, frame, transitionType);
  }

  void dispatchOnLoadEnd(
      CefBrowser browser, CefFrame frame, int httpStatusCode) {
    _loadHandler?.onLoadEnd(browser, frame, httpStatusCode);
  }

  void dispatchOnLoadError(CefBrowser browser, CefFrame frame,
      CefErrorCode errorCode, String errorText, String failedUrl) {
    _loadHandler?.onLoadError(browser, frame, errorCode, errorText, failedUrl);
  }

  // ── DisplayHandler ───────────────────────────────────────────────────────

  void dispatchOnAddressChange(
      CefBrowser browser, CefFrame frame, String url) {
    _displayHandler?.onAddressChange(browser, frame, url);
  }

  void dispatchOnTitleChange(CefBrowser browser, String title) {
    _displayHandler?.onTitleChange(browser, title);
  }

  bool dispatchOnTooltip(CefBrowser browser, String text) =>
      _displayHandler?.onTooltip(browser, text) ?? false;

  void dispatchOnStatusMessage(CefBrowser browser, String value) =>
      _displayHandler?.onStatusMessage(browser, value);

  bool dispatchOnConsoleMessage(CefBrowser browser, CefLogSeverity level,
          String message, String source, int line) =>
      _displayHandler?.onConsoleMessage(browser, level, message, source, line) ??
      false;

  bool dispatchOnCursorChange(CefBrowser browser, int cursorType) =>
      _displayHandler?.onCursorChange(browser, cursorType) ?? false;

  // ── FocusHandler ─────────────────────────────────────────────────────────

  void dispatchOnTakeFocus(CefBrowser browser, bool next) =>
      _focusHandler?.onTakeFocus(browser, next);

  bool dispatchOnSetFocus(CefBrowser browser, CefFocusSource source) =>
      _focusHandler?.onSetFocus(browser, source) ?? false;

  void dispatchOnGotFocus(CefBrowser browser) =>
      _focusHandler?.onGotFocus(browser);

  // ── KeyboardHandler ──────────────────────────────────────────────────────

  bool dispatchOnPreKeyEvent(CefBrowser browser, CefKeyEvent event) =>
      _keyboardHandler?.onPreKeyEvent(browser, event) ?? false;

  bool dispatchOnKeyEvent(CefBrowser browser, CefKeyEvent event) =>
      _keyboardHandler?.onKeyEvent(browser, event) ?? false;

  // ── JSDialogHandler ──────────────────────────────────────────────────────

  bool dispatchOnJSDialog(
    CefBrowser browser,
    String originUrl,
    CefJSDialogType dialogType,
    String messageText,
    String defaultPromptText,
    CefJSDialogCallback callback,
  ) =>
      _jsDialogHandler?.onJSDialog(
          browser, originUrl, dialogType, messageText, defaultPromptText, callback) ??
      false;

  bool dispatchOnBeforeUnloadDialog(CefBrowser browser, String messageText,
          bool isReload, CefJSDialogCallback callback) =>
      _jsDialogHandler?.onBeforeUnloadDialog(
          browser, messageText, isReload, callback) ??
      false;

  void dispatchOnResetDialogState(CefBrowser browser) =>
      _jsDialogHandler?.onResetDialogState(browser);

  void dispatchOnDialogClosed(CefBrowser browser) =>
      _jsDialogHandler?.onDialogClosed(browser);

  // ── DownloadHandler ──────────────────────────────────────────────────────

  bool dispatchOnBeforeDownload(
    CefBrowser browser,
    CefDownloadItem item,
    String suggestedName,
    CefBeforeDownloadCallback callback,
  ) =>
      _downloadHandler?.onBeforeDownload(
          browser, item, suggestedName, callback) ??
      false;

  void dispatchOnDownloadUpdated(CefBrowser browser, CefDownloadItem item,
          CefDownloadItemCallback callback) =>
      _downloadHandler?.onDownloadUpdated(browser, item, callback);

  // ── ContextMenuHandler ───────────────────────────────────────────────────

  void dispatchOnBeforeContextMenu(CefBrowser browser, CefFrame frame,
          CefContextMenuParams params, CefMenuModel model) =>
      _contextMenuHandler?.onBeforeContextMenu(browser, frame, params, model);

  bool dispatchRunContextMenu(
    CefBrowser browser,
    CefFrame frame,
    CefContextMenuParams params,
    CefMenuModel model,
    CefRunContextMenuCallback callback,
  ) =>
      _contextMenuHandler?.runContextMenu(
          browser, frame, params, model, callback) ??
      false;

  bool dispatchOnContextMenuCommand(CefBrowser browser, CefFrame frame,
          CefContextMenuParams params, int commandId, int eventFlags) =>
      _contextMenuHandler?.onContextMenuCommand(
          browser, frame, params, commandId, eventFlags) ??
      false;

  void dispatchOnContextMenuDismissed(CefBrowser browser, CefFrame frame) =>
      _contextMenuHandler?.onContextMenuDismissed(browser, frame);

  // ── RequestHandler ───────────────────────────────────────────────────────

  bool dispatchOnCertificateError(CefBrowser browser, CefErrorCode certError,
          String requestUrl, CefCallback callback) =>
      _requestHandler?.onCertificateError(
          browser, certError, requestUrl, callback) ??
      false;

  void dispatchOnRenderProcessTerminated(CefBrowser browser,
          CefTerminationStatus status, int errorCode, String errorString) =>
      _requestHandler?.onRenderProcessTerminated(
          browser, status, errorCode, errorString);

  // ─── Disposal ─────────────────────────────────────────────────────────────

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    // TODO: Notify native layer to destroy all owned browsers via FFI.
    _lifeSpanHandlers.clear();
  }

  bool get isDisposed => _isDisposed;
}
