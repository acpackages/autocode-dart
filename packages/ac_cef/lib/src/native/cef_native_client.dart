import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import '../cef_browser.dart';
import '../cef_browser_settings.dart';
import '../cef_client.dart';
import '../cef_frame.dart';
import '../cef_menu_model.dart';
import '../cef_message_router.dart';
import '../cef_settings.dart';
import '../handler/cef_context_menu_handler.dart';
import '../handler/cef_download_handler.dart';
import '../handler/cef_js_dialog_handler.dart';
import '../handler/cef_keyboard_handler.dart';
import '../handler/cef_life_span_handler.dart';
import '../handler/cef_load_handler.dart';
import '../handler/cef_request_handler.dart';
import '../handler/cef_find_handler.dart';
import '../network/cef_request.dart';
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
int  _onBeforePopup(int id, Pointer<Utf8> url, Pointer<Utf8> name,
    int disposition, int userGesture) =>
    (_activeClient?._fwdBeforePopup(
            id, _safeString(url), _safeString(name),
            disposition, userGesture != 0) ?? false)
        ? 1 : 0;
void _onCursorChanged(int id, int type) =>
    _activeClient?._fwdCursorChanged(id, type);
void _onGotFocus(int id) => _activeClient?._fwdGotFocus(id);
void _onStatusMessage(int id, Pointer<Utf8> value) =>
    _activeClient?._fwdStatusMessage(id, _safeString(value));
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

int _onBeforeBrowse(int id, Pointer<Utf8> url, int isRedirect, int userGesture) =>
    (_activeClient?._fwdBeforeBrowse(
            id, _safeString(url), isRedirect != 0, userGesture != 0) ?? false)
        ? 1 : 0;
int _onBeforeResourceLoad(int id, Pointer<Utf8> url, Pointer<Utf8> method) =>
    (_activeClient?._fwdBeforeResourceLoad(id, _safeString(url), _safeString(method)) ?? false)
        ? 1 : 0;
void _onBeforeContextMenu(
    int id, int x, int y,
    int count,
    Pointer<Int32> commandIds,
    Pointer<Pointer<Utf8>> labels,
    Pointer<Int32> itemTypes,
    Pointer<Int32> enabledFlags,
    Pointer<Int32> checkedFlags,
    // CefContextMenuParams fields
    Pointer<Utf8> linkUrl,
    Pointer<Utf8> pageUrl,
    Pointer<Utf8> frameUrl,
    Pointer<Utf8> sourceUrl,
    Pointer<Utf8> selectionText,
    Pointer<Utf8> misspelledWord,
    int mediaType,
    int typeFlags,
    int mediaStateFlags,
    int editStateFlags,
    int isEditable,
    int hasImageContents) {
  // Copy all data out of C-owned memory before the callback returns.
  final ids      = List<int>.generate(count, (i) => commandIds[i]);
  final lbls     = List<String>.generate(
      count, (i) => labels[i] == nullptr ? '' : labels[i].toDartString());
  final types    = List<int>.generate(count, (i) => itemTypes[i]);
  final enabled  = List<bool>.generate(count, (i) => enabledFlags[i] != 0);
  final checked  = List<bool>.generate(count, (i) => checkedFlags[i] != 0);
  _activeClient?._fwdBeforeContextMenu(
    id, x, y, ids, lbls, types, enabled, checked,
    _safeString(linkUrl), _safeString(pageUrl),
    _safeString(frameUrl), _safeString(sourceUrl),
    _safeString(selectionText), _safeString(misspelledWord),
    mediaType, typeFlags, mediaStateFlags, editStateFlags,
    isEditable != 0, hasImageContents != 0,
  );
}

void _onQuery(int id, int qId, Pointer<Utf8> req, int persistent) =>
    _activeClient?._fwdQuery(id, qId, _safeString(req), persistent != 0);
void _onQueryCanceled(int id, int qId) =>
    _activeClient?._fwdQueryCanceled(id, qId);

final Map<int, List<Uint8List>> _paintBufferPool = {};
final Map<int, int> _paintBufferIndex = {};

/// Called by C for every paint frame.  [buffer] is valid only during this call.
/// [dirty] is a flat pointer to dirty_count * 4 ints (x, y, w, h per rect).
void _onPaint(int id, int isPopup, Pointer<Void> buffer, int w, int h,
    Pointer<Int32> dirty, int dirtyCount) {
  final client = _activeClient;
  if (client == null) return;
  final reqLen = w * h * 4;
  if (reqLen <= 0) return;
  final bytes = buffer.cast<Uint8>().asTypedList(reqLen);

  // Reusable double-buffer per browser ID to eliminate ~500 MB/s heap churn
  final pool = _paintBufferPool.putIfAbsent(
      id, () => [Uint8List(reqLen), Uint8List(reqLen)]);
  if (pool[0].length != reqLen) {
    pool[0] = Uint8List(reqLen);
    pool[1] = Uint8List(reqLen);
  }
  final idx = (_paintBufferIndex[id] ?? 0) ^ 1;
  _paintBufferIndex[id] = idx;
  final copy = pool[idx];
  copy.setRange(0, reqLen, bytes);

  // Parse dirty rects from the flat int array.
  final rects = <DirtyRect>[];
  if (dirty != nullptr && dirtyCount > 0) {
    for (int i = 0; i < dirtyCount; i++) {
      final base = i * 4;
      rects.add((
        x: dirty[base],
        y: dirty[base + 1],
        width:  dirty[base + 2],
        height: dirty[base + 3],
      ));
    }
  }
  client._fwdPaint(id, isPopup != 0, copy, w, h, rects);
}

void _onPopupShow(int id, int show) =>
    _activeClient?._fwdPopupShow(id, show != 0);
void _onPopupSize(int id, int x, int y, int w, int h) =>
    _activeClient?._fwdPopupSize(id, x, y, w, h);

// ─── Session 3 top-level callbacks ───────────────────────────────────────────

void _onFullscreenModeChange(int id, int fullscreen) =>
    _activeClient?._fwdFullscreenModeChange(id, fullscreen != 0);

int _onDoClose(int id) => (_activeClient?._fwdDoClose(id) ?? false) ? 1 : 0;

void _onLoadingProgressChange(int id, double progress) =>
    _activeClient?._fwdLoadingProgressChange(id, progress);

void _onFaviconUrlChange(int id, Pointer<Utf8> urlsFlat) {
  if (urlsFlat == nullptr) {
    _activeClient?._fwdFaviconUrlChange(id, const []);
    return;
  }
  try {
    final raw  = urlsFlat.toDartString();
    final urls = raw.split('\n').where((s) => s.isNotEmpty).toList();
    _activeClient?._fwdFaviconUrlChange(id, urls);
  } on FormatException {
    // CEF can occasionally emit non-UTF-8 bytes for the favicon URL
    // (e.g. during early/transient browser states). Swallow the error
    // and forward an empty list so the app stays alive.
    _activeClient?._fwdFaviconUrlChange(id, const []);
  }
}

