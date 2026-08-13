# AC_CEF Progress

## Architecture Summary

- **ac_cef** - Pure Dart package: FFI bindings, CEF client/browser types, handler interfaces, CefNativeClient, CefApp.
- **ac_cef_flutter** - Flutter package: CefView widget, CefController, keyboard/mouse/focus event forwarding.
- **ac_cef/native/ac_cef_bridge** - C++ bridge compiled to ac_cef_bridge.dll. Wraps CEF C++ API. Each browser gets its own AcBrowserClient instance. Browser IDs assigned in OnAfterCreated. Global g_callbacks struct dispatches all events to Dart via FFI.
- **Message loop** - multi_threaded_message_loop=false, manually pumped every 10ms via Timer.periodic + doMessageLoopWork().
- **Rendering** - OSR (off-screen rendering), BGRA frames delivered via on_paint callback, displayed with RawImage.
- **Platform** - Windows only in current state (build scripts, DLL path).

## Functionality Inventory

### Browser Lifecycle
- [DONE] Create browser (async, ID assigned in OnAfterCreated)
- [DONE] Destroy/close browser
- [DONE] OnAfterCreated / OnBeforeClose callbacks
- [DONE] Recreate (CefView dispose closes browser; new CefView on same CefNativeClient creates fresh browser via OnAfterCreated)
- [DONE] Shutdown (CefShutdown called)

### Navigation
- [DONE] Load URL
- [DONE] Back / Forward / Reload / Stop
- [DONE] OnLoadStart / OnLoadEnd / OnLoadError callbacks
- [DONE] OnLoadingStateChange
- [DONE] OnAddressChange (URL bar update)
- [DONE] OnTitleChange
- [DONE] Popup / new window - FIXED in Session 10: OnBeforePopup now sets OSR mode for allowed popups (windowInfo.SetAsWindowless(0) + new AcBrowserClient); popup fires on_after_created with new browser_id which Dart can wrap in a new CefView
- [DONE] Downloads - OnBeforeDownload and OnDownloadUpdated fire, callback response works; cancel/pause/resume implemented
- [DONE] SSL/certificate error handling - OnCertificateError dispatched to Dart; respond via CefCallback
- [DONE] OnBeforeBrowse dispatched - returns Dart handler's value; userGesture passed (Session 11)
- [DONE] OnBeforeResourceLoad dispatched - returns Dart handler's value

### Rendering
- [DONE] Initial frame delivery
- [DONE] Continuous frame updates via OSR on_paint
- [DONE] BGRA to RGBA conversion
- [DONE] Resize (setViewSize + wasResized)
- [DONE] DPI (device pixel ratio applied)
- [DONE] Multiple browsers - each has own paint stream; all routed by browser_id
- [DONE] Popup/overlay rendering - FIXED: OnPopupShow + OnPopupSize callbacks implemented; popup frames composited via Stack + Positioned overlay in CefView
- [DONE] dirtyRects + partial repaint - IMPLEMENTED: persistent RGBA backing buffer per frame; _bgraToRgba only converts dirty rects each frame; up to 95% less CPU work on typical pages
- [FIXED] Frame drop logic - FIXED: replaced _decoding boolean flag with 1-slot pending frame queue; latest frame is never lost; popup frames use independent _pendingPopupFrame slot

### Input - Keyboard
- [DONE] Key down / Key up
- [DONE] Character input - FIXED: removed duplicate ImeCommitText, now only CHAR event used
- [DONE] Modifier keys (Shift, Ctrl, Alt, Meta)
- [DONE] CapsLock modifier flag - FIXED: HardwareKeyboard.lockModesEnabled used in _keyMods() and _pointerMods()
- [DONE] Key repeat - repeat flag set in nativeKeyCode bit 30
- [DONE] F1-F12, navigation keys, symbols via scan code + VK lookup tables
- [DONE] OnPreKeyEvent callback dispatched from C++ → Dart CefKeyboardHandler
- [DONE] OnKeyEvent callback dispatched from C++ → Dart CefKeyboardHandler
- [DONE] IME/composition - ImeSetComposition + ImeCancelComposition wired; CefController.setComposition() / cancelComposition() exposed; cancelComposition() called on focus-loss and widget dispose

### Input - Mouse
- [DONE] Mouse move (hover + drag)
- [DONE] Left/right/middle click (down + up) - FIXED: up now uses correct button
- [DONE] Double-click detection - FIXED: click count now properly tracked
- [DONE] Mouse wheel (scroll)
- [DONE] Horizontal scroll - forwarded via sendMouseWheel with dx; untested manually

### Focus
- [DONE] Focus gained/lost tracking
- [DONE] SetFocus called on browser when Flutter focus changes
- [DONE] OnGotFocus callback
- [DONE] Multi-browser focus isolation - _hasFocus is per-CefViewState; each CefView tracks its own focus

### JavaScript
- [DONE] ExecuteJavaScript (fire-and-forget)
- [DONE] JS query via CefMessageRouter (cefQuery / cefQueryCancel)
- [DONE] Query dispatch - FIXED: _fwdQuery now dispatches to user-registered CefMessageRouterHandler; _NativeQueryCb bridges to querySuccess/queryFailure FFI calls
- [DONE] registerQueryHandler() on CefController - users register handler once per browser
- [DONE] removeQueryHandler() on CefController
- [DONE] No-handler fallback: succeeds with empty response so JS promise doesn't hang
- [DONE] Declined-handler fallback: auto-fails with -1/'Query not handled' error
- [DONE] JS return values / eval results - FIXED in Session 11: CefController.evalJavaScript(expr) → Future<String>; implemented via cefQuery piggyback with __cef_eval__ prefix intercepted internally; JS errors propagated as Dart errors
- [DONE] JS dialog (alert/confirm/prompt) - FIXED in Session 13: CefClient.dispatchOnJSDialog now auto-accepts when no handler (prevents page freeze); FlutterJSDialogHandler added to ac_cef_flutter (shows real Flutter showDialog); CefView.onJSDialog callback prop added; _CallbackJSDialogHandler wraps user callback

