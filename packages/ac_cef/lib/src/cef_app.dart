import 'cef_settings.dart';
import 'native/cef_bindings.dart';
import 'native/cef_native_client.dart';
import 'cef_client.dart';

/// State of the CefApp lifecycle matching JCEF's [org.cef.CefApp.CefAppState].
enum CefAppState {
  none,
  newApp,
  initializing,
  initialized,
  shuttingDown,
  terminated,
}

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

  CefAppState _state = CefAppState.none;

  CefApp._() {
    _state = CefAppState.newApp;
  }

  /// Returns the singleton [CefApp] instance.
  factory CefApp.getInstance() {
    return _instance ??= CefApp._();
  }

  /// Returns the current lifecycle state of [CefApp].
  CefAppState getState() => _state;

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
    if (_state == CefAppState.initialized) return true;

    _state = CefAppState.initializing;
    _bindings = CefBindings.load(libraryPath ?? CefBindings.defaultLibraryPath());
    _client = client ?? CefClient();
    _native = CefNativeClient(bindings: _bindings, client: _client);

    final ok = _native.initialize(settings);
    if (ok) {
      _state = CefAppState.initialized;
    } else {
      _state = CefAppState.none;
    }
    return ok;
  }

  /// Access the underlying [CefClient] to register handlers.
  CefClient get client {
    if (_state != CefAppState.initialized) {
      throw StateError('CefApp.start() must be called first.');
    }
    return _client;
  }

  /// Access the [CefNativeClient] for creating browsers and managing the bridge.
  CefNativeClient get native {
    if (_state != CefAppState.initialized) {
      throw StateError('CefApp.start() must be called first.');
    }
    return _native;
  }

  /// Starts the built-in 1ms CEF message-loop pump timer.
  /// Shortcut for `native.startMessagePump()`.
  void startMessagePump() => _native.startMessagePump();

  /// Stops the pump started by [startMessagePump].
  void stopMessagePump()  => _native.stopMessagePump();

  /// Whether CEF has been initialized.
  bool get isStarted => _state == CefAppState.initialized;

  /// Shut down CEF. Must be called before the process exits.
  void shutdown() {
    if (_state != CefAppState.initialized) return;
    _state = CefAppState.shuttingDown;
    _native.shutdown();
    _state = CefAppState.terminated;
    _instance = null;
  }
}
