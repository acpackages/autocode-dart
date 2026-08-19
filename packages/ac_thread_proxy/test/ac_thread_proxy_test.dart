import 'dart:async';
import 'dart:isolate';
import 'package:test/test.dart';
import 'package:ac_thread_proxy/ac_thread_proxy.dart';

void main() {
  group('AcThreadChannel Tests', () {
    late ReceivePort mainReceivePort;
    late AcThreadChannel mainChannel;
    late AcThreadChannel childChannel;

    setUp(() {
      mainReceivePort = ReceivePort();
      mainChannel = AcThreadChannel(receivePort: mainReceivePort);
      childChannel = AcThreadChannel(sendPort: mainReceivePort.sendPort);
    });

    tearDown(() {
      mainChannel.close();
      childChannel.close();
    });

    test('successfully communicates back and forth', () async {
      childChannel.on(key: 'add', callback: (Map<String, dynamic> args) async {
        return (args['a'] as int) + (args['b'] as int);
      });

      final result = await mainChannel.emit(key: 'add', data: {'a': 10, 'b': 20});
      expect(result, equals(30));
    });

    test('handles 0-arity callback when data is passed (resilience to arity mismatch)', () async {
      childChannel.on(key: 'ping', callback: () async {
        return 'pong';
      });

      final result = await mainChannel.emit(key: 'ping', data: {'extra': 'data'});
      expect(result, equals('pong'));
    });

    test('handles 1-arity callback when data is null (resilience to arity mismatch)', () async {
      childChannel.on(key: 'checkNull', callback: (args) async {
        return args == null ? 'was_null' : 'not_null';
      });

      final result = await mainChannel.emit(key: 'checkNull');
      expect(result, equals('was_null'));
    });

    test('returns error when callback throws an exception without hanging', () async {
      childChannel.on(key: 'failingOp', callback: (args) async {
        throw FormatException('Invalid payload format');
      });

      expect(
        () async => await mainChannel.emit(key: 'failingOp', data: {}),
        throwsA(predicate((e) => e.toString().contains('Invalid payload format'))),
      );
    });

    test('returns error when key is not registered without hanging', () async {
      expect(
        () async => await mainChannel.emit(key: 'unregistered_key'),
        throwsA(predicate((e) => e.toString().contains('No callback registered for key'))),
      );
    });

    test('handles timeout when requested', () async {
      childChannel.on(key: 'slowOp', callback: (args) async {
        await Future.delayed(const Duration(seconds: 2));
        return 'done';
      });

      expect(
        () async => await mainChannel.emit(
          key: 'slowOp',
          timeout: const Duration(milliseconds: 100),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('closing channel completes pending requests with error', () async {
      childChannel.on(key: 'neverCompletes', callback: (args) async {
        await Completer<void>().future;
      });

      final future = mainChannel.emit(key: 'neverCompletes');
      await Future.delayed(const Duration(milliseconds: 50));
      mainChannel.close();

      expect(
        () async => await future,
        throwsA(isA<StateError>()),
      );
    });
  });
}

