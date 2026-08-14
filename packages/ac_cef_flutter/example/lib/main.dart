import 'package:ac_cef_flutter/ac_cef_flutter.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Build a client with all useful handlers attached.
  final client = CefClient()
    ..addLoadHandler(_AppLoadHandler())
    ..addDisplayHandler(_AppDisplayHandler())
    ..addLifeSpanHandler(_AppLifeSpanHandler())
    ..addJSDialogHandler(_AppJSDialogHandler());

  try {
    debugPrint('[App] Initializing CEF via initCef...');
    final native = await initCef(
      args: args,
      client: client,
      logSeverity: CefLogSeverity.verbose,
    );
    debugPrint('[App] CEF initialized successfully.');
    runApp(AcCefDemoApp(native: native));
  } catch (e) {
    debugPrint('[App] FAILED to initialize CEF: $e');
    runApp(_MissingDllApp(dll: 'ac_cef_bridge.dll', error: e.toString()));
  }
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
  final String _status   = '';

  // Use CefBrowserState as the reactive source of truth for URL / title /
  // loading / nav-state. It is wired automatically when CefController.state is
  // first accessed (which happens inside CefView's OnAfterCreated via
  // _BoundDisplayHandler / _BoundLoadHandler). Using it here avoids the
  // handler-replacement problem that arose when _UiDisplayHandler was added
  // before _BoundDisplayHandler was registered.
  CefBrowserState? _browserState;

  @override
  void initState() {
    super.initState();
    // Status messages are delivered through the display handler that CefView
    // registers internally (_BoundDisplayHandler). We still need a lightweight
    // wrapper to capture onStatus because _BoundDisplayHandler doesn't expose it.
    // We add our own AFTER CefView's handler has already been installed (i.e.
    // we install it lazily in onCreated, not here, to avoid the replacement race).
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
            initialUrl: 'https://flutter.dev',
            frameRate: 60,
            onCreated: (c) {
              // Register the JS message router for this browser.
              widget.native.registerMessageRouter(c.browserId);
              // Attach CefBrowserState — this hooks into the controller's
              // callback slots (onUrlChanged, onTitleChanged, …) which are
              // already wired by CefView's _BoundDisplayHandler at this point.
              final state = c.state;
              state.addListener(_onBrowserStateChanged);
              setState(() {
                _controller   = c;
                _browserState = state;
                // Seed URL bar immediately if the state already has a URL.
                if (state.url.isNotEmpty) _urlCtrl.text = state.url;
              });
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
            enabled: _browserState?.canGoBack ?? false,
            onTap: () => _controller?.goBack(),
            tooltip: 'Back',
          ),
          // Forward
          _NavButton(
            icon: Icons.arrow_forward_ios,
            enabled: _browserState?.canGoForward ?? false,
            onTap: () => _controller?.goForward(),
            tooltip: 'Forward',
          ),
          // Reload / Stop
          _NavButton(
            icon: (_browserState?.isLoading ?? false) ? Icons.close : Icons.refresh,
            enabled: true,
            onTap: () => (_browserState?.isLoading ?? false)
                ? _controller?.stopLoad()
                : _controller?.reload(),
            tooltip: (_browserState?.isLoading ?? false) ? 'Stop' : 'Reload',
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
                  prefixIcon: (_browserState?.isLoading ?? false)
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
      bottom: ((_browserState?.title ?? '').isNotEmpty)
          ? PreferredSize(
              preferredSize: const Size.fromHeight(22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                  child: Text(_browserState!.title,
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

  void _onBrowserStateChanged() {
    final state = _browserState;
    if (state == null || !mounted) return;
    // Log state changes to the console so we can verify page loading.
    if (state.url.isNotEmpty) {
      debugPrint('[Browser] URL: ${state.url}  loading=${state.isLoading}  title="${state.title}"');
    }
    setState(() {
      if (state.url.isNotEmpty) _urlCtrl.text = state.url;
    });
  }

  @override
  void dispose() {
    _browserState?.removeListener(_onBrowserStateChanged);
    _urlCtrl.dispose();
    _focusNode.dispose();
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

  @override
  void onFaviconUrlChange(CefBrowser browser, List<String> iconUrls) {
    // TODO: implement onFaviconUrlChange
  }
}

class _AppLifeSpanHandler extends CefLifeSpanHandler {
  @override void onAfterCreated(CefBrowser b)     => debugPrint('[CEF] created ${b.nativeBrowserId}');
  @override void onAfterParentChanged(CefBrowser b) {}
  @override bool doClose(CefBrowser b)             => false;
  @override void onBeforeClose(CefBrowser b)       => debugPrint('[CEF] closed ${b.nativeBrowserId}');

  @override
  bool onBeforePopup(CefBrowser browser, CefFrame frame, String targetUrl, String targetFrameName, CefWindowOpenDisposition disposition, bool userGesture) => false;
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

