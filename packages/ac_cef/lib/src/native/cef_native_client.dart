import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import '../cef_browser.dart';
import '../cef_browser_settings.dart';
import '../cef_client.dart';
import '../cef_frame.dart';
import '../cef_settings.dart';
import '../handler/cef_download_handler.dart';
import '../handler/cef_js_dialog_handler.dart';
import '../handler/cef_load_handler.dart';
import 'cef_bindings.dart';
import 'paint_frame.dart';

// ─── Static native callbacks (top-level / global functions) ──────────────────
// Must be top-level so dart:ffi can take their address via Pointer.fromFunction.

CefNativeClient? _activeClient;

/// Safely decode a native C string pointer.
/// CEF on Windows may pass strings that contain invalid UTF-8 bytes
/// (e.g. from CefString's wide-char to char conversion).
/// Falls back to Latin-1 if UTF-8 decoding fails.
String _safeString(Pointer<Utf8> p) {
  if (p == nullptr) return '';
  try {
    return p.toDartString();
  } catch (_) {
    // Fallback: read raw bytes until null terminator and decode as latin1
    final ptr = p.cast<Uint8>();
    int len = 0;
    while (ptr[len] != 0) len++;
    if (len == 0) return '';
    final bytes = ptr.asTypedList(len);
    return latin1.decode(bytes);
  }
}

// ignore: non_constant_identifier_names
void _onUrlChanged(int id, Pointer<Utf8> url) =>
    _activeClient?._fwdUrlChanged(id, _safeString(url));
void _onTitleChanged(int id, Pointer<Utf8> title) =>
    _activeClient?._fwdTitleChanged(id, _safeString(title));
void _onLoadingStateChanged(int id, int loading, int back, int fwd) =>
    _activeClient?._fwdLoadingStateChanged(id, loading != 0, back != 0, fwd != 0);
void _onLoadStart(int id, Pointer<Utf8> frameUrl, int transition) {
    _activeClient?._fwdLoadStart(id, _safeString(frameUrl), transition);
}
void _onLoadEnd(int id, Pointer<Utf8> frameUrl, int status) {
    _activeClient?._fwdLoadEnd(id, _safeString(frameUrl), status);
}
void _onLoadError(int id, Pointer<Utf8> frameUrl, int code,
    Pointer<Utf8> text, Pointer<Utf8> url) =>
    _activeClient?._fwdLoadError(id, _safeString(frameUrl), code,
        _safeString(text), _safeString(url));
void _onAfterCreated(int id) => _activeClient?._fwdAfterCreated(id);
void _onBeforeClose(int id)  => _activeClient?._fwdBeforeClose(id);
int  _onBeforePopup(int id, Pointer<Utf8> url, Pointer<Utf8> name) =>
    (_activeClient?._fwdBeforePopup(id, _safeString(url), _safeString(name)) ?? false)
        ? 1 : 0;
void _onCursorChanged(int id, int type) =>
    _activeClient?._fwdCursorChanged(id, type);
void _onGotFocus(int id) => _activeClient?._fwdGotFocus(id);
int  _onConsoleMessage(int id, int level,
    Pointer<Utf8> msg, Pointer<Utf8> src, int line) =>
    (_activeClient?._fwdConsoleMessage(id, level,
        _safeString(msg), _safeString(src), line) ?? false)
        ? 1 : 0;
int _onJSDialog(int id, Pointer<Utf8> origin, int type,
    Pointer<Utf8> msg, Pointer<Utf8> prompt, int cbId) =>
    (_activeClient?._fwdJSDialog(id, _safeString(origin), type,
        _safeString(msg), _safeString(prompt), cbId) ?? false)
        ? 1 : 0;
int _onBeforeDownload(int id, int dlId, Pointer<Utf8> url,
    Pointer<Utf8> name, int cbId) =>
    (_activeClient?._fwdBeforeDownload(id, dlId,
        _safeString(url), _safeString(name), cbId) ?? false)
        ? 1 : 0;
void _onDownloadUpdated(int id, int dlId, int pct, int done, int canceled) =>
    _activeClient?._fwdDownloadUpdated(id, dlId, pct, done != 0, canceled != 0);

int _onBeforeBrowse(int id, Pointer<Utf8> url, int isRedirect) =>
    (_activeClient?._fwdBeforeBrowse(id, _safeString(url), isRedirect != 0) ?? false)
        ? 1 : 0;
