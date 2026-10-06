import 'dart:io';
import 'package:ac_patches_server/ac_patches_server.dart';

void main(List<String> args) async {
  final portStr = Platform.environment['PORT'] ?? '8080';
  final port = int.tryParse(portStr) ?? 8080;
  final dbPath = Platform.environment['DB_PATH'] ?? 'ac_patches.db';
  final storagePath = Platform.environment['STORAGE_PATH'] ?? 'storage';

  final app = AcPatchesServerApp(
    port: port,
    dbPath: dbPath,
    storageDir: Directory(storagePath),
  );

  stdout.writeln('Initializing ac_patches server...');
  await app.initialize();
  stdout.writeln('Starting ac_patches server on port $port...');
  await app.start();
  stdout.writeln('ac_patches server running at http://localhost:$port');

  ProcessSignal.sigint.watch().listen((_) async {
    stdout.writeln('Stopping server...');
    await app.stop();
    exit(0);
  });
}
