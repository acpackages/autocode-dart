import 'dart:async';
import 'dart:isolate';
// import 'package:test/test.dart';
import 'package:arcitect/arcitect.dart';

// Test Classes

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
  String title = "Original Title";
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
  // group('Arcitect Isolate RPC Tests', () {
  //   test('acCreateIsolateInstance creates proxy and supports basic calls', () async {
  //     dynamic appProxy = await acCreateIsolateInstance(App);
  //
  //     // Verify initial property value
  //     expect(await appProxy.title, equals("Original Title"));
  //     expect(await appProxy.port, equals(8080));
  //     expect(await appProxy.running, equals(false));
  //
  //     appProxy.port = 9000;
  //     await Future.delayed(Duration(milliseconds: 100));
  //     expect(await appProxy.port, equals(9000));
  //
  //     // Verify method execution modifying state
  //     await appProxy.start();
  //     expect(await appProxy.running, equals(true));
  //
  //     // Verify method with arguments and return value
  //     final sum = await appProxy.add(15, 25);
  //     expect(sum, equals(40));
  //   });
  //
  //   test('supports returning nested class instances (pass-by-proxy)', () async {
  //     dynamic appProxy = await acCreateIsolateInstance(App);
  //
  //     // Retrieve database proxy
  //     dynamic dbProxy = await appProxy.getDatabase();
  //
  //     // Log a message
  //     await dbProxy.log("Hello Isolate!");
  //
  //     // Verify logs
  //     final logs = await dbProxy.getLogs();
  //     expect(logs, equals(["Hello Isolate!"]));
  //   });
  //
  //   test('supports bidirectional callbacks (main to child and vice-versa)', () async {
  //     dynamic appProxy = await acCreateIsolateInstance(App);
  //     final callback = MainCallback();
  //
  //     // Pass main thread object as a callback to the child isolate
  //     await appProxy.runCallback(callback, "Hello from main!");
  //
  //     // Verify callback was invoked and received the message
  //     expect(callback.receivedMessage, equals("Hello from main!"));
  //   });
  // });
}