int _onBeforeResourceLoad(int id, Pointer<Utf8> url, Pointer<Utf8> method) =>
    (_activeClient?._fwdBeforeResourceLoad(id, _safeString(url), _safeString(method)) ?? false)
        ? 1 : 0;
void _onBeforeContextMenu(int id, int x, int y) =>
    _activeClient?._fwdBeforeContextMenu(id, x, y);

void _onQuery(int id, int qId, Pointer<Utf8> req, int persistent) =>
    _activeClient?._fwdQuery(id, qId, _safeString(req), persistent != 0);
void _onQueryCanceled(int id, int qId) =>
    _activeClient?._fwdQueryCanceled(id, qId);

/// Called by C for every paint frame.  [buffer] is valid only during this call.
bool _firstPaint = true;
void _onPaint(int id, int isPopup, Pointer<Void> buffer, int w, int h) {
  if (_firstPaint) {
    print('[CEF] Paint frames arriving! ${w}x${h}');
    _firstPaint = false;
  }
  final client = _activeClient;
  if (client == null) return;
  // Copy the pixel data immediately — buffer is CEF-owned and freed after return.
  final bytes = buffer.cast<Uint8>().asTypedList(w * h * 4);
  final copy  = Uint8List.fromList(bytes);
  client._fwdPaint(id, isPopup != 0, copy, w, h);
}

/// Called by C to query the view rect for this browser.
void _getViewRect(int id, Pointer<Int32> x, Pointer<Int32> y,
    Pointer<Int32> w, Pointer<Int32> h) {
  final size = _activeClient?._viewSizes[id];
  x.value = 0;
  y.value = 0;
  w.value = size?.width.toInt()  ?? 800;
  h.value = size?.height.toInt() ?? 600;
}

// ─── CefNativeClient ─────────────────────────────────────────────────────────

class _ViewSize {
  final double width;
  final double height;
  final double dpr;
  const _ViewSize(this.width, this.height, this.dpr);
}

class CefNativeClient {
  final CefBindings bindings;
  final CefClient client;

  bool _initialized = false;

  // browser-id → CefBrowser
  final Map<int, CefBrowser> _browsers = {};

  // browser-id → current view size (logical pixels × DPR)
  final Map<int, _ViewSize> _viewSizes = {};

  // browser-id → StreamController for paint frames
  final Map<int, StreamController<PaintFrame>> _paintStreams = {};

  // browser-id → StreamController for cursor type changes
  final Map<int, StreamController<int>> _cursorStreams = {};

  // pending JS / download callback IDs → Dart closures
  final Map<int, CefJSDialogCallback>       _jsCbs  = {};
  final Map<int, CefBeforeDownloadCallback> _dlCbs  = {};
  
  // pending queries
  final Map<int, Completer<String>> _queries = {};

  // Keep NativeCallables alive
  final List<NativeCallable> _callables = [];

  CefNativeClient({required this.bindings, required this.client});

  // ─── Initialization ────────────────────────────────────────────────────────

