import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ac_cef/ac_cef.dart';

export 'package:ac_cef/ac_cef.dart'
    show CefNativeClient, CefClient, CefSettings, CefBrowserSettings;

// ─── CEF event flag constants (from cef_types.h) ─────────────────────────────

class _CefEventFlags {
  static const int none              = 0;
  static const int capsLockOn        = 1 << 0;
  static const int shiftDown         = 1 << 1;
  static const int controlDown       = 1 << 2;
  static const int altDown           = 1 << 3;
  static const int leftMouseButton   = 1 << 4;
  static const int middleMouseButton = 1 << 5;
  static const int rightMouseButton  = 1 << 6;
  static const int commandDown       = 1 << 7;
  static const int numLockOn         = 1 << 8;
  static const int isKeyPad          = 1 << 9;
  static const int isLeft            = 1 << 10;
  static const int isRight           = 1 << 11;
}

// ─── CEF key event types ─────────────────────────────────────────────────────

class _CefKeyEventType {
  static const int rawKeyDown = 0;
  static const int keyDown    = 1;
  static const int keyUp      = 2;
  static const int char_      = 3;
}

// ─── CefController ────────────────────────────────────────────────────────────

/// Public API for controlling the browser embedded in a [CefView].
///
/// Obtained from [CefView.onCreated].
class CefController {
  final CefNativeClient _native;
  int _browserId = 0;
  bool _ready = false;

  // Queued calls held until OnAfterCreated fires
  final _queue = <void Function()>[];

  // Wired by CefView
  void Function(String)? onUrlChanged;
  void Function(String)? onTitleChanged;
  void Function(bool, bool, bool)? onLoadingStateChanged;

  CefController._(this._native);

  void _bind(int browserId) {
    _browserId = browserId;
    _ready = true;
    for (final fn in _queue) fn();
    _queue.clear();
  }

  void _run(void Function() fn) => _ready ? fn() : _queue.add(fn);

  void loadUrl(String url)          => _run(() => _native.loadUrl(_browserId, url));
  void goBack()                      => _run(() => _native.goBack(_browserId));
  void goForward()                   => _run(() => _native.goForward(_browserId));
  void reload()                      => _run(() => _native.reload(_browserId));
  void stopLoad()                    => _run(() => _native.stopLoad(_browserId));
  void executeJavaScript(String js)  => _run(() => _native.executeJavaScript(_browserId, js));
  void setZoomLevel(double z)        => _run(() => _native.setZoomLevel(_browserId, z));
  double getZoomLevel()              => _ready ? _native.getZoomLevel(_browserId) : 1.0;
  void setFocus(bool f)              => _run(() => _native.setFocus(_browserId, f));
  void close()                       => _run(() => _native.closeBrowser(_browserId));
  void invalidate()                  => _run(() => _native.invalidate(_browserId));

  // DevTools
  void openDevTools()  => _run(() => _native.openDevTools(_browserId));
  void closeDevTools() => _run(() => _native.closeDevTools(_browserId));

  // State queries (synchronous — returns immediately from native)
  bool get canGoBackNow    => _ready && _native.canGoBack(_browserId);
  bool get canGoForwardNow => _ready && _native.canGoForward(_browserId);
  bool get isLoadingNow    => _ready && _native.isLoading(_browserId);

  /// Returns the current URL from the native browser.
  String get currentUrl => _ready ? _native.getUrl(_browserId) : '';

  // Message router (JS ↔ Dart)
  void querySuccess(int queryId, String response) =>
      _run(() => _native.querySuccess(_browserId, queryId, response));

  void queryFailure(int queryId, int errorCode, String errorMsg) =>
      _run(() => _native.queryFailure(_browserId, queryId, errorCode, errorMsg));

  bool get isReady => _ready;
  int  get browserId => _browserId;
}

// ─── CefView ─────────────────────────────────────────────────────────────────

typedef CefViewCreatedCallback = void Function(CefController controller);

