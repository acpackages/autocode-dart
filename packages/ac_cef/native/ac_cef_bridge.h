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
    int64_t browser_id, const char* target_url, const char* target_frame_name,
    int disposition, int user_gesture);
typedef void (*OnCursorChangedCallback)(int64_t browser_id, int cursor_type);
typedef void (*OnGotFocusCallback)(int64_t browser_id);
typedef void (*OnStatusMessageCallback)(int64_t browser_id, const char* value);
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
    int64_t browser_id, const char* url, int is_redirect, int user_gesture);

typedef int (*OnBeforeResourceLoadCallback)(
    int64_t browser_id, const char* url, const char* method);

/// Called just before a context menu is displayed.
/// [count] is the number of items in the default menu.
/// [command_ids] / [labels] / [item_types] / [enabled_flags] / [checked_flags]
/// are parallel arrays of length [count] describing each default item.
/// The following fields come from CefContextMenuParams:
///   [link_url]         — URL of the hovered link (empty if none)
///   [page_url]         — URL of the top-level page
///   [frame_url]        — URL of the focused frame
///   [source_url]       — URL of the image/media element (empty if none)
///   [selection_text]   — currently selected text (empty if none)
///   [misspelled_word]  — misspelled word under cursor (empty if none)
///   [media_type]       — cef_media_type_t int (0=none,1=image,2=video,3=audio,4=file,5=plugin)
///   [type_flags]       — bitmask of CefContextMenuTypeFlags
///   [media_state_flags]— bitmask of CefContextMenuMediaStateFlags
///   [edit_state_flags] — bitmask of CefContextMenuEditStateFlags
///   [is_editable]      — 1 if the context node is editable
///   [has_image_contents]— 1 if there is an image loaded in the node
/// Dart must copy any data it needs — all pointers are invalid after return.
/// After this callback returns, C++ clears the native menu so no OS menu appears;
/// Dart should show a custom Flutter overlay instead.
typedef void (*OnBeforeContextMenuCallback)(
    int64_t browser_id, int x, int y,
    // Menu items (parallel arrays of length count)
    int count,
    const int*    command_ids,
    const char**  labels,
    const int*    item_types,
    const int*    enabled_flags,
    const int*    checked_flags,
    // CefContextMenuParams fields
    const char*   link_url,
    const char*   page_url,
    const char*   frame_url,
    const char*   source_url,
    const char*   selection_text,
    const char*   misspelled_word,
    int           media_type,
    int           type_flags,
    int           media_state_flags,
    int           edit_state_flags,
    int           is_editable,
    int           has_image_contents);

typedef void (*OnPopupShowCallback)(int64_t browser_id, int show);
typedef void (*OnPopupSizeCallback)(int64_t browser_id, int x, int y, int width, int height);

/// Fired when the page enters or exits fullscreen mode.
typedef void (*OnFullscreenModeChangeCallback)(int64_t browser_id, int fullscreen);

/// Fired when the page reports new favicon URLs.
/// [urls_flat] is a '\0'-separated list terminated by '\0\0'. May be NULL.
typedef void (*OnFaviconUrlChangeCallback)(int64_t browser_id, const char* urls_flat);

/// Fired by CefFindHandler::OnFindResult each time the browser reports match status.
/// [identifier]           matches the value from ac_cef_find.
/// [count]                total number of matches found so far.
/// [active_match_ordinal] 1-based index of the currently highlighted match (0 if none).
/// [selection_rect_*]     bounding rect of the active match in physical pixels.
/// [final_update]         1 when the search is complete.
typedef void (*OnFindResultCallback)(
    int64_t browser_id,
    int     identifier,
    int     count,
    int     active_match_ordinal,
    int     selection_rect_x,
    int     selection_rect_y,
    int     selection_rect_w,
    int     selection_rect_h,
    int     final_update);

