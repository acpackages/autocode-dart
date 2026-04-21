import 'dart:async';
import 'dart:io';
import 'package:ac_cef/ac_cef.dart';
import 'package:ac_cef_flutter/ac_cef_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  // On Windows, ac_cef_bridge.dll must be in the same directory as the .exe.
  // The build_windows.ps1 script copies it there automatically.
  final bridgePath = _resolveBridgePath();

  late final CefBindings bindings;
  try {
    print('[App] Loading bridge from: $bridgePath');
    bindings = CefBindings.load(bridgePath);
    print('[App] Bridge loaded successfully.');
  } catch (e) {
    print('[App] FAILED to load bridge: $e');
    // Show a helpful error if the DLL is missing.
    runApp(_MissingDllApp(dll: bridgePath, error: e.toString()));
    return;
  }

  // Build a client with all useful handlers attached.
  final client = CefClient()
    ..addLoadHandler(_AppLoadHandler())
    ..addDisplayHandler(_AppDisplayHandler())
    ..addLifeSpanHandler(_AppLifeSpanHandler())
    ..addJSDialogHandler(_AppJSDialogHandler());

  final native = CefNativeClient(bindings: bindings, client: client);

  print('[App] Initializing CEF...');
  final ok = native.initialize(CefSettings(
    browserSubprocessPath: _siblingPath('jcef_helper.exe'),
    // Cache goes next to the exe so it persists across runs.
    cachePath: _siblingPath('cef_cache'),
    logFile: _siblingPath('cef_debug.log'),
    logSeverity: CefLogSeverity.verbose,
    resourcesDirPath: _exeDir(),
    localesDirPath: _exeDir() + '\\locales',
    noSandbox: true,
  ));

  if (!ok) {
    print('[App] CEF initialization FAILED.');
    runApp(const _InitFailedApp());
    return;
  }
  print('[App] CEF initialized successfully.');

  // IMPORTANT: Since we disabled multi_threaded_message_loop for thread safety 
  // with Dart FFI callbacks, we must pump the CEF message loop manually.
  Timer.periodic(const Duration(milliseconds: 10), (timer) {
    native.doMessageLoopWork();
  });

  runApp(AcCefDemoApp(native: native));
}

/// Resolve the DLL path relative to the executable on Windows,
/// or fall back to the default for other platforms.
String _resolveBridgePath() {
  if (Platform.isWindows) {
    return '${_exeDir()}\\ac_cef_bridge.dll';
  }
  return CefBindings.defaultLibraryPath();
}

/// Returns the directory containing the running executable.
String _exeDir() => File(Platform.resolvedExecutable).parent.path;

/// Returns a path next to the running executable.
String _siblingPath(String name) {
  return '${_exeDir()}\\$name';
}

// ─── App shell ────────────────────────────────────────────────────────────────

class AcCefDemoApp extends StatelessWidget {
  final CefNativeClient native;
  const AcCefDemoApp({super.key, required this.native});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ac_cef Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BrowserPage(native: native),
    );
  }
}

// ─── Browser page ─────────────────────────────────────────────────────────────

class BrowserPage extends StatefulWidget {
  final CefNativeClient native;
  const BrowserPage({super.key, required this.native});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  final _urlCtrl = TextEditingController(text: 'https://flutter.dev');
  final _focusNode = FocusNode();

  CefController? _controller;
  String _title    = 'New Tab';
  String _status   = '';
  bool _loading    = false;
  bool _canBack    = false;
  bool _canFwd     = false;

  @override
  void initState() {
    super.initState();

    // Attach a display handler that feeds our UI state.
    widget.native.client
      ..addDisplayHandler(_UiDisplayHandler(
        onTitle:  (t) => setState(() => _title = t),
        onUrl:    (u) => setState(() => _urlCtrl.text = u),
        onStatus: (s) => setState(() => _status = s),
      ))
      ..addLoadHandler(_UiLoadHandler(
        onState: (loading, back, fwd) => setState(() {
          _loading = loading;
          _canBack = back;
          _canFwd  = fwd;
        }),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ── Browser surface ──────────────────────────────────────────────
          CefView(
            native: widget.native,
            initialUrl: 'https://google.com',
            frameRate: 60,
            onCreated: (c) {
              setState(() => _controller = c);
              // Register the JS message router for this browser
              widget.native.registerMessageRouter(c.browserId);
            },
          ),

          // ── Status bar overlay ───────────────────────────────────────────
          if (_status.isNotEmpty)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(_status,
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          // Back
          _NavButton(
            icon: Icons.arrow_back_ios_new,
            enabled: _canBack,
            onTap: () => _controller?.goBack(),
            tooltip: 'Back',
          ),
          // Forward
          _NavButton(
            icon: Icons.arrow_forward_ios,
            enabled: _canFwd,
            onTap: () => _controller?.goForward(),
            tooltip: 'Forward',
          ),
          // Reload / Stop
          _NavButton(
            icon: _loading ? Icons.close : Icons.refresh,
            enabled: true,
            onTap: () => _loading ? _controller?.stopLoad() : _controller?.reload(),
            tooltip: _loading ? 'Stop' : 'Reload',
          ),

          // ── URL bar ───────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: TextField(
                controller: _urlCtrl,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 13),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : const Icon(Icons.lock_outline, size: 16,
                            color: Colors.green),
                ),
                onSubmitted: _navigate,
                onTap: () => _urlCtrl.selection = TextSelection(
                    baseOffset: 0, extentOffset: _urlCtrl.text.length),
              ),
            ),
          ),

          // ── Dev tools shortcut ────────────────────────────────────────────
          _NavButton(
            icon: Icons.more_vert,
            enabled: true,
            onTap: _showMenu,
            tooltip: 'Menu',
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottom: _title.isNotEmpty
          ? PreferredSize(
              preferredSize: const Size.fromHeight(22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                  child: Text(_title,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            )
          : null,
    );
  }

  void _navigate(String input) {
    _focusNode.unfocus();
    final url = input.startsWith('http') ? input : 'https://$input';
    _controller?.loadUrl(url);
  }

  void _showMenu() {
    showDialog<void>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Options'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _controller?.openDevTools();
            },
            child: const Text('Open DevTools'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _controller?.executeJavaScript(
                  'alert("Hello from Dart!")');
            },
            child: const Text('Run JavaScript'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              widget.native.clearAllCookies();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cookies cleared')));
            },
            child: const Text('Clear cookies'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _controller?.setZoomLevel(1.5);
            },
            child: const Text('Zoom 150%'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _controller?.setZoomLevel(0);
            },
            child: const Text('Reset zoom'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _focusNode.dispose();
    widget.native.shutdown();
    super.dispose();
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;
  const _NavButton({required this.icon, required this.enabled,
      required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18,
              color: enabled ? Colors.black87 : Colors.black26),
        ),
      ),
    );
  }
}