  bool initialize([CefSettings? settings]) {
    if (_initialized) return true;
    _activeClient = this;

    final map  = (settings ?? CefSettings()).toMap();
    final keys = calloc<Pointer<Utf8>>(map.length);
    final vals = calloc<Pointer<Utf8>>(map.length);
    final ptrs = <Pointer<Utf8>>[];

    int i = 0;
    for (final e in map.entries) {
      final k = e.key.toNativeUtf8();
      final v = e.value.toNativeUtf8();
      ptrs.addAll([k, v]);
      keys[i] = k;
      vals[i] = v;
      i++;
    }

    final cb = calloc<AcCefCallbacksStruct>();
    
    _regVoid(NativeCallable<OnUrlChangedCallback>.listener(_onUrlChanged), (p) => cb.ref.on_url_changed = p);
    _regVoid(NativeCallable<OnTitleChangedCallback>.listener(_onTitleChanged), (p) => cb.ref.on_title_changed = p);
    _regVoid(NativeCallable<OnLoadingStateChangedCallback>.listener(_onLoadingStateChanged), (p) => cb.ref.on_loading_state_changed = p);
    _regVoid(NativeCallable<OnLoadStartCallback>.listener(_onLoadStart), (p) => cb.ref.on_load_start = p);
    _regVoid(NativeCallable<OnLoadEndCallback>.listener(_onLoadEnd), (p) => cb.ref.on_load_end = p);
    _regVoid(NativeCallable<OnLoadErrorCallback>.listener(_onLoadError), (p) => cb.ref.on_load_error = p);
    _regVoid(NativeCallable<OnAfterCreatedCallback>.listener(_onAfterCreated), (p) => cb.ref.on_after_created = p);
    _regVoid(NativeCallable<OnBeforeCloseCallback>.listener(_onBeforeClose), (p) => cb.ref.on_before_close = p);
    _regVoid(NativeCallable<OnCursorChangedCallback>.listener(_onCursorChanged), (p) => cb.ref.on_cursor_changed = p);
    _regVoid(NativeCallable<OnGotFocusCallback>.listener(_onGotFocus), (p) => cb.ref.on_got_focus = p);
    _regVoid(NativeCallable<OnDownloadUpdatedCallback>.listener(_onDownloadUpdated), (p) => cb.ref.on_download_updated = p);
    _regVoid(NativeCallable<OnBeforeContextMenuCallback>.listener(_onBeforeContextMenu), (p) => cb.ref.on_before_context_menu = p);
    _regVoid(NativeCallable<OnPaintCallback>.listener(_onPaint), (p) => cb.ref.on_paint = p);
    _regVoid(NativeCallable<GetViewRectCallback>.listener(_getViewRect), (p) => cb.ref.get_view_rect = p);
    
    // Blocking / Non-void callbacks
    cb.ref.on_before_browse = Pointer.fromFunction<OnBeforeBrowseCallback>(_onBeforeBrowse, 0);
    cb.ref.on_before_resource_load = Pointer.fromFunction<OnBeforeResourceLoadCallback>(_onBeforeResourceLoad, 0);
    cb.ref.on_before_popup = Pointer.fromFunction<OnBeforePopupCallback>(_onBeforePopup, 0);
    cb.ref.on_console_message = Pointer.fromFunction<OnConsoleMessageCallback>(_onConsoleMessage, 0);
    cb.ref.on_js_dialog = Pointer.fromFunction<OnJSDialogCallback>(_onJSDialog, 0);
    cb.ref.on_before_download = Pointer.fromFunction<OnBeforeDownloadCallback>(_onBeforeDownload, 0);

    final result = bindings.initialize(keys, vals, map.length, cb);

    for (final p in ptrs) calloc.free(p);
    calloc.free(keys);
    calloc.free(vals);
    calloc.free(cb);

    _initialized = result != 0;
    return _initialized;
  }

  void _regVoid<T extends Function>(NativeCallable<T> nc, void Function(Pointer<NativeFunction<T>>) setter) {
    _callables.add(nc);
    setter(nc.nativeFunction);
  }

  // ─── Browser API ──────────────────────────────────────────────────────────

  void registerMessageRouter(int browserId, {String queryFn = 'cefQuery', String cancelFn = 'cefQueryCancel'}) {
    using((arena) {
      bindings.messageRouterCreate(
        browserId,
        queryFn.toNativeUtf8(allocator: arena),
        cancelFn.toNativeUtf8(allocator: arena),
        Pointer.fromFunction<OnQueryCallback>(_onQuery),
        Pointer.fromFunction<OnQueryCanceledCallback>(_onQueryCanceled),
      );
    });
  }

  void _fwdQuery(int id, int qId, String req, bool persistent) {
    print('[CEF] JS Query: browser=$id id=$qId body=$req');
    // For now just echo or succeed with a placeholder
    querySuccess(id, qId, '{"status": "ok", "echo": "$req"}');
  }

  void _fwdQueryCanceled(int id, int qId) {
    print('[CEF] JS Query Canceled: $qId');
  }

  /// Returns a [Stream<PaintFrame>] for [browserId] that emits every OSR frame.
  Stream<PaintFrame> paintFrames(int browserId) {
    _paintStreams.putIfAbsent(
        browserId, () => StreamController<PaintFrame>.broadcast());
    return _paintStreams[browserId]!.stream;
  }

  /// Returns a [Stream<int>] for [browserId] that emits cursor type changes.
  Stream<int> cursorChanges(int browserId) {
    _cursorStreams.putIfAbsent(
        browserId, () => StreamController<int>.broadcast());
    return _cursorStreams[browserId]!.stream;
  }

