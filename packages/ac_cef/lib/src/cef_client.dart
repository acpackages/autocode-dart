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
import 'handler/cef_find_handler.dart';
import 'handler/cef_keyboard_handler.dart';
import 'handler/cef_life_span_handler.dart';
import 'handler/cef_load_handler.dart';
import 'handler/cef_request_handler.dart';
import 'network/cef_request.dart';

/// The central client that owns browsers and routes all handler callbacks.
///
/// Mirrors JCEF's [org.cef.CefClient]. Register handlers using the
/// [addXxxHandler] methods, then call [createBrowser] to instantiate a browser.
///
/// Supports multiple handlers per category (mirroring JCEF's multi-handler
/// and multi-browser support).
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

  final List<CefContextMenuHandler> _contextMenuHandlers = [];
  final List<CefDisplayHandler>     _displayHandlers     = [];
  final List<CefDownloadHandler>    _downloadHandlers    = [];
  final List<CefFocusHandler>       _focusHandlers       = [];
  final List<CefFindHandler>        _findHandlers        = [];
  final List<CefJSDialogHandler>    _jsDialogHandlers    = [];
  final List<CefKeyboardHandler>    _keyboardHandlers    = [];
  final List<CefLoadHandler>        _loadHandlers        = [];
  final List<CefRequestHandler>     _requestHandlers     = [];
  final List<CefLifeSpanHandler>    _lifeSpanHandlers    = [];

  bool _isDisposed = false;

  // ─── Handler add/remove API ───────────────────────────────────────────────

  /// Register a handler for context menu events.
  CefClient addContextMenuHandler(CefContextMenuHandler handler) {
    _contextMenuHandlers.add(handler);
    return this;
  }

  void removeContextMenuHandler([CefContextMenuHandler? handler]) {
    if (handler != null) {
      _contextMenuHandlers.remove(handler);
    } else {
      _contextMenuHandlers.clear();
    }
  }

  /// Register a handler for display/UI events (title, address, cursor…).
  CefClient addDisplayHandler(CefDisplayHandler handler) {
    _displayHandlers.add(handler);
    return this;
  }

  void removeDisplayHandler([CefDisplayHandler? handler]) {
    if (handler != null) {
      _displayHandlers.remove(handler);
    } else {
      _displayHandlers.clear();
    }
  }

  /// Register a handler for file download events.
  CefClient addDownloadHandler(CefDownloadHandler handler) {
    _downloadHandlers.add(handler);
    return this;
  }

  void removeDownloadHandler([CefDownloadHandler? handler]) {
    if (handler != null) {
      _downloadHandlers.remove(handler);
    } else {
      _downloadHandlers.clear();
    }
  }

  /// Register a handler for focus events.
  CefClient addFocusHandler(CefFocusHandler handler) {
    _focusHandlers.add(handler);
    return this;
  }

  void removeFocusHandler([CefFocusHandler? handler]) {
    if (handler != null) {
      _focusHandlers.remove(handler);
    } else {
      _focusHandlers.clear();
    }
  }

  /// Register a handler for JavaScript alert/confirm/prompt dialogs.
  CefClient addJSDialogHandler(CefJSDialogHandler handler) {
    _jsDialogHandlers.add(handler);
    return this;
  }

  void removeJSDialogHandler([CefJSDialogHandler? handler]) {
    if (handler != null) {
      _jsDialogHandlers.remove(handler);
    } else {
      _jsDialogHandlers.clear();
    }
  }

  /// Register a handler for find-in-page results.
  CefClient addFindHandler(CefFindHandler handler) {
    _findHandlers.add(handler);
    return this;
  }

  void removeFindHandler([CefFindHandler? handler]) {
    if (handler != null) {
      _findHandlers.remove(handler);
    } else {
      _findHandlers.clear();
    }
  }

  /// Register a handler for keyboard events.
  CefClient addKeyboardHandler(CefKeyboardHandler handler) {
    _keyboardHandlers.add(handler);
    return this;
  }

  void removeKeyboardHandler([CefKeyboardHandler? handler]) {
    if (handler != null) {
      _keyboardHandlers.remove(handler);
    } else {
      _keyboardHandlers.clear();
    }
  }

  /// Register a handler for load state events.
  CefClient addLoadHandler(CefLoadHandler handler) {
    _loadHandlers.add(handler);
    return this;
  }

  void removeLoadHandler([CefLoadHandler? handler]) {
    if (handler != null) {
      _loadHandlers.remove(handler);
    } else {
      _loadHandlers.clear();
    }
  }

  /// Register a handler for navigation/request events.
  CefClient addRequestHandler(CefRequestHandler handler) {
    _requestHandlers.add(handler);
    return this;
  }

  void removeRequestHandler([CefRequestHandler? handler]) {
    if (handler != null) {
      _requestHandlers.remove(handler);
    } else {
      _requestHandlers.clear();
    }
  }

  /// The first registered [CefRequestHandler], or null if none is registered.
  CefRequestHandler? get requestHandler =>
      _requestHandlers.isNotEmpty ? _requestHandlers.first : null;

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
    return browser;
  }

  // ─── Internal callback dispatch (called from native layer via FFI) ─────────

  // ── LifeSpanHandler ──────────────────────────────────────────────────────

  bool dispatchOnBeforePopup(
      CefBrowser browser, CefFrame frame, String url, String frameName,
      CefWindowOpenDisposition disposition, bool userGesture) {
    bool result = false;
    for (final h in List.of(_lifeSpanHandlers)) {
      result |= h.onBeforePopup(
          browser, frame, url, frameName, disposition, userGesture);
    }
    return result;
  }

  void dispatchOnAfterCreated(CefBrowser browser) {
    for (final h in List.of(_lifeSpanHandlers)) {
      h.onAfterCreated(browser);
    }
  }

  void dispatchOnAfterParentChanged(CefBrowser browser) {
    for (final h in List.of(_lifeSpanHandlers)) {
      h.onAfterParentChanged(browser);
    }
  }

  bool dispatchDoClose(CefBrowser browser) {
    bool result = false;
    for (final h in List.of(_lifeSpanHandlers)) {
      result |= h.doClose(browser);
    }
    return result;
  }

  void dispatchOnBeforeClose(CefBrowser browser) {
    for (final h in List.of(_lifeSpanHandlers)) {
      h.onBeforeClose(browser);
    }
  }

  // ── LoadHandler ──────────────────────────────────────────────────────────

  void dispatchOnLoadingStateChange(
      CefBrowser browser, bool isLoading, bool canGoBack, bool canGoForward) {
    for (final h in List.of(_loadHandlers)) {
      h.onLoadingStateChange(browser, isLoading, canGoBack, canGoForward);
    }
  }

  void dispatchOnLoadStart(
      CefBrowser browser, CefFrame frame, int transitionType) {
    for (final h in List.of(_loadHandlers)) {
      h.onLoadStart(browser, frame, transitionType);
    }
  }

  void dispatchOnLoadEnd(
      CefBrowser browser, CefFrame frame, int httpStatusCode) {
    for (final h in List.of(_loadHandlers)) {
      h.onLoadEnd(browser, frame, httpStatusCode);
    }
  }

  void dispatchOnLoadError(CefBrowser browser, CefFrame frame,
      CefErrorCode errorCode, String errorText, String failedUrl) {
    for (final h in List.of(_loadHandlers)) {
      h.onLoadError(browser, frame, errorCode, errorText, failedUrl);
    }
  }

  // ── DisplayHandler ───────────────────────────────────────────────────────

  void dispatchOnAddressChange(
      CefBrowser browser, CefFrame frame, String url) {
    for (final h in List.of(_displayHandlers)) {
      h.onAddressChange(browser, frame, url);
    }
  }

  void dispatchOnTitleChange(CefBrowser browser, String title) {
    for (final h in List.of(_displayHandlers)) {
      h.onTitleChange(browser, title);
    }
  }

  void dispatchOnLoadingProgressChange(CefBrowser browser, double progress) {
    for (final h in List.of(_displayHandlers)) {
      h.onLoadingProgressChange(browser, progress);
    }
  }

  void dispatchOnFullscreenModeChange(CefBrowser browser, bool fullscreen) {
    for (final h in List.of(_displayHandlers)) {
      h.onFullscreenModeChange(browser, fullscreen);
    }
  }

  void dispatchOnFaviconUrlChange(CefBrowser browser, List<String> urls) {
    for (final h in List.of(_displayHandlers)) {
      h.onFaviconUrlChange(browser, urls);
    }
  }

  bool dispatchOnTooltip(CefBrowser browser, String text) {
    bool handled = false;
    for (final h in List.of(_displayHandlers)) {
      handled |= h.onTooltip(browser, text);
    }
    return handled;
  }

  void dispatchOnStatusMessage(CefBrowser browser, String value) {
    for (final h in List.of(_displayHandlers)) {
      h.onStatusMessage(browser, value);
    }
  }

  bool dispatchOnConsoleMessage(CefBrowser browser, CefLogSeverity level,
          String message, String source, int line) {
    bool handled = false;
    for (final h in List.of(_displayHandlers)) {
      handled |= h.onConsoleMessage(browser, level, message, source, line);
    }
    return handled;
  }

  bool dispatchOnCursorChange(CefBrowser browser, int cursorType) {
    bool handled = false;
    for (final h in List.of(_displayHandlers)) {
      handled |= h.onCursorChange(browser, cursorType);
    }
    return handled;
  }

  // ── FocusHandler ─────────────────────────────────────────────────────────

  void dispatchOnTakeFocus(CefBrowser browser, bool next) {
    for (final h in List.of(_focusHandlers)) {
      h.onTakeFocus(browser, next);
    }
  }

  bool dispatchOnSetFocus(CefBrowser browser, CefFocusSource source) {
    bool handled = false;
    for (final h in List.of(_focusHandlers)) {
      handled |= h.onSetFocus(browser, source);
    }
    return handled;
  }

  void dispatchOnGotFocus(CefBrowser browser) {
    for (final h in List.of(_focusHandlers)) {
      h.onGotFocus(browser);
    }
  }

  // ── KeyboardHandler ──────────────────────────────────────────────────────

  bool dispatchOnPreKeyEvent(CefBrowser browser, CefKeyEvent event) {
    bool handled = false;
    for (final h in List.of(_keyboardHandlers)) {
      handled |= h.onPreKeyEvent(browser, event);
    }
    return handled;
  }

  bool dispatchOnKeyEvent(CefBrowser browser, CefKeyEvent event) {
    bool handled = false;
    for (final h in List.of(_keyboardHandlers)) {
      handled |= h.onKeyEvent(browser, event);
    }
    return handled;
  }

  // ── JSDialogHandler ──────────────────────────────────────────────────────

  bool dispatchOnJSDialog(
    CefBrowser browser,
    String originUrl,
    CefJSDialogType dialogType,
    String messageText,
    String defaultPromptText,
    CefJSDialogCallback callback,
  ) {
    final handlers = List.of(_jsDialogHandlers);
    if (handlers.isNotEmpty) {
      bool handled = false;
      for (final h in handlers) {
        handled |= h.onJSDialog(browser, originUrl, dialogType, messageText,
            defaultPromptText, callback);
      }
      return handled;
    }
    // No handler registered — auto-accept to prevent the page from freezing.
    callback.onContinue(true, '');
    return true;
  }

  bool dispatchOnBeforeUnloadDialog(CefBrowser browser, String messageText,
      bool isReload, CefJSDialogCallback callback) {
    final handlers = List.of(_jsDialogHandlers);
    if (handlers.isNotEmpty) {
      bool handled = false;
      for (final h in handlers) {
        handled |= h.onBeforeUnloadDialog(
            browser, messageText, isReload, callback);
      }
      return handled;
    }
    return false;
  }

  void dispatchOnResetDialogState(CefBrowser browser) {
    for (final h in List.of(_jsDialogHandlers)) {
      h.onResetDialogState(browser);
    }
  }

  void dispatchOnDialogClosed(CefBrowser browser) {
    for (final h in List.of(_jsDialogHandlers)) {
      h.onDialogClosed(browser);
    }
  }

  // ── FindHandler ───────────────────────────────────────────────────────────

  void dispatchOnFindResult(CefBrowser browser, CefFindResult result) {
    for (final h in List.of(_findHandlers)) {
      h.onFindResult(browser, result);
    }
  }

  // ── DownloadHandler ──────────────────────────────────────────────────────

  bool dispatchOnBeforeDownload(
    CefBrowser browser,
    CefDownloadItem item,
    String suggestedName,
    CefBeforeDownloadCallback callback,
  ) {
    bool handled = false;
    for (final h in List.of(_downloadHandlers)) {
      handled |= h.onBeforeDownload(browser, item, suggestedName, callback);
    }
    return handled;
  }

  void dispatchOnDownloadUpdated(CefBrowser browser, CefDownloadItem item,
      CefDownloadItemCallback callback) {
    for (final h in List.of(_downloadHandlers)) {
      h.onDownloadUpdated(browser, item, callback);
    }
  }

  // ── ContextMenuHandler ───────────────────────────────────────────────────

  void dispatchOnBeforeContextMenu(CefBrowser browser, CefFrame frame,
      CefContextMenuParams params, CefMenuModel model) {
    for (final h in List.of(_contextMenuHandlers)) {
      h.onBeforeContextMenu(browser, frame, params, model);
    }
  }

  bool dispatchRunContextMenu(
    CefBrowser browser,
    CefFrame frame,
    CefContextMenuParams params,
    CefMenuModel model,
    CefRunContextMenuCallback callback,
  ) {
    bool handled = false;
    for (final h in List.of(_contextMenuHandlers)) {
      handled |= h.runContextMenu(browser, frame, params, model, callback);
    }
    return handled;
  }

  bool dispatchOnContextMenuCommand(CefBrowser browser, CefFrame frame,
      CefContextMenuParams params, int commandId, int eventFlags) {
    bool handled = false;
    for (final h in List.of(_contextMenuHandlers)) {
      handled |= h.onContextMenuCommand(
          browser, frame, params, commandId, eventFlags);
    }
    return handled;
  }

  void dispatchOnContextMenuDismissed(CefBrowser browser, CefFrame frame) {
    for (final h in List.of(_contextMenuHandlers)) {
      h.onContextMenuDismissed(browser, frame);
    }
  }

  // ── RequestHandler ───────────────────────────────────────────────────────

  bool dispatchOnCertificateError(CefBrowser browser, CefErrorCode certError,
      String requestUrl, CefCallback callback) {
    bool handled = false;
    for (final h in List.of(_requestHandlers)) {
      handled |=
          h.onCertificateError(browser, certError, requestUrl, callback);
    }
    return handled;
  }

  bool dispatchOnBeforeResourceLoad(
      CefBrowser browser, CefFrame frame, CefRequest request) {
    bool handled = false;
    for (final h in List.of(_requestHandlers)) {
      handled |= h.onBeforeResourceLoad(browser, frame, request);
    }
    return handled;
  }

  void dispatchOnRenderProcessTerminated(CefBrowser browser,
      CefTerminationStatus status, int errorCode, String errorString) {
    for (final h in List.of(_requestHandlers)) {
      h.onRenderProcessTerminated(browser, status, errorCode, errorString);
    }
  }

  // ─── Disposal ─────────────────────────────────────────────────────────────

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _contextMenuHandlers.clear();
    _displayHandlers.clear();
    _downloadHandlers.clear();
    _focusHandlers.clear();
    _findHandlers.clear();
    _jsDialogHandlers.clear();
    _keyboardHandlers.clear();
    _loadHandlers.clear();
    _requestHandlers.clear();
    _lifeSpanHandlers.clear();
  }

  bool get isDisposed => _isDisposed;
}
