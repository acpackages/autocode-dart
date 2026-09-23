import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_exceptor/ac_exceptor.dart';
import 'package:autocode/autocode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';


const Symbol _kAcExceptorIgnoreZoneKey = #_acExceptorIgnore;
class AcExceptorFlutter extends AcExceptor {
  static FlutterExceptionHandler? _originalFlutterOnError;
  static ErrorCallback? _originalPlatformOnError;

  void _handleFlutterError(FlutterErrorDetails details) {
    if (Zone.current[_kAcExceptorIgnoreZoneKey] == true) {
      return;
    }
    capture(details.exception, details.stack ?? StackTrace.current);

    if (_originalFlutterOnError != null) {
      _originalFlutterOnError!(details);
    } else {
      FlutterError.presentError(details);
    }
  }

  /// Internal handler for Dart uncaught exceptions.
  bool _handlePlatformError(Object exception, StackTrace stackTrace) {
    if (Zone.current[_kAcExceptorIgnoreZoneKey] == true) {
      return true;
    }
    capture(exception, stackTrace);

    if (_originalPlatformOnError != null) {
      return _originalPlatformOnError!(exception, stackTrace);
    }
    return false;
  }

  @override
  Future<void> dispose() async {
    if (!isInitialized) return;
    super.dispose();
    if (FlutterError.onError == _handleFlutterError) {
      FlutterError.onError = _originalFlutterOnError;
    }
    if (PlatformDispatcher.instance.onError == _handlePlatformError) {
      PlatformDispatcher.instance.onError = _originalPlatformOnError;
    }
    _originalFlutterOnError = null;
    _originalPlatformOnError = null;
  }
  
  Future<void> initialize({
    String databasePath = '_ac_exceptor_/cache.db',
    String dataDictionaryName = 'ac_exceptor',
    bool registerFlutterError = true,
    bool registerPlatformDispatcher = true,
  }) async {
    super.initialize(databasePath: databasePath,dataDictionaryName: dataDictionaryName);

    // 4. Register error handlers safely (auto-adapting for main vs background isolates)
    if (registerFlutterError) {
      try {
        _originalFlutterOnError = FlutterError.onError;
        FlutterError.onError = _handleFlutterError;
      } catch (_) {
        // Ignored if Flutter framework bindings are unavailable in this isolate
      }
    }

    if (registerPlatformDispatcher) {
      try {
        _originalPlatformOnError = PlatformDispatcher.instance.onError;
        PlatformDispatcher.instance.onError = _handlePlatformError;
      } catch (_) {
        // Ignored if PlatformDispatcher is unavailable in this isolate
      }
    }
  }
  /// Completely initializes [AcExceptor] and launches the Flutter application [app]
  /// inside a guarded asynchronous error boundary.
  ///
  /// This protects the entire application lifecycle, including synchronous startup failures,
  /// widget build/render errors, and uncaught async exceptions.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   await AcExceptor.runAppGuarded(const MyApp());
  /// }
  /// ```
  Future<void> runAppGuarded(
      Widget app, {
        String databasePath = '_ac_exceptor_/cache.db',
        String dataDictionaryName = 'ac_exceptor',
        bool registerFlutterError = true,
        bool registerPlatformDispatcher = true,
      }) async {
    await runGuarded(
          () => runApp(app),
      databasePath: databasePath,
      dataDictionaryName: dataDictionaryName,
      registerFlutterError: registerFlutterError,
      registerPlatformDispatcher: registerPlatformDispatcher,
    );
  }

  Future<void> runGuarded(
      FutureOr<void> Function() runner, {
        String databasePath = '_ac_exceptor_/cache.db',
        String dataDictionaryName = 'ac_exceptor',
        bool registerFlutterError = true,
        bool registerPlatformDispatcher = true,
      }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await initialize(
      databasePath: databasePath,
      dataDictionaryName: dataDictionaryName,
      registerFlutterError: registerFlutterError,
      registerPlatformDispatcher: registerPlatformDispatcher,
    );

    await guardAsync(() async {
      await runner();
    });
  }
}
