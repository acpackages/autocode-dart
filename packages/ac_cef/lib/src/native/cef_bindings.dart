// Dart FFI bindings for ac_cef_bridge.dll / libac_cef_bridge.so
// Every C export in ac_cef_bridge.h is represented here as a Dart callable.

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ─── Callback typedefs (Dart → C function pointers) ──────────────────────────

typedef OnUrlChangedCallback           = Void Function(Int64, Pointer<Utf8>);
typedef OnTitleChangedCallback         = Void Function(Int64, Pointer<Utf8>);
typedef OnLoadingStateChangedCallback  = Void Function(Int64, Int32, Int32, Int32);
typedef OnLoadStartCallback            = Void Function(Int64, Pointer<Utf8>, Int32);
typedef OnLoadEndCallback              = Void Function(Int64, Pointer<Utf8>, Int32);
typedef OnLoadErrorCallback            = Void Function(Int64, Pointer<Utf8>, Int32, Pointer<Utf8>, Pointer<Utf8>);
typedef OnAfterCreatedCallback         = Void Function(Int64);
typedef OnBeforeCloseCallback          = Void Function(Int64);
typedef OnBeforePopupCallback          = Int32 Function(Int64, Pointer<Utf8>, Pointer<Utf8>);
typedef OnCursorChangedCallback        = Void Function(Int64, Int32);
typedef OnGotFocusCallback             = Void Function(Int64);
typedef OnConsoleMessageCallback       = Int32 Function(Int64, Int32, Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef OnJSDialogCallback             = Int32 Function(Int64, Pointer<Utf8>, Int32, Pointer<Utf8>, Pointer<Utf8>, Int64);
typedef OnBeforeDownloadCallback       = Int32 Function(Int64, Int64, Pointer<Utf8>, Pointer<Utf8>, Int64);
typedef OnDownloadUpdatedCallback      = Void Function(Int64, Int64, Int32, Int32, Int32);

typedef OnBeforeBrowseCallback         = Int32 Function(Int64, Pointer<Utf8>, Int32);
typedef OnBeforeResourceLoadCallback   = Int32 Function(Int64, Pointer<Utf8>, Pointer<Utf8>);
typedef OnBeforeContextMenuCallback    = Void  Function(Int64, Int32, Int32);

typedef OnQueryCallback                = Void Function(Int64, Int64, Pointer<Utf8>, Int32);
typedef OnQueryCanceledCallback        = Void Function(Int64, Int64);

/// Called from C for every CEF paint frame. [buffer] contains BGRA pixels.
typedef OnPaintCallback    = Void Function(Int64, Int32, Pointer<Void>, Int32, Int32);
typedef GetViewRectCallback = Void Function(Int64, Pointer<Int32>, Pointer<Int32>, Pointer<Int32>, Pointer<Int32>);

// ─── AcCefCallbacks struct (matches C struct layout exactly) ─────────────────

final class AcCefCallbacksStruct extends Struct {
  external Pointer<NativeFunction<OnUrlChangedCallback>>          on_url_changed;
  external Pointer<NativeFunction<OnTitleChangedCallback>>        on_title_changed;
  external Pointer<NativeFunction<OnLoadingStateChangedCallback>> on_loading_state_changed;
  external Pointer<NativeFunction<OnLoadStartCallback>>           on_load_start;
  external Pointer<NativeFunction<OnLoadEndCallback>>             on_load_end;
  external Pointer<NativeFunction<OnLoadErrorCallback>>           on_load_error;
  external Pointer<NativeFunction<OnAfterCreatedCallback>>        on_after_created;
  external Pointer<NativeFunction<OnBeforeCloseCallback>>         on_before_close;
  external Pointer<NativeFunction<OnBeforePopupCallback>>         on_before_popup;
  external Pointer<NativeFunction<OnCursorChangedCallback>>       on_cursor_changed;
  external Pointer<NativeFunction<OnGotFocusCallback>>            on_got_focus;
  external Pointer<NativeFunction<OnConsoleMessageCallback>>      on_console_message;
  external Pointer<NativeFunction<OnJSDialogCallback>>            on_js_dialog;
  external Pointer<NativeFunction<OnBeforeDownloadCallback>>      on_before_download;
  external Pointer<NativeFunction<OnDownloadUpdatedCallback>>     on_download_updated;
  external Pointer<NativeFunction<OnBeforeBrowseCallback>>        on_before_browse;
  external Pointer<NativeFunction<OnBeforeResourceLoadCallback>>  on_before_resource_load;
  external Pointer<NativeFunction<OnBeforeContextMenuCallback>>   on_before_context_menu;
  external Pointer<NativeFunction<OnPaintCallback>>               on_paint;
  external Pointer<NativeFunction<GetViewRectCallback>>           get_view_rect;
}

// ─── C function type pairs (C sig / Dart sig) ─────────────────────────────────

// ac_cef_initialize
typedef _InitializeC    = Int32 Function(Pointer<Pointer<Utf8>>, Pointer<Pointer<Utf8>>, Int32, Pointer<AcCefCallbacksStruct>);
typedef _InitializeDart = int   Function(Pointer<Pointer<Utf8>>, Pointer<Pointer<Utf8>>, int,  Pointer<AcCefCallbacksStruct>);

// ac_cef_shutdown
typedef _VoidC    = Void Function();
typedef _VoidDart = void Function();

// int64 input functions (browser_id only)
typedef _Int64C    = Void Function(Int64);
typedef _Int64Dart = void Function(int);

// ac_cef_load_url / ac_cef_execute_javascript
typedef _Int64StrC    = Void Function(Int64, Pointer<Utf8>);
typedef _Int64StrDart = void Function(int, Pointer<Utf8>);

// ac_cef_set_zoom_level / ac_cef_get_zoom_level
typedef _SetZoomC    = Void Function(Int64, Double);
typedef _SetZoomDart = void Function(int, double);
typedef _GetZoomC    = Double Function(Int64);
typedef _GetZoomDart = double Function(int);

// ac_cef_was_hidden / ac_cef_set_focus / ac_cef_close_browser
typedef _Int64Int32C    = Void Function(Int64, Int32);
typedef _Int64Int32Dart = void Function(int, int);

// ac_cef_set_view_size
typedef _SetViewSizeC    = Void Function(Int64, Int32, Int32, Float);
typedef _SetViewSizeDart = void Function(int, int, int, double);

// ac_cef_invalidate (reuses _Int64C/_Int64Dart)
typedef _InvalidateC    = Void Function(Int64);
typedef _InvalidateDart = void Function(int);

// ac_cef_create_browser
typedef _CreateBrowserC    = Int64 Function(Pointer<Utf8>, Int32, Int32);
typedef _CreateBrowserDart = int   Function(Pointer<Utf8>, int,  int);

// ac_cef_send_mouse_move
typedef _MouseMoveC    = Void Function(Int64, Int32, Int32, Int32, Int32);
typedef _MouseMoveDart = void Function(int, int, int, int, int);

// ac_cef_send_mouse_click
typedef _MouseClickC    = Void Function(Int64, Int32, Int32, Int32, Int32, Int32, Int32);
typedef _MouseClickDart = void Function(int, int, int, int, int, int, int);

// ac_cef_send_mouse_wheel
typedef _MouseWheelC    = Void Function(Int64, Int32, Int32, Int32, Int32);
typedef _MouseWheelDart = void Function(int, int, int, int, int);

// ac_cef_send_key_event
typedef _KeyEventC    = Void Function(Int64, Int32, Int32, Int32, Int32, Int32, Int32, Int32);
typedef _KeyEventDart = void Function(int, int, int, int, int, int, int, int);

// ac_cef_ime_commit_text
typedef _ImeCommitTextC    = Void Function(Int64, Pointer<Utf8>);
typedef _ImeCommitTextDart = void Function(int, Pointer<Utf8>);

// ac_cef_js_dialog_response
typedef _JSDialogResponseC    = Void Function(Int64, Int32, Pointer<Utf8>);
typedef _JSDialogResponseDart = void Function(int, int, Pointer<Utf8>);

// ac_cef_before_download_response
typedef _BeforeDownloadResponseC    = Void Function(Int64, Pointer<Utf8>, Int32);
typedef _BeforeDownloadResponseDart = void Function(int, Pointer<Utf8>, int);

// ac_cef_set_cookie
typedef _SetCookieC    = Void Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Int32, Int32, Int64);
typedef _SetCookieDart = void Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, int, int, int);