/// Flutter widget that displays a Chromium browser via Off-Screen Rendering.
///
/// CEF renders each frame to a BGRA pixel buffer which is decoded into a
/// [ui.Image] and displayed using [RawImage].  All input events (mouse,
/// keyboard, scroll, focus) are forwarded to the browser via [CefNativeClient].
///
/// ```dart
/// CefView(
///   native: nativeClient,
///   initialUrl: 'https://flutter.dev',
///   onCreated: (c) => controller = c,
/// )
/// ```
class CefView extends StatefulWidget {
  final CefNativeClient native;
  final String initialUrl;
  final CefViewCreatedCallback? onCreated;
  final Color backgroundColor;
  final int frameRate;

  const CefView({
    super.key,
    required this.native,
    this.initialUrl = 'about:blank',
    this.onCreated,
    this.backgroundColor = Colors.white,
    this.frameRate = 60,
  });

  @override
  State<CefView> createState() => _CefViewState();
}

class _CefViewState extends State<CefView> {
  late final CefController _controller;

  // Decoded frame image — rebuilt every OnPaint
  ui.Image? _frame;
  bool _decoding = false;

  // Browser size in physical pixels
  Size _physicalSize = Size.zero;
  double _dpr = 1.0;

  // Stream subscription to paint frames
  StreamSubscription<PaintFrame>? _paintSub;

  // Stream subscription to cursor changes
  StreamSubscription<int>? _cursorSub;

  // Current cursor type from CEF (mapped to Flutter cursor)
  MouseCursor _currentCursor = SystemMouseCursors.basic;

  // Track if we have focus (for keyboard input routing)
  bool _hasFocus = false;
  final FocusNode _focusNode = FocusNode(debugLabel: 'CefView');

  @override
  void initState() {
    super.initState();
    _controller = CefController._(widget.native);

    // Use global keyboard handler — Focus.onKeyEvent can miss events
    HardwareKeyboard.instance.addHandler(_onHardwareKey);

    // Register a life-span handler to capture the browser ID
    widget.native.client.addLifeSpanHandler(
      _BoundLifeSpanHandler(
        onAfterCreated: (browser) {
          final id = browser.nativeBrowserId;
          _controller._bind(id);

          // Subscribe to the paint stream for this browser
          _paintSub = widget.native.paintFrames(id).listen(_onPaintFrame);

          // Subscribe to cursor changes for this browser
          _cursorSub = widget.native.cursorChanges(id).listen((cursorType) {
            if (mounted) {
              setState(() {
                _currentCursor = _mapCefCursor(cursorType);
              });
            }
          });

          // Push initial view size if we have it
          if (_physicalSize != Size.zero) {
            widget.native.setViewSize(id,
                _physicalSize.width / _dpr,
                _physicalSize.height / _dpr,
                _dpr);
          }

          // Give focus to the browser immediately
          widget.native.setFocus(id, true);

          widget.onCreated?.call(_controller);
        },
        onBeforeClose: (browser) {
          _paintSub?.cancel();
          _paintSub = null;
          _cursorSub?.cancel();
          _cursorSub = null;
        },
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _createBrowser());
  }

  void _createBrowser() {
    widget.native.createBrowser(
      widget.initialUrl,
      windowless: true,
      isTransparent: widget.backgroundColor == Colors.transparent,
      settings: CefBrowserSettings()..windowlessFrameRate = widget.frameRate,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dpr = MediaQuery.of(context).devicePixelRatio;
  }

  // ─── Paint frame handler ───────────────────────────────────────────────────

  void _onPaintFrame(PaintFrame frame) {
    // Skip if a decode is already in flight — drop the frame to avoid build-up
    if (_decoding || !mounted) return;
    _decoding = true;

    _decodeBgra(frame).then((image) {
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _frame?.dispose();
        _frame = image;
      });
    }).whenComplete(() => _decoding = false);
  }