/// OnPreKeyEvent: returns 1 to consume the event. Writes isShortcut out-param.
int _onPreKeyEvent(int id, int type, int wk, int nk, int mods,
    int ch, int uch, int sys, Pointer<Int32> isShortcutOut) {
  final client = _activeClient;
  if (client == null) return 0;
  final (handled, shortcut) = client._fwdPreKeyEvent(id, type, wk, nk, mods, ch, uch, sys != 0);
  if (isShortcutOut != nullptr) isShortcutOut.value = shortcut ? 1 : 0;
  return handled ? 1 : 0;
}

/// OnKeyEvent: returns 1 to indicate the event was handled.
int _onKeyEvent(int id, int type, int wk, int nk, int mods,
    int ch, int uch, int sys) =>
    (_activeClient?._fwdKeyEvent(id, type, wk, nk, mods, ch, uch, sys != 0) ?? false) ? 1 : 0;

/// OnCertificateError: returns 1 to indicate we will handle it asynchronously.
int _onCertificateError(int id, int certError, Pointer<Utf8> url, int cbId) =>
    (_activeClient?._fwdCertificateError(id, certError, _safeString(url), cbId) ?? false) ? 1 : 0;

// ─── Session 7 top-level callbacks ──────────────────────────────────────────────────

/// OnRenderProcessTerminated: void — dispatched to CefRequestHandler.
void _onRenderProcessTerminated(int id, int status, int errorCode, Pointer<Utf8> errorString) =>
    _activeClient?._fwdRenderProcessTerminated(
        id, status, errorCode, _safeString(errorString));

/// OnBeforeUnloadDialog: returns 1 when Dart handles it.
/// Dart must respond via ac_cef_js_dialog_response (shared with JSDialog).
int _onBeforeUnloadDialog(int id, Pointer<Utf8> msg, int isReload, int cbId) =>
    (_activeClient?._fwdBeforeUnloadDialog(
        id, _safeString(msg), isReload != 0, cbId) ?? false) ? 1 : 0;

/// OnTooltip: returns 1 if Dart suppresses the default tooltip.
int _onTooltip(int id, Pointer<Utf8> text) =>
    (_activeClient?._fwdTooltip(id, _safeString(text)) ?? false) ? 1 : 0;

/// OnFindResult: delivers find-in-page match info to Dart.
void _onFindResult(int id, int identifier, int count,
    int activeMatchOrdinal,
    int selX, int selY, int selW, int selH,
    int finalUpdate) {
  _activeClient?._fwdFindResult(id, identifier, count,
      activeMatchOrdinal, selX, selY, selW, selH, finalUpdate != 0);
}