/// Called before a key event is sent to the renderer.
/// [is_keyboard_shortcut_out] is written to 1 if the event is a keyboard shortcut.
/// Returns 1 to cancel the event (prevent it reaching the renderer).
typedef int  (*OnPreKeyEventCallback)(
    int64_t browser_id, int type,
    int windows_key_code, int native_key_code, int modifiers,
    int character, int unmodified_character, int is_system_key,
    int* is_keyboard_shortcut_out);

/// Called after the renderer processes a key event.
/// Returns 1 to indicate the event was handled.
typedef int  (*OnKeyEventCallback)(
    int64_t browser_id, int type,
    int windows_key_code, int native_key_code, int modifiers,
    int character, int unmodified_character, int is_system_key);

/// Called when a certificate error occurs during a navigation.
/// Dart must respond via ac_cef_certificate_error_response.
typedef int  (*OnCertificateErrorCallback)(
    int64_t browser_id, int cert_error,
    const char* request_url, int64_t callback_id);

/// Called when the browser's render process terminates unexpectedly.
/// [status] maps to cef_termination_status_t: 0=abnormal, 1=killed, 2=crashed,
///          3=oom, 4=launch_failed, 5=integrity_failure.
/// [error_code] and [error_string] provide additional detail where available.
typedef void (*OnRenderProcessTerminatedCallback)(
    int64_t browser_id, int status, int error_code, const char* error_string);

/// Called when a page asks to leave (beforeunload event).
/// Return 1 from Dart to handle the dialog (suppress the default close);
/// call ac_cef_js_dialog_response(callback_id, 1, "") to confirm leaving or
/// ac_cef_js_dialog_response(callback_id, 0, "") to stay.
/// Return 0 to let CEF auto-accept the dialog.
typedef int  (*OnBeforeUnloadDialogCallback)(
    int64_t browser_id, const char* message_text,
    int is_reload, int64_t callback_id);

/// Called when the page wants to show a tooltip.
/// Return 1 if Dart handled the tooltip (suppresses CEF default).
typedef int  (*OnTooltipCallback)(
    int64_t browser_id, const char* text);

/// Called by CEF's CefRenderHandler::OnPaint for every frame.
/// [buffer] points to CEF-owned BGRA pixel data of [width] x [height] pixels.
/// Dart must copy the data within this callback — the pointer is invalid after return.
/// [dirty_rects] is a flat array of (x, y, width, height) int quads, one per dirty region.
/// [dirty_count] is the number of rects (i.e. dirty_rects has dirty_count * 4 elements).
typedef void (*OnPaintCallback)(
    int64_t browser_id,
    int is_popup,
    const void* buffer,
    int width,
    int height,
    const int* dirty_rects,
    int dirty_count);

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
  OnStatusMessageCallback        on_status_message;
  OnConsoleMessageCallback       on_console_message;
  OnJSDialogCallback             on_js_dialog;
  OnBeforeDownloadCallback       on_before_download;
  OnDownloadUpdatedCallback      on_download_updated;
  OnBeforeBrowseCallback         on_before_browse;
  OnBeforeResourceLoadCallback   on_before_resource_load;
  OnBeforeContextMenuCallback    on_before_context_menu;
  OnPopupShowCallback            on_popup_show;
  OnPopupSizeCallback            on_popup_size;
  OnPaintCallback                on_paint;
  GetViewRectCallback            get_view_rect;
  // ── Session 3 additions ──────────────────────────────────────────────────
  OnFullscreenModeChangeCallback on_fullscreen_mode_change;
  OnFaviconUrlChangeCallback     on_favicon_url_change;
  OnPreKeyEventCallback          on_pre_key_event;
  OnKeyEventCallback             on_key_event;
  OnCertificateErrorCallback     on_certificate_error;
  // ── Session 7 additions ──────────────────────────────────────────────────
  OnRenderProcessTerminatedCallback on_render_process_terminated;
  OnBeforeUnloadDialogCallback      on_before_unload_dialog;
  OnTooltipCallback                 on_tooltip;
  // ── Session 15 additions ─────────────────────────────────────────────────
  OnFindResultCallback              on_find_result;
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

