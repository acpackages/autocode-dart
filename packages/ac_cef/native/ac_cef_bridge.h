// ac_cef_bridge.h
// C bridge between the CEF C API and the Dart FFI layer.
// This file is compiled as part of the ac_cef native shared library.
//
// On Windows:  compile into ac_cef_bridge.dll
// On Linux:    compile into libac_cef_bridge.so
// On macOS:    compile into libac_cef_bridge.dylib
//
// The Dart side loads this library via dart:ffi and invokes these functions.

#pragma once

#ifdef _WIN32
#  define AC_CEF_EXPORT __declspec(dllexport)
#else
#  define AC_CEF_EXPORT __attribute__((visibility("default")))
#endif

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// ─── Dart callback typedefs ───────────────────────────────────────────────────
// These function pointers are set by Dart and invoked from C when CEF fires
// the corresponding events.

typedef void (*OnUrlChangedCallback)(int64_t browser_id, const char* url);
typedef void (*OnTitleChangedCallback)(int64_t browser_id, const char* title);
typedef void (*OnLoadingStateChangedCallback)(
    int64_t browser_id, int is_loading, int can_go_back, int can_go_forward);
typedef void (*OnLoadStartCallback)(
    int64_t browser_id, const char* frame_id, int transition_type);
typedef void (*OnLoadEndCallback)(
    int64_t browser_id, const char* frame_id, int http_status_code);
typedef void (*OnLoadErrorCallback)(
    int64_t browser_id, const char* frame_id, int error_code,
    const char* error_text, const char* failed_url);
typedef void (*OnAfterCreatedCallback)(int64_t browser_id);
typedef void (*OnBeforeCloseCallback)(int64_t browser_id);
typedef int  (*OnBeforePopupCallback)(
    int64_t browser_id, const char* target_url, const char* target_frame_name);
typedef void (*OnCursorChangedCallback)(int64_t browser_id, int cursor_type);
typedef void (*OnGotFocusCallback)(int64_t browser_id);
typedef int  (*OnConsoleMessageCallback)(
    int64_t browser_id, int level,
    const char* message, const char* source, int line);
typedef int  (*OnJSDialogCallback)(
    int64_t browser_id, const char* origin_url, int dialog_type,
    const char* message_text, const char* default_prompt_text,
    int64_t callback_id);
typedef int  (*OnBeforeDownloadCallback)(
    int64_t browser_id, int64_t download_id,
    const char* url, const char* suggested_name, int64_t callback_id);
typedef void (*OnDownloadUpdatedCallback)(
    int64_t browser_id, int64_t download_id,
    int percent_complete, int is_complete, int is_canceled);

typedef int (*OnBeforeBrowseCallback)(
    int64_t browser_id, const char* url, int is_redirect);

typedef int (*OnBeforeResourceLoadCallback)(
    int64_t browser_id, const char* url, const char* method);

typedef void (*OnBeforeContextMenuCallback)(
    int64_t browser_id, int x, int y);

/// Called by CEF's CefRenderHandler::OnPaint for every frame.
/// [buffer] points to CEF-owned BGRA pixel data of [width] x [height] pixels.
/// Dart must copy the data within this callback — the pointer is invalid after return.
typedef void (*OnPaintCallback)(
    int64_t browser_id,
    int is_popup,
    const void* buffer,
    int width,
    int height);

/// Called when CEF needs to know the view rect for the OSR browser.
typedef void (*GetViewRectCallback)(
    int64_t browser_id,
    int* x, int* y, int* width, int* height);

// ─── Struct: callback table ───────────────────────────────────────────────────

