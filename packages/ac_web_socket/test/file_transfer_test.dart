import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:ac_web_socket/ac_web_socket.dart';

void main() {
  group('AcWebSocket File Transfer', () {
    test('Should send and receive a file correctly', () async {
      final server = AcWsServer()..port = 0;
      await server.start();
      final port = server.port;

      String? receivedName;
      int? receivedSize;
      List<int> receivedBytes = [];
      final transferCompleter = Completer<void>();

      server.onConnection(handler: ({required socket}) {
        socket.onFile(
          event: 'test_file',
          handler: ({required transferId, required name, required totalSize, required stream, metadata}) async {
            receivedName = name;
            receivedSize = totalSize;
            await for (final chunk in stream) {
              receivedBytes.addAll(chunk);
            }
            transferCompleter.complete();
          },
        );
      });

      final client = AcWsClient(url: 'ws://localhost:$port');
      final s1 = await client.connect();
      expect(s1, isNotNull);

      // Create a dummy file
      final file = File('test_transfer.tmp');
      final content = List.generate(100 * 1024, (i) => i % 256); // 100KB
      await file.writeAsBytes(content);

      try {
        double lastProgress = 0;
        await s1!.sendFile(
          file: file,
          event: 'test_file',
          onProgress: (progress) {
            lastProgress = progress;
            print('Progress: ${(progress * 100).toStringAsFixed(1)}%');
          },
          chunkSize: 16 * 1024, // 16KB chunks
        );

        await transferCompleter.future.timeout(Duration(seconds: 10));

        expect(receivedName, equals('test_transfer.tmp'));
        expect(receivedSize, equals(content.length));
        expect(receivedBytes, equals(content));
        expect(lastProgress, equals(1.0));
      } finally {
        if (await file.exists()) await file.delete();
        await client.disconnect();
        await server.stop();
      }
    });
  });
}