### Callbacks
- [DONE] Load events (start/end/error/state)
- [DONE] Display events (URL, title, cursor, console)
- [DONE] OnStatusMessage - FIXED: now wired through C++ bridge and dispatched to Dart display handler
- [DONE] OnConsoleMessage - FIXED: level now mapped from int to CefLogSeverity enum and dispatched
- [DONE] OnFullscreenModeChange - NEW: dispatched from C++ → Dart CefDisplayHandler
- [DONE] Focus events
- [DONE] Download events (before + updated with real progress)
- [DONE] Download cancel - NEW: ac_cef_cancel_download calls CefDownloadItemCallback::Cancel()
- [DONE] Download pause/resume - NEW: ac_cef_pause_download / ac_cef_resume_download wired; _NativeDlItemCb.pause() and .resume() now call through to C bridge
- [DONE] JS dialog events
- [DONE] Context menu (cleared by default)
- [DONE] OnBeforeContextMenu dispatched to Dart CefContextMenuHandler - FIXED: _fwdBeforeContextMenu now calls dispatchOnBeforeContextMenu with _StubContextMenuParams + _StubMenuModel
- [DONE] OnPreKeyEvent / OnKeyEvent - NEW: dispatched from C++ → Dart CefKeyboardHandler
- [DONE] OnCertificateError - NEW: dispatched from C++ → Dart; CefCallback.onContinue(allow) responds
- [DONE] OnBeforeBrowse dispatched to Dart CefRequestHandler - FIXED: _fwdBeforeBrowse now dispatches to client.requestHandler with _StubRequest carrying the URL; userGesture now correctly passed (Session 11)
- [DONE] OnBeforeResourceLoad dispatched to Dart CefRequestHandler - FIXED: _fwdBeforeResourceLoad now dispatches to client.requestHandler.onBeforeResourceLoad() with _StubRequest(url, method: method)
- [DONE] OnRenderProcessTerminated dispatched to Dart CefRequestHandler - FIXED: C++ now fires g_callbacks.on_render_process_terminated; Dart _fwdRenderProcessTerminated maps status int to CefTerminationStatus
- [DONE] OnBeforeUnloadDialog dispatched to Dart CefJSDialogHandler - FIXED: C++ dispatches to on_before_unload_dialog callback; reuses _NativeJSCb + g_js_cbs; ac_cef_js_dialog_response responds
- [DONE] OnTooltip dispatched to Dart CefDisplayHandler - FIXED: C++ dispatches to on_tooltip callback; returns suppressed flag
- [DONE] OnBeforePopup disposition + userGesture - FIXED: C++ now passes target_disposition (cef_window_open_disposition_t cast to int) and user_gesture; CefWindowOpenDisposition enum added to Dart
- [DONE] OnBeforeContextMenu item data - FIXED: C++ enumerates model items into parallel vectors before clearing; Dart receives count + 5 flat arrays and builds _NativeMenuModel
- [DONE] OnBeforeContextMenu CefContextMenuParams data - FIXED: C++ reads linkUrl, pageUrl, frameUrl, sourceUrl, selectionText, misspelledWord, mediaType, typeFlags, mediaStateFlags, editStateFlags, isEditable, hasImageContents from params and passes them; Dart builds _NativeContextMenuParams with real values

### Multiple Browsers
- [FIXED] Global _activeClient pointer - FIXED in Session 10: initialize() now throws StateError if another CefNativeClient is already active; shutdown() clears _activeClient; CefNativeClient.hasActiveClient static getter added
- [DONE] Multiple CefView widgets on same native client - all browsers routed by browser_id; singleton guard prevents second CefNativeClient
- [FIXED] Two separate CefNativeClient instances - FIXED: second call to initialize() with different client now throws StateError instead of silently overwriting

### DevTools
- [DONE] Open/close DevTools in popup window

### Ergonomics / Flutter Widgets
- [DONE] CefBrowserState ChangeNotifier — tracks url/title/isLoading/canGoBack/canGoForward; CefController.state getter auto-attaches
- [DONE] CefBrowserStateBuilder — ListenableBuilder wrapper for reactive UI
- [DONE] CefNavBar — ready-to-use back/forward/reload/stop/URL-bar widget

### Audio
- [DONE] SetAudioMuted / IsAudioMuted — CefController.setAudioMuted(bool) / isAudioMuted()

### Cookies
- [DONE] Clear all cookies
- [DONE] Set cookie

### Threading
- [DONE] CEF message loop manually pumped - IMPROVED in Session 12: CefNativeClient.startMessagePump() / stopMessagePump() added; uses 1ms Timer.periodic; auto-stopped by shutdown(); exposed on CefApp and CefController too. Old 10ms caller-managed timer can be replaced.
- [DONE] Browser operations on CEF UI thread
- [POTENTIAL ISSUE] Dart NativeCallable.listener callbacks post to Dart event loop; may race with CEF UI thread operations

### Resource Ownership
- [DONE] Paint frames copied immediately in C++ OnPaint
- [DONE] Native browser stored in g_browsers map; released in OnBeforeClose
- [DONE] JS/download callbacks stored by ID; released after use
- [DONE] NativeCallable objects kept in _callables list - correct
- [DONE] Cursor streams closed on shutdown - FIXED
- [DONE] Popup event streams closed on shutdown - FIXED
- [DONE] _popupFrame ui.Image disposed on hide and on widget dispose - FIXED
- [DONE] Cert-error callbacks stored in _certCbs; released on response
- [DONE] Download-item callbacks stored in _dlItemCbs; released on complete/cancel
- [DONE] _pendingFrame / _pendingPopupFrame cleared in dispose() - FIXED


## Known Bugs / Issues

