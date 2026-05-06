import 'dart:async';
import 'dart:io';
import 'package:ac_web_socket/ac_web_socket.dart';

void main() async {
  // 1. Setup Server
  final server = AcWsServer()..port = 3001;
  
  server.onConnection(handler: ({required socket}) {
    print('Server: Client connected: ${socket.id}');

    // Listen for files on the 'upload' event
    socket.onFile(
      event: 'upload',
      handler: ({required transferId, required name, required totalSize, required stream, metadata}) async {
        print('\nServer: Receiving file "$name" ($totalSize bytes)...');
        print('Server: Metadata: $metadata');
        
        final outputFile = File('received_$name');
        final sink = outputFile.openWrite();
        
        int received = 0;
        await for (final chunk in stream) {
          sink.add(chunk);
          received += chunk.length;
          // Server-side logging if needed
        }
        
        await sink.close();
        print('Server: File "$name" saved successfully to ${outputFile.path}');
        
        // Notify the client that processing is done
        socket.emit(event: 'upload_complete', data: {'name': name, 'status': 'success'});
      },
    );
  });

  await server.start();
  print('Server: Started on port 3001');

  // 2. Setup Client
  final client = AcWsClient(url: 'ws://localhost:3001');
  final socket = await client.connect();

  if (socket != null) {
    print('Client: Connected to server');

    // Create a dummy file to transfer (approx 500KB)
    final testFile = File('test_upload.txt');
    await testFile.writeAsString('This is a test file transfer using ac_web_socket with progress callback.\n' * 5000);
    print('Client: Created test file "${testFile.path}" (${await testFile.length()} bytes)');

    final completer = Completer<void>();

    // Listen for completion notification from server
    socket.on(event: 'upload_complete', handler: ({data, callback}) {
      print('\nClient: Server confirmed: ${data['name']} status is ${data['status']}');
      completer.complete();
    });

    // Start file transfer with progress callback
    print('Client: Starting file transfer...');
    await socket.sendFile(
      file: testFile,
      event: 'upload',
      metadata: {'type': 'test_data', 'author': 'ac_web_socket_example'},
      onProgress: (progress) {
        // Output progress as a bar or percentage
        final percent = (progress * 100).toStringAsFixed(1);
        stdout.write('\rClient: Upload progress: $percent%');
      },
      chunkSize: 16 * 1024, // 16KB chunks
    );
    print('\nClient: File sent, waiting for server confirmation...');

    // Wait for the server to acknowledge completion
    await completer.future.timeout(Duration(seconds: 10), onTimeout: () {
      print('Client: Timeout waiting for server confirmation.');
    });
    
    // Cleanup
    if (await testFile.exists()) await testFile.delete();
    print('Client: Cleaned up local test file.');
    
    // Check if received file exists and cleanup
    final receivedFile = File('received_test_upload.txt');
    if (await receivedFile.exists()) {
      print('Client: Verifying received file exists... Yes.');
      await receivedFile.delete();
      print('Client: Cleaned up server-received file.');
    }
  }

  await Future.delayed(Duration(seconds: 1));
  await client.disconnect();
  await server.stop();
  print('\nExample finished.');
}
