import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ac_exceptor_data_dictionary.dart';

const Symbol _kAcExceptorIgnoreZoneKey = #_acExceptorIgnore;

/// Executes [action] and completely ignores and suppresses any exception that occurs inside it.
///
/// Any exception thrown synchronously or asynchronously within [action] will:
/// 1. Be completely ignored by [AcExceptor] (will NOT be captured or stored in the database).
/// 2. Not crash the caller (returns [fallbackValue] or `null`).
///
/// Supports both synchronous and asynchronous functions.
///
/// Example:
/// ```dart
/// // Synchronous usage:
/// final result = acExceptorIgnore(() => riskyOperation(), fallbackValue: 'default');
///
/// // Asynchronous usage:
/// final data = await acExceptorIgnore(() async => await fetchRiskyData());
/// ```
dynamic acExceptorIgnore<T>(dynamic Function() action, {T? fallbackValue}) {
  return runZoned(() {
    try {
      final dynamic result = action();
      if (result is Future) {
        return result.then<T?>(
          (dynamic val) => val as T?,
          onError: (Object error, StackTrace stackTrace) => fallbackValue,
        );
      }
      return result as T?;
    } catch (_) {
      return fallbackValue;
    }
  }, zoneValues: {_kAcExceptorIgnoreZoneKey: true});
}

/// Lightweight Dart & Flutter exception-capturing utility that persists grouped
/// exception summaries and separate occurrence logs into a local SQLite database.
class AcExceptor {
  AcExceptor._();

  static String _databasePath = '_ac_exceptor_/cache.db';
  static final String _dataDictionaryName = 'ac_exceptor';
  static late AcSqliteDao _dao;
  static bool _initialized = false;
  static bool _isInternalCapturing = false;
  static Future<void> _queue = Future.value();

  static FlutterExceptionHandler? _originalFlutterOnError;
  static ErrorCallback? _originalPlatformOnError;

  /// Whether [AcExceptor] has been initialized.
  static bool get isInitialized => _initialized;

  /// Returns `true` if running on the main/root isolate, or `false` if running on a background worker isolate.
  static bool get isMainIsolate {
    final name = Isolate.current.debugName;
    return name == null || name == 'main';
  }

  /// The active database path.
  static String get databasePath => _databasePath;

  /// The active data dictionary name.
  static String get dataDictionaryName => _dataDictionaryName;

  /// Executes [action] and suppresses any exception that occurs inside it.
  /// Neither records to [AcExceptor] nor throws to caller.
  static dynamic ignore<T>(dynamic Function() action, {T? fallbackValue}) =>
      acExceptorIgnore<T>(action, fallbackValue: fallbackValue);

  static ReceivePort? _isolateErrorPort;

  /// A [ReceivePort] on the main isolate that listens for uncaught errors from worker isolates
  /// spawned via [Isolate.spawn].
  ///
  /// Example:
  /// ```dart
  /// Isolate.spawn(
  ///   workerEntryPoint,
  ///   args,
  ///   onError: AcExceptor.isolateErrorPort.sendPort,
  /// );
  /// ```
  static ReceivePort get isolateErrorPort {
    if (_isolateErrorPort == null) {
      _isolateErrorPort = ReceivePort();
      _isolateErrorPort!.listen((dynamic message) {
        if (message is List && message.length >= 2) {
          final dynamic error = message[0];
          final StackTrace stack =
              message[1] is String
                  ? StackTrace.fromString(message[1] as String)
                  : StackTrace.current;
          capture(error, stack);
        } else if (message != null) {
          capture(message, StackTrace.current);
        }
      });
    }
    return _isolateErrorPort!;
  }

  /// Spawns a background isolate and automatically routes any uncaught errors to [AcExceptor].
  ///
  /// Example:
  /// ```dart
  /// await AcExceptor.spawnIsolate(myWorkerFunction, message);
  /// ```
  static Future<Isolate> spawnIsolate<T>(
    void Function(T message) entryPoint,
    T message, {
    bool paused = false,
    bool errorsAreFatal = true,
    SendPort? onExit,
    String? debugName,
  }) {
    return Isolate.spawn<T>(
      entryPoint,
      message,
      paused: paused,
      errorsAreFatal: errorsAreFatal,
      onExit: onExit,
      onError: isolateErrorPort.sendPort,
      debugName: debugName,
    );
  }