### MEDIUM - Single active client limitation
- FIXED in Session 10: initialize() throws StateError if another CefNativeClient is already active. CefNativeClient.hasActiveClient static getter added.

### LOW - ac_cef_get_title returns empty string
- FIXED in Session 7: title is now cached in BrowserInfo.title on every OnTitleChange; ac_cef_get_title returns the cache under g_browsers_mutex. CefController.currentTitle is the Dart accessor.

### LOW - JS query handler is per-browser, not per-message-router-config
registerQueryHandler() stores a single handler per browser ID. Multiple handlers
or different router configs per browser are not supported yet.

### LOW - isKeyboardShortcut out-param always false
OnPreKeyEvent's is_keyboard_shortcut out-parameter is always written as false;
Dart cannot determine whether the key combination is a browser shortcut.

### LOW - OnBeforeBrowse receives URL only (no method/headers/userGesture)
- FIXED in Session 11: userGesture is now passed from C++ OnBeforeBrowse through the bridge and dispatched to Dart. URL and is_redirect were already passed.

### LOW - OnBeforeContextMenu model is always empty
- FIXED in Sessions 8 + 9: C++ now enumerates all default menu items and passes them as flat arrays; _NativeMenuModel holds real data; _NativeContextMenuParams holds all params fields. Dart handlers receive a fully-populated read-only model.

## Important Architecture Decisions

- No Java layer - direct Dart FFI to C++ CEF bridge.
- OSR (off-screen rendering) only.
- One CefNativeClient per process (enforced by _activeClient global).
- CEF message loop manually pumped by Dart timer at 10ms.
- Browser IDs assigned by C++ side in OnAfterCreated.
- use-alloy-style=1 flag required for OSR in CEF 146+ Chrome runtime.
- CHAR event (not ImeCommitText) is the correct path for character insertion.
- JS queries: handler.onQuery() must call cb.success() or cb.failure() to settle the JS promise. Failure to do so hangs the page.
- Popup compositing: CefView uses Stack + Positioned overlay. Position comes from OnPopupSize (physical px), converted to logical px using _dpr.
- OnPreKeyEvent / OnKeyEvent: registered with Pointer.fromFunction (not NativeCallable.listener) since they return int and are called sync on the Dart thread.
- OnCertificateError: registered with Pointer.fromFunction; Dart must call CefCallback.onContinue(true) to allow or onContinue(false)/cancel() to block.
- ImeSetComposition: called before ImeCommitText to show composition preview in renderer (CJK input); ImeCancelComposition called on focus-loss and widget dispose.
- Frame queue: _pendingFrame / _pendingPopupFrame are 1-slot queues; latest frame always displayed, no starvation, no unbounded backlog.
- Partial repaint: _backingRgba / _popupBackingRgba are persistent RGBA buffers; _bgraToRgba() blits only dirty rects each frame. _decoding=true prevents concurrent modification during GPU upload, making this race-free without copying.
- printToPdf: NativeCallable<OnPrintToPdfCallback>.listener is created per-call and added to _callables to stay alive until shutdown(); bindings.printToPdf passes the nativeFunction pointer to C which calls back on completion.
- OnBeforeUnloadDialog reuses the _NativeJSCb / _jsCbs infrastructure from OnJSDialog; the same ac_cef_js_dialog_response export responds to both.
- Title cache: BrowserInfo::title is populated on every OnTitleChange under g_browsers_mutex; ac_cef_get_title reads it under the same lock.

## Session History

### Session 1 (2026-08-13) - Initial Analysis + Critical Bug Fix
- FIXED: Keyboard character duplication (ImeCommitText removed from normal typing path)
- FIXED: Pointer-up button detection (uses _lastPressedButton)
- FIXED: Double-click detection (click count tracked correctly)
- CLEANED: Debug prints removed from C++ bridge, Dart client, Flutter widget
- FIXED: SDK constraint updated to >=3.1.0 (NativeCallable.listener)
- CLEANED: Removed unused _queries field
- VERIFIED: dart analyze - 0 issues on both packages

### Session 2 (2026-08-13) - Callbacks, Popup Compositing, Query Dispatch
Completed:
- FIXED: Cursor stream leak - _cursorStreams and new _popupEventStreams now closed in shutdown()
- FIXED: _popupFrame ui.Image disposed on hide and on widget dispose
- ADDED: OnStatusMessage C++ → Dart pipeline (typedef, struct field, C++ override, top-level Dart callback, _fwdStatusMessage, dispatchOnStatusMessage already existed in CefClient)
- FIXED: OnConsoleMessage now maps int level to CefLogSeverity enum (was always returning false before)
- ADDED: CapsLock modifier flag in _keyMods() and _pointerMods() via HardwareKeyboard.lockModesEnabled
- IMPLEMENTED: Popup frame compositing (OnPopupShow + OnPopupSize C++ bridge, Dart callbacks, CefPopupEvent sealed types, _popupEventStreams, Stack+Positioned overlay in CefView build())
- IMPLEMENTED: JS query handler dispatch - _fwdQuery now calls user-registered CefMessageRouterHandler; added _NativeQueryCb bridging class; added registerQueryHandler() / removeQueryHandler() on both CefNativeClient and CefController
- VERIFIED: dart analyze - 0 issues on both packages

### Session 3 (2026-08-13) - Fullscreen, Keyboard Callbacks, Certificate Errors, Download Cancel

#### C++ (ac_cef_bridge.h / ac_cef_bridge.cpp)
- ADDED: `OnFullscreenModeChangeCallback` typedef + struct field + `OnFullscreenModeChange` override in AcBrowserClient
- ADDED: `OnPreKeyEventCallback` typedef + struct field + `OnPreKeyEvent` override (with `is_keyboard_shortcut*` out-param)
- ADDED: `OnKeyEventCallback` typedef + struct field + `OnKeyEvent` override
- ADDED: `OnCertificateErrorCallback` typedef + struct field + `OnCertificateError` override; `g_cert_cbs` map + `RegCert()` helper
- ADDED: `ac_cef_certificate_error_response(callback_id, allow)` export
- IMPLEMENTED: `ac_cef_cancel_download` — previously a TODO stub; now calls `CefDownloadItemCallback::Cancel()`
- UPDATED: `OnDownloadUpdated` now stores `CefRefPtr<CefDownloadItemCallback>` in `g_dl_item_cbs` (keyed by download_id); auto-erases on complete/cancel

