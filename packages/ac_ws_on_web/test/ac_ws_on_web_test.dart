import 'dart:async';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:ac_web/ac_web.dart';
import 'package:ac_ws_server/ac_ws_server.dart';
import 'package:ac_ws_on_web/ac_ws_on_web.dart';
import 'package:ac_ws_client/ac_ws_client.dart';

void main() {
  group('AcWsOnWeb Tests', () {
    late AcWsServer wsServer;
    late AcWeb app;
    late AcWsOnWeb bridge;
    late AcWsClient client;
    final port = 8081;

    setUp(() async {
      wsServer = AcWsServer();
      app = AcWeb();
      // bridge = AcWsOnWeb(wsServer, app);
      
      app.get(
        url: 'test',
        handler: (req, logger) async {
          return AcWebResponse.json(data: {'success': true});
        },
      );
      wsServer.port = 8081;
      await wsServer.start();
      client = AcWsClient('ws://localhost:$port');
      await client.connect();
    });

    tearDown(() async {
      client.disconnect();
      await wsServer.stop();
    });

    test('should handle web_request and return response via ack', () async {
      final response = await client.emit('web_request', {
        'url': 'test',
        'method': 'GET',
      }) as Map<String, dynamic>;

      expect(response['status'], equals(200));
      expect(response['content']['success'], isTrue);
    });

    test('should return 404 for unknown route', () async {
      final response = await client.emit('web_request', {
        'url': 'unknown',
        'method': 'GET',
      }) as Map<String, dynamic>;

      expect(response['status'], equals(404));
    });

    test('should support custom event name', () async {
      final customWsServer = AcWsServer();
      final customApp = AcWeb();
      // AcWsOnWeb(customWsServer, customApp, eventName: 'custom_event');
      
      customApp.get(url: 'custom', handler: (r, l) async => AcWebResponse.json(data: 'ok'));
      customWsServer.port = 8082;
      await customWsServer.start();
      final customClient = AcWsClient('ws://localhost:8082');
      await customClient.connect();
      
      final response = await customClient.emit('custom_event', {
        'url': 'custom',
        'method': 'GET',
      }) as Map<String, dynamic>;
      
      expect(response['content'], equals('ok'));
      
      customClient.disconnect();
      await customWsServer.stop();
    });
  });
}
