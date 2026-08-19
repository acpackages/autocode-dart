import 'dart:io';
import 'dart:isolate';

import 'package:ac_exceptor/ac_exceptor.dart';
import 'package:autocode/autocode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {
  group('AcExceptor SQLite & Error Handling Tests', () {
    const testDbPath = 'test_cache/test_exceptor.db';

    void deleteTestDb() {
      final file = File(testDbPath);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
      final parent = file.parent;
      if (parent.existsSync()) {
        try {
          parent.deleteSync(recursive: true);
        } catch (_) {}
      }
    }

    setUp(() async {
      deleteTestDb();
      await AcExceptor.initialize(
        databasePath: testDbPath,
        registerFlutterError: false,
        registerPlatformDispatcher: false,
      );
    });

    tearDown(() async {
      await AcExceptor.dispose();
      deleteTestDb();
    });

    test('1. Database file is created at the specified path', () async {
      expect(File(testDbPath).existsSync(), isTrue);
      expect(AcExceptor.isInitialized, isTrue);
      expect(AcExceptor.databasePath, equals(testDbPath));
    });

    test(
      '2 & 3. Tables (exceptions and exception_occurrences) are created in schema',
      () async {
        final exceptions = await AcExceptor.getExceptions();
        final occurrences = await AcExceptor.getOccurrences();

        expect(exceptions, isEmpty);
        expect(occurrences, isEmpty);
      },
    );

    test(
      '4. Inserting a new exception creates a grouped record and an occurrence record',
      () async {
        final ex = FormatException('Invalid JSON payload');
        final stack = StackTrace.current;

        await AcExceptor.capture(ex, stack);

        final exceptions = await AcExceptor.getExceptions();
        final occurrences = await AcExceptor.getOccurrences();

        expect(exceptions.length, equals(1));
        expect(occurrences.length, equals(1));

        final grouped = exceptions.first;
        expect(
          grouped[AcExceptorColumns.exceptionType],
          equals('FormatException'),
        );
        expect(
          grouped[AcExceptorColumns.exceptionMessage],
          equals('FormatException: Invalid JSON payload'),
        );
        expect(grouped[AcExceptorColumns.occurrenceCount], equals(1));
        expect(grouped[AcExceptorColumns.firstOccurredAt], isNotEmpty);
        expect(grouped[AcExceptorColumns.lastOccurredAt], isNotEmpty);
        expect(
          grouped[AcExceptorColumns.firstOccurredAt],
          equals(grouped[AcExceptorColumns.lastOccurredAt]),
        );

        final occ = occurrences.first;
        expect(
          occ[AcExceptorColumns.exceptionId],
          equals(grouped[AcExceptorColumns.id]),
        );
        expect(occ[AcExceptorColumns.occurredAt], isNotEmpty);
      },
    );

    test(
      '5 & 6. Duplicate identical exceptions are grouped and occurrence_count is incremented',
      () async {
        // Capture 5 identical exceptions
        for (int i = 0; i < 5; i++) {
          await AcExceptor.capture(TypeError(), StackTrace.current);
        }

        final exceptions = await AcExceptor.getExceptions();
        final occurrences = await AcExceptor.getOccurrences();

        // Only 1 grouped row
        expect(exceptions.length, equals(1));
        expect(exceptions.first[AcExceptorColumns.occurrenceCount], equals(5));

        // 5 individual occurrence rows
        expect(occurrences.length, equals(5));
        for (final occ in occurrences) {
          expect(
            occ[AcExceptorColumns.exceptionId],
            equals(exceptions.first[AcExceptorColumns.id]),
          );
          expect(occ[AcExceptorColumns.occurredAt], isNotEmpty);
        }
      },
    );

    test('7. Multiple occurrence timestamps are stored individually', () async {
      final ex = StateError('Operation not supported');

      await AcExceptor.capture(ex, StackTrace.current);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await AcExceptor.capture(ex, StackTrace.current);

      final occurrences = await AcExceptor.getOccurrences();
      expect(occurrences.length, equals(2));

      final firstTimestamp =
          occurrences[0][AcExceptorColumns.occurredAt] as String;
      final secondTimestamp =
          occurrences[1][AcExceptorColumns.occurredAt] as String;

      expect(firstTimestamp, isNotEmpty);
      expect(secondTimestamp, isNotEmpty);
    });

    test('8. Different messages create separate grouped exceptions', () async {
      await AcExceptor.capture(Exception('Error A'), StackTrace.current);
      await AcExceptor.capture(Exception('Error B'), StackTrace.current);

      final exceptions = await AcExceptor.getExceptions();
      expect(exceptions.length, equals(2));

      final messages =
          exceptions.map((e) => e[AcExceptorColumns.exceptionMessage]).toList();
      expect(messages, contains('Exception: Error A'));
      expect(messages, contains('Exception: Error B'));
    });

    test(
      '9. Different exception types with same message create separate grouped exceptions',
      () async {
        await AcExceptor.capture(
          FormatException('Duplicate message'),
          StackTrace.current,
        );
        await AcExceptor.capture(
          StateError('Duplicate message'),
          StackTrace.current,
        );

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(2));

        final types =
            exceptions.map((e) => e[AcExceptorColumns.exceptionType]).toList();
        expect(types, contains('FormatException'));
        expect(types, contains('StateError'));
      },
    );

    test(
      '10. Stack trace is stored in both exceptions and occurrences tables',
      () async {
        final stack = StackTrace.fromString('line 1: funcA\nline 2: funcB');
        await AcExceptor.capture(ArgumentError('Invalid argument'), stack);

        final exceptions = await AcExceptor.getExceptions();
        final occurrences = await AcExceptor.getOccurrences();

        expect(
          exceptions.first[AcExceptorColumns.stackTrace],
          contains('funcA'),
        );
        expect(
          occurrences.first[AcExceptorColumns.stackTrace],
          contains('funcA'),
        );
      },
    );

    test(
      '11. Manual capture handles arbitrary objects without throwing',
      () async {
        await AcExceptor.capture('A simple string error', StackTrace.current);
        await AcExceptor.capture({
          'code': 500,
          'error': 'Server error',
        }, StackTrace.current);

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(2));
      },
    );

    test(
      '12. Concurrent captures serialize properly and do not create duplicate grouped records',
      () async {
        final ex = RangeError('Index out of bounds');

        // Fire 10 concurrent captures at the same time
        await Future.wait(
          List.generate(10, (_) => AcExceptor.capture(ex, StackTrace.current)),
        );

        final exceptions = await AcExceptor.getExceptions();
        final occurrences = await AcExceptor.getOccurrences();

        expect(exceptions.length, equals(1));
        expect(exceptions.first[AcExceptorColumns.occurrenceCount], equals(10));
        expect(occurrences.length, equals(10));
      },
    );

    test(
      '13. FlutterError.onError interception works and preserves original handler',
      () async {
        await AcExceptor.dispose();

        bool originalCalled = false;
        void originalHandler(FlutterErrorDetails details) {
          originalCalled = true;
        }

        FlutterError.onError = originalHandler;

        await AcExceptor.initialize(
          databasePath: testDbPath,
          registerFlutterError: true,
          registerPlatformDispatcher: false,
        );

        final errorDetails = FlutterErrorDetails(
          exception: FlutterError('Widget layout error'),
          stack: StackTrace.current,
        );

        FlutterError.onError!(errorDetails);

        // Give event loop time to process async capture queue
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionType],
          equals('FlutterError'),
        );
        expect(originalCalled, isTrue);
      },
    );

    test(
      '14. PlatformDispatcher.instance.onError interception works',
      () async {
        await AcExceptor.dispose();

        await AcExceptor.initialize(
          databasePath: testDbPath,
          registerFlutterError: false,
          registerPlatformDispatcher: true,
        );

        final testEx = StateError('Uncaught platform error');
        PlatformDispatcher.instance.onError!(testEx, StackTrace.current);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionMessage],
          contains('Uncaught platform error'),
        );
      },
    );

    test(
      '15. Background isolate can initialize and capture exceptions into shared database',
      () async {
        expect(AcExceptor.isMainIsolate, isTrue);

        final port = ReceivePort();
        await Isolate.spawn(_backgroundWorkerEntryPoint, {
          'port': port.sendPort,
          'dbPath': testDbPath,
        });

        final isolateResult = await port.first;
        expect(isolateResult, equals('done'));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionType],
          equals('UnimplementedError'),
        );
        expect(
          exceptions.first[AcExceptorColumns.exceptionMessage],
          contains('Worker isolate failed'),
        );
      },
    );

    test(
      '16. captureHandled correctly stores is_handled flag in database',
      () async {
        await AcExceptor.captureHandled(
          FormatException('Handled parse error'),
          StackTrace.current,
        );

        final exceptions = await AcExceptor.getExceptions();
        final occurrences = await AcExceptor.getOccurrences();

        expect(exceptions.length, equals(1));
        expect(exceptions.first[AcExceptorColumns.isHandled], equals(1));

        expect(occurrences.length, equals(1));
        expect(occurrences.first[AcExceptorColumns.isHandled], equals(1));
      },
    );

    test(
      '17. AcExceptor.guard executes safely, captures handled errors, and returns fallback',
      () async {
        final result = AcExceptor.guard<int>(() {
          throw ArgumentError('Invalid calculation argument');
        }, fallbackValue: 42);

        expect(result, equals(42));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionType],
          equals('ArgumentError'),
        );
        expect(exceptions.first[AcExceptorColumns.isHandled], equals(1));
      },
    );

    test(
      '18. AcExceptor.guardAsync executes safely and captures asynchronous handled errors',
      () async {
        final result = await AcExceptor.guardAsync<String>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          throw HttpException('Failed network request');
        }, onError: (e, st) => 'recovered');

        expect(result, equals('recovered'));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionType],
          equals('HttpException'),
        );
        expect(exceptions.first[AcExceptorColumns.isHandled], equals(1));
      },
    );

    test(
      '19. acExceptorIgnore suppresses synchronous exceptions and does not record to database',
      () async {
        final result = acExceptorIgnore<int>(() {
          throw RangeError('Ignored synchronous error');
        }, fallbackValue: -1);

        expect(result, equals(-1));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions, isEmpty);
      },
    );

    test(
      '20. acExceptorIgnore suppresses asynchronous exceptions and does not record to database',
      () async {
        final result = await acExceptorIgnore<String>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          throw const SocketException('Ignored async socket error');
        }, fallbackValue: 'fallback_ok');

        expect(result, equals('fallback_ok'));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions, isEmpty);
      },
    );

    test(
      '21. AcExceptor.ignore prevents inner capture calls from saving to database',
      () async {
        AcExceptor.ignore(() {
          AcExceptor.capture(
            StateError('Explicitly ignored capture'),
            StackTrace.current,
          );
        });

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions, isEmpty);
      },
    );

    test(
      '22. Future.captureHandled auto-captures rejected future and returns fallback',
      () async {
        final future = Future<String>.error(
          const FileSystemException('File not found'),
        );

        final result = await future.captureHandled(
          fallbackValue: 'fallback_content',
        );
        expect(result, equals('fallback_content'));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionType],
          equals('FileSystemException'),
        );
        expect(exceptions.first[AcExceptorColumns.isHandled], equals(1));
      },
    );

    test('23. Function.guarded auto-captures synchronous errors', () async {
      int riskyCalc() => throw const FormatException('Bad formula');
      final safeCalc = riskyCalc.guarded(fallbackValue: 0);

      final result = safeCalc();
      expect(result, equals(0));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final exceptions = await AcExceptor.getExceptions();
      expect(exceptions.length, equals(1));
      expect(
        exceptions.first[AcExceptorColumns.exceptionType],
        equals('FormatException'),
      );
      expect(exceptions.first[AcExceptorColumns.isHandled], equals(1));
    });

    test(
      '24. AsyncFunction.guardedAsync auto-captures asynchronous errors',
      () async {
        Future<String> fetchRemote() async =>
            throw const SocketException('Connection reset');
        final safeFetch = fetchRemote.guardedAsync(fallbackValue: 'offline');

        final result = await safeFetch();
        expect(result, equals('offline'));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionType],
          equals('SocketException'),
        );
        expect(exceptions.first[AcExceptorColumns.isHandled], equals(1));
      },
    );

    test(
      '25. AcExceptor.runAppGuarded safely initializes and wraps app execution',
      () async {
        // Dispose existing instance first
        await AcExceptor.dispose();

        await AcExceptor.runAppGuarded(
          const SizedBox(),
          databasePath: testDbPath,
        );

        expect(AcExceptor.isInitialized, isTrue);
        expect(AcExceptor.databasePath, equals(testDbPath));
      },
    );

    test(
      '25b. AcExceptor.runGuarded safely initializes and wraps custom runner callback',
      () async {
        await AcExceptor.dispose();

        bool customRunnerExecuted = false;
        await AcExceptor.runGuarded(
          () async {
            customRunnerExecuted = true;
          },
          databasePath: testDbPath,
        );

        expect(AcExceptor.isInitialized, isTrue);
        expect(customRunnerExecuted, isTrue);
        expect(AcExceptor.databasePath, equals(testDbPath));
      },
    );

    test(
      '26. AcExceptor.spawnIsolate automatically captures unmanaged exceptions from background isolate',
      () async {
        final isolate = await AcExceptor.spawnIsolate(
          _unmanagedIsolateEntryPoint,
          'trigger_unmanaged_crash',
        );

        // Allow worker isolate to crash and error port to deliver message
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionMessage],
          contains('Uncaught crash in raw spawned isolate'),
        );

        isolate.kill(priority: Isolate.immediate);
      },
    );

    test(
      '27. AcExceptor.runIsolate captures exceptions and rethrows to caller',
      () async {
        try {
          await AcExceptor.runIsolate<int>(() {
            throw const FormatException('Failed computation in runIsolate');
          });
          fail('Should have rethrown');
        } catch (e) {
          expect(e, isA<FormatException>());
        }

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionType],
          equals('FormatException'),
        );
      },
    );

    test(
      '28. AcExceptor.runIsolateGuarded captures exceptions and returns fallback',
      () async {
        final result = await AcExceptor.runIsolateGuarded<String>(() {
          throw const SocketException('Worker isolate timeout');
        }, fallbackValue: 'fallback_iso');

        expect(result, equals('fallback_iso'));

        final exceptions = await AcExceptor.getExceptions();
        expect(exceptions.length, equals(1));
        expect(
          exceptions.first[AcExceptorColumns.exceptionType],
          equals('SocketException'),
        );
      },
    );

    test('29. AcLogger.error automatically captures handled exception into SQLite', () async {
      final logger = AcLogger(logMessages: false);
      logger.error('Database connection failed on query');

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final exceptions = await AcExceptor.getExceptions();
      final occurrences = await AcExceptor.getOccurrences();

      expect(exceptions.length, equals(1));
      expect(exceptions.first[AcExceptorColumns.exceptionMessage], contains('Database connection failed on query'));
      expect(exceptions.first[AcExceptorColumns.isHandled], equals(1));
      expect(occurrences.length, equals(1));
      expect(occurrences.first[AcExceptorColumns.isHandled], equals(1));
    });

    test('30. AcResult.setException automatically captures handled exception into SQLite', () async {
      final result = AcResult();
      result.setException(
        exception: const FormatException('Invalid customer tax ID format'),
        stackTrace: StackTrace.current,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final exceptions = await AcExceptor.getExceptions();
      expect(exceptions.length, equals(1));
      expect(exceptions.first[AcExceptorColumns.exceptionType], equals('FormatException'));
      expect(exceptions.first[AcExceptorColumns.exceptionMessage], contains('Invalid customer tax ID format'));
      expect(exceptions.first[AcExceptorColumns.isHandled], equals(1));
    });
  });
}

void _unmanagedIsolateEntryPoint(String message) {
  // Raw unmanaged throw without try/catch or AcExceptor.initialize
  throw Exception('Uncaught crash in raw spawned isolate: $message');
}

void _backgroundWorkerEntryPoint(Map<String, dynamic> args) async {
  final sendPort = args['port'] as SendPort;
  final dbPath = args['dbPath'] as String;

  // Simply initialize and capture in background isolate
  await AcExceptor.initialize(databasePath: dbPath);

  await AcExceptor.capture(
    UnimplementedError('Worker isolate failed'),
    StackTrace.current,
  );

  await AcExceptor.dispose();
  sendPort.send('done');
}
