import 'cef_settings.dart';
import 'native/cef_bindings.dart';
import 'native/cef_native_client.dart';
import 'cef_client.dart';

/// Top-level entry point for CEF initialization.
///
/// This is a convenience wrapper around [CefNativeClient] that mirrors
/// JCEF's `CefApp.getInstance()` singleton pattern.
///
/// ```dart
/// final app = CefApp.getInstance();
/// app.start(settings: CefSettings(cachePath: '.cache'));
/// // ... create browsers via app.client ...
/// app.shutdown();
/// ```
class CefApp {
  static CefApp? _instance;

  late final CefBindings _bindings;
  late final CefClient _client;
  late final CefNativeClient _native;

  bool _started = false;

  CefApp._();

  /// Returns the singleton [CefApp] instance.
  factory CefApp.getInstance() {
    return _instance ??= CefApp._();
  }

  /// Load and initialize CEF.
  ///
  /// [libraryPath] — path to `ac_cef_bridge.dll` / `libac_cef_bridge.so`.
  /// If null, [CefBindings.defaultLibraryPath()] is used.
  ///
  /// Returns `true` on success.
  bool start({
    CefSettings? settings,
    String? libraryPath,
    CefClient? client,
  }) {
    if (_started) return true;

    _bindings = CefBindings.load(libraryPath ?? CefBindings.defaultLibraryPath());
    _client = client ?? CefClient();
    _native = CefNativeClient(bindings: _bindings, client: _client);

    _started = _native.initialize(settings);
    return _started;
  }

  /// Access the underlying [CefClient] to register handlers.
  CefClient get client {
    if (!_started) throw StateError('CefApp.start() must be called first.');
    return _client;
  }

  /// Access the [CefNativeClient] for creating browsers and managing the bridge.
  CefNativeClient get native {
    if (!_started) throw StateError('CefApp.start() must be called first.');
    return _native;
  }

  /// Whether CEF has been initialized.
  bool get isStarted => _started;

  /// Shut down CEF. Must be called before the process exits.
  void shutdown() {
    if (!_started) return;
    _native.shutdown();
    _started = false;
    _instance = null;
  }
}
