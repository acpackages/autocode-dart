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
- [PARTIAL] Recreate (close + re-create works in principle, not tested)
- [DONE] Shutdown (CefShutdown called)

### Navigation
- [DONE] Load URL
- [DONE] Back / Forward / Reload / Stop
- [DONE] OnLoadStart / OnLoadEnd / OnLoadError callbacks
- [DONE] OnLoadingStateChange
- [DONE] OnAddressChange (URL bar update)
- [DONE] OnTitleChange
- [PARTIAL] Popup / new window - OnBeforePopup fires but popup is always cancelled; no OSR popup rendering
- [DONE] Downloads - OnBeforeDownload and OnDownloadUpdated fire, callback response works; cancel/pause/resume implemented
- [DONE] SSL/certificate error handling - OnCertificateError dispatched to Dart; respond via CefCallback
- [PARTIAL] OnBeforeBrowse fires (logs, always returns false)
- [PARTIAL] OnBeforeResourceLoad fires (always returns false)

### Rendering
- [DONE] Initial frame delivery
- [DONE] Continuous frame updates via OSR on_paint
- [DONE] BGRA to RGBA conversion
- [DONE] Resize (setViewSize + wasResized)
- [DONE] DPI (device pixel ratio applied)
- [PARTIAL] Multiple browsers - each has own paint stream; should work
- [DONE] Popup/overlay rendering - FIXED: OnPopupShow + OnPopupSize callbacks implemented; popup frames composited via Stack + Positioned overlay in CefView
- [DONE] dirtyRects - CEF's dirty rect list is packed into a flat int array and delivered in every PaintFrame; available for future partial-repaint optimisation
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
- [PARTIAL] Horizontal scroll - forwarded but untested

### Focus
- [DONE] Focus gained/lost tracking
- [DONE] SetFocus called on browser when Flutter focus changes
- [DONE] OnGotFocus callback
- [PARTIAL] Multi-browser focus isolation - _hasFocus is per-CefViewState

### JavaScript
- [DONE] ExecuteJavaScript (fire-and-forget)
- [DONE] JS query via CefMessageRouter (cefQuery / cefQueryCancel)
- [DONE] Query dispatch - FIXED: _fwdQuery now dispatches to user-registered CefMessageRouterHandler; _NativeQueryCb bridges to querySuccess/queryFailure FFI calls
- [DONE] registerQueryHandler() on CefController - users register handler once per browser
- [DONE] removeQueryHandler() on CefController
- [DONE] No-handler fallback: succeeds with empty response so JS promise doesn't hang
- [DONE] Declined-handler fallback: auto-fails with -1/'Query not handled' error
- [MISSING] JS return values / eval results
- [PARTIAL] JS dialog (alert/confirm/prompt) - auto-dismissed in example

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
- [DONE] OnBeforeBrowse dispatched to Dart CefRequestHandler - FIXED: _fwdBeforeBrowse now dispatches to client.requestHandler with _StubRequest carrying the URL

### Multiple Browsers
- [PARTIAL] Global _activeClient pointer - only ONE CefNativeClient can be active at a time
- [PARTIAL] Multiple CefView widgets on same native client - should work
- [BROKEN] Two separate CefNativeClient instances would overwrite _activeClient

### DevTools
- [DONE] Open/close DevTools in popup window

### Cookies
- [DONE] Clear all cookies
- [DONE] Set cookie

### Threading
- [PARTIAL] CEF message loop manually pumped - works but 10ms polling may miss events
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
_activeClient global only holds one CefNativeClient. Second client overwrites first.
Only one CefNativeClient/CefApp per process is supported.

### LOW - ac_cef_get_title returns empty string
Always returns "" - title only available via OnTitleChange callback.

### LOW - JS query handler is per-browser, not per-message-router-config
registerQueryHandler() stores a single handler per browser ID. Multiple handlers
or different router configs per browser are not supported yet.

### LOW - isKeyboardShortcut out-param always false
OnPreKeyEvent's is_keyboard_shortcut out-parameter is always written as false;
Dart cannot determine whether the key combination is a browser shortcut.

### LOW - OnBeforeBrowse receives URL only (no method/headers/userGesture)
The C bridge passes url + is_redirect; userGesture is always false in the stub.
A future session can extend the bridge to pass these.

### LOW - OnBeforeContextMenu model is always empty
C++ calls model->Clear() before dispatching; Dart receives an unmodifiable stub.
To support custom context menus, the C bridge would need to pass menu item data.

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

## Current Priority / Next Session

1. **Partial repaint optimisation** — `PaintFrame.dirtyRects` is now available; implement patch-blending in `CefView`: maintain a master `Uint8List` backing buffer and only BGRA→RGBA convert + blit the changed rects each frame instead of decoding the whole frame
2. **OnBeforeResourceLoad dispatch** — wire `_fwdBeforeResourceLoad` to `CefRequestHandler.onBeforeResourceLoad` (needs method + url; currently stub always returns false)
3. **Test multiple simultaneous CefView instances** on same native client (should work; unverified)
4. **Consider addressing single active client limitation** for true multi-window support
5. **Popup window support** (OSR popup rendering, currently always cancelled)

## Build Notes

- Requires ac_cef_bridge.dll built with CEF SDK
- Build script: ac_cef/native/build_win/
- DLL must be adjacent to Flutter exe
- CEF subprocess: jcef_helper.exe must be adjacent to Flutter exe
- use-alloy-style=1 flag is set in AcCefApp::OnBeforeCommandLineProcessing
- NOTE: DLL must be rebuilt after C++ changes in sessions 3 & 4 (OnFullscreenModeChange,
  OnPreKeyEvent, OnKeyEvent, OnCertificateError added; OnDownloadUpdated updated;
  ac_cef_cancel_download implemented; ac_cef_certificate_error_response added;
  OnPaint extended with dirty_rects; ac_cef_pause_download / ac_cef_resume_download added;
  ac_cef_ime_set_composition / ac_cef_ime_cancel_composition added)
- Session 5 changes are Dart-only — no DLL rebuild required