  CefBrowser createBrowser(String url, {
    bool windowless = true,
    bool isTransparent = false,
    CefBrowserSettings? settings,
  }) {
    if (!_initialized) throw StateError('Call initialize() first.');
    if (client.isDisposed) throw StateError('CefClient is disposed.');

    final fps = settings?.windowlessFrameRate ?? 30;
    final nUrl = url.toNativeUtf8();
    bindings.createBrowser(nUrl, fps, isTransparent ? 1 : 0);
    calloc.free(nUrl);

    final browser = CefBrowser(url, windowless: windowless, settings: settings);
    return browser;
  }

  // ─── View size (must be called before first paint) ────────────────────────

  void setViewSize(int browserId, double width, double height, double dpr) {
    _viewSizes[browserId] = _ViewSize(width * dpr, height * dpr, dpr);
    bindings.setViewSize(
        browserId, (width * dpr).round(), (height * dpr).round(), dpr);
    bindings.wasResized(browserId);
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void loadUrl(int id, String url) {
    final s = url.toNativeUtf8();
    bindings.loadUrl(id, s);
    calloc.free(s);
  }

  void goBack(int id)    => bindings.goBack(id);
  void goForward(int id) => bindings.goForward(id);
  void reload(int id)    => bindings.reload(id);
  void stopLoad(int id)  => bindings.stopLoad(id);

  void closeBrowser(int id, {bool force = false}) =>
      bindings.closeBrowser(id, force ? 1 : 0);

  void executeJavaScript(int id, String code) {
    final s = code.toNativeUtf8();
    bindings.executeJavaScript(id, s);
    calloc.free(s);
  }

  void setZoomLevel(int id, double level) => bindings.setZoomLevel(id, level);
  double getZoomLevel(int id) => bindings.getZoomLevel(id);

  // ─── Focus / visibility ───────────────────────────────────────────────────

  void setFocus(int id, bool focus)         => bindings.setFocus(id, focus ? 1 : 0);
  void wasResized(int id)                   => bindings.wasResized(id);
  void wasHidden(int id, bool hidden)       => bindings.wasHidden(id, hidden ? 1 : 0);
  void invalidate(int id)                   => bindings.invalidate(id);

  // ─── Input ────────────────────────────────────────────────────────────────

  void sendMouseMove(int id, int x, int y, int mods, {bool leave = false}) =>
      bindings.sendMouseMove(id, x, y, mods, leave ? 1 : 0);

  void sendMouseClick(int id, int x, int y, int button, bool up,
      int clickCount, int mods) =>
      bindings.sendMouseClick(id, x, y, button, up ? 1 : 0, clickCount, mods);

  void sendMouseWheel(int id, int x, int y, int dx, int dy) =>
      bindings.sendMouseWheel(id, x, y, dx, dy);

  void sendKeyEvent(int id, {
    required int type,
    required int windowsKeyCode,
    required int nativeKeyCode,
    required int modifiers,
    required int character,
    required int unmodifiedCharacter,
    bool isSystemKey = false,
    bool focusOnEditableField = false,
  }) =>
      bindings.sendKeyEvent(id, type, windowsKeyCode, nativeKeyCode,
          modifiers, character, unmodifiedCharacter, isSystemKey ? 1 : 0);

  /// Commit text directly via IME (required for text input in CEF 146+).
  void imeCommitText(int id, String text) {
    final s = text.toNativeUtf8();
    bindings.imeCommitText(id, s);
    calloc.free(s);
  }

  // ─── Callbacks / cookies ──────────────────────────────────────────────────

  void respondJSDialog(int cbId, bool success, String input) {
    final s = input.toNativeUtf8();
    bindings.jsDialogResponse(cbId, success ? 1 : 0, s);
    calloc.free(s);
    _jsCbs.remove(cbId);
  }

  void respondBeforeDownload(int cbId, String path, {bool showDialog = true}) {
    final s = path.toNativeUtf8();
    bindings.beforeDownloadResponse(cbId, s, showDialog ? 1 : 0);
    calloc.free(s);
    _dlCbs.remove(cbId);
  }

  void clearAllCookies() => bindings.clearAllCookies();

  void setCookie(String url, {
    required String name, required String value,
    String domain = '', String path = '/',
    bool secure = false, bool httpOnly = false, int expires = 0,
  }) {
    final args = [url, name, value, domain, path]
        .map((s) => s.toNativeUtf8()).toList();
    bindings.setCookie(args[0], args[1], args[2], args[3], args[4],
        secure ? 1 : 0, httpOnly ? 1 : 0, expires);
    for (final a in args) calloc.free(a);
  }
  // ─── DevTools ──────────────────────────────────────────────────────────────

  void openDevTools(int id)  => bindings.openDevTools(id);
  void closeDevTools(int id) => bindings.closeDevTools(id);

  // ─── Browser state queries ────────────────────────────────────────────────

  bool canGoBack(int id)    => bindings.canGoBack(id) != 0;
  bool canGoForward(int id) => bindings.canGoForward(id) != 0;
  bool isLoading(int id)    => bindings.isLoading(id) != 0;

  String getUrl(int id) {
    final ptr = bindings.getUrl(id);
    final s = ptr.toDartString();
    calloc.free(ptr);
    return s;
  }

  String getTitle(int id) {
    final ptr = bindings.getTitle(id);
    final s = ptr.toDartString();
    calloc.free(ptr);
    return s;
  }

  // ─── Message router ──────────────────────────────────────────────────────

  void querySuccess(int browserId, int queryId, String response) {
    final s = response.toNativeUtf8();
    bindings.queryResponse(browserId, queryId, s);
    calloc.free(s);
  }

  void queryFailure(int browserId, int queryId, int errorCode, String errorMsg) {
    final s = errorMsg.toNativeUtf8();
    bindings.queryFailure(browserId, queryId, errorCode, s);
    calloc.free(s);
  }

  // ─── Message loop ─────────────────────────────────────────────────────────

  void doMessageLoopWork() => bindings.doMessageLoopWork();
  void runMessageLoop()     => bindings.runMessageLoop();
  void quitMessageLoop()    => bindings.quitMessageLoop();

  // ─── Shutdown ─────────────────────────────────────────────────────────────

  void shutdown() {
    if (!_initialized) return;
    for (final sc in _paintStreams.values) sc.close();
    _paintStreams.clear();
    client.dispose();
    bindings.shutdown();
    _initialized = false;
    _activeClient = null;
  }

  bool get isInitialized => _initialized;

  // ─── Internal callback forwarders ─────────────────────────────────────────

  void _fwdUrlChanged(int id, String url) =>
      client.dispatchOnAddressChange(_browsers[id] ?? _stub, _noFrame, url);

  void _fwdTitleChanged(int id, String title) =>
      client.dispatchOnTitleChange(_browsers[id] ?? _stub, title);

  void _fwdLoadingStateChanged(int id, bool l, bool back, bool fwd) =>
      client.dispatchOnLoadingStateChange(
          _browsers[id] ?? _stub, l, back, fwd);

  void _fwdLoadStart(int id, String frameId, int transition) =>
      client.dispatchOnLoadStart(_browsers[id] ?? _stub, _StubFrame(frameId), transition);

  void _fwdLoadEnd(int id, String frameId, int status) =>
      client.dispatchOnLoadEnd(_browsers[id] ?? _stub, _StubFrame(frameId), status);

  void _fwdLoadError(int id, String frameId, int code, String text, String url) =>
      client.dispatchOnLoadError(_browsers[id] ?? _stub, _StubFrame(frameId),
          CefErrorCode.findByCode(code), text, url);

  void _fwdAfterCreated(int id) {
    final browser = CefBrowser('', windowless: true)..nativeBrowserId = id;
    _browsers[id] = browser;
    _paintStreams.putIfAbsent(
        id, () => StreamController<PaintFrame>.broadcast());
    client.dispatchOnAfterCreated(browser);
  }

  void _fwdBeforeClose(int id) {
    final b = _browsers[id] ?? _stub;
    client.dispatchOnBeforeClose(b);
    _browsers.remove(id);
    _viewSizes.remove(id);
    _paintStreams[id]?.close();
    _paintStreams.remove(id);
    _cursorStreams[id]?.close();
    _cursorStreams.remove(id);
  }

  bool _fwdBeforePopup(int id, String url, String name) =>
      client.dispatchOnBeforePopup(_browsers[id] ?? _stub, _noFrame, url, name);

  void _fwdCursorChanged(int id, int type) {
    // Emit to the cursor stream so widgets can track cursor changes
    _cursorStreams[id]?.add(type);
    client.dispatchOnCursorChange(_browsers[id] ?? _stub, type);
  }

  void _fwdGotFocus(int id) =>
      client.dispatchOnGotFocus(_browsers[id] ?? _stub);

  bool _fwdConsoleMessage(int id, int level, String msg, String src, int line) =>
      false; // TODO: map level to CefLogSeverity

  bool _fwdJSDialog(int id, String origin, int type, String msg,
      String prompt, int cbId) {
    final cb = _NativeJSCb(this, cbId);
    _jsCbs[cbId] = cb;
    return client.dispatchOnJSDialog(
      _browsers[id] ?? _stub, origin,
      CefJSDialogType.values[type.clamp(0, 2)],
      msg, prompt, cb,
    );
  }

  bool _fwdBeforeDownload(int id, int dlId, String url,
      String name, int cbId) {
    final cb = _NativeDlCb(this, cbId);
    _dlCbs[cbId] = cb;
    return client.dispatchOnBeforeDownload(
      _browsers[id] ?? _stub,
      _StubDownloadItem(dlId, url, name),
      name, cb,
    );
  }

  void _fwdDownloadUpdated(int id, int dlId, int pct, bool done, bool canceled) {
    // TODO: full download tracking
  }

  bool _fwdBeforeBrowse(int id, String url, bool isRedirect) {
    print('[CEF] OnBeforeBrowse (Dart): $url (Redirect: $isRedirect)');
    return false;
  }

  bool _fwdBeforeResourceLoad(int id, String url, String method) {
    return false;
  }

  void _fwdBeforeContextMenu(int id, int x, int y) {
    print('[CEF] OnBeforeContextMenu (Dart) at $x,$y');
  }

  /// The hot path: copy BGRA buffer and push to the per-browser stream.
  void _fwdPaint(int id, bool isPopup, Uint8List pixels, int w, int h) {
    _paintStreams[id]?.add(PaintFrame(
      pixels: pixels,
      width:  w,
      height: h,
      isPopup: isPopup,
    ));
  }

  // ─── Stubs ────────────────────────────────────────────────────────────────
  static final CefBrowser _stub   = CefBrowser('');
  static final CefFrame   _noFrame = _StubFrame();
}

// ─── Inline stub implementations ─────────────────────────────────────────────

class _StubFrame implements CefFrame {
  final String? _id;
  _StubFrame([this._id]);

