import 'dart:async';
import 'package:test/test.dart';
import 'package:ac_thread_proxy/ac_thread_proxy.dart';

class Database {
  final List<String> logs = [];

  Future<void> log(String message) async {
    logs.add(message);
  }

  Future<List<String>> getLogs() async {
    return logs;
  }
}

class App {
  String title = "Proxy Server";
  int port = 8080;
  bool running = false;
  final Database db = Database();

  Future<void> start() async {
    running = true;
  }

  Future<int> add(int a, int b) async {
    return a + b;
  }

  Future<Database> getDatabase() async {
    return db;
  }

  Future<void> runCallback(dynamic callback, String message) async {
    await callback.onEvent(message);
  }
}

class MainCallback {
  String? receivedMessage;

  Future<void> onEvent(String msg) async {
    receivedMessage = msg;
  }
}

void main() {
  group('ac_thread_proxy tests', () {
    test('creates proxy and supports basic calls using named parameters', () async {
      // Use named parameters to create isolate instance
      dynamic appProxy = await acCreateIsolateInstance(clazz: App);

      // Verify properties
      expect(await appProxy.title, equals("Proxy Server"));
      expect(await appProxy.port, equals(8080));
      expect(await appProxy.running, equals(false));

      // Setter invocation and waiting for it
      appProxy.port = 9999;
      await Future.delayed(Duration(milliseconds: 100));
      expect(await appProxy.port, equals(9999));

      // Void methods
      await appProxy.start();
      expect(await appProxy.running, equals(true));

      // Positional args
      final sum = await appProxy.add(100, 200);
      expect(sum, equals(300));
    });

    test('supports nested object proxies', () async {
      dynamic appProxy = await acCreateIsolateInstance(clazz: App);

      // Get proxy for nested instance
      dynamic dbProxy = await appProxy.getDatabase();

      await dbProxy.log("nested transaction logged");
      final logs = await dbProxy.getLogs();
      expect(logs, equals(["nested transaction logged"]));
    });

    test('supports bidirectional callbacks', () async {
      dynamic appProxy = await acCreateIsolateInstance(clazz: App);
      final callback = MainCallback();

      await appProxy.runCallback(callback, "ping-pong");
      expect(callback.receivedMessage, equals("ping-pong"));
    });
  });
}