// ─── Error screens ────────────────────────────────────────────────────────────

class _MissingDllApp extends StatelessWidget {
  final String dll;
  final String error;
  const _MissingDllApp({required this.dll, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Missing native bridge',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Could not load: $dll'),
              const SizedBox(height: 8),
              Text(error, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              const Text('Run the build script first:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const SelectableText(
                  '.\\build_windows.ps1 -CefRoot C:\\path\\to\\cef_binary',
                  style: TextStyle(fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitFailedApp extends StatelessWidget {
  const _InitFailedApp();
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('CEF initialization failed.\n'
              'Check that all CEF DLLs are next to the .exe.',
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

// ─── Handler implementations ──────────────────────────────────────────────────

class _AppLoadHandler extends CefLoadHandler {
  @override void onLoadingStateChange(CefBrowser b, bool l, bool back, bool fwd) {}
  @override void onLoadStart(CefBrowser b, CefFrame f, int t) {}
  @override void onLoadEnd(CefBrowser b, CefFrame f, int s) {}
  @override void onLoadError(CefBrowser b, CefFrame f,
      CefErrorCode e, String text, String url) {
    debugPrint('[CEF] Load error $e on $url: $text');
  }
}

class _AppDisplayHandler extends CefDisplayHandler {
  @override void onAddressChange(CefBrowser b, CefFrame f, String url) {}
  @override void onTitleChange(CefBrowser b, String t) {}
  @override void onFullscreenModeChange(CefBrowser b, bool f) {}
  @override bool onTooltip(CefBrowser b, String t) => false;
  @override void onStatusMessage(CefBrowser b, String s) {}
  @override bool onConsoleMessage(CefBrowser b, CefLogSeverity l,
      String m, String s, int ln) {
    debugPrint('[CEF console] $m ($s:$ln)');
    return false;
  }
  @override bool onCursorChange(CefBrowser b, int t) => false;
}

class _AppLifeSpanHandler extends CefLifeSpanHandler {
  @override bool onBeforePopup(CefBrowser b, CefFrame f, String u, String n) => false;
  @override void onAfterCreated(CefBrowser b)     => debugPrint('[CEF] created ${b.nativeBrowserId}');
  @override void onAfterParentChanged(CefBrowser b) {}
  @override bool doClose(CefBrowser b)             => false;
  @override void onBeforeClose(CefBrowser b)       => debugPrint('[CEF] closed ${b.nativeBrowserId}');
}

class _AppJSDialogHandler extends CefJSDialogHandler {
  @override
  bool onJSDialog(CefBrowser b, String origin, CefJSDialogType type,
      String msg, String prompt, CefJSDialogCallback cb) {
    // Auto-dismiss alerts/confirms for demo purposes.
    cb.onContinue(true, '');
    return true;
  }
  @override bool onBeforeUnloadDialog(CefBrowser b, String msg,
      bool reload, CefJSDialogCallback cb) { cb.onContinue(true, ''); return true; }
  @override void onResetDialogState(CefBrowser b) {}
  @override void onDialogClosed(CefBrowser b) {}
}

// ── Stateful UI handlers ───────────────────────────────────────────────────────

class _UiDisplayHandler extends CefDisplayHandler {
  final void Function(String) onTitle;
  final void Function(String) onUrl;
  final void Function(String) onStatus;
  _UiDisplayHandler({required this.onTitle, required this.onUrl, required this.onStatus});
  @override void onAddressChange(CefBrowser b, CefFrame f, String url) => onUrl(url);
  @override void onTitleChange(CefBrowser b, String t)                  => onTitle(t);
  @override void onFullscreenModeChange(CefBrowser b, bool f)           {}
  @override bool onTooltip(CefBrowser b, String t)                      => false;
  @override void onStatusMessage(CefBrowser b, String s)                => onStatus(s);
  @override bool onConsoleMessage(CefBrowser b, CefLogSeverity l,
      String m, String s, int ln) => false;
  @override bool onCursorChange(CefBrowser b, int t)                    => false;
}

class _UiLoadHandler extends CefLoadHandler {
  final void Function(bool, bool, bool) onState;
  _UiLoadHandler({required this.onState});
  @override void onLoadingStateChange(CefBrowser b, bool l, bool bk, bool fw) =>
      onState(l, bk, fw);
  @override void onLoadStart(CefBrowser b, CefFrame f, int t) {}
  @override void onLoadEnd(CefBrowser b, CefFrame f, int s)   {}
  @override void onLoadError(CefBrowser b, CefFrame f,
      CefErrorCode e, String t, String u) {}
}