typedef struct AcCefCallbacks {
  OnUrlChangedCallback           on_url_changed;
  OnTitleChangedCallback         on_title_changed;
  OnLoadingStateChangedCallback  on_loading_state_changed;
  OnLoadStartCallback            on_load_start;
  OnLoadEndCallback              on_load_end;
  OnLoadErrorCallback            on_load_error;
  OnAfterCreatedCallback         on_after_created;
  OnBeforeCloseCallback          on_before_close;
  OnBeforePopupCallback          on_before_popup;
  OnCursorChangedCallback        on_cursor_changed;
  OnGotFocusCallback             on_got_focus;
  OnConsoleMessageCallback       on_console_message;
  OnJSDialogCallback             on_js_dialog;
  OnBeforeDownloadCallback       on_before_download;
  OnDownloadUpdatedCallback      on_download_updated;
  OnBeforeBrowseCallback         on_before_browse;
  OnBeforeResourceLoadCallback   on_before_resource_load;
  OnBeforeContextMenuCallback    on_before_context_menu;
  OnPaintCallback                on_paint;
  GetViewRectCallback            get_view_rect;
} AcCefCallbacks;

// ─── Init / shutdown ──────────────────────────────────────────────────────────

/// Initialize CEF with the given settings map (key=value pairs, null-terminated).
/// Returns 1 on success, 0 on failure.
AC_CEF_EXPORT int ac_cef_initialize(
    const char** keys,
    const char** values,
    int count,
    const AcCefCallbacks* callbacks);

AC_CEF_EXPORT void ac_cef_shutdown(void);

// ─── Message loop ─────────────────────────────────────────────────────────────

AC_CEF_EXPORT void ac_cef_do_message_loop_work(void);
AC_CEF_EXPORT void ac_cef_run_message_loop(void);
AC_CEF_EXPORT void ac_cef_quit_message_loop(void);

// ─── Browser management ───────────────────────────────────────────────────────

/// Create an off-screen browser and return its integer ID (> 0), or 0 on error.
AC_CEF_EXPORT int64_t ac_cef_create_browser(
    const char* url,
    int windowless_frame_rate,
    int is_transparent);

/// Load a URL in an existing browser.
AC_CEF_EXPORT void ac_cef_load_url(int64_t browser_id, const char* url);

/// Browser navigation helpers.
AC_CEF_EXPORT void ac_cef_go_back(int64_t browser_id);
AC_CEF_EXPORT void ac_cef_go_forward(int64_t browser_id);
AC_CEF_EXPORT void ac_cef_reload(int64_t browser_id);
AC_CEF_EXPORT void ac_cef_stop_load(int64_t browser_id);
AC_CEF_EXPORT void ac_cef_close_browser(int64_t browser_id, int force_close);

/// Execute JavaScript in the main frame of [browser_id].
AC_CEF_EXPORT void ac_cef_execute_javascript(
    int64_t browser_id, const char* code);

/// Zoom level (+/- from default).
AC_CEF_EXPORT void ac_cef_set_zoom_level(int64_t browser_id, double level);
AC_CEF_EXPORT double ac_cef_get_zoom_level(int64_t browser_id);

// ─── Input events ─────────────────────────────────────────────────────────────

AC_CEF_EXPORT void ac_cef_send_mouse_move(
    int64_t browser_id, int x, int y, int modifiers, int mouse_leave);
AC_CEF_EXPORT void ac_cef_send_mouse_click(
    int64_t browser_id, int x, int y,
    int button, int mouse_up, int click_count, int modifiers);
AC_CEF_EXPORT void ac_cef_send_mouse_wheel(
    int64_t browser_id, int x, int y, int delta_x, int delta_y);
AC_CEF_EXPORT void ac_cef_send_key_event(
    int64_t browser_id,
    int type,               /* 0=rawkeydown, 1=keyup, 2=char */
    int windows_key_code,
    int native_key_code,
    int modifiers,
    int character,
    int unmodified_character,
    int is_system_key);

// ─── Focus ────────────────────────────────────────────────────────────────────

AC_CEF_EXPORT void ac_cef_set_focus(int64_t browser_id, int focus);

// ─── OSR resize / paint ───────────────────────────────────────────────────────

AC_CEF_EXPORT void ac_cef_was_resized(int64_t browser_id);
AC_CEF_EXPORT void ac_cef_was_hidden(int64_t browser_id, int hidden);

/// Force an immediate repaint of the entire view.
AC_CEF_EXPORT void ac_cef_invalidate(int64_t browser_id);

