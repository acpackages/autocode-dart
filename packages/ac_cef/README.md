# ac_cef — Dart/Flutter CEF Port

A pure-Dart FFI port of the **Chromium Embedded Framework (CEF)**, mirroring
the [JCEF](https://github.com/chromiumembedded/java-cef) architecture.

| Package | Purpose |
|---|---|
| `ac_cef` | Engine — FFI bindings, all handler interfaces, `CefNativeClient` |
| `ac_cef_flutter` | UI — `CefView` widget, `CefController` |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Flutter app                                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │  CefView (ac_cef_flutter)                       │   │
│  │  • BGRA→RGBA decode → RawImage                  │   │
│  │  • Forwards pointer / keyboard → CefNativeClient│   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │  CefNativeClient  (ac_cef)                      │   │
│  │  • Registers 17 C function-pointer callbacks    │   │
│  │  • Routes OnPaint frames → Stream<PaintFrame>   │   │
│  │  • Calls CefClient.dispatchXxx for all events   │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │  CefClient  (ac_cef)                            │   │
│  │  • addXxxHandler() registration                 │   │
│  │  • dispatchXxx() → handler implementations      │   │
│  └─────────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────────┘
                        │  dart:ffi
┌───────────────────────▼─────────────────────────────────┐
│  ac_cef_bridge.dll / libac_cef_bridge.so                │
│  • AcBrowserClient (C++) — full CEF handler impl        │
│  • AcRenderHandler — GetViewRect + OnPaint              │
│  • AcCefCallbacks struct — 17 Dart function pointers    │
└───────────────────────┬─────────────────────────────────┘
                        │  CEF C++ API
┌───────────────────────▼─────────────────────────────────┐
│  libcef.dll / libcef.so  (CEF binary distribution)      │
└─────────────────────────────────────────────────────────┘
```

---

## Prerequisites

1. **CEF binary distribution** — download for your platform from
   [https://cef-builds.spotifycdn.com/index.html](https://cef-builds.spotifycdn.com/index.html).
   Choose a **64-bit Release** build.

2. **CMake ≥ 3.19** and a C++17 compiler (MSVC on Windows, Clang/GCC on Linux/macOS).

3. **Dart SDK ≥ 3.0** / **Flutter ≥ 3.10**.

---

## Step 1 — Build the native bridge

```bash
cd ac_cef/native

cmake -DCEF_ROOT=/path/to/cef_binary_xxx_windows64 \
      -DCMAKE_BUILD_TYPE=Release \
      -B build

cmake --build build --config Release
```

This produces `build/out/ac_cef_bridge.dll` (Windows) or
`build/out/libac_cef_bridge.so` (Linux).

Copy the output **and** all CEF resource files next to your Flutter executable:

```
your_app/
  your_app.exe
  ac_cef_bridge.dll      ← bridge
  libcef.dll             ← from CEF distribution
  chrome_elf.dll         ← from CEF distribution
  icudtl.dat             ← from CEF distribution
  resources/             ← from CEF distribution
  locales/               ← from CEF distribution
```

---

## Step 2 — `ac_cef` usage (pure Dart)

```dart
import 'package:ac_cef/ac_cef.dart';

// Load the bridge
final bindings = CefBindings.load(CefBindings.defaultLibraryPath());

// Build a client with handlers
final client = CefClient()
  ..addLoadHandler(MyLoadHandler())
  ..addDisplayHandler(MyDisplayHandler())
  ..addLifeSpanHandler(MyLifeSpanHandler());

// Create native client and initialise CEF
final native = CefNativeClient(bindings: bindings, client: client);
native.initialize(CefSettings(
  cachePath: '.cache/cef',
  remoteDebuggingPort: 9222,   // open chrome://inspect to debug
));

// Create a browser (ID arrives asynchronously via onAfterCreated)
native.createBrowser('https://flutter.dev');
```

---

## Step 3 — `ac_cef_flutter` usage

```dart
import 'package:ac_cef_flutter/ac_cef_flutter.dart';

CefController? _controller;

@override
Widget build(BuildContext context) {
  return CefView(
    native: native,
    initialUrl: 'https://pub.dev',
    frameRate: 60,
    onCreated: (c) => setState(() => _controller = c),
  );
}

// Then use the controller:
_controller?.loadUrl('https://dart.dev');
_controller?.executeJavaScript('document.title = "Hello from Dart!"');
_controller?.setZoomLevel(1.5);
```

---

## Handler reference

| Handler | Key callbacks |
|---|---|
| `CefLoadHandler` | `onLoadingStateChange`, `onLoadStart`, `onLoadEnd`, `onLoadError` |
| `CefDisplayHandler` | `onAddressChange`, `onTitleChange`, `onConsoleMessage`, `onCursorChange` |
| `CefLifeSpanHandler` | `onBeforePopup`, `onAfterCreated`, `doClose`, `onBeforeClose` |
| `CefFocusHandler` | `onTakeFocus`, `onSetFocus`, `onGotFocus` |
| `CefKeyboardHandler` | `onPreKeyEvent`, `onKeyEvent` |
| `CefJSDialogHandler` | `onJSDialog`, `onBeforeUnloadDialog` |
| `CefDownloadHandler` | `onBeforeDownload`, `onDownloadUpdated` |
| `CefContextMenuHandler` | `onBeforeContextMenu`, `onContextMenuCommand` |
| `CefRequestHandler` | `onBeforeBrowse`, `onCertificateError`, `onRenderProcessTerminated` |

Register any combination with `client.addXxxHandler(...)`. Multiple
`CefLifeSpanHandler`s can be registered simultaneously.

---

## Implementing a custom handler

```dart
class MyLoadHandler extends CefLoadHandler {
  @override
  void onLoadingStateChange(
      CefBrowser browser, bool isLoading, bool canGoBack, bool canGoForward) {
    print('Loading: $isLoading');
  }

  @override
  void onLoadError(CefBrowser b, CefFrame f,
      CefErrorCode code, String text, String failedUrl) {
    print('Error $code on $failedUrl: $text');
  }

  @override void onLoadStart(CefBrowser b, CefFrame f, int t) {}
  @override void onLoadEnd(CefBrowser b, CefFrame f, int s) {}
}
```

---

## Cookie management

```dart
native.setCookie('https://example.com',
  name: 'session', value: 'abc123',
  domain: 'example.com', path: '/',
  secure: true, httpOnly: true);

native.clearAllCookies();
```

---

## Remote debugging

Set `remoteDebuggingPort` in `CefSettings` and open
**chrome://inspect** in any Chromium browser to debug pages running
inside the embedded browser.

---

## Package layout

```
ac_cef/
├── lib/
│   ├── ac_cef.dart              # main export barrel
│   └── src/
│       ├── cef_app.dart
│       ├── cef_browser.dart
│       ├── cef_browser_settings.dart
│       ├── cef_client.dart          ← handler registration + dispatch
│       ├── cef_frame.dart
│       ├── cef_menu_model.dart
│       ├── cef_message_router.dart
│       ├── cef_settings.dart
│       ├── handler/
│       │   ├── cef_context_menu_handler.dart
│       │   ├── cef_display_handler.dart
│       │   ├── cef_download_handler.dart
│       │   ├── cef_focus_handler.dart
│       │   ├── cef_js_dialog_handler.dart
│       │   ├── cef_keyboard_handler.dart
│       │   ├── cef_life_span_handler.dart
│       │   ├── cef_load_handler.dart
│       │   └── cef_request_handler.dart
│       ├── native/
│       │   ├── cef_bindings.dart    ← dart:ffi type definitions
│       │   ├── cef_native_client.dart ← bridge orchestrator
│       │   └── paint_frame.dart     ← OSR frame data
│       └── network/
│           └── cef_request.dart
└── native/
    ├── ac_cef_bridge.h          ← C API (26 functions + callback struct)
    ├── ac_cef_bridge.cpp        ← C++ implementation (CEF handlers)
    └── CMakeLists.txt

ac_cef_flutter/
├── lib/
│   └── ac_cef_flutter.dart      ← CefView + CefController
└── example/
    └── lib/main.dart            ← full browser demo app
```

---

## License

BSD 3-Clause — same as CEF itself.