// ─── IME ─────────────────────────────────────────────────────────────────────

/// Set the IME composition string shown in the renderer.
/// [cursor_pos] is the caret position within [text] (0-based code-unit index).
/// Pass cursor_pos = -1 to place the caret at the end of text.
/// [selection_start] / [selection_end]: range to replace (-1 = current cursor).
AC_CEF_EXPORT void ac_cef_ime_set_composition(
    int64_t browser_id,
    const char* text,
    int cursor_pos,
    int selection_start,
    int selection_end);

/// Cancel any active IME composition without committing.
AC_CEF_EXPORT void ac_cef_ime_cancel_composition(int64_t browser_id);

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

/// Cancel a download via its download_id.
AC_CEF_EXPORT void ac_cef_cancel_download(int64_t browser_id, int64_t download_id);

/// Pause an active download.
AC_CEF_EXPORT void ac_cef_pause_download(int64_t browser_id, int64_t download_id);

/// Resume a paused download.
AC_CEF_EXPORT void ac_cef_resume_download(int64_t browser_id, int64_t download_id);

/// Respond to an OnCertificateError callback.
/// [allow] = 1 to proceed with the request despite the error, 0 to cancel.
AC_CEF_EXPORT void ac_cef_certificate_error_response(int64_t callback_id, int allow);

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

// ─── Find in page ─────────────────────────────────────────────────────────────

/// Start or continue a find-in-page search.
/// [search_text]  – text to find.
/// [forward]      – 1 = forward, 0 = backward.
/// [match_case]   – 1 = case-sensitive.
/// [find_next]    – 1 = continue previous search, 0 = new search.
AC_CEF_EXPORT void ac_cef_find(
    int64_t browser_id,
    const char* search_text,
    int forward,
    int match_case,
    int find_next);

/// Stop an active find-in-page search.
/// [clear_selection] – 1 = deselect the current match.
AC_CEF_EXPORT void ac_cef_stop_find(int64_t browser_id, int clear_selection);

// ─── Async source / text retrieval ────────────────────────────────────────────

/// Callback invoked when GetSource / GetText completes.
/// [callback_id] matches the value passed to ac_cef_get_source / ac_cef_get_text.
/// [text] is null-terminated and owned by the bridge until the callback returns.
typedef void (*OnStringVisitCallback)(int64_t callback_id, const char* text);

/// Retrieve the HTML source of the main frame asynchronously.
AC_CEF_EXPORT void ac_cef_get_source(
    int64_t browser_id,
    int64_t callback_id,
    OnStringVisitCallback callback);

/// Retrieve the plain-text content of the main frame asynchronously.
// ─── LoadRequest (POST) ──────────────────────────────────────────────────────

/// Load a URL with custom method and optional body.
/// method: e.g. "POST", "PUT" — if NULL defaults to "GET".
/// body: request body bytes — NULL or empty for no body.
/// body_size: byte count of body.
AC_CEF_EXPORT void ac_cef_load_request(
    int64_t browser_id,
    const char* url,
    const char* method,
    const char* body,
    int         body_size
);

// ─── Audio ─────────────────────────────────────────────────────────────────────

/// Mute or unmute the browser's audio output.
AC_CEF_EXPORT void ac_cef_set_audio_muted(int64_t browser_id, int muted);

/// Returns 1 if the browser's audio is currently muted, 0 otherwise.
AC_CEF_EXPORT int  ac_cef_is_audio_muted(int64_t browser_id);

AC_CEF_EXPORT void ac_cef_get_text(
    int64_t browser_id,
    int64_t callback_id,
    OnStringVisitCallback callback);

#ifdef __cplusplus
}
#endif