/// Called by C to query the view rect for this browser.
/// Returns LOGICAL pixels — CEF multiplies by device_scale_factor internally
/// to determine the physical paint buffer size.
void _getViewRect(int id, Pointer<Int32> x, Pointer<Int32> y,
    Pointer<Int32> w, Pointer<Int32> h) {
  final size = _activeClient?._viewSizes[id];
  x.value = 0;
  y.value = 0;
  // _viewSizes now stores logical width/height directly (after the fix to
  // setViewSize). Round to int for the out-parameters.
  w.value = size?.width.round()  ?? 800;
  h.value = size?.height.round() ?? 600;
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

  // browser-id → StreamController for popup show/size events
  final Map<int, StreamController<CefPopupEvent>> _popupEventStreams = {};

  // pending JS / download callback IDs → Dart closures
  final Map<int, CefJSDialogCallback>       _jsCbs  = {};
  final Map<int, CefBeforeDownloadCallback> _dlCbs  = {};

  // pending certificate-error callback IDs
  final Map<int, CefCallback> _certCbs = {};

  // active download-item callbacks keyed by download_id
  final Map<int, CefDownloadItemCallback> _dlItemCbs = {};

  // browser-id → user-registered JS query handler
  final Map<int, CefMessageRouterHandler> _queryHandlers = {};

  // JS eval completers keyed by eval-id string (e.g. '__cef_eval__:3')
  final Map<String, Completer<String>> _evalCompleters = {};
  int _evalCounter = 0;

  // Keep NativeCallables alive
  final List<NativeCallable> _callables = [];

  CefNativeClient({required this.bindings, required this.client});

  // ─── Initialization ────────────────────────────────────────────────────────

  bool initialize([CefSettings? settings]) {
    if (_initialized) return true;
    // ── Singleton guard ─────────────────────────────────────────────────────
    // CEF only supports one CefApp per process. If another CefNativeClient is
    // already active (i.e. initialize() was called and shutdown() not yet
    // called) we refuse to proceed rather than silently overwriting the global
    // callback pointer and corrupting the running instance.
    if (_activeClient != null && _activeClient != this) {
      throw StateError(
        'A CefNativeClient is already active in this process. '
        'Call shutdown() on the existing instance before creating a new one. '
        'CEF only supports one CefApp per process.');
    }
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

    // ── String-passing callbacks: .isolateLocal so Dart reads the const char*
    // synchronously while the C++ stack frame is still alive.
    // (NativeCallable.listener is async — the pointer is freed before Dart runs.)
    _regVoid(NativeCallable<OnUrlChangedCallback>.isolateLocal(_onUrlChanged), (p) => cb.ref.on_url_changed = p);
    _regVoid(NativeCallable<OnTitleChangedCallback>.isolateLocal(_onTitleChanged), (p) => cb.ref.on_title_changed = p);
    _regVoid(NativeCallable<OnLoadStartCallback>.isolateLocal(_onLoadStart), (p) => cb.ref.on_load_start = p);
    _regVoid(NativeCallable<OnLoadEndCallback>.isolateLocal(_onLoadEnd), (p) => cb.ref.on_load_end = p);
    _regVoid(NativeCallable<OnLoadErrorCallback>.isolateLocal(_onLoadError), (p) => cb.ref.on_load_error = p);
    _regVoid(NativeCallable<OnStatusMessageCallback>.isolateLocal(_onStatusMessage), (p) => cb.ref.on_status_message = p);
    _regVoid(NativeCallable<OnBeforeContextMenuCallback>.isolateLocal(_onBeforeContextMenu), (p) => cb.ref.on_before_context_menu = p);
    _regVoid(NativeCallable<OnFaviconUrlChangeCallback>.isolateLocal(_onFaviconUrlChange), (p) => cb.ref.on_favicon_url_change = p);
    _regVoid(NativeCallable<OnRenderProcessTerminatedCallback>.isolateLocal(_onRenderProcessTerminated), (p) => cb.ref.on_render_process_terminated = p);
    _regVoid(NativeCallable<OnDownloadUpdatedCallback>.isolateLocal(_onDownloadUpdated), (p) => cb.ref.on_download_updated = p);

    // GetViewRect writes to out-params synchronously — must also be .isolateLocal.
    _regVoid(NativeCallable<GetViewRectCallback>.isolateLocal(_getViewRect), (p) => cb.ref.get_view_rect = p);

    // ── Integer-only callbacks: .listener is fine (no pointer args).
    _regVoid(NativeCallable<OnLoadingStateChangedCallback>.listener(_onLoadingStateChanged), (p) => cb.ref.on_loading_state_changed = p);
    _regVoid(NativeCallable<OnAfterCreatedCallback>.listener(_onAfterCreated), (p) => cb.ref.on_after_created = p);
    _regVoid(NativeCallable<OnBeforeCloseCallback>.listener(_onBeforeClose), (p) => cb.ref.on_before_close = p);
    _regVoid(NativeCallable<OnCursorChangedCallback>.listener(_onCursorChanged), (p) => cb.ref.on_cursor_changed = p);
    _regVoid(NativeCallable<OnGotFocusCallback>.listener(_onGotFocus), (p) => cb.ref.on_got_focus = p);
    _regVoid(NativeCallable<OnPopupShowCallback>.listener(_onPopupShow), (p) => cb.ref.on_popup_show = p);
    _regVoid(NativeCallable<OnPopupSizeCallback>.listener(_onPopupSize), (p) => cb.ref.on_popup_size = p);
    // OnPaint passes a raw pixel buffer pointer. Use .isolateLocal so the
    // handler runs synchronously on the Dart thread before C++ returns from
    // OnPaint — this ensures we copy the buffer while it is still valid.
    // This is safe because OnPaint is always called from CefDoMessageLoopWork(),
    // which is driven by our Dart timer on the Dart isolate thread.
    _regVoid(NativeCallable<OnPaintCallback>.isolateLocal(_onPaint), (p) => cb.ref.on_paint = p);
    _regVoid(NativeCallable<OnFullscreenModeChangeCallback>.listener(_onFullscreenModeChange),
             (p) => cb.ref.on_fullscreen_mode_change = p);
    _regVoid(NativeCallable<OnLoadingProgressChangeCallback>.listener(_onLoadingProgressChange),
             (p) => cb.ref.on_loading_progress_change = p);

    // Session 3: pre-key / key-event / cert-error (return int → Pointer.fromFunction)
    cb.ref.on_pre_key_event     = Pointer.fromFunction<OnPreKeyEventCallback>(_onPreKeyEvent, 0);
    cb.ref.on_key_event         = Pointer.fromFunction<OnKeyEventCallback>(_onKeyEvent, 0);
    cb.ref.on_certificate_error = Pointer.fromFunction<OnCertificateErrorCallback>(_onCertificateError, 0);
    // Session 7: before-unload-dialog and tooltip (return int → Pointer.fromFunction)
    cb.ref.on_before_unload_dialog =
        Pointer.fromFunction<OnBeforeUnloadDialogCallback>(_onBeforeUnloadDialog, 0);
    cb.ref.on_tooltip =
        Pointer.fromFunction<OnTooltipCallback>(_onTooltip, 0);
    // Session 15: find result
    cb.ref.on_find_result =
        Pointer.fromFunction<OnFindResultCallback>(_onFindResult);

    // Blocking / Non-void callbacks
    cb.ref.on_before_browse = Pointer.fromFunction<OnBeforeBrowseCallback>(_onBeforeBrowse, 0);
    cb.ref.on_before_resource_load = Pointer.fromFunction<OnBeforeResourceLoadCallback>(_onBeforeResourceLoad, 0);
    cb.ref.on_before_popup = Pointer.fromFunction<OnBeforePopupCallback>(_onBeforePopup, 0);
    cb.ref.on_console_message = Pointer.fromFunction<OnConsoleMessageCallback>(_onConsoleMessage, 0);
    cb.ref.on_js_dialog = Pointer.fromFunction<OnJSDialogCallback>(_onJSDialog, 0);
    cb.ref.on_before_download = Pointer.fromFunction<OnBeforeDownloadCallback>(_onBeforeDownload, 0);
    cb.ref.on_do_close = Pointer.fromFunction<OnDoCloseCallback>(_onDoClose, 0);

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

  /// Register a [CefMessageRouterHandler] for [browserId].
  ///
  /// The handler receives every `window.cefQuery(...)` call from JavaScript
  /// and must call [CefQueryCallback.success] or [CefQueryCallback.failure].
  void registerQueryHandler(int browserId, CefMessageRouterHandler handler) {
    _queryHandlers[browserId] = handler;
  }

  /// Remove a previously registered query handler.
  void removeQueryHandler(int browserId) {
    _queryHandlers.remove(browserId);
  }

  // ── JS eval via cefQuery piggyback ─────────────────────────────────────────

  /// Evaluates [expression] in the context of [browserId] and returns the
  /// string representation of the result.
  ///
  /// Works by injecting a small JS wrapper that calls `window.cefQuery` with
  /// a special `__cef_eval__:<id>` prefix.  The internal handler intercepts
  /// these queries before user-registered handlers see them, so user code is
  /// not affected.
  ///
  /// Throws if [browserId] is not known or CEF is not initialised.
  Future<String> evalJavaScript(int browserId, String expression) {
    final evalId = '__cef_eval__:${_evalCounter++}';
    final completer = Completer<String>();
    _evalCompleters[evalId] = completer;
    // Wrap expression so errors are also reported back via cefQuery.
    final safe = expression.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
    executeJavaScript(browserId, '''
(function(){
  try {
    var __r = (function(){ return ($safe); })();
    window.cefQuery({request:'$evalId:'+String(__r),
      onSuccess:function(){},onFailure:function(){}});
  } catch(e) {
    window.cefQuery({request:'$evalId:ERROR:'+e.message,
      onSuccess:function(){},onFailure:function(){}});
  }
})();
''');
    return completer.future;
  }

  /// Evaluates [expression] and parses the result as an [int].
  /// Throws if the JS expression throws or the result is not a valid integer.
  Future<int> evalJavaScriptInt(int browserId, String expression) async {
    final s = await evalJavaScript(browserId, 'Math.trunc($expression)');
    return int.parse(s.contains('.') ? s.split('.').first : s);
  }

  /// Evaluates [expression] and parses the result as a [double].
  Future<double> evalJavaScriptDouble(int browserId, String expression) async =>
      double.parse(await evalJavaScript(browserId, 'Number($expression)'));

  /// Evaluates [expression] and parses the result as a [bool].
  /// The JS expression must produce a truthy/falsy value.
  Future<bool> evalJavaScriptBool(int browserId, String expression) async =>
      (await evalJavaScript(browserId, '!!($expression)')) == 'true';

  /// Evaluates [expression], which must produce a JSON-serialisable value.
  /// Returns the parsed Dart object (Map, List, String, num, bool, or null).
  Future<Object?> evalJavaScriptJson(int browserId, String expression) async {
    final s = await evalJavaScript(
        browserId, 'JSON.stringify($expression)');
    return jsonDecode(s);
  }

  void _fwdQuery(int id, int qId, String req, bool persistent) {
    // ── Intercept internal JS-eval replies ─────────────────────────────────
    if (req.startsWith('__cef_eval__:')) {
      final colon2 = req.indexOf(':', '__cef_eval__:'.length);
      if (colon2 >= 0) {
        final evalId = req.substring(0, colon2);
        final value  = req.substring(colon2 + 1);
        final c = _evalCompleters.remove(evalId);
        if (c != null) {
          if (value.startsWith('ERROR:')) {
            c.completeError(value.substring(6));
          } else {
            c.complete(value);
          }
        }
      }
      // Respond with empty success so the cefQuery JS promise resolves.
      _NativeQueryCb(this, id, qId).success('');
      return;
    }
    // ── Normal user-registered handler path ────────────────────────────────
    final handler = _queryHandlers[id];
    final browser = _browsers[id] ?? _stub;
    final cb = _NativeQueryCb(this, id, qId);
    if (handler != null) {
      final handled = handler.onQuery(browser, qId, req, persistent, cb);
      if (!handled) {
        cb.failure(-1, 'Query not handled');
      }
    } else {
      cb.success('');
    }
  }

  void _fwdQueryCanceled(int id, int qId) {
    _queryHandlers[id]?.onQueryCanceled(_browsers[id] ?? _stub, qId);
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

  /// Returns a [Stream<CefPopupEvent>] for [browserId] with popup show/size events.
  Stream<CefPopupEvent> popupEvents(int browserId) {
    _popupEventStreams.putIfAbsent(
        browserId, () => StreamController<CefPopupEvent>.broadcast());
    return _popupEventStreams[browserId]!.stream;
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

    final browser = CefBrowser(url, windowless: windowless, settings: settings, nativeClient: this);
    return browser;
  }

  // ─── View size (must be called before first paint) ────────────────────────

  void setViewSize(int browserId, double width, double height, double dpr) {
    // Store LOGICAL dimensions (width, height are already in logical pixels).
    // The C bridge receives PHYSICAL pixels so it can pass them to
    // ac_cef_set_view_size, which divides by dpr to recover the logical size
    // and stores it in BrowserInfo for GetViewRect.
    _viewSizes[browserId] = _ViewSize(width, height, dpr);
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
  void reloadIgnoreCache(int id) => bindings.reloadIgnoreCache(id);
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

  // ─── Find in page ─────────────────────────────────────────────────────────

  /// Start or continue a find-in-page search.
  ///
  /// Set [findNext] to `false` for a new search and `true` to move to the
  /// next/previous match.
  void find(int id, String searchText, {
    bool forward   = true,
    bool matchCase = false,
    bool findNext  = false,
  }) {
    final s = searchText.toNativeUtf8();
    bindings.find(id, s,
        forward    ? 1 : 0,
        matchCase  ? 1 : 0,
        findNext   ? 1 : 0);
    calloc.free(s);
  }

  /// Stop the current find-in-page search.
  void stopFind(int id, {bool clearSelection = true}) =>
      bindings.stopFind(id, clearSelection ? 1 : 0);

  // ─── Audio ────────────────────────────────────────────────────────────────

  /// Mute or unmute the browser's audio output.
  void setAudioMuted(int id, bool muted) =>
      bindings.setAudioMuted(id, muted ? 1 : 0);

  /// Returns `true` if the browser's audio is currently muted.
  bool isAudioMuted(int id) => bindings.isAudioMuted(id) != 0;

  // ─── LoadRequest ──────────────────────────────────────────────────────────

  /// Load [url] using [method] (e.g. `'POST'`) with optional [body] and [headers].
  ///
  /// [body] is encoded as UTF-8 bytes before being sent.  Pass `null` or an
  /// empty string for requests that have no body (e.g. GET).
  void loadRequest(int id, String url,
      {String method = 'GET', String? body, Map<String, String>? headers}) {
    using((arena) {
      final urlPtr  = url.toNativeUtf8(allocator: arena);
      final mthPtr  = method.toNativeUtf8(allocator: arena);
      Pointer<Utf8> hdrPtr = nullptr;
      if (headers != null && headers.isNotEmpty) {
        final sb = StringBuffer();
        for (final entry in headers.entries) {
          sb.write('${entry.key}\n${entry.value}\n');
        }
        hdrPtr = sb.toString().toNativeUtf8(allocator: arena);
      }
      if (body == null || body.isEmpty) {
        bindings.loadRequest(id, urlPtr, mthPtr, nullptr, 0, hdrPtr);
      } else {
        final bytes  = utf8.encode(body);
        final bufPtr = arena<Uint8>(bytes.length);
        for (int i = 0; i < bytes.length; i++) bufPtr[i] = bytes[i];
        bindings.loadRequest(
            id, urlPtr, mthPtr, bufPtr.cast<Utf8>(), bytes.length, hdrPtr);
      }
    });
  }

  // ─── Async source / text ──────────────────────────────────────────────────

  /// Returns the HTML source of the main frame.
  Future<String> getSource(int id) {
    final completer = Completer<String>();
    late NativeCallable<OnStringVisitCallbackNative> nc;
    nc = NativeCallable<OnStringVisitCallbackNative>.isolateLocal(
      (int cbId, Pointer<Utf8> text) {
        completer.complete(_safeString(text));
        nc.close();
      },
    );
    _callables.add(nc); // prevent GC until close() is called
    bindings.getSource(id, 0, nc.nativeFunction);
    return completer.future;
  }

  /// Returns the plain-text content of the main frame.
  Future<String> getText(int id) {
    final completer = Completer<String>();
    late NativeCallable<OnStringVisitCallbackNative> nc;
    nc = NativeCallable<OnStringVisitCallbackNative>.isolateLocal(
      (int cbId, Pointer<Utf8> text) {
        completer.complete(_safeString(text));
        nc.close();
      },
    );
    _callables.add(nc);
    bindings.getText(id, 0, nc.nativeFunction);
    return completer.future;
  }

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

  /// Set the IME composition string shown in the renderer.
  /// [cursorPos] is the caret position within [text] (0-based code-unit index).
  /// Pass -1 to place the caret at the end.
  void imeSetComposition(int id, String text, {int cursorPos = -1,
      int selectionStart = -1, int selectionEnd = -1}) {
    final s = text.toNativeUtf8();
    bindings.imeSetComposition(id, s, cursorPos, selectionStart, selectionEnd);
    calloc.free(s);
  }

  /// Cancel any active IME composition without committing.
  void imeCancelComposition(int id) => bindings.imeCancelComposition(id);

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

  // ─── Download cancel / pause / resume ────────────────────────────────────

  /// Cancel an active download identified by [downloadId].
  void cancelDownload(int browserId, int downloadId) =>
      bindings.cancelDownload(browserId, downloadId);

  /// Pause an active download identified by [downloadId].
  void pauseDownload(int browserId, int downloadId) =>
      bindings.pauseDownload(browserId, downloadId);

  /// Resume a paused download identified by [downloadId].
  void resumeDownload(int browserId, int downloadId) =>
      bindings.resumeDownload(browserId, downloadId);

  // ─── Print to PDF ────────────────────────────────────────────────────────────

  /// Print the page at [browserId] to a PDF at [path].
  ///
  /// [onDone] is called on the Dart thread when printing completes.
  /// [ok] is true if the file was written successfully.
  void printToPdf(
      int browserId, String path, void Function(bool ok) onDone) {
    // Use a late variable so the callback can close and remove itself.
    late final NativeCallable<OnPrintToPdfCallback> nc;
    nc = NativeCallable<OnPrintToPdfCallback>.listener(
        (int bid, Pointer<Utf8> pathPtr, int ok) {
          onDone(ok != 0);
          // Release the NativeCallable once the PDF is done — it is a one-shot.
          nc.close();
          _callables.remove(nc);
        });
    _callables.add(nc);
    final s = path.toNativeUtf8();
    bindings.printToPdf(browserId, s, nc.nativeFunction);
    calloc.free(s);
  }

  // ─── Certificate error response ───────────────────────────────────────────

  /// Respond to a certificate error.
  /// Set [allow] to true to proceed despite the error; false to cancel.
  void respondCertError(int callbackId, bool allow) {
    bindings.certificateErrorResponse(callbackId, allow ? 1 : 0);
    _certCbs.remove(callbackId);
  }

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

  /// Raw access — call once per frame inside your own timer or render loop.
  void doMessageLoopWork() => bindings.doMessageLoopWork();
  void runMessageLoop()     => bindings.runMessageLoop();
  void quitMessageLoop()    => bindings.quitMessageLoop();

  Timer? _pumpTimer;

  /// Starts a built-in 1 ms periodic timer that calls [doMessageLoopWork]
  /// on every tick.  This is the simplest way to drive the CEF message loop
  /// without managing your own timer.
  ///
  /// Calling this multiple times is safe — only one timer runs at a time.
  /// The pump is automatically stopped by [shutdown].
  void startMessagePump() {
    _pumpTimer ??= Timer.periodic(
      const Duration(milliseconds: 1),
      (_) => doMessageLoopWork(),
    );
  }

  /// Stops the timer started by [startMessagePump].
  void stopMessagePump() {
    _pumpTimer?.cancel();
    _pumpTimer = null;
  }

  // ─── Shutdown ─────────────────────────────────────────────────────────────

  void shutdown() {
    if (!_initialized) return;
    stopMessagePump();
    for (final sc in _paintStreams.values)       sc.close();
    for (final sc in _cursorStreams.values)      sc.close();
    for (final sc in _popupEventStreams.values)  sc.close();
    _paintStreams.clear();
    _cursorStreams.clear();
    _popupEventStreams.clear();
    client.dispose();
    bindings.shutdown();
    _initialized = false;
    _activeClient = null;
  }

  bool get isInitialized => _initialized;

  /// True if any [CefNativeClient] has called [initialize] and not yet [shutdown].
  /// Useful to guard against accidental double-initialization.
  static bool get hasActiveClient => _activeClient != null;

  /// Returns the currently active [CefNativeClient] instance, or null.
  static CefNativeClient? get activeClient => _activeClient;

  // ─── Internal callback forwarders ─────────────────────────────────────────

  void _fwdUrlChanged(int id, String url) =>
      client.dispatchOnAddressChange(_browsers[id] ?? _stub, _noFrame, url);

  void _fwdTitleChanged(int id, String title) =>
      client.dispatchOnTitleChange(_browsers[id] ?? _stub, title);

  void _fwdLoadingProgressChange(int id, double progress) =>
      client.dispatchOnLoadingProgressChange(_browsers[id] ?? _stub, progress);

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
    final browser = CefBrowser('', windowless: true, nativeClient: this)..nativeBrowserId = id;
    _browsers[id] = browser;
    _paintStreams.putIfAbsent(
        id, () => StreamController<PaintFrame>.broadcast());
    client.dispatchOnAfterCreated(browser);
  }

  bool _fwdDoClose(int id) =>
      client.dispatchDoClose(_browsers[id] ?? _stub);

  void _fwdBeforeClose(int id) {
    final b = _browsers[id] ?? _stub;
    client.dispatchOnBeforeClose(b);
    _browsers.remove(id);
    _viewSizes.remove(id);
    _paintStreams[id]?.close();
    _paintStreams.remove(id);
    _cursorStreams[id]?.close();
    _cursorStreams.remove(id);
    _popupEventStreams[id]?.close();
    _popupEventStreams.remove(id);
    _paintBufferPool.remove(id);
    _paintBufferIndex.remove(id);
  }

  bool _fwdBeforePopup(int id, String url, String name,
      int disposition, bool userGesture) {
    final disp = CefWindowOpenDisposition.values[
        disposition.clamp(0, CefWindowOpenDisposition.values.length - 1)];
    return client.dispatchOnBeforePopup(
        _browsers[id] ?? _stub, _noFrame, url, name, disp, userGesture);
  }

  void _fwdCursorChanged(int id, int type) {
    // Emit to the cursor stream so widgets can track cursor changes
    _cursorStreams[id]?.add(type);
    client.dispatchOnCursorChange(_browsers[id] ?? _stub, type);
  }

  void _fwdGotFocus(int id) =>
      client.dispatchOnGotFocus(_browsers[id] ?? _stub);

  void _fwdStatusMessage(int id, String value) =>
      client.dispatchOnStatusMessage(_browsers[id] ?? _stub, value);

  bool _fwdConsoleMessage(int id, int level, String msg, String src, int line) {
    // Map C-side cef_log_severity_t integer to Dart enum.
    // Values: 0=default, 1=verbose, 2=info, 3=warning, 4=error, 5=fatal, 99=disable
    final severity = CefLogSeverity.values.firstWhere(
      (s) => s.index == level,
      orElse: () => CefLogSeverity.defaultSeverity,
    );
    return client.dispatchOnConsoleMessage(
        _browsers[id] ?? _stub, severity, msg, src, line);
  }

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
    final item = _StubDownloadItemUpdated(dlId, pct, done, canceled);
    // Reuse existing _NativeDlItemCb or create a new one
    final cb = _dlItemCbs.putIfAbsent(dlId, () => _NativeDlItemCb(this, id, dlId));
    client.dispatchOnDownloadUpdated(_browsers[id] ?? _stub, item, cb);
    // Clean up once the download is finished
    if (done || canceled) _dlItemCbs.remove(dlId);
  }

  bool _fwdBeforeBrowse(int id, String url, bool isRedirect, bool userGesture) {
    final handler = _browsers.containsKey(id)
        ? client.requestHandler
        : null;
    if (handler == null) return false;
    return handler.onBeforeBrowse(
      _browsers[id] ?? _stub,
      _noFrame,
      _StubRequest(url),
      userGesture,
      isRedirect,
    );
  }

  bool _fwdBeforeResourceLoad(int id, String url, String method) {
    final handler = client.requestHandler;
    if (handler == null) return false;
    return handler.onBeforeResourceLoad(
      _browsers[id] ?? _stub,
      _noFrame,
      _StubRequest(url, method: method),
    );
  }

  void _fwdBeforeContextMenu(int id, int x, int y,
      List<int> commandIds, List<String> labels,
      List<int> types, List<bool> enabled, List<bool> checked,
      String linkUrl, String pageUrl, String frameUrl, String sourceUrl,
      String selectionText, String misspelledWord,
      int mediaType, int typeFlags, int mediaStateFlags, int editStateFlags,
      bool isEditable, bool hasImageContents) {
    client.dispatchOnBeforeContextMenu(
      _browsers[id] ?? _stub,
      _noFrame,
      _NativeContextMenuParams(
        x: x, y: y,
        linkUrl: linkUrl, pageUrl: pageUrl,
        frameUrl: frameUrl, sourceUrl: sourceUrl,
        selectionText: selectionText, misspelledWord: misspelledWord,
        mediaType: mediaType, typeFlags: typeFlags,
        mediaStateFlags: mediaStateFlags, editStateFlags: editStateFlags,
        isEditable: isEditable, hasImageContents: hasImageContents,
      ),
      _NativeMenuModel(commandIds, labels, types, enabled, checked),
    );
  }

  // ─── Session 3 forwarders ────────────────────────────────────────────────

  void _fwdFullscreenModeChange(int id, bool fullscreen) =>
      client.dispatchOnFullscreenModeChange(_browsers[id] ?? _stub, fullscreen);

  void _fwdFaviconUrlChange(int id, List<String> urls) =>
      client.dispatchOnFaviconUrlChange(_browsers[id] ?? _stub, urls);

  /// Returns (handled, isKeyboardShortcut).
  (bool, bool) _fwdPreKeyEvent(int id, int type, int wk, int nk, int mods,
      int ch, int uch, bool sys) {
    final event = _buildKeyEvent(type, wk, nk, mods, ch, uch, sys);
    final handled = client.dispatchOnPreKeyEvent(_browsers[id] ?? _stub, event);
    return (handled, false); // isKeyboardShortcut always false (not tracked)
  }

  bool _fwdKeyEvent(int id, int type, int wk, int nk, int mods,
      int ch, int uch, bool sys) {
    final event = _buildKeyEvent(type, wk, nk, mods, ch, uch, sys);
    return client.dispatchOnKeyEvent(_browsers[id] ?? _stub, event);
  }

  bool _fwdCertificateError(int id, int certError, String url, int cbId) {
    final cb = _NativeCertCb(this, cbId);
    _certCbs[cbId] = cb;
    return client.dispatchOnCertificateError(
        _browsers[id] ?? _stub, CefErrorCode.findByCode(certError), url, cb);
  }

  // ─── Session 7 forwarders ────────────────────────────────────────────────────

  void _fwdRenderProcessTerminated(int id, int status, int errorCode, String errorString) {
    final s = CefTerminationStatus.values[
        status.clamp(0, CefTerminationStatus.values.length - 1)];
    client.dispatchOnRenderProcessTerminated(
        _browsers[id] ?? _stub, s, errorCode, errorString);
  }

  /// Dispatch before-unload dialog to [CefJSDialogHandler.onBeforeUnloadDialog].
  /// Reuses [_NativeJSCb] and [_jsCbs] — the C side responds via ac_cef_js_dialog_response.
  bool _fwdBeforeUnloadDialog(int id, String msg, bool isReload, int cbId) {
    final cb = _NativeJSCb(this, cbId);
    _jsCbs[cbId] = cb;
    return client.dispatchOnBeforeUnloadDialog(
        _browsers[id] ?? _stub, msg, isReload, cb);
  }

  /// Dispatch tooltip text to [CefDisplayHandler.onTooltip].
  /// Returns true to suppress the default platform tooltip.
  bool _fwdTooltip(int id, String text) =>
      client.dispatchOnTooltip(_browsers[id] ?? _stub, text);

  /// Dispatch an OnFindResult event to the registered [CefFindHandler].
  void _fwdFindResult(int id, int identifier, int count,
      int activeMatchOrdinal,
      int selX, int selY, int selW, int selH,
      bool finalUpdate) {
    final result = CefFindResult(
      identifier:          identifier,
      count:               count,
      activeMatchOrdinal:  activeMatchOrdinal,
      selectionRect:       CefRect(
          selX.toDouble(), selY.toDouble(),
          selW.toDouble(), selH.toDouble()),
      finalUpdate:         finalUpdate,
    );
    client.dispatchOnFindResult(_browsers[id] ?? _stub, result);
  }

  /// Build a [CefKeyEvent] from raw C values.
  static CefKeyEvent _buildKeyEvent(
      int type, int wk, int nk, int mods, int ch, int uch, bool sys) {
    final t = CefKeyEventType.values[
        type.clamp(0, CefKeyEventType.values.length - 1)];
    return CefKeyEvent(
      type: t,
      modifiers: mods,
      windowsKeyCode: wk,
      nativeKeyCode: nk,
      isSystemKey: sys,
      character: ch,
      unmodifiedCharacter: uch,
      focusOnEditableField: false,
    );
  }

  void _fwdPopupShow(int id, bool show) {
    _popupEventStreams[id]?.add(CefPopupShowEvent(show));
  }

  void _fwdPopupSize(int id, int x, int y, int w, int h) {
    _popupEventStreams[id]?.add(CefPopupSizeEvent(x, y, w, h));
  }

  /// The hot path: copy BGRA buffer and push to the per-browser stream.
  void _fwdPaint(int id, bool isPopup, Uint8List pixels, int w, int h,
      List<DirtyRect> dirtyRects) {
    _paintStreams[id]?.add(PaintFrame(
      pixels: pixels,
      width:  w,
      height: h,
      isPopup: isPopup,
      dirtyRects: dirtyRects,
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

// ─── Native certificate-error callback ───────────────────────────────────────

/// Bridges [CefCallback] (from OnCertificateError) to [CefNativeClient.respondCertError].
class _NativeCertCb implements CefCallback {
  final CefNativeClient _c;
  final int _id;
  bool _settled = false;
  _NativeCertCb(this._c, this._id);

  @override
  void onContinue(bool allow) {
    if (_settled) return;
    _settled = true;
    _c.respondCertError(_id, allow);
  }

  @override
  void cancel() {
    if (_settled) return;
    _settled = true;
    _c.respondCertError(_id, false);
  }
}

// ─── Native download-item callback ───────────────────────────────────────────

/// Bridges [CefDownloadItemCallback] to [CefNativeClient.cancelDownload] /
/// [CefNativeClient.pauseDownload] / [CefNativeClient.resumeDownload].
class _NativeDlItemCb implements CefDownloadItemCallback {
  final CefNativeClient _c;
  final int _browserId;
  final int _downloadId;
  _NativeDlItemCb(this._c, this._browserId, this._downloadId);

  @override
  void cancel()  => _c.cancelDownload(_browserId, _downloadId);
  @override
  void pause()   => _c.pauseDownload(_browserId, _downloadId);
  @override
  void resume()  => _c.resumeDownload(_browserId, _downloadId);
}

// ─── Download item with progress info ────────────────────────────────────────

/// A [CefDownloadItem] that carries progress data from OnDownloadUpdated.
class _StubDownloadItemUpdated implements CefDownloadItem {
  final int _id;
  final int _pct;
  final bool _done;
  final bool _canceled;
  _StubDownloadItemUpdated(this._id, this._pct, this._done, this._canceled);

  @override bool isValid()       => true;
  @override bool isInProgress()  => !_done && !_canceled;
  @override bool isComplete()    => _done;
  @override bool isCanceled()    => _canceled;
  @override int getCurrentSpeed()    => 0;
  @override int getPercentComplete() => _pct;
  @override int getTotalBytes()      => 0;
  @override int getReceivedBytes()   => 0;
  @override DateTime getStartTime()  => DateTime.fromMillisecondsSinceEpoch(0);
  @override DateTime getEndTime()    => DateTime.fromMillisecondsSinceEpoch(0);
  @override String getFullPath()     => '';
  @override int getId()              => _id;
  @override String getURL()          => '';
  @override String getSuggestedFileName()    => '';
  @override String getContentDisposition()   => '';
  @override String getMimeType()     => '';
}

// ─── Native query callback ────────────────────────────────────────────────────

/// Bridges [CefQueryCallback] to the native [CefNativeClient.querySuccess] /
/// [CefNativeClient.queryFailure] FFI calls.
class _NativeQueryCb implements CefQueryCallback {
  final CefNativeClient _client;
  final int _browserId;
  final int _queryId;
  bool _settled = false;

  _NativeQueryCb(this._client, this._browserId, this._queryId);

  @override
  void success(String response) {
    if (_settled) return;
    _settled = true;
    _client.querySuccess(_browserId, _queryId, response);
  }

  @override
  void failure(int errorCode, String errorMessage) {
    if (_settled) return;
    _settled = true;
    _client.queryFailure(_browserId, _queryId, errorCode, errorMessage);
  }
}

// ─── Stub CefRequest (used in _fwdBeforeBrowse + _fwdBeforeResourceLoad) ─────

/// Minimal [CefRequest] carrying the URL and (optionally) HTTP method from the C bridge.
/// Navigation interception needs [getURL]; resource-load interception also needs [getMethod].
/// All mutating methods are no-ops.
class _StubRequest implements CefRequest {
  final String _url;
  final String _method;
  _StubRequest(this._url, {String method = 'GET'}) : _method = method;

  @override void dispose() {}
  @override int getIdentifier() => 0;
  @override bool isReadOnly() => true;
  @override String getURL() => _url;
  @override void setURL(String url) {}
  @override String getMethod() => _method;
  @override void setMethod(String method) {}
  @override void setReferrer(String url, CefReferrerPolicy policy) {}
  @override String getReferrerURL() => '';
  @override CefReferrerPolicy getReferrerPolicy() => CefReferrerPolicy.referrerPolicyDefault;
  @override String? getHeaderByName(String name) => null;
  @override void setHeaderByName(String name, String value, bool overwrite) {}
  @override Map<String, String> getHeaderMap() => const {};
  @override void setHeaderMap(Map<String, String> headerMap) {}
  @override int getFlags() => 0;
  @override void setFlags(int flags) {}
  @override String getFirstPartyForCookies() => '';
  @override void setFirstPartyForCookies(String url) {}
  @override CefResourceType getResourceType() => CefResourceType.rtMainFrame;
  @override CefTransitionType getTransitionType() => CefTransitionType.ttLink;
}

// ─── Stub CefContextMenuParams (used in _fwdBeforeContextMenu) ────────────────

/// Minimal [CefContextMenuParams] carrying the (x, y) coordinates from C.
/// Read-populated [CefContextMenuParams] backed by data passed from C++.
class _NativeContextMenuParams implements CefContextMenuParams {
  final int    _x;
  final int    _y;
  final String _linkUrl;
  final String _pageUrl;
  final String _frameUrl;
  final String _sourceUrl;
  final String _selectionText;
  final String _misspelledWord;
  final int    _mediaType;
  final int    _typeFlags;
  final int    _mediaStateFlags;
  final int    _editStateFlags;
  final bool   _isEditable;
  final bool   _hasImageContents;

  _NativeContextMenuParams({
    required int x, required int y,
    required String linkUrl, required String pageUrl,
    required String frameUrl, required String sourceUrl,
    required String selectionText, required String misspelledWord,
    required int mediaType, required int typeFlags,
    required int mediaStateFlags, required int editStateFlags,
    required bool isEditable, required bool hasImageContents,
  })  : _x = x, _y = y,
        _linkUrl = linkUrl, _pageUrl = pageUrl,
        _frameUrl = frameUrl, _sourceUrl = sourceUrl,
        _selectionText = selectionText, _misspelledWord = misspelledWord,
        _mediaType = mediaType, _typeFlags = typeFlags,
        _mediaStateFlags = mediaStateFlags, _editStateFlags = editStateFlags,
        _isEditable = isEditable, _hasImageContents = hasImageContents;

  @override int          getXCoord()            => _x;
  @override int          getYCoord()            => _y;
  @override String       getLinkUrl()           => _linkUrl;
  @override String       getUnfilteredLinkUrl() => _linkUrl; // same — C bridge doesn't separate
  @override String       getPageUrl()           => _pageUrl;
  @override String       getFrameUrl()          => _frameUrl;
  @override String       getSourceUrl()         => _sourceUrl;
  @override String       getSelectionText()     => _selectionText;
  @override String       getMisspelledWord()    => _misspelledWord;
  @override CefMediaType getMediaType() {
    const map = [
      CefMediaType.none, CefMediaType.image, CefMediaType.video,
      CefMediaType.audio, CefMediaType.file, CefMediaType.plugin,
    ];
    return (_mediaType >= 0 && _mediaType < map.length)
        ? map[_mediaType] : CefMediaType.none;
  }
  @override int  getTypeFlags()       => _typeFlags;
  @override int  getMediaStateFlags() => _mediaStateFlags;
  @override int  getEditStateFlags()  => _editStateFlags;
  @override bool isEditable()         => _isEditable;
  @override bool hasImageContents()   => _hasImageContents;
  @override bool isSpellCheckEnabled()=> false; // not passed from C
  @override String getFrameCharset()  => '';     // not passed from C
}

// ignore: unused_element  — kept as a zero-data fallback

// ─── Stub CefMenuModel (used in _fwdBeforeContextMenu) ───────────────────────

/// No-op [CefMenuModel] passed to [CefContextMenuHandler.onBeforeContextMenu].
/// The C bridge already calls model->Clear() before dispatching to Dart,
/// so the model is effectively empty when the handler receives it.
// ignore: unused_element  — kept as a zero-item fallback, replaced by _NativeMenuModel at runtime
class _StubMenuModel implements CefMenuModel {
  @override bool clear() => true;
  @override int getCount() => 0;
  @override bool addSeparator() => false;
  @override bool addItem(int commandId, String label) => false;
  @override bool addCheckItem(int commandId, String label) => false;
  @override bool addRadioItem(int commandId, String label, int groupId) => false;
  @override CefMenuModel? addSubMenu(int commandId, String label) => null;
  @override bool insertSeparatorAt(int index) => false;
  @override bool insertItemAt(int index, int commandId, String label) => false;
  @override bool insertCheckItemAt(int index, int commandId, String label) => false;
  @override bool insertRadioItemAt(int index, int commandId, String label, int groupId) => false;
  @override CefMenuModel? insertSubMenuAt(int index, int commandId, String label) => null;
  @override bool remove(int commandId) => false;
  @override bool removeAt(int index) => false;
  @override int getIndexOf(int commandId) => -1;
  @override int getCommandIdAt(int index) => -1;
  @override bool setCommandIdAt(int index, int commandId) => false;
  @override String getLabel(int commandId) => '';
  @override String getLabelAt(int index) => '';
  @override bool setLabel(int commandId, String label) => false;
  @override bool setLabelAt(int index, String label) => false;
  @override CefMenuItemType getType(int commandId) => CefMenuItemType.none;
  @override CefMenuItemType getTypeAt(int index) => CefMenuItemType.none;
  @override int getGroupId(int commandId) => 0;
  @override int getGroupIdAt(int index) => 0;
  @override bool setGroupId(int commandId, int groupId) => false;
  @override bool setGroupIdAt(int index, int groupId) => false;
  @override CefMenuModel? getSubMenu(int commandId) => null;
  @override CefMenuModel? getSubMenuAt(int index) => null;
  @override bool isVisible(int commandId) => false;
  @override bool isVisibleAt(int index) => false;
  @override bool setVisible(int commandId, bool visible) => false;
  @override bool setVisibleAt(int index, bool visible) => false;
  @override bool isEnabled(int commandId) => false;
  @override bool isEnabledAt(int index) => false;
  @override bool setEnabled(int commandId, bool enabled) => false;
  @override bool setEnabledAt(int index, bool enabled) => false;
  @override bool isChecked(int commandId) => false;
  @override bool isCheckedAt(int index) => false;
  @override bool setChecked(int commandId, bool checked) => false;
  @override bool setCheckedAt(int index, bool checked) => false;
}

/// Read-only [CefMenuModel] backed by item arrays copied from C++.
///
/// Populated with the default browser context-menu items before the
/// native model is cleared. Mutation methods are no-ops — Dart should
/// use the data to build a custom Flutter overlay instead.
class _NativeMenuModel implements CefMenuModel {
  final List<int>    _ids;
  final List<String> _labels;
  final List<int>    _types;   // raw int, maps to CefMenuItemType
  final List<bool>   _enabled;
  final List<bool>   _checked;

  _NativeMenuModel(
      this._ids, this._labels, this._types, this._enabled, this._checked);

  bool _inRange(int i) => i >= 0 && i < _ids.length;

  static CefMenuItemType _toType(int t) {
    // CEF cef_menu_item_type_t: 0=none,1=command,2=check,3=radio,4=separator,5=submenu
    const map = [
      CefMenuItemType.none,
      CefMenuItemType.command,
      CefMenuItemType.check,
      CefMenuItemType.radio,
      CefMenuItemType.separator,
      CefMenuItemType.submenu,
    ];
    return (t >= 0 && t < map.length) ? map[t] : CefMenuItemType.none;
  }

  // ── Read accessors ──────────────────────────────────────────────────────────
  @override int    getCount()                => _ids.length;
  @override int    getCommandIdAt(int i)     => _inRange(i) ? _ids[i]    : -1;
  @override String getLabelAt(int i)         => _inRange(i) ? _labels[i] : '';
  @override CefMenuItemType getTypeAt(int i) => _inRange(i) ? _toType(_types[i]) : CefMenuItemType.none;
  @override bool   isEnabledAt(int i)        => _inRange(i) && _enabled[i];
  @override bool   isCheckedAt(int i)        => _inRange(i) && _checked[i];
  @override bool   isVisibleAt(int i)        => _inRange(i); // assume visible if present

  @override int getIndexOf(int commandId) => _ids.indexOf(commandId);

  @override String         getLabel(int id)  { final i = getIndexOf(id); return i < 0 ? '' : _labels[i]; }
  @override CefMenuItemType getType(int id)  { final i = getIndexOf(id); return i < 0 ? CefMenuItemType.none : _toType(_types[i]); }
  @override bool           isEnabled(int id) { final i = getIndexOf(id); return i >= 0 && _enabled[i]; }
  @override bool           isChecked(int id) { final i = getIndexOf(id); return i >= 0 && _checked[i]; }
  @override bool           isVisible(int id) => getIndexOf(id) >= 0;

  // ── Unused group/submenu accessors ─────────────────────────────────────────
  @override int           getGroupId(int id)     => 0;
  @override int           getGroupIdAt(int i)    => 0;
  @override CefMenuModel? getSubMenu(int id)      => null;
  @override CefMenuModel? getSubMenuAt(int i)     => null;

  // ── No-op mutation methods (native model is already cleared on C side) ─────
  @override bool  clear()                                               => false;
  @override bool  addSeparator()                                        => false;
  @override bool  addItem(int id, String l)                             => false;
  @override bool  addCheckItem(int id, String l)                        => false;
  @override bool  addRadioItem(int id, String l, int g)                 => false;
  @override CefMenuModel? addSubMenu(int id, String l)                  => null;
  @override bool  insertSeparatorAt(int i)                              => false;
  @override bool  insertItemAt(int i, int id, String l)                 => false;
  @override bool  insertCheckItemAt(int i, int id, String l)            => false;
  @override bool  insertRadioItemAt(int i, int id, String l, int g)     => false;
  @override CefMenuModel? insertSubMenuAt(int i, int id, String l)      => null;
  @override bool  remove(int id)                                        => false;
  @override bool  removeAt(int i)                                       => false;
  @override bool  setCommandIdAt(int i, int id)                         => false;
  @override bool  setLabel(int id, String l)                            => false;
  @override bool  setLabelAt(int i, String l)                           => false;
  @override bool  setGroupId(int id, int g)                             => false;
  @override bool  setGroupIdAt(int i, int g)                            => false;
  @override bool  setVisible(int id, bool v)                            => false;
  @override bool  setVisibleAt(int i, bool v)                           => false;
  @override bool  setEnabled(int id, bool e)                            => false;
  @override bool  setEnabledAt(int i, bool e)                           => false;
  @override bool  setChecked(int id, bool c)                            => false;
  @override bool  setCheckedAt(int i, bool c)                           => false;
}