/// Update the logical view size used by the OSR renderer.
/// Call after any layout change, before ac_cef_was_resized.
AC_CEF_EXPORT void ac_cef_set_view_size(
    int64_t browser_id, int width, int height, float device_pixel_ratio);

// ─── Callback responses ───────────────────────────────────────────────────────

/// Respond to an OnJSDialog callback.
AC_CEF_EXPORT void ac_cef_js_dialog_response(
    int64_t callback_id, int success, const char* user_input);

/// Respond to an OnBeforeDownload callback.
AC_CEF_EXPORT void ac_cef_before_download_response(
    int64_t callback_id, const char* download_path, int show_dialog);

/// Cancel a download via OnDownloadUpdated callback handle.
AC_CEF_EXPORT void ac_cef_cancel_download(int64_t browser_id, int64_t download_id);

// ─── Cookie management ────────────────────────────────────────────────────────

AC_CEF_EXPORT void ac_cef_clear_all_cookies(void);
AC_CEF_EXPORT void ac_cef_set_cookie(
    const char* url,
    const char* name,
    const char* value,
    const char* domain,
    const char* path,
    int secure,
    int http_only,
    int64_t expires);

// ─── Message router (JS ↔ Dart queries) ───────────────────────────────────────
// Mirrors JCEF's CefMessageRouter / CefMessageRouterHandler.

/// Callback from C when JavaScript calls cefQuery().
/// Dart must respond via ac_cef_query_response or ac_cef_query_failure.
typedef void (*OnQueryCallback)(
    int64_t browser_id,
    int64_t query_id,
    const char* request,
    int persistent);

/// Callback when a pending query is canceled.
typedef void (*OnQueryCanceledCallback)(
    int64_t browser_id,
    int64_t query_id);

/// Enable the message router for a browser.
/// [js_query_fn] is the JS function name, e.g. "cefQuery".
/// [js_cancel_fn] is the JS cancel function name, e.g. "cefQueryCancel".
AC_CEF_EXPORT void ac_cef_message_router_create(
    int64_t browser_id,
    const char* js_query_fn,
    const char* js_cancel_fn,
    OnQueryCallback on_query,
    OnQueryCanceledCallback on_query_canceled);

/// Respond successfully to a JS query.
AC_CEF_EXPORT void ac_cef_query_response(
    int64_t browser_id,
    int64_t query_id,
    const char* response);

/// Respond with failure to a JS query.
AC_CEF_EXPORT void ac_cef_query_failure(
    int64_t browser_id,
    int64_t query_id,
    int error_code,
    const char* error_message);

// ─── DevTools ─────────────────────────────────────────────────────────────────

/// Open DevTools in a separate window for [browser_id].
AC_CEF_EXPORT void ac_cef_open_dev_tools(int64_t browser_id);

/// Close DevTools for [browser_id].
AC_CEF_EXPORT void ac_cef_close_dev_tools(int64_t browser_id);

// ─── Print to PDF ─────────────────────────────────────────────────────────────

/// Print the current page to a PDF file at [path].
/// Calls back via OnPrintToPdfCallback when complete.
typedef void (*OnPrintToPdfCallback)(int64_t browser_id, const char* path, int ok);

AC_CEF_EXPORT void ac_cef_print_to_pdf(
    int64_t browser_id,
    const char* path,
    OnPrintToPdfCallback callback);

// ─── Utility ──────────────────────────────────────────────────────────────────

/// Get the current URL of a browser. Caller must free the returned string.
AC_CEF_EXPORT const char* ac_cef_get_url(int64_t browser_id);

/// Get the page title. Caller must free the returned string.
AC_CEF_EXPORT const char* ac_cef_get_title(int64_t browser_id);

/// Check if the browser can navigate back/forward.
AC_CEF_EXPORT int ac_cef_can_go_back(int64_t browser_id);
AC_CEF_EXPORT int ac_cef_can_go_forward(int64_t browser_id);

/// Check if the browser is currently loading.
AC_CEF_EXPORT int ac_cef_is_loading(int64_t browser_id);

#ifdef __cplusplus
}
#endif