  /// Decode a BGRA [PaintFrame] into a [ui.Image] by swapping B↔R channels.
  ///
  /// CEF delivers BGRA; Flutter's [ui.decodeImageFromPixels] expects RGBA.
  static Future<ui.Image> _decodeBgra(PaintFrame frame) {
    final rgba = Uint8List(frame.pixels.length);
    for (int i = 0; i < frame.pixels.length; i += 4) {
      rgba[i + 0] = frame.pixels[i + 2]; // R ← B
      rgba[i + 1] = frame.pixels[i + 1]; // G
      rgba[i + 2] = frame.pixels[i + 0]; // B ← R
      rgba[i + 3] = frame.pixels[i + 3]; // A
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba, frame.width, frame.height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  // ─── Layout / size change ──────────────────────────────────────────────────

  void _onLayoutChanged(Size logicalSize) {
    final physical = Size(logicalSize.width * _dpr, logicalSize.height * _dpr);
    if (physical == _physicalSize) return;
    _physicalSize = physical;

    if (_controller.isReady) {
      widget.native.setViewSize(
          _controller.browserId, logicalSize.width, logicalSize.height, _dpr);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _onLayoutChanged(constraints.biggest);

      return Focus(
        focusNode: _focusNode,
        autofocus: true,
        onFocusChange: (hasFocus) {
          _hasFocus = hasFocus;
          print('[CefView] Focus changed: $_hasFocus');
          if (_controller.isReady) _controller.setFocus(hasFocus);
        },
        child: MouseRegion(
          cursor: _currentCursor,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown:   _onPointerDown,
            onPointerMove:   _onPointerMove,
            onPointerUp:     _onPointerUp,
            onPointerHover:  _onPointerHover,
            onPointerSignal: _onPointerSignal,
            child: SizedBox.expand(
              child: _frame == null
                  ? ColoredBox(color: widget.backgroundColor)
                  : RawImage(
                      image: _frame,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.low,
                    ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Mouse input forwarding ────────────────────────────────────────────────

  void _onPointerHover(PointerHoverEvent e) {
    if (!_controller.isReady) return;
    widget.native.sendMouseMove(
      _controller.browserId,
      _px(e.localPosition.dx), _px(e.localPosition.dy),
      _pointerMods(e),
    );
  }

  void _onPointerDown(PointerDownEvent e) {
    if (!_controller.isReady) return;
    // Request Flutter focus on click
    _focusNode.requestFocus();

    widget.native.sendMouseClick(
      _controller.browserId,
      _px(e.localPosition.dx), _px(e.localPosition.dy),
      _button(e.buttons), false, 1, _pointerMods(e),
    );
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (!_controller.isReady) return;
    widget.native.sendMouseMove(
      _controller.browserId,
      _px(e.localPosition.dx), _px(e.localPosition.dy),
      _pointerMods(e),
    );
  }

  void _onPointerUp(PointerUpEvent e) {
    if (!_controller.isReady) return;
    // For pointer up, buttons is already 0, so infer from the change
    final btn = _button(e.pointer == 0 ? kPrimaryMouseButton : e.buttons);
    widget.native.sendMouseClick(
      _controller.browserId,
      _px(e.localPosition.dx), _px(e.localPosition.dy),
      0, true, 1, _pointerMods(e),
    );
  }

  void _onPointerSignal(PointerSignalEvent e) {
    if (!_controller.isReady) return;
    if (e is PointerScrollEvent) {
      // CEF expects: positive dy = scroll up, negative dy = scroll down.
      // Flutter gives: positive dy = scroll down.
      // So we invert the sign. Also scale for CEF (120 units per notch).
      widget.native.sendMouseWheel(
        _controller.browserId,
        _px(e.localPosition.dx), _px(e.localPosition.dy),
        -e.scrollDelta.dx.round(),
        -e.scrollDelta.dy.round(),
      );
    }
  }

  // ─── Keyboard input forwarding ─────────────────────────────────────────────

  /// Global keyboard handler — called for ALL key events regardless of focus tree.
  /// We only forward to CEF when _hasFocus is true.
  bool _onHardwareKey(KeyEvent e) {
    if (!_controller.isReady || !_hasFocus) return false;

    final int mods = _keyMods();
    final int wk = _windowsKeyCode(e.logicalKey);
    int nk = _windowsScanCode(e.physicalKey);

    // Debug logging
    print('[CefView] KeyEvent: ${e.runtimeType} key=${e.logicalKey.keyLabel} '
        'wk=0x${wk.toRadixString(16)} nk=0x${nk.toRadixString(16)} char=${e.character} mods=$mods');

    final bool isSys = (mods & _CefEventFlags.altDown) != 0;

    if (e is KeyDownEvent || e is KeyRepeatEvent) {
      // For repeat events, set bit 30 (previous key state = was pressed)
      if (e is KeyRepeatEvent) nk = nk | 0x40000000;

      // Send RAWKEYDOWN
      widget.native.sendKeyEvent(
        _controller.browserId,
        type: _CefKeyEventType.rawKeyDown,
        windowsKeyCode: wk,
        nativeKeyCode: nk,
        modifiers: mods,
        character: 0,
        unmodifiedCharacter: 0,
        isSystemKey: isSys,
      );

      // For printable characters, also send a CHAR event + IME commit.
      if (e.character != null && e.character!.isNotEmpty) {
        final charCode = e.character!.codeUnitAt(0);
        widget.native.sendKeyEvent(
          _controller.browserId,
          type: _CefKeyEventType.char_,
          windowsKeyCode: charCode,
          nativeKeyCode: nk,
          modifiers: mods,
          character: charCode,
          unmodifiedCharacter: charCode,
          isSystemKey: isSys,
          focusOnEditableField: true,
        );
        // Use IME to directly commit text — required in CEF 146+ Chrome runtime
        widget.native.imeCommitText(_controller.browserId, e.character!);
      }
    } else if (e is KeyUpEvent) {
      // For KEYUP, set bits 30 (previous key state) and 31 (transition state)
      nk = nk | 0xC0000000;
      widget.native.sendKeyEvent(
        _controller.browserId,
        type: _CefKeyEventType.keyUp,
        windowsKeyCode: wk,
        nativeKeyCode: nk,
        modifiers: mods,
        character: 0,
        unmodifiedCharacter: 0,
        isSystemKey: isSys,
      );
    }

    return true; // We handled the event
  }

  /// Map a Flutter [PhysicalKeyboardKey] to a Windows scan code in lParam format.
  ///
  /// On Windows, CEF's native_key_code is the lParam value from WM_KEYDOWN.
  /// Format:
  /// bits 0-15  = repeat count (must be >= 1)
  /// bits 16-23 = scan code
  /// bit 24     = extended key flag
  /// bit 29     = context code (1 if Alt is down)
  static int _windowsScanCode(PhysicalKeyboardKey key) {
    final sc = _scanCodeMap[key];
    int lp = (sc ?? 0) << 16 | 1;

    // Set extended bit (24) for certain keys
    if (_extendedKeys.contains(key)) {
      lp |= 0x01000000;
    }

    // Set bit 29 if Alt is down (Context code)
    if (HardwareKeyboard.instance.isAltPressed) {
      lp |= 0x20000000;
    }

    return lp;
  }

  static final _extendedKeys = {
    PhysicalKeyboardKey.arrowLeft,
    PhysicalKeyboardKey.arrowUp,
    PhysicalKeyboardKey.arrowRight,
    PhysicalKeyboardKey.arrowDown,
    PhysicalKeyboardKey.insert,
    PhysicalKeyboardKey.delete,
    PhysicalKeyboardKey.home,
    PhysicalKeyboardKey.end,
    PhysicalKeyboardKey.pageUp,
    PhysicalKeyboardKey.pageDown,
    PhysicalKeyboardKey.numLock,
    PhysicalKeyboardKey.numpadDivide,
    PhysicalKeyboardKey.numpadEnter,
    PhysicalKeyboardKey.controlRight,
    PhysicalKeyboardKey.altRight,
  };

  /// USB HID → Windows scan code mapping for common keys.
  static final Map<PhysicalKeyboardKey, int> _scanCodeMap = {
    PhysicalKeyboardKey.keyA: 0x1E,
    PhysicalKeyboardKey.keyB: 0x30,
    PhysicalKeyboardKey.keyC: 0x2E,
    PhysicalKeyboardKey.keyD: 0x20,
    PhysicalKeyboardKey.keyE: 0x12,
    PhysicalKeyboardKey.keyF: 0x21,
    PhysicalKeyboardKey.keyG: 0x22,
    PhysicalKeyboardKey.keyH: 0x23,
    PhysicalKeyboardKey.keyI: 0x17,
    PhysicalKeyboardKey.keyJ: 0x24,
    PhysicalKeyboardKey.keyK: 0x25,
    PhysicalKeyboardKey.keyL: 0x26,
    PhysicalKeyboardKey.keyM: 0x32,
    PhysicalKeyboardKey.keyN: 0x31,
    PhysicalKeyboardKey.keyO: 0x18,
    PhysicalKeyboardKey.keyP: 0x19,
    PhysicalKeyboardKey.keyQ: 0x10,
    PhysicalKeyboardKey.keyR: 0x13,
    PhysicalKeyboardKey.keyS: 0x1F,
    PhysicalKeyboardKey.keyT: 0x14,
    PhysicalKeyboardKey.keyU: 0x16,
    PhysicalKeyboardKey.keyV: 0x2F,
    PhysicalKeyboardKey.keyW: 0x11,
    PhysicalKeyboardKey.keyX: 0x2D,
    PhysicalKeyboardKey.keyY: 0x15,
    PhysicalKeyboardKey.keyZ: 0x2C,
    PhysicalKeyboardKey.digit1: 0x02,
    PhysicalKeyboardKey.digit2: 0x03,
    PhysicalKeyboardKey.digit3: 0x04,
    PhysicalKeyboardKey.digit4: 0x05,
    PhysicalKeyboardKey.digit5: 0x06,
    PhysicalKeyboardKey.digit6: 0x07,
    PhysicalKeyboardKey.digit7: 0x08,
    PhysicalKeyboardKey.digit8: 0x09,
    PhysicalKeyboardKey.digit9: 0x0A,
    PhysicalKeyboardKey.digit0: 0x0B,
    PhysicalKeyboardKey.enter: 0x1C,
    PhysicalKeyboardKey.escape: 0x01,
    PhysicalKeyboardKey.backspace: 0x0E,
    PhysicalKeyboardKey.tab: 0x0F,
    PhysicalKeyboardKey.space: 0x39,
    PhysicalKeyboardKey.minus: 0x0C,
    PhysicalKeyboardKey.equal: 0x0D,
    PhysicalKeyboardKey.bracketLeft: 0x1A,
    PhysicalKeyboardKey.bracketRight: 0x1B,
    PhysicalKeyboardKey.backslash: 0x2B,
    PhysicalKeyboardKey.semicolon: 0x27,
    PhysicalKeyboardKey.quote: 0x28,
    PhysicalKeyboardKey.backquote: 0x29,
    PhysicalKeyboardKey.comma: 0x33,
    PhysicalKeyboardKey.period: 0x34,
    PhysicalKeyboardKey.slash: 0x35,
    PhysicalKeyboardKey.capsLock: 0x3A,
    PhysicalKeyboardKey.f1: 0x3B,
    PhysicalKeyboardKey.f2: 0x3C,
    PhysicalKeyboardKey.f3: 0x3D,
    PhysicalKeyboardKey.f4: 0x3E,
    PhysicalKeyboardKey.f5: 0x3F,
    PhysicalKeyboardKey.f6: 0x40,
    PhysicalKeyboardKey.f7: 0x41,
    PhysicalKeyboardKey.f8: 0x42,
    PhysicalKeyboardKey.f9: 0x43,
    PhysicalKeyboardKey.f10: 0x44,
    PhysicalKeyboardKey.f11: 0x57,
    PhysicalKeyboardKey.f12: 0x58,
    PhysicalKeyboardKey.delete: 0x53,
    PhysicalKeyboardKey.insert: 0x52,
    PhysicalKeyboardKey.home: 0x47,
    PhysicalKeyboardKey.end: 0x4F,
    PhysicalKeyboardKey.pageUp: 0x49,
    PhysicalKeyboardKey.pageDown: 0x51,
    PhysicalKeyboardKey.arrowRight: 0x4D,
    PhysicalKeyboardKey.arrowLeft: 0x4B,
    PhysicalKeyboardKey.arrowDown: 0x50,
    PhysicalKeyboardKey.arrowUp: 0x48,
    PhysicalKeyboardKey.shiftLeft: 0x2A,
    PhysicalKeyboardKey.shiftRight: 0x36,
    PhysicalKeyboardKey.controlLeft: 0x1D,
    PhysicalKeyboardKey.altLeft: 0x38,
  };

  // ─── Helpers ───────────────────────────────────────────────────────────────

  int _px(double v) => (v * _dpr).round();

  /// Map Flutter button flags to CEF button index (0=left, 1=right, 2=middle).
  int _button(int buttons) {
    if (buttons & kSecondaryMouseButton != 0) return 1;
    if (buttons & kMiddleMouseButton    != 0) return 2;
    return 0;
  }

  /// Map pointer event buttons to CEF modifier flags.
  int _pointerMods(PointerEvent e) {
    int m = 0;
    if (e.buttons & kPrimaryMouseButton   != 0) m |= _CefEventFlags.leftMouseButton;
    if (e.buttons & kSecondaryMouseButton != 0) m |= _CefEventFlags.rightMouseButton;
    if (e.buttons & kMiddleMouseButton    != 0) m |= _CefEventFlags.middleMouseButton;

    // Also include keyboard modifiers
    final hw = HardwareKeyboard.instance;
    if (hw.isShiftPressed)   m |= _CefEventFlags.shiftDown;
    if (hw.isControlPressed) m |= _CefEventFlags.controlDown;
    if (hw.isAltPressed)     m |= _CefEventFlags.altDown;
    if (hw.isMetaPressed)    m |= _CefEventFlags.commandDown;
    return m;
  }

  /// Map keyboard state to CEF modifier flags.
  int _keyMods() {
    int m = 0;
    final hw = HardwareKeyboard.instance;
    if (hw.isShiftPressed)   m |= _CefEventFlags.shiftDown;
    if (hw.isControlPressed) m |= _CefEventFlags.controlDown;
    if (hw.isAltPressed)     m |= _CefEventFlags.altDown;
    if (hw.isMetaPressed)    m |= _CefEventFlags.commandDown;
    return m;
  }

  /// Map a Flutter [LogicalKeyboardKey] to a Windows Virtual Key code.
  ///
  /// CEF on Windows expects VK_* codes in windows_key_code for
  /// RAWKEYDOWN/KEYUP events.
  static int _windowsKeyCode(LogicalKeyboardKey key) {
    // Check the lookup table first
    final mapped = _keyMap[key];
    if (mapped != null) return mapped;

    // For letter keys (a-z), VK code is the uppercase ASCII value
    final id = key.keyId;
    if (id >= 0x61 && id <= 0x7A) return id - 0x20; // 'a'-'z' → 'A'-'Z'
    if (id >= 0x30 && id <= 0x39) return id;          // '0'-'9'
    if (id >= 0x20 && id <= 0x7E) return id;          // Other ASCII

    return 0;
  }

  /// Map CEF cursor type to Flutter [MouseCursor].
  static MouseCursor _mapCefCursor(int cefType) {
    // CEF cursor type values from cef_types.h (cef_cursor_type_t)
    switch (cefType) {
      case 0:  return SystemMouseCursors.basic;          // CT_POINTER
      case 1:  return SystemMouseCursors.precise;          // CT_CROSS
      case 2:  return SystemMouseCursors.click;           // CT_HAND
      case 3:  return SystemMouseCursors.text;            // CT_IBEAM
      case 4:  return SystemMouseCursors.wait;            // CT_WAIT
      case 5:  return SystemMouseCursors.help;            // CT_HELP
      case 6:  return SystemMouseCursors.resizeRight;     // CT_EASTRESIZE
      case 7:  return SystemMouseCursors.resizeUp;        // CT_NORTHRESIZE
      case 8:  return SystemMouseCursors.resizeUpRight;   // CT_NORTHEASTRESIZE
      case 9:  return SystemMouseCursors.resizeUpLeft;    // CT_NORTHWESTRESIZE
      case 10: return SystemMouseCursors.resizeDown;      // CT_SOUTHRESIZE
      case 11: return SystemMouseCursors.resizeDownRight; // CT_SOUTHEASTRESIZE
      case 12: return SystemMouseCursors.resizeDownLeft;  // CT_SOUTHWESTRESIZE
      case 13: return SystemMouseCursors.resizeLeft;      // CT_WESTRESIZE
      case 14: return SystemMouseCursors.resizeUpDown;    // CT_NORTHSOUTHRESIZE
      case 15: return SystemMouseCursors.resizeLeftRight; // CT_EASTWESTRESIZE
      case 16: return SystemMouseCursors.resizeUpLeftDownRight; // CT_NORTHEASTSOUTHWESTRESIZE
      case 17: return SystemMouseCursors.resizeUpRightDownLeft; // CT_NORTHWESTSOUTHEASTRESIZE
      case 18: return SystemMouseCursors.resizeColumn;    // CT_COLUMNRESIZE
      case 19: return SystemMouseCursors.resizeRow;       // CT_ROWRESIZE
      case 20: return SystemMouseCursors.allScroll;       // CT_MIDDLEPANNING
      case 24: return SystemMouseCursors.move;            // CT_MOVE
      case 25: return SystemMouseCursors.verticalText;    // CT_VERTICALTEXT
      case 26: return SystemMouseCursors.cell;            // CT_CELL
      case 27: return SystemMouseCursors.contextMenu;     // CT_CONTEXTMENU
      case 28: return SystemMouseCursors.alias;           // CT_ALIAS
      case 29: return SystemMouseCursors.progress;        // CT_PROGRESS
      case 30: return SystemMouseCursors.noDrop;          // CT_NODROP
      case 31: return SystemMouseCursors.copy;            // CT_COPY
      case 32: return SystemMouseCursors.basic;           // CT_NONE (hide not available, use basic)
      case 33: return SystemMouseCursors.forbidden;       // CT_NOTALLOWED
      case 34: return SystemMouseCursors.grab;            // CT_GRAB
      case 35: return SystemMouseCursors.grabbing;        // CT_GRABBING
      default: return SystemMouseCursors.basic;
    }
  }

  /// Lookup table for non-ASCII Flutter keys → Windows VK codes.
  static final Map<LogicalKeyboardKey, int> _keyMap = {
    LogicalKeyboardKey.backspace:     0x08, // VK_BACK
    LogicalKeyboardKey.tab:           0x09, // VK_TAB
    LogicalKeyboardKey.enter:         0x0D, // VK_RETURN
    LogicalKeyboardKey.escape:        0x1B, // VK_ESCAPE
    LogicalKeyboardKey.space:         0x20, // VK_SPACE
    LogicalKeyboardKey.delete:        0x2E, // VK_DELETE
    LogicalKeyboardKey.insert:        0x2D, // VK_INSERT
    LogicalKeyboardKey.home:          0x24, // VK_HOME
    LogicalKeyboardKey.end:           0x23, // VK_END
    LogicalKeyboardKey.pageUp:        0x21, // VK_PRIOR
    LogicalKeyboardKey.pageDown:      0x22, // VK_NEXT
    LogicalKeyboardKey.arrowLeft:     0x25, // VK_LEFT
    LogicalKeyboardKey.arrowUp:       0x26, // VK_UP
    LogicalKeyboardKey.arrowRight:    0x27, // VK_RIGHT
    LogicalKeyboardKey.arrowDown:     0x28, // VK_DOWN
    LogicalKeyboardKey.shiftLeft:     0x10, // VK_SHIFT
    LogicalKeyboardKey.shiftRight:    0x10,
    LogicalKeyboardKey.controlLeft:   0x11, // VK_CONTROL
    LogicalKeyboardKey.controlRight:  0x11,
    LogicalKeyboardKey.altLeft:       0x12, // VK_MENU
    LogicalKeyboardKey.altRight:      0x12,
    LogicalKeyboardKey.metaLeft:      0x5B, // VK_LWIN
    LogicalKeyboardKey.metaRight:     0x5C, // VK_RWIN
    LogicalKeyboardKey.capsLock:      0x14, // VK_CAPITAL
    LogicalKeyboardKey.numLock:       0x90, // VK_NUMLOCK
    LogicalKeyboardKey.scrollLock:    0x91, // VK_SCROLL
    LogicalKeyboardKey.f1:            0x70, // VK_F1
    LogicalKeyboardKey.f2:            0x71,
    LogicalKeyboardKey.f3:            0x72,
    LogicalKeyboardKey.f4:            0x73,
    LogicalKeyboardKey.f5:            0x74,
    LogicalKeyboardKey.f6:            0x75,
    LogicalKeyboardKey.f7:            0x76,
    LogicalKeyboardKey.f8:            0x77,
    LogicalKeyboardKey.f9:            0x78,
    LogicalKeyboardKey.f10:           0x79,
    LogicalKeyboardKey.f11:           0x7A,
    LogicalKeyboardKey.f12:           0x7B,
    LogicalKeyboardKey.numpad0:       0x60, // VK_NUMPAD0
    LogicalKeyboardKey.numpad1:       0x61,
    LogicalKeyboardKey.numpad2:       0x62,
    LogicalKeyboardKey.numpad3:       0x63,
    LogicalKeyboardKey.numpad4:       0x64,
    LogicalKeyboardKey.numpad5:       0x65,
    LogicalKeyboardKey.numpad6:       0x66,
    LogicalKeyboardKey.numpad7:       0x67,
    LogicalKeyboardKey.numpad8:       0x68,
    LogicalKeyboardKey.numpad9:       0x69,
    LogicalKeyboardKey.numpadMultiply: 0x6A, // VK_MULTIPLY
    LogicalKeyboardKey.numpadAdd:      0x6B, // VK_ADD
    LogicalKeyboardKey.numpadSubtract: 0x6D, // VK_SUBTRACT
    LogicalKeyboardKey.numpadDecimal:  0x6E, // VK_DECIMAL
    LogicalKeyboardKey.numpadDivide:   0x6F, // VK_DIVIDE
    LogicalKeyboardKey.numpadEnter:    0x0D, // VK_RETURN
    LogicalKeyboardKey.semicolon:     0xBA, // VK_OEM_1
    LogicalKeyboardKey.equal:         0xBB, // VK_OEM_PLUS
    LogicalKeyboardKey.comma:         0xBC, // VK_OEM_COMMA
    LogicalKeyboardKey.minus:         0xBD, // VK_OEM_MINUS
    LogicalKeyboardKey.period:        0xBE, // VK_OEM_PERIOD
    LogicalKeyboardKey.slash:         0xBF, // VK_OEM_2
    LogicalKeyboardKey.backquote:     0xC0, // VK_OEM_3
    LogicalKeyboardKey.bracketLeft:   0xDB, // VK_OEM_4
    LogicalKeyboardKey.backslash:     0xDC, // VK_OEM_5
    LogicalKeyboardKey.bracketRight:  0xDD, // VK_OEM_6
    LogicalKeyboardKey.quoteSingle:   0xDE, // VK_OEM_7
  };

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    _paintSub?.cancel();
    _cursorSub?.cancel();
    _frame?.dispose();
    _focusNode.dispose();
    if (_controller.isReady) {
      widget.native.closeBrowser(_controller.browserId);
    }
    super.dispose();
  }
}

// ─── Internal life-span handler ───────────────────────────────────────────────

class _BoundLifeSpanHandler extends CefLifeSpanHandler {
  final void Function(CefBrowser) _onCreated;
  final void Function(CefBrowser) _onClose;

  _BoundLifeSpanHandler({
    required void Function(CefBrowser) onAfterCreated,
    required void Function(CefBrowser) onBeforeClose,
  }) : _onCreated = onAfterCreated, _onClose = onBeforeClose;

  @override
  bool onBeforePopup(CefBrowser b, CefFrame f, String u, String n) => false;

  @override
  void onAfterCreated(CefBrowser b) => _onCreated(b);

  @override
  void onAfterParentChanged(CefBrowser b) {}

  @override
  bool doClose(CefBrowser b) => false;

  @override
  void onBeforeClose(CefBrowser b) => _onClose(b);
}