// ac_cef_open_dev_tools / ac_cef_close_dev_tools (reuses _Int64C/_Int64Dart)

// ac_cef_can_go_back / ac_cef_can_go_forward / ac_cef_is_loading
typedef _BoolQueryC    = Int32 Function(Int64);
typedef _BoolQueryDart = int   Function(int);

// ac_cef_get_url / ac_cef_get_title
typedef _GetStrC    = Pointer<Utf8> Function(Int64);
typedef _GetStrDart = Pointer<Utf8> Function(int);

// ac_cef_query_response
typedef _QueryResponseC    = Void Function(Int64, Int64, Pointer<Utf8>);
typedef _QueryResponseDart = void Function(int, int, Pointer<Utf8>);

// ac_cef_query_failure
typedef _QueryFailureC    = Void Function(Int64, Int64, Int32, Pointer<Utf8>);
typedef _QueryFailureDart = void Function(int, int, int, Pointer<Utf8>);

// ac_cef_message_router_create
typedef _MsgRouterCreateC = Void Function(Int64, Pointer<Utf8>, Pointer<Utf8>, Pointer<NativeFunction<OnQueryCallback>>, Pointer<NativeFunction<OnQueryCanceledCallback>>);
typedef _MsgRouterCreateDart = void Function(int, Pointer<Utf8>, Pointer<Utf8>, Pointer<NativeFunction<OnQueryCallback>>, Pointer<NativeFunction<OnQueryCanceledCallback>>);

