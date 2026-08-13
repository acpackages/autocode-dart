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
- [PARTIAL] Downloads - OnBeforeDownload and OnDownloadUpdated fire, callback response works; cancel now implemented
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
- [KNOWN BUG] Frame drop logic (_decoding flag) may cause missed frames

### Input - Keyboard
- [DONE] Key down / Key up
- [DONE] Character input - FIXED: removed duplicate ImeCommitText, now only CHAR event used
- [DONE] Modifier keys (Shift, Ctrl, Alt, Meta)
- [DONE] CapsLock modifier flag - FIXED: HardwareKeyboard.lockModesEnabled used in _keyMods() and _pointerMods()
- [DONE] Key repeat - repeat flag set in nativeKeyCode bit 30
- [DONE] F1-F12, navigation keys, symbols via scan code + VK lookup tables
- [DONE] OnPreKeyEvent callback dispatched from C++ → Dart CefKeyboardHandler
- [DONE] OnKeyEvent callback dispatched from C++ → Dart CefKeyboardHandler
- [MISSING] IME/composition (ImeSetComposition not implemented)

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
- [DONE] JS dialog events
- [DONE] Context menu (cleared by default)
- [DONE] OnPreKeyEvent / OnKeyEvent - NEW: dispatched from C++ → Dart CefKeyboardHandler
- [DONE] OnCertificateError - NEW: dispatched from C++ → Dart; CefCallback.onContinue(allow) responds

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

## Known Bugs / Issues

### MEDIUM - Single active client limitation
_activeClient global only holds one CefNativeClient. Second client overwrites first.
Only one CefNativeClient/CefApp per process is supported.

### LOW - ac_cef_get_title returns empty string
Always returns "" - title only available via OnTitleChange callback.

### LOW - Frame decode throttling may skip popup updates
_popupDecoding flag gates popup frames independently of main frame, but a busy
main frame decode could still cause stutter if both streams fire rapidly.

### LOW - JS query handler is per-browser, not per-message-router-config
registerQueryHandler() stores a single handler per browser ID. Multiple handlers
or different router configs per browser are not supported yet.

### LOW - isKeyboardShortcut out-param always false
OnPreKeyEvent's is_keyboard_shortcut out-parameter is always written as false;
Dart cannot determine whether the key combination is a browser shortcut.

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

## Current Priority / Next Session

1. Test multiple simultaneous CefView instances on same native client (should work; unverified)
2. Consider addressing single active client limitation for true multi-window support
3. Implement IME/composition support (ImeSetComposition)
4. Partial updates using dirtyRects from OnPaint to reduce CPU load
5. Popup window support (OSR popup rendering, currently always cancelled)
6. Download pause/resume via ac_cef_pause_download / ac_cef_resume_download exports

## Build Notes

- Requires ac_cef_bridge.dll built with CEF SDK
- Build script: ac_cef/native/build_win/
- DLL must be adjacent to Flutter exe
- CEF subprocess: jcef_helper.exe must be adjacent to Flutter exe
- use-alloy-style=1 flag is set in AcCefApp::OnBeforeCommandLineProcessing
- NOTE: DLL must be rebuilt after C++ changes in this session (OnFullscreenModeChange,
  OnPreKeyEvent, OnKeyEvent, OnCertificateError added; OnDownloadUpdated updated;
  ac_cef_cancel_download implemented; ac_cef_certificate_error_response added)
