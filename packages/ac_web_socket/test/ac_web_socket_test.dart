import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:ac_web_socket/ac_web_socket.dart';

void main() {
  group('AcWebSocket Integration Suite', () {
    test('Verify Core Functionalities', () async {
      final server = AcWsServer()..port = 0;
      await server.start();
      final port = server.port;

      final interceptorLogs = <String>[];

      // Setup Server
      server.onConnection(handler: ({required socket}) {
        socket.on(event: 'echo', handler: ({data, callback}) => socket.emit(event: 'echo', data: data));
        socket.on(event: 'ack', handler: ({data, callback}) => callback?.call(response: 'ok'));
        socket.on(event: 'bin', handler: ({data, callback}) {
           if (data is Uint8List) {
             socket.sendBinary(bytes: data);
           }
        });
        socket.addIncomingInterceptor(handler:({required message, callback, abort}) {
          interceptorLogs.add(message['e'] ?? 'none');
        });
      });

      // Setup Namespace
      final nsp = server.of(name: '/chat');
      nsp.onConnection(handler: ({required socket}) {
        socket.on(event: 'join', handler: ({data, callback}) {
          socket.join(room: data as String);
          callback?.call(response: 'joined');
        });
      });

      // Client 1 (Main)
      final c1 = AcWsClient(url: 'ws://localhost:$port');
      final s1 = await c1.connect();
      expect(s1, isNotNull);

      // Client 2 (Chat)
      final c2 = AcWsClient(url: 'ws://localhost:$port', nsp: '/chat');
      final s2 = await c2.connect();
      expect(s2, isNotNull);

      await Future.delayed(Duration(milliseconds: 200));

      // 1. Echo & Ack
      final echoRes = Completer<dynamic>();
      s1!.on(event: 'echo', handler: ({data, callback}) => echoRes.complete(data));
      s1.emit(event: 'echo', data: 'hello');
      expect(await echoRes.future.timeout(Duration(seconds: 5)), equals('hello'));
      expect(await s1.emit(event: 'ack', data: 'test'), equals('ok'));

      // 2. Binary
      final binRes = Completer<Uint8List>();
      s1.on(event: 'bin', handler: ({data, callback}) => binRes.complete(data as Uint8List));
      s1.sendBinary(bytes: Uint8List.fromList([1, 2, 3]));
      expect(await binRes.future.timeout(Duration(seconds: 5)), equals(Uint8List.fromList([1, 2, 3])));

      // 3. Rooms
      final roomRes = Completer<String>();
      s2!.on(event: 'msg', handler: ({data, callback}) => roomRes.complete(data as String));
      await s2.emit(event: 'join', data: 'lounge');
      await Future.delayed(Duration(milliseconds: 300));
      nsp.to(room: 'lounge').emit(event: 'msg', data: 'hi');
      expect(await roomRes.future.timeout(Duration(seconds: 5)), equals('hi'));

      // 4. Interceptor check
      expect(interceptorLogs, contains('echo'));
      expect(interceptorLogs, contains('ack'));

      await c1.disconnect();
      await c2.disconnect();
      await server.stop();
    });
  });
}