// ac_cef_print_to_pdf
typedef OnPrintToPdfCallback = Void Function(Int64, Pointer<Utf8>, Int32);
typedef _PrintToPdfC = Void Function(Int64, Pointer<Utf8>, Pointer<NativeFunction<OnPrintToPdfCallback>>);
typedef _PrintToPdfDart = void Function(int, Pointer<Utf8>, Pointer<NativeFunction<OnPrintToPdfCallback>>);

// ─── CefBindings ──────────────────────────────────────────────────────────────

class CefBindings {
  final DynamicLibrary _lib;

  late final _InitializeDart           initialize;
  late final _VoidDart                 shutdown;
  late final _VoidDart                 doMessageLoopWork;
  late final _VoidDart                 runMessageLoop;
  late final _VoidDart                 quitMessageLoop;
  late final _CreateBrowserDart        createBrowser;
  late final _Int64StrDart             loadUrl;
  late final _Int64Dart                goBack;
  late final _Int64Dart                goForward;
  late final _Int64Dart                reload;
  late final _Int64Dart                stopLoad;
  late final _Int64Int32Dart           closeBrowser;
  late final _Int64StrDart             executeJavaScript;
  late final _SetZoomDart              setZoomLevel;
  late final _GetZoomDart              getZoomLevel;
  late final _MouseMoveDart            sendMouseMove;
  late final _MouseClickDart           sendMouseClick;
  late final _MouseWheelDart           sendMouseWheel;
  late final _KeyEventDart             sendKeyEvent;
  late final _ImeCommitTextDart        imeCommitText;
  late final _Int64Int32Dart           setFocus;
  late final _Int64Dart                wasResized;
  late final _Int64Int32Dart           wasHidden;
  late final _SetViewSizeDart          setViewSize;
  late final _InvalidateDart           invalidate;
  late final _JSDialogResponseDart     jsDialogResponse;
  late final _BeforeDownloadResponseDart beforeDownloadResponse;
  late final _VoidDart                 clearAllCookies;
  late final _SetCookieDart            setCookie;
  late final _Int64Dart                openDevTools;
  late final _Int64Dart                closeDevTools;
  late final _BoolQueryDart            canGoBack;
  late final _BoolQueryDart            canGoForward;
  late final _BoolQueryDart            isLoading;
  late final _GetStrDart               getUrl;
  late final _GetStrDart               getTitle;
  late final _MsgRouterCreateDart      messageRouterCreate;
  late final _QueryResponseDart        queryResponse;
  late final _QueryFailureDart         queryFailure;
  late final _PrintToPdfDart           printToPdf;