  @override void dispose() {}
  @override String? getIdentifier() => _id;
  @override String getURL() => '';
  @override String getName() => '';
  @override bool isMain() => true;
  @override bool isValid() => false;
  @override bool isFocused() => false;
  @override CefFrame? getParent() => null;
  @override void executeJavaScript(String code, String url, int line) {}
  @override void undo() {}
  @override void redo() {}
  @override void cut() {}
  @override void copy() {}
  @override void paste() {}
  @override void delete() {}
  @override void selectAll() {}
}

class _NativeJSCb implements CefJSDialogCallback {
  final CefNativeClient _c;
  final int _id;
  _NativeJSCb(this._c, this._id);
  @override
  void onContinue(bool success, String input) =>
      _c.respondJSDialog(_id, success, input);
}

class _NativeDlCb implements CefBeforeDownloadCallback {
  final CefNativeClient _c;
  final int _id;
  _NativeDlCb(this._c, this._id);
  @override
  void onContinue(String path, bool show) =>
      _c.respondBeforeDownload(_id, path, showDialog: show);
}

class _StubDownloadItem implements CefDownloadItem {
  final int _id;
  final String _url;
  final String _name;
  _StubDownloadItem(this._id, this._url, this._name);
  @override bool isValid()       => true;
  @override bool isInProgress()  => true;
  @override bool isComplete()    => false;
  @override bool isCanceled()    => false;
  @override int getCurrentSpeed()   => 0;
  @override int getPercentComplete()=> 0;
  @override int getTotalBytes()     => 0;
  @override int getReceivedBytes()  => 0;
  @override DateTime getStartTime() => DateTime.now();
  @override DateTime getEndTime()   => DateTime.now();
  @override String getFullPath()    => '';
  @override int getId()             => _id;
  @override String getURL()         => _url;
  @override String getSuggestedFileName() => _name;
  @override String getContentDisposition()=> '';
  @override String getMimeType()    => '';
}