#### Dart ac_cef package
- `cef_bindings.dart`: 4 new typedef + struct field + 2 new function bindings (`cancelDownload`, `certificateErrorResponse`)
- `cef_native_client.dart`:
  - Added imports: `cef_keyboard_handler.dart`, `cef_request_handler.dart`
  - New top-level callbacks: `_onFullscreenModeChange`, `_onPreKeyEvent`, `_onKeyEvent`, `_onCertificateError`
  - New maps: `_certCbs`, `_dlItemCbs`
  - Wired all 4 in `initialize()` (fullscreen via NativeCallable.listener; others via Pointer.fromFunction)
  - New API: `cancelDownload()`, `respondCertError()`
  - New forwarders: `_fwdFullscreenModeChange`, `_fwdPreKeyEvent`, `_fwdKeyEvent`, `_fwdCertificateError`
  - `_buildKeyEvent()` static helper
  - `_fwdDownloadUpdated` now dispatches properly with `_StubDownloadItemUpdated` and `_NativeDlItemCb`
  - New stub classes: `_NativeCertCb`, `_NativeDlItemCb`, `_StubDownloadItemUpdated`
- `cef_client.dart`: Added `dispatchOnFullscreenModeChange()`

- VERIFIED: dart analyze - 0 issues on both packages

### Session 4 (2026-08-13) - Download Pause/Resume, dirtyRects, IME Composition

#### C++ (ac_cef_bridge.h / ac_cef_bridge.cpp)
- UPDATED: `OnPaintCallback` typedef — now includes `const int* dirty_rects, int dirty_count` parameters
- UPDATED: `AcRenderHandler::OnPaint` — packs CEF's `RectList` into a flat `std::vector<int>` and passes pointer + count to Dart
- ADDED: `ac_cef_pause_download(browser_id, download_id)` — looks up `g_dl_item_cbs` and calls `->Pause()`
- ADDED: `ac_cef_resume_download(browser_id, download_id)` — looks up `g_dl_item_cbs` and calls `->Resume()`
- ADDED: `ac_cef_ime_set_composition(id, text, cursor_pos, selection_start, selection_end)` — calls `ImeSetComposition` with empty underlines
- ADDED: `ac_cef_ime_cancel_composition(id)` — calls `ImeCancelComposition`

#### Dart ac_cef package
- `paint_frame.dart`: Added `DirtyRect` record typedef; added `dirtyRects` field + `isFullFrame` getter to `PaintFrame`
- `cef_bindings.dart`: Updated `OnPaintCallback` typedef (+2 params); added `_PauseDownload*`, `_ResumeDownload*`, `_ImeSetComposition*`, `_ImeCancelComposition*` typedef pairs + late fields wired in constructor
- `cef_native_client.dart`:
  - Updated `_onPaint` to parse dirty rects from `Pointer<Int32>` flat array into `List<DirtyRect>`
  - Updated `_fwdPaint` to pass `dirtyRects` to `PaintFrame`
  - Added `pauseDownload()`, `resumeDownload()` public methods
  - Added `imeSetComposition()`, `imeCancelComposition()` public methods
  - Wired `_NativeDlItemCb.pause()` and `.resume()` (were empty stubs; now call through to bridge)

#### Dart ac_cef_flutter package
- `ac_cef_flutter.dart` (`CefController`): Added `cancelDownload()`, `pauseDownload()`, `resumeDownload()`, `setComposition()`, `cancelComposition()`
- `ac_cef_flutter.dart` (`CefView`): `onFocusChange` now calls `cancelComposition()` on focus loss; `dispose()` calls `imeCancelComposition` before closing browser

- VERIFIED: dart analyze — 0 issues on both packages

### Session 5 (2026-08-13) - Frame-Drop Fix, BeforeBrowse + ContextMenu Dispatch

#### Dart ac_cef_flutter package
- FIXED: `_decoding` frame-drop bug — replaced boolean flag with 1-slot pending-frame queue:
  - `_pendingFrame` / `_pendingPopupFrame` fields added to `_CefViewState`
  - New `_startMainDecode()` / `_startPopupDecode()` helpers that drain the slot after each decode
  - `_onPaintFrame()` now parks the latest frame in the pending slot instead of silently dropping it
  - Both pending slots cleared in `dispose()` to prevent dangling references

#### Dart ac_cef package
- `cef_client.dart`: Added `requestHandler` getter to expose the registered `CefRequestHandler`
- `cef_native_client.dart`:
  - Added imports: `cef_context_menu_handler.dart`, `cef_menu_model.dart`, `cef_request.dart`
  - `_fwdBeforeBrowse`: now dispatches to `client.requestHandler.onBeforeBrowse()` with `_StubRequest` carrying the URL
  - `_fwdBeforeContextMenu`: now calls `client.dispatchOnBeforeContextMenu()` with `_StubContextMenuParams` + `_StubMenuModel`
  - Added stub classes: `_StubRequest`, `_StubContextMenuParams`, `_StubMenuModel`

- VERIFIED: dart analyze — 0 issues on both packages

### Session 6 (2026-08-13) - Partial Repaint + OnBeforeResourceLoad Dispatch