  CefBindings._(this._lib) {
    initialize          = _lib.lookupFunction<_InitializeC,         _InitializeDart>('ac_cef_initialize');
    shutdown            = _lib.lookupFunction<_VoidC,               _VoidDart>      ('ac_cef_shutdown');
    doMessageLoopWork   = _lib.lookupFunction<_VoidC,               _VoidDart>      ('ac_cef_do_message_loop_work');
    runMessageLoop      = _lib.lookupFunction<_VoidC,               _VoidDart>      ('ac_cef_run_message_loop');
    quitMessageLoop     = _lib.lookupFunction<_VoidC,               _VoidDart>      ('ac_cef_quit_message_loop');
    createBrowser       = _lib.lookupFunction<_CreateBrowserC,      _CreateBrowserDart>('ac_cef_create_browser');
    loadUrl             = _lib.lookupFunction<_Int64StrC,           _Int64StrDart>  ('ac_cef_load_url');
    goBack              = _lib.lookupFunction<_Int64C,              _Int64Dart>     ('ac_cef_go_back');
    goForward           = _lib.lookupFunction<_Int64C,              _Int64Dart>     ('ac_cef_go_forward');
    reload              = _lib.lookupFunction<_Int64C,              _Int64Dart>     ('ac_cef_reload');
    stopLoad            = _lib.lookupFunction<_Int64C,              _Int64Dart>     ('ac_cef_stop_load');
    closeBrowser        = _lib.lookupFunction<_Int64Int32C,         _Int64Int32Dart>('ac_cef_close_browser');
    executeJavaScript   = _lib.lookupFunction<_Int64StrC,           _Int64StrDart>  ('ac_cef_execute_javascript');
    setZoomLevel        = _lib.lookupFunction<_SetZoomC,            _SetZoomDart>   ('ac_cef_set_zoom_level');
    getZoomLevel        = _lib.lookupFunction<_GetZoomC,            _GetZoomDart>   ('ac_cef_get_zoom_level');
    sendMouseMove       = _lib.lookupFunction<_MouseMoveC,          _MouseMoveDart> ('ac_cef_send_mouse_move');
    sendMouseClick      = _lib.lookupFunction<_MouseClickC,         _MouseClickDart>('ac_cef_send_mouse_click');
    sendMouseWheel      = _lib.lookupFunction<_MouseWheelC,         _MouseWheelDart>('ac_cef_send_mouse_wheel');
    sendKeyEvent        = _lib.lookupFunction<_KeyEventC,           _KeyEventDart>  ('ac_cef_send_key_event');
    imeCommitText       = _lib.lookupFunction<_ImeCommitTextC,      _ImeCommitTextDart>('ac_cef_ime_commit_text');
    setFocus            = _lib.lookupFunction<_Int64Int32C,         _Int64Int32Dart>('ac_cef_set_focus');
    wasResized          = _lib.lookupFunction<_Int64C,              _Int64Dart>     ('ac_cef_was_resized');
    wasHidden           = _lib.lookupFunction<_Int64Int32C,         _Int64Int32Dart>('ac_cef_was_hidden');
    setViewSize         = _lib.lookupFunction<_SetViewSizeC,        _SetViewSizeDart>('ac_cef_set_view_size');
    invalidate          = _lib.lookupFunction<_InvalidateC,         _InvalidateDart>('ac_cef_invalidate');
    jsDialogResponse    = _lib.lookupFunction<_JSDialogResponseC,   _JSDialogResponseDart>('ac_cef_js_dialog_response');
    beforeDownloadResponse = _lib.lookupFunction<_BeforeDownloadResponseC, _BeforeDownloadResponseDart>('ac_cef_before_download_response');
    clearAllCookies     = _lib.lookupFunction<_VoidC,               _VoidDart>      ('ac_cef_clear_all_cookies');
    setCookie           = _lib.lookupFunction<_SetCookieC,          _SetCookieDart> ('ac_cef_set_cookie');
    openDevTools        = _lib.lookupFunction<_Int64C,              _Int64Dart>     ('ac_cef_open_dev_tools');
    closeDevTools       = _lib.lookupFunction<_Int64C,              _Int64Dart>     ('ac_cef_close_dev_tools');
    canGoBack           = _lib.lookupFunction<_BoolQueryC,          _BoolQueryDart> ('ac_cef_can_go_back');
    canGoForward        = _lib.lookupFunction<_BoolQueryC,          _BoolQueryDart> ('ac_cef_can_go_forward');
    isLoading           = _lib.lookupFunction<_BoolQueryC,          _BoolQueryDart> ('ac_cef_is_loading');
    getUrl              = _lib.lookupFunction<_GetStrC,             _GetStrDart>    ('ac_cef_get_url');
    getTitle            = _lib.lookupFunction<_GetStrC,             _GetStrDart>    ('ac_cef_get_title');
    messageRouterCreate = _lib.lookupFunction<_MsgRouterCreateC,    _MsgRouterCreateDart>('ac_cef_message_router_create');
    queryResponse       = _lib.lookupFunction<_QueryResponseC,      _QueryResponseDart>('ac_cef_query_response');
    queryFailure        = _lib.lookupFunction<_QueryFailureC,       _QueryFailureDart> ('ac_cef_query_failure');
    printToPdf          = _lib.lookupFunction<_PrintToPdfC,         _PrintToPdfDart>   ('ac_cef_print_to_pdf');
  }

  factory CefBindings.load(String libraryPath) =>
      CefBindings._(DynamicLibrary.open(libraryPath));

  static String defaultLibraryPath() {
    if (Platform.isWindows) return 'ac_cef_bridge.dll';
    if (Platform.isLinux)   return 'libac_cef_bridge.so';
    if (Platform.isMacOS)   return 'libac_cef_bridge.dylib';
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}
