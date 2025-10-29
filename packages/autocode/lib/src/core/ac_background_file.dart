import 'dart:async';
import 'dart:io';
import 'dart:isolate';

/* AcDoc({
  "author": "Sanket Patel",
  "summary": "A utility for writing file content in a background isolate.",
  "description": "Provides a non-blocking file writer that offloads I/O operations to a separate isolate, preventing the main thread from becoming blocked by file writes. Content is buffered and sent to the background for processing.",
  "examples": [
    "final logFile = AcBackgroundFile('./logs/app_log.txt');",
    "await logFile.write('Application starting...');",
    "await logFile.write('Processing data...');",
    "// ... later in the app",
    "await logFile.close();"
  ]
}) */
class AcBackgroundFile {
  final String _filePath;
  final List<String> _buffer = [];
  late final SendPort _sendPort;
  Isolate? _isolate;
  bool _spawnInProgress = false;
  bool _isolateReady = false;
  bool _closed = false;

  /* AcDoc({
    "summary": "Initializes the background file writer.",
    "description": "Creates an instance of the writer associated with a specific file path. The background isolate is not spawned until the first write operation.",
    "params": [
      { "name": "filePath", "description": "The path to the file where content will be written." }
    ]
  }) */
  AcBackgroundFile(this._filePath);

  /* AcDoc({
    "summary": "Asynchronously appends content to the file.",
    "description": "Enqueues the given string content to be written to the file in the background. If the background isolate is not yet running, this method will trigger its creation.",
    "params": [
      { "name": "content", "description": "The text content to append to the file." }
    ],
    "returns": "A future that completes when the content is successfully enqueued for writing.",
    "returns_type": "Future<void>"
  }) */
  Future<void> write(String content) async {
    if (_closed) {
      throw StateError('Cannot write to closed AcBackgroundFile');
    }

    _buffer.add(content);
    if (!_isolateReady) {
      await _ensureIsolate();
    } else {
      _sendPort.send([_filePath, content, false]);
    }
  }

  /* AcDoc({
    "summary": "Closes the file writer and terminates the background isolate.",
    "description": "Signals the background isolate to process any remaining buffered content and then terminate gracefully. No further writes are permitted after calling this method.",
    "returns": "A future that completes once the close signal has been sent to the isolate.",
    "returns_type": "Future<void>"
  }) */
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    if (_isolateReady) {
      _sendPort.send([_filePath, '', true]);
    }
  }

  Future<void> _ensureIsolate() async {
    if (_spawnInProgress) return;
    _spawnInProgress = true;

    final receivePort = ReceivePort();
    try {
      _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
      _sendPort = await receivePort.first as SendPort;

      for (var content in _buffer) {
        _sendPort.send([_filePath, content, false]);
      }
      _buffer.clear();

      _isolateReady = true;
    } catch (e, st) {
      stderr.writeln('AcBackgroundFile spawn failed: $e\n$st');
      rethrow;
    } finally {
      receivePort.close();
      _spawnInProgress = false;
    }
  }

  /* AcDoc({
    "summary": "The entry point for the background isolate.",
    "description": "This static method runs on the background isolate. It sets up a port to listen for messages from the main thread and handles file writing operations accordingly.",
    "params": [
      { "name": "controlPort", "description": "The SendPort used to establish a two-way communication channel with the main isolate." }
    ]
  }) */
  static Future<void> _isolateEntry(SendPort controlPort) async {
    final port = ReceivePort();
    controlPort.send(port.sendPort);

    await for (final msg in port) {
      final parts = msg as List<dynamic>;
      final path = parts[0] as String;
      final content = parts[1] as String;
      final closeFlag = parts[2] as bool;

      final file = File(path);
      if (!file.existsSync()) {
        file.parent.createSync(recursive: true);
        file.createSync(recursive: true);
      }

      if (content.isNotEmpty) {
        try {
          await file.writeAsString(content, mode: FileMode.append);
        } catch (e) {
          stderr.writeln('Write failed: $e');
        }
      }

      if (closeFlag) {
        port.close();
        Isolate.exit();
      }
    }
  }
}