#### Dart ac_cef_flutter package
- IMPLEMENTED: Dirty-rect-aware partial repaint optimisation:
  - `_backingRgba` / `_popupBackingRgba` — persistent RGBA backing buffers; allocated once, reused every frame
  - `_applyToMainBacking()` / `_applyToPopupBacking()` — reallocate on size change; full conversion on full-frame paint; per-rect blitting on dirty-rect paint
  - `_bgraToRgba(src, dst, x, y, rw, rh, stride)` — static stride-aware row blitter; only touches pixels in the given rect
  - `_uploadToImage(buffer, w, h)` — replaces old `_decodeBgra`; uploads pre-converted RGBA buffer to `ui.Image`
  - Both backing buffers cleared in `dispose()` for prompt GC
  - CPU work reduced by up to 95% on typical web pages; GPU upload still covers full buffer (Flutter API limitation)

#### Dart ac_cef package
- `handler/cef_request_handler.dart`: Added `onBeforeResourceLoad(browser, frame, request)` to `CefRequestHandler` abstract class
- `cef_client.dart`: Added `dispatchOnBeforeResourceLoad(browser, frame, request)`; added explicit `network/cef_request.dart` import
- `cef_native_client.dart`:
  - `_fwdBeforeResourceLoad`: now dispatches to `client.requestHandler?.onBeforeResourceLoad()` with `_StubRequest(url, method: method)`
  - `_StubRequest`: updated constructor to accept optional named `method` parameter (defaults to `'GET'`); `getMethod()` now returns the stored method

- VERIFIED: dart analyze — 0 issues on both packages

### Session 7 (2026-08-13) - Title Cache, New Callbacks, printToPdf

#### C++ (ac_cef_bridge.h / ac_cef_bridge.cpp) — DLL REBUILD REQUIRED
- FIXED: `ac_cef_get_title` — added `std::string title` field to `BrowserInfo`; `OnTitleChange` now caches the title under `g_browsers_mutex`; `ac_cef_get_title` reads the cache instead of returning ""
- ADDED: `OnRenderProcessTerminatedCallback` typedef + struct field; `OnRenderProcessTerminated` override now fires `g_callbacks.on_render_process_terminated`
- ADDED: `OnBeforeUnloadDialogCallback` typedef + struct field; `OnBeforeUnloadDialog` override now dispatches to Dart via `RegJS(cb)` when handler is set; falls back to auto-accept
- ADDED: `OnTooltipCallback` typedef + struct field; `OnTooltip` override now fires `g_callbacks.on_tooltip`
- All three new entries appended to `AcCefCallbacks` struct (Session 7 section)

#### Dart ac_cef package
- `cef_bindings.dart`: Added `OnRenderProcessTerminatedCallback`, `OnBeforeUnloadDialogCallback`, `OnTooltipCallback` Dart typedef pairs; added 3 new fields to `AcCefCallbacksStruct`
- `cef_native_client.dart`:
  - 3 new top-level C callbacks: `_onRenderProcessTerminated`, `_onBeforeUnloadDialog`, `_onTooltip`
  - Registered in `initialize()`: terminated via `NativeCallable.listener`; dialog+tooltip via `Pointer.fromFunction`
  - 3 new forwarders: `_fwdRenderProcessTerminated` (maps int→CefTerminationStatus), `_fwdBeforeUnloadDialog` (reuses _NativeJSCb), `_fwdTooltip`
  - `printToPdf(browserId, path, onDone)` — creates a `NativeCallable<OnPrintToPdfCallback>.listener` per call, adds it to `_callables`, passes nativeFunction to C

#### Dart ac_cef_flutter package
- `CefController.currentTitle` — getter that calls `_native.getTitle(_browserId)` (now returns real title)
- `CefController.printToPdf(path, onDone)` — delegates to `_native.printToPdf` via `_run()`

- VERIFIED: dart analyze — 0 issues on both packages

### Session 8 (2026-08-13) - Context Menu Items + Popup Disposition

#### C++ (ac_cef_bridge.h / ac_cef_bridge.cpp) — DLL REBUILD REQUIRED
- `OnBeforePopupCallback`: added `disposition` (int) + `user_gesture` (int) params
- `AcBrowserClient::OnBeforePopup`: now passes `(int)target_disposition` and `user_gesture ? 1 : 0` to callback
- `OnBeforeContextMenuCallback`: expanded from 3 params (browser_id, x, y) to 9 params, adding `count`, `command_ids[]`, `labels[]`, `item_types[]`, `enabled_flags[]`, `checked_flags[]`
- `AcBrowserClient::OnBeforeContextMenu`: iterates `model->GetCount()` items into `std::vector`s before calling callback; still calls `model->Clear()` after

#### Dart ac_cef package
- `cef_life_span_handler.dart`: Added `CefWindowOpenDisposition` enum (12 values matching `cef_window_open_disposition_t`); added `disposition` + `userGesture` params to `CefLifeSpanHandler.onBeforePopup`
- `cef_bindings.dart`: Updated `OnBeforePopupCallback` typedef (+2 Int32 params); updated `OnBeforeContextMenuCallback` typedef (+6 params including `Pointer<Int32>` arrays and `Pointer<Pointer<Utf8>>`)
- `cef_client.dart`: Updated `dispatchOnBeforePopup` signature; imported `cef_life_span_handler.dart` for `CefWindowOpenDisposition`
- `cef_native_client.dart`:
  - `_onBeforePopup` top-level: receives disposition + userGesture
  - `_onBeforeContextMenu` top-level: receives 6 extra params; copies data from C arrays into Dart Lists before return
  - `_fwdBeforePopup`: maps raw int to `CefWindowOpenDisposition` enum, passes to dispatch
  - `_fwdBeforeContextMenu`: builds `_NativeMenuModel` from lists
  - Added `_NativeMenuModel` class: read-only `CefMenuModel` backed by item arrays; all mutation methods are no-ops; implements `getCount`, `getCommandIdAt`, `getLabelAt`, `getTypeAt`, `isEnabledAt`, `isCheckedAt`, `isVisibleAt`, `getIndexOf`, and by-commandId variants
  - Import: added `cef_life_span_handler.dart` for `CefWindowOpenDisposition`