  /// Completely initializes [AcExceptor] and runs the [runner] callback inside
  /// a guarded asynchronous error boundary.
  ///
  /// This protects the entire application lifecycle, including synchronous startup failures,
  /// widget initialization errors, and uncaught async exceptions.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   await AcExceptor.runGuarded(() async {
  ///     // Setup services...
  ///     runApp(const MyApp());
  ///   });
  /// }
  /// ```
  static Future<void> runGuarded(
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
  static Future<void> runAppGuarded(
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

  /// Initializes the exception-capturing mechanism and SQLite database schema.
  ///
  /// - Automatically detects whether it is running on the main isolate or a background
  ///   worker isolate. You can simply call `await AcExceptor.initialize();` identically in both.
  /// - Creates / opens the SQLite database at [databasePath] (defaults to `_ac_exceptor_/cache.db`).
  /// - Defines and updates the database schema via [AcDataDictionary] and [AcSqlDbSchemaManager].
  /// - Hooks [FlutterError.onError] and [PlatformDispatcher.instance.onError] safely.
  ///
  /// This is safe to call during application bootstrap (e.g. before `runApp`) or at
  /// the start of background isolates.
  static Future<void> initialize({
    String databasePath = '_ac_exceptor_/cache.db',
    String dataDictionaryName = 'ac_exceptor',
    bool registerFlutterError = true,
    bool registerPlatformDispatcher = true,
  }) async {
    if (_initialized &&
        _databasePath == databasePath &&
        _dataDictionaryName == dataDictionaryName) {
      return;
    }

    if (_initialized) {
      await dispose();
    }

    _databasePath = databasePath;

    // Ensure target directory exists for SQLite database file
    final dbFile = File(_databasePath);
    if (!dbFile.parent.existsSync()) {
      dbFile.parent.createSync(recursive: true);
    }

    // 1. Register the schema with AcDataDictionary
    AcDataDictionary.registerDataDictionaryJsonString(
      jsonString: kAcExceptorDataDictionaryJson,
      dataDictionaryName: _dataDictionaryName,
    );

    // 2. Initialize SQLite DAO
    _dao = AcSqliteDao();
    await _dao.setSqlConnection(
      sqlConnection: AcSqlConnection(database: _databasePath),
    );

    // 3. Ensure tables exist (fast, silent, and idempotent across all isolates)
    await _dao.executeStatement(
      statement: '''
      CREATE TABLE IF NOT EXISTS ${AcExceptorTables.exceptions} (
        ${AcExceptorColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AcExceptorColumns.exceptionType} TEXT NOT NULL,
        ${AcExceptorColumns.exceptionMessage} TEXT NOT NULL,
        ${AcExceptorColumns.stackTrace} TEXT,
        ${AcExceptorColumns.firstOccurredAt} TEXT NOT NULL,
        ${AcExceptorColumns.lastOccurredAt} TEXT NOT NULL,
        ${AcExceptorColumns.occurrenceCount} INTEGER NOT NULL DEFAULT 1,
        ${AcExceptorColumns.isHandled} INTEGER NOT NULL DEFAULT 0,
        UNIQUE(${AcExceptorColumns.exceptionType}, ${AcExceptorColumns.exceptionMessage})
      );
      ''',
    );
    await _dao.executeStatement(
      statement: '''
      CREATE TABLE IF NOT EXISTS ${AcExceptorTables.exceptionOccurrences} (
        ${AcExceptorColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AcExceptorColumns.exceptionId} INTEGER NOT NULL,
        ${AcExceptorColumns.occurredAt} TEXT NOT NULL,
        ${AcExceptorColumns.stackTrace} TEXT,
        ${AcExceptorColumns.isHandled} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${AcExceptorColumns.exceptionId}) REFERENCES ${AcExceptorTables.exceptions} (${AcExceptorColumns.id}) ON DELETE CASCADE
      );
      ''',
    );

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

    // 5. Connect AcLogger and AcResult hooks to capture all handled exceptions
    AcLogger.onErrorCallback = ({
      required dynamic error,
      StackTrace? stackTrace,
      String? message,
    }) {
      if (Zone.current[_kAcExceptorIgnoreZoneKey] == true) return;
      captureHandled(error ?? message, stackTrace);
    };

    AcResult.onException = (dynamic ex, dynamic st) {
      if (Zone.current[_kAcExceptorIgnoreZoneKey] == true) return;
      StackTrace? trace;
      if (st is StackTrace) {
        trace = st;
      } else if (st is String && st.isNotEmpty) {
        trace = StackTrace.fromString(st);
      }
      captureHandled(ex, trace);
    };

    if (isMainIsolate) {
      // Auto-activate error port listener on main isolate
      isolateErrorPort;
    }

    _initialized = true;
  }

  /// Runs [computation] in a background worker isolate with full automatic exception capture
  /// (both managed and unmanaged errors inside the isolate are persisted to SQLite).
  ///
  /// Example:
  /// ```dart
  /// final result = await AcExceptor.runIsolate(() {
  ///   return heavyComputation();
  /// });
  /// ```
  static Future<R> runIsolate<R>(
    FutureOr<R> Function() computation, {
    String? debugName,
  }) async {
    final String activeDbPath = _databasePath;
    final String activeDdName = _dataDictionaryName;

    return await Isolate.run<R>(() async {
      await initialize(
        databasePath: activeDbPath,
        dataDictionaryName: activeDdName,
      );

      try {
        return await computation();
      } catch (error, stackTrace) {
        await capture(error, stackTrace, true);
        rethrow;
      }
    }, debugName: debugName);
  }

  /// Runs [computation] in a background worker isolate, automatically captures any managed
  /// or unmanaged exception to SQLite, and returns [fallbackValue] instead of throwing.
  ///
  /// Example:
  /// ```dart
  /// final result = await AcExceptor.runIsolateGuarded(
  ///   () => heavyComputation(),
  ///   fallbackValue: defaultValue,
  /// );
  /// ```
  static Future<R?> runIsolateGuarded<R>(
    FutureOr<R> Function() computation, {
    R? fallbackValue,
    String? debugName,
  }) async {
    try {
      return await runIsolate<R>(computation, debugName: debugName);
    } catch (_) {
      return fallbackValue;
    }
  }

  /// Records a caught exception with its optional stack trace.
  ///
  /// Set [isHandled] to `true` (or use [captureHandled]) to record it as a handled exception.
  static Future<void> capture(
    dynamic exception, [
    StackTrace? stackTrace,
    bool isHandled = false,
  ]) {
    if (!_initialized ||
        _isInternalCapturing ||
        Zone.current[_kAcExceptorIgnoreZoneKey] == true) {
      return Future.value();
    }

    final Completer<void> completer = Completer<void>();
    _queue = _queue.then((_) async {
      _isInternalCapturing = true;
      try {
        await _recordException(
          exception,
          stackTrace ?? StackTrace.current,
          isHandled: isHandled,
        );
        if (!completer.isCompleted) completer.complete();
      } catch (e, st) {
        // Prevent recursive reporting and application instability
        developer.log(
          'AcExceptor: internal capture error — $e',
          name: 'ac_exceptor',
          error: e,
          stackTrace: st,
        );
        if (!completer.isCompleted) completer.complete();
      } finally {
        _isInternalCapturing = false;
      }
    });

    return completer.future;
  }

  /// Convenience shorthand to record a handled exception with its optional stack trace.
  static Future<void> captureHandled(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) => capture(exception, stackTrace, true);

  /// Safely executes synchronous [action]. If an exception occurs, it is automatically
  /// recorded as a handled exception via [captureHandled], and [onError] or [fallbackValue] is returned.
  static T? guard<T>(
    T Function() action, {
    T Function(Object error, StackTrace stackTrace)? onError,
    T? fallbackValue,
  }) {
    try {
      return action();
    } catch (e, st) {
      captureHandled(e, st);
      if (onError != null) {
        return onError(e, st);
      }
      return fallbackValue;
    }
  }

  /// Safely executes asynchronous [action]. If an exception occurs, it is automatically
  /// recorded as a handled exception via [captureHandled], and [onError] or [fallbackValue] is returned.
  static Future<T?> guardAsync<T>(
    Future<T> Function() action, {
    FutureOr<T> Function(Object error, StackTrace stackTrace)? onError,
    T? fallbackValue,
  }) async {
    try {
      return await action();
    } catch (e, st) {
      await captureHandled(e, st);
      if (onError != null) {
        return await onError(e, st);
      }
      return fallbackValue;
    }
  }

  /// Internal handler for Flutter framework errors.
  static void _handleFlutterError(FlutterErrorDetails details) {
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
  static bool _handlePlatformError(Object exception, StackTrace stackTrace) {
    if (Zone.current[_kAcExceptorIgnoreZoneKey] == true) {
      return true;
    }
    capture(exception, stackTrace);

    if (_originalPlatformOnError != null) {
      return _originalPlatformOnError!(exception, stackTrace);
    }
    return false;
  }

  /// Persists or updates the grouped exception and writes the individual occurrence row.
  static Future<void> _recordException(
    dynamic exception,
    StackTrace stackTrace, {
    bool isHandled = false,
  }) async {
    final String exceptionType = exception.runtimeType.toString();
    final String exceptionMessage = exception.toString();
    final String stackTraceStr = stackTrace.toString();
    final String now = DateTime.now().toUtcIso8601String();
    final int handledVal = isHandled ? 1 : 0;

    // Check if an existing grouped exception with matching type & message exists
    final existingResult = await _dao.getRows(
      statement:
          'SELECT ${AcExceptorColumns.id}, ${AcExceptorColumns.occurrenceCount} '
          'FROM ${AcExceptorTables.exceptions} '
          'WHERE ${AcExceptorColumns.exceptionType} = :type '
          'AND ${AcExceptorColumns.exceptionMessage} = :message '
          'LIMIT 1',
      parameters: {':type': exceptionType, ':message': exceptionMessage},
    );

    if (existingResult.isSuccess() && existingResult.rows.isNotEmpty) {
      final row = existingResult.rows.first;
      final int exceptionId = row[AcExceptorColumns.id] as int;
      final int currentCount =
          (row[AcExceptorColumns.occurrenceCount] as int? ?? 1) + 1;

      // Update existing grouped record
      await _dao.updateRow(
        tableName: AcExceptorTables.exceptions,
        row: {
          AcExceptorColumns.occurrenceCount: currentCount,
          AcExceptorColumns.lastOccurredAt: now,
          AcExceptorColumns.stackTrace: stackTraceStr,
          AcExceptorColumns.isHandled: handledVal,
        },
        condition: '${AcExceptorColumns.id} = :id',
        parameters: {':id': exceptionId},
      );

      // Insert new occurrence row
      await _dao.insertRow(
        tableName: AcExceptorTables.exceptionOccurrences,
        row: {
          AcExceptorColumns.exceptionId: exceptionId,
          AcExceptorColumns.occurredAt: now,
          AcExceptorColumns.stackTrace: stackTraceStr,
          AcExceptorColumns.isHandled: handledVal,
        },
      );
    } else {
      // Insert new grouped exception
      final insertResult = await _dao.insertRow(
        tableName: AcExceptorTables.exceptions,
        row: {
          AcExceptorColumns.exceptionType: exceptionType,
          AcExceptorColumns.exceptionMessage: exceptionMessage,
          AcExceptorColumns.stackTrace: stackTraceStr,
          AcExceptorColumns.firstOccurredAt: now,
          AcExceptorColumns.lastOccurredAt: now,
          AcExceptorColumns.occurrenceCount: 1,
          AcExceptorColumns.isHandled: handledVal,
        },
      );

      final int? exceptionId = insertResult.lastInsertedId;
      if (exceptionId != null) {
        // Insert first occurrence row
        await _dao.insertRow(
          tableName: AcExceptorTables.exceptionOccurrences,
          row: {
            AcExceptorColumns.exceptionId: exceptionId,
            AcExceptorColumns.occurredAt: now,
            AcExceptorColumns.stackTrace: stackTraceStr,
            AcExceptorColumns.isHandled: handledVal,
          },
        );
      }
    }
  }

  /// Retrieves all grouped exceptions from the SQLite database.
  static Future<List<Map<String, dynamic>>> getExceptions() async {
    if (!_initialized) return [];
    final result = await _dao.getRows(
      statement:
          'SELECT * FROM ${AcExceptorTables.exceptions} ORDER BY ${AcExceptorColumns.id} ASC',
    );
    return result.rows;
  }

  /// Retrieves occurrence records from the SQLite database, optionally filtered by [exceptionId].
  static Future<List<Map<String, dynamic>>> getOccurrences({
    int? exceptionId,
  }) async {
    if (!_initialized) return [];
    if (exceptionId != null) {
      final result = await _dao.getRows(
        statement:
            'SELECT * FROM ${AcExceptorTables.exceptionOccurrences} '
            'WHERE ${AcExceptorColumns.exceptionId} = :id '
            'ORDER BY ${AcExceptorColumns.id} ASC',
        parameters: {':id': exceptionId},
      );
      return result.rows;
    }
    final result = await _dao.getRows(
      statement:
          'SELECT * FROM ${AcExceptorTables.exceptionOccurrences} '
          'ORDER BY ${AcExceptorColumns.id} ASC',
    );
    return result.rows;
  }

  /// Disposes the exception handler, unhooks error listeners, and closes the database connection.
  static Future<void> dispose() async {
    if (!_initialized) return;

    if (FlutterError.onError == _handleFlutterError) {
      FlutterError.onError = _originalFlutterOnError;
    }
    if (PlatformDispatcher.instance.onError == _handlePlatformError) {
      PlatformDispatcher.instance.onError = _originalPlatformOnError;
    }
    _originalFlutterOnError = null;
    _originalPlatformOnError = null;

    AcLogger.onErrorCallback = null;
    AcResult.onException = null;

    try {
      await _queue;
    } catch (_) {}

    try {
      await _dao.close();
    } catch (_) {}

    _isolateErrorPort?.close();
    _isolateErrorPort = null;

    _initialized = false;
  }
}

/// Extension on [Future] for auto-capturing handled errors into [AcExceptor].
extension AcExceptorFutureExtension<T> on Future<T> {
  /// Automatically captures any error occurring on this [Future] as a handled exception
  /// in [AcExceptor] and optionally returns [fallbackValue].
  Future<T?> captureHandled({T? fallbackValue}) {
    return then<T?>(
      (val) => val,
      onError: (Object error, StackTrace stackTrace) async {
        await AcExceptor.captureHandled(error, stackTrace);
        return fallbackValue;
      },
    );
  }
}

/// Extension on synchronous functions for auto-capturing handled errors into [AcExceptor].
extension AcExceptorFunctionExtension<T> on T Function() {
  /// Returns a guarded version of this function that automatically captures any thrown
  /// exception in [AcExceptor] as a handled exception and returns [fallbackValue].
  T? Function() guarded({T? fallbackValue}) {
    return () => AcExceptor.guard(this, fallbackValue: fallbackValue);
  }
}

/// Extension on asynchronous functions for auto-capturing handled errors into [AcExceptor].
extension AcExceptorAsyncFunctionExtension<T> on Future<T> Function() {
  /// Returns a guarded version of this async function that automatically captures any thrown
  /// exception in [AcExceptor] as a handled exception and returns [fallbackValue].
  Future<T?> Function() guardedAsync({T? fallbackValue}) {
    return () => AcExceptor.guardAsync(this, fallbackValue: fallbackValue);
  }
}