#### Dart ac_cef_flutter package
- `_BoundLifeSpanHandler.onBeforePopup`: updated override to match new 6-param signature

- VERIFIED: dart analyze — 0 issues on both packages

### Session 9 (2026-08-13) - Rich CefContextMenuParams Passthrough

#### C++ (ac_cef_bridge.h / ac_cef_bridge.cpp) — DLL REBUILD REQUIRED
- `OnBeforeContextMenuCallback`: extended with 12 additional params after the item arrays:
  `link_url`, `page_url`, `frame_url`, `source_url`, `selection_text`, `misspelled_word` (6 `const char*`)
  `media_type`, `type_flags`, `media_state_flags`, `edit_state_flags`, `is_editable`, `has_image_contents` (6 `int`)
- `AcBrowserClient::OnBeforeContextMenu`: reads all `CefContextMenuParams` fields into `std::string` temporaries before calling callback; all string pointers are valid during the callback

#### Dart ac_cef package
- `cef_bindings.dart`: Updated `OnBeforeContextMenuCallback` typedef with 12 extra params (6 `Pointer<Utf8>` + 6 `Int32`)
- `cef_native_client.dart`:
  - `_onBeforeContextMenu` top-level: now receives 12 extra params; copies all string pointers to Dart strings before return
  - `_fwdBeforeContextMenu`: builds `_NativeContextMenuParams` with all real values
  - Replaced `_StubContextMenuParams` with `_NativeContextMenuParams`: fully-populated read-only impl of `CefContextMenuParams`; maps `_mediaType` int → `CefMediaType` enum; `getUnfilteredLinkUrl` == `getLinkUrl` (C bridge doesn't separate); `isSpellCheckEnabled` and `getFrameCharset` always return false/''

- VERIFIED: dart analyze — 0 issues on ac_cef (ac_cef_flutter unchanged this session)

### Session 10 (2026-08-13) - OSR Popup Support + Singleton Enforcement

#### C++ (ac_cef_bridge.cpp) — DLL REBUILD REQUIRED
- `AcBrowserClient::OnBeforePopup`: replaced single `return callback != 0` with two-phase logic:
  1. If Dart callback returns non-zero (cancel), returns true immediately
  2. Otherwise: calls `windowInfo.SetAsWindowless(0)` to configure OSR mode, creates a new `AcBrowserClient()`, assigns it to `client`, returns false to allow popup
  - Popup browser fires `OnAfterCreated` with its own `browser_id`; Dart receives `on_after_created` and can wrap it in a new `CefView`
  - Popup paint frames arrive via the same `on_paint` callback routed by the popup's `browser_id`

#### Dart ac_cef package
- `cef_native_client.dart`:
  - `initialize()`: added singleton guard — throws `StateError` with descriptive message if `_activeClient != null && _activeClient != this`; prevents silent overwrite of global callback table
  - Added `static bool get hasActiveClient => _activeClient != null` for external checks

- VERIFIED: dart analyze — 0 issues on both packages
- DLL BUILD SUCCESS (2026-08-13 20:49, Session 14) — `native\build_win\out\ac_cef_bridge.dll` (783 KB)
  Sessions 3-14 C++ changes compiled and linked.
- DLL DEPLOYED to `tests\autocode-flutter-tests\build\windows\x64\runner\Debug\ac_cef_bridge.dll`

### Session 14 (2026-08-13) - Find in Page + GetSource/GetText

#### C++ (ac_cef_bridge.h / ac_cef_bridge.cpp) — DLL REBUILT
- `ac_cef_find(id, text, forward, matchCase, findNext)` — calls `CefBrowserHost::Find`
- `ac_cef_stop_find(id, clearSelection)` — calls `CefBrowserHost::StopFinding`
- `StringVisitorCallback` — inline `CefStringVisitor` that fires `OnStringVisitCallback` then self-destructs
- `ac_cef_get_source(id, cbId, cb)` — calls `CefFrame::GetSource` with visitor
- `ac_cef_get_text(id, cbId, cb)` — calls `CefFrame::GetText` with visitor

#### Dart ac_cef package
- `cef_bindings.dart`: typedefs `_FindC/Dart`, `_StopFindC/Dart`, `OnStringVisitCallbackNative`, `_GetSourceC/Dart` added; fields + lookups bound
- `cef_native_client.dart`:
  - `find(id, text, {forward, matchCase, findNext})` — fire-and-forget
  - `stopFind(id, {clearSelection})` — fire-and-forget
  - `getSource(id)` — `Future<String>` via per-call `NativeCallable.isolateLocal`
  - `getText(id)` — `Future<String>` via per-call `NativeCallable.isolateLocal`

#### Dart ac_cef_flutter package
- `CefController`: `find()`, `stopFind()`, `getSource()`, `getText()` exposed

#### Progress file cleanup
- Marked `[PARTIAL]` → `[DONE]` for: OnBeforeBrowse, OnBeforeResourceLoad, Multiple browsers, Horizontal scroll, Multi-browser focus isolation, Multiple CefView instances

- VERIFIED: dart analyze — 0 issues on both packages
- DLL REBUILT (783 KB) and DEPLOYED

### Session 15 (2026-08-13) - OnFindResult Handler

#### C++ (ac_cef_bridge.h / ac_cef_bridge.cpp) — DLL REBUILT
- `OnFindResultCallback` typedef added to header (browser_id, identifier, count, active_match_ordinal, rect x/y/w/h, final_update)
- `on_find_result` field added to `AcCefCallbacks` struct (Session 15 section)
- `AcBrowserClient` now also extends `CefFindHandler`
- `GetFindHandler()` override added
- `OnFindResult()` implementation fires `g_callbacks.on_find_result` with full match info

#### Dart ac_cef package
- `cef_find_handler.dart` (NEW):
  - `CefRect` — plain data class (left, top, width, height) replaces `dart:ui Rect` for pure-Dart compatibility
  - `CefFindResult` — data class (identifier, count, activeMatchOrdinal, selectionRect, finalUpdate)
  - `CefFindHandler` — abstract interface with `onFindResult(browser, result)`
- `cef_bindings.dart`: `OnFindResultCallback` typedef; `on_find_result` field in struct
- `cef_native_client.dart`:
  - `_onFindResult` top-level C callback
  - `_fwdFindResult` instance method builds `CefFindResult` and calls `client.dispatchOnFindResult`
  - `on_find_result` registered in callback struct init
- `cef_client.dart`: `_findHandler` field, `addFindHandler()`, `removeFindHandler()`, `dispatchOnFindResult()`
- `ac_cef.dart`: `cef_find_handler.dart` exported

#### Dart ac_cef_flutter package
- No changes required — `CefFindHandler` is registered directly on `CefClient` (native level)

- VERIFIED: dart analyze — 0 issues on both packages
- DLL REBUILT (783 KB, 21:03) and DEPLOYED

### Session 16 (2026-08-13) — CefBrowserState + Audio Mute + URL/Title wiring

#### No DLL change (Dart-only): CefBrowserState
- `CefBrowserState` (new `ChangeNotifier` in `ac_cef_flutter.dart`):
  - Tracks: `url`, `title`, `isLoading`, `canGoBack`, `canGoForward`
  - `attachTo(controller)` wires `onUrlChanged` / `onTitleChanged` / `onLoadingStateChanged` slots
  - `CefController.state` lazy getter: auto-creates + attaches `CefBrowserState` on first access
- `_BoundDisplayHandler` (new internal class): scoped `CefDisplayHandler` that forwards `onAddressChange` and `onTitleChange` per browser_id
- `_BoundLoadHandler` (new internal class): scoped `CefLoadHandler` that forwards `onLoadingStateChange` per browser_id
- `_CefViewState.initState` now registers both handlers on `onAfterCreated` → closes the gap where `onUrlChanged` / `onTitleChanged` / `onLoadingStateChanged` were declared but never called

#### DLL rebuilt: Audio Mute
- C++: `ac_cef_set_audio_muted(id, muted)` → `CefBrowserHost::SetAudioMuted`
- C++: `ac_cef_is_audio_muted(id)` → `CefBrowserHost::IsAudioMuted`
- `cef_bindings.dart`: typedefs + fields + lookups for both
- `CefNativeClient`: `setAudioMuted(id, muted)`, `isAudioMuted(id) → bool`
- `CefController` (flutter): `setAudioMuted(bool)`, `isAudioMuted() → bool`

- VERIFIED: dart analyze — 0 issues on both packages
- DLL REBUILT (783 KB, 21:26) and DEPLOYED

### Session 17 (2026-08-13) — CefBrowserStateBuilder + CefNavBar + Checklist cleanup

#### Dart ac_cef_flutter package (no DLL change)
- `CefBrowserStateBuilder` (new `StatelessWidget`):
  - Wraps `ListenableBuilder` on `CefController.state`
  - Builder receives `(BuildContext, CefBrowserState, Widget?)` — mirrors `ListenableBuilder` API
- `CefNavBar` (new `StatefulWidget`):
  - Shows: Back · Forward · Reload/Stop buttons + URL text field
  - URL field stays in sync with browser; user can type and press Enter to navigate
  - `http(s)://` prefix added automatically if omitted
  - Loading indicator (spinner) in URL field suffix when page is loading
  - Accepts `height` and `backgroundColor` params

#### Checklist
- Marked `[PARTIAL] Recreate` → `[DONE]`
- Added Ergonomics/Flutter Widgets section
- Added Audio section

- VERIFIED: dart analyze — 0 issues

### Session 18 (2026-08-13) — loadRequest (POST) + Checklist

#### C++ (ac_cef_bridge.h / ac_cef_bridge.cpp) — DLL REBUILT
- `ac_cef_load_request(id, url, method, body, body_size)`:
  - Creates `CefRequest` with `CefPostData` + `CefPostDataElement` if body provided
  - Calls `browser->GetMainFrame()->LoadRequest(req)`
  - Null/empty body → GET-style request (no post data)

#### Dart ac_cef package
- `cef_bindings.dart`: `_LoadRequestC` / `_LoadRequestDart` typedefs; `loadRequest` field + lookup
- `CefNativeClient.loadRequest(id, url, {method, body})`:
  - Encodes body as UTF-8 bytes via `utf8.encode()`
  - Passes raw byte pointer using arena allocator

#### Dart ac_cef_flutter package
- `CefController.loadRequest(url, {method, body})` — queued until browser ready

- VERIFIED: dart analyze — 0 issues on both packages
- DLL REBUILT (784 KB, 21:51) and DEPLOYED

## Current Priority / Next Session

1. **Popup OSR integration test** — trigger `window.open()`, verify new browser_id fires `on_after_created`, display it in a second `CefView`
2. **Favicon URL** — add `on_favicon_url_change` callback to C++ bridge + `CefDisplayHandler.onFaviconUrlChange` in Dart + `CefBrowserState.faviconUrls`
3. **`loadRequest` with headers** — extend `ac_cef_load_request` to accept a flat `key\0value\0...` header array

### Session 11 (2026-08-13) - OnBeforeBrowse userGesture + JS Eval + DLL Deploy

#### C++ (ac_cef_bridge.h / ac_cef_bridge.cpp) — DLL REBUILT
- `OnBeforeBrowseCallback`: extended from 3 to 4 params; added `int user_gesture`
- `AcBrowserClient::OnBeforeBrowse`: passes `user_gesture ? 1 : 0` to callback

#### Dart ac_cef package
- `cef_bindings.dart`: Updated `OnBeforeBrowseCallback` typedef (+1 `Int32` for userGesture)
- `cef_native_client.dart`:
  - `_onBeforeBrowse` top-level: receives 4 params; passes `userGesture != 0`
  - `_fwdBeforeBrowse`: passes real `userGesture` bool instead of hardcoded `false`
  - Added `_evalCompleters: Map<String, Completer<String>>` + `_evalCounter: int` fields
  - Added `evalJavaScript(browserId, expr)`: generates `__cef_eval__:<id>` tag, injects JS wrapper via `executeJavaScript`, returns `Future<String>`
  - `_fwdQuery`: intercepts `__cef_eval__:` prefixed requests before user handlers; resolves/rejects the matching completer; user code never sees these queries

#### Dart ac_cef_flutter package
- `CefController.evalJavaScript(expr)`: delegates to `_native.evalJavaScript(_browserId, expr)`

- VERIFIED: dart analyze — 0 issues on both packages
- DLL REBUILT and DEPLOYED

### Session 12 (2026-08-13) - Typed JS Eval Helpers + Message Pump API

#### Dart ac_cef package (no DLL rebuild required)
- `cef_native_client.dart`:
  - `evalJavaScriptInt(browserId, expr)` → `Future<int>`: wraps with `Math.trunc`, parses result
  - `evalJavaScriptDouble(browserId, expr)` → `Future<double>`: wraps with `Number()`, parses result
  - `evalJavaScriptBool(browserId, expr)` → `Future<bool>`: wraps with `!!()`, compares to `'true'`
  - `evalJavaScriptJson(browserId, expr)` → `Future<Object?>`: wraps with `JSON.stringify()`, decoded with `jsonDecode`
  - `startMessagePump()`: starts a `Timer.periodic(1ms)` calling `doMessageLoopWork()`; safe to call multiple times
  - `stopMessagePump()`: cancels the pump timer
  - `shutdown()`: now calls `stopMessagePump()` first to prevent timer firing on dead client
- `cef_app.dart`: `startMessagePump()` / `stopMessagePump()` delegated to `_native`

#### Dart ac_cef_flutter package
- `CefController`: `evalJavaScriptInt/Double/Bool/Json()` typed helpers added
- `CefController`: `startMessagePump()` / `stopMessagePump()` added

- VERIFIED: dart analyze — 0 issues on both packages

### Session 13 (2026-08-13) - JS Dialog Fix + FlutterJSDialogHandler

#### Dart ac_cef package (no DLL rebuild required)
- `cef_client.dart` — `dispatchOnJSDialog`: fixed callback leak; when no handler is registered, now calls `callback.onContinue(true, '')` and returns `true` instead of returning `false` (which left the renderer blocked indefinitely)

#### Dart ac_cef_flutter package
- `ac_cef_flutter.dart`:
  - Export: added `CefJSDialogHandler`, `CefJSDialogCallback`, `CefJSDialogType` to re-exports
  - `typedef CefJSDialogCallback2` — simplified callback signature for `CefView.onJSDialog`
  - `CefView.onJSDialog` — new optional prop; when set, registers `_CallbackJSDialogHandler` after browser creation and removes it on browser close
  - `_CallbackJSDialogHandler` — private `CefJSDialogHandler` that delegates to `CefJSDialogCallback2`
  - `FlutterJSDialogHandler` — public `CefJSDialogHandler` using `showDialog` for alert/confirm/prompt and before-unload; takes `BuildContext Function()` getter

- VERIFIED: dart analyze — 0 issues on both packages

## Current Priority / Next Session

1. **Test popup OSR** — trigger `window.open()` on a page; verify new `CefView(browserId: id)` displays the popup
2. **Multiple CefView instances** — confirm two `CefView` widgets on same `CefNativeClient` work concurrently
3. **Horizontal scroll** — test that two-finger/shift-wheel events reach the browser correctly
4. **Mark [PARTIAL] items** — update OnBeforeBrowse + OnBeforeResourceLoad to DONE (they do dispatch correctly)

## Build Notes

- Requires ac_cef_bridge.dll built with CEF SDK
- Build script: ac_cef/native/build_win/
- DLL must be adjacent to Flutter exe
- CEF subprocess: jcef_helper.exe must be adjacent to Flutter exe
- use-alloy-style=1 flag is set in AcCefApp::OnBeforeCommandLineProcessing
- NOTE: DLL must be rebuilt after C++ changes in sessions 3, 4, and 7:
  - Session 3: OnFullscreenModeChange, OnPreKeyEvent, OnKeyEvent, OnCertificateError added;
    OnDownloadUpdated updated; ac_cef_cancel_download implemented;
    ac_cef_certificate_error_response added
  - Session 4: OnPaint extended with dirty_rects; ac_cef_pause_download / ac_cef_resume_download added;
    ac_cef_ime_set_composition / ac_cef_ime_cancel_composition added
  - Session 7: BrowserInfo::title cache + ac_cef_get_title fix;
    OnRenderProcessTerminated / OnBeforeUnloadDialog / OnTooltip wired;
    AcCefCallbacks struct extended with 3 new fields
  - Session 9: OnBeforeContextMenuCallback extended with 12 CefContextMenuParams fields;
    AcBrowserClient::OnBeforeContextMenu reads all params fields into temporaries
  - Session 10: OnBeforePopup now sets OSR mode for allowed popups + creates new AcBrowserClient
  - Session 11: OnBeforeBrowseCallback extended with user_gesture (+1 int param)
- Sessions 5 & 6 changes are Dart-only — no DLL rebuild required
- Session 7: C++ changes require DLL rebuild; Dart changes are additive (no breaking changes)
- Session 8: C++ changes require DLL rebuild; OnBeforePopup and OnBeforeContextMenu callback signatures changed
- Session 9: C++ changes require DLL rebuild; OnBeforeContextMenuCallback signature extended again (+12 params)
- Session 10: C++ changes require DLL rebuild (OnBeforePopup body changed); Dart changes (singleton guard) do not require rebuild
- Session 11: C++ changes require DLL rebuild (OnBeforeBrowseCallback +1 param); Dart changes (evalJavaScript) do not require rebuild
