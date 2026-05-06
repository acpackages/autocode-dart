import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:ac_web_socket/ac_web_socket.dart';

void main() async {
  // 1. Setup Server
  final server = AcWsServer()..port = 3002;
  
  server.onConnection(handler: ({required socket}) {
    print('Server: Client connected: ${socket.id}');

    // Handle the live video stream
    socket.onStream(
      event: 'live_video',
      handler: ({required transferId, required stream, metadata}) async {
        print('\nServer: Started receiving live video stream ($transferId)');
        print('Server: Metadata: $metadata');
        
        int totalBytes = 0;
        int frameCount = 0;
        
        await for (final chunk in stream) {
          if (chunk is List<int>) {
            totalBytes += chunk.length;
            frameCount++;
            // In a real app, you would process this frame or broadcast it to other clients
            stdout.write('\rServer: Received frame $frameCount, Total: ${totalBytes} bytes');
          }
        }
        print('\nServer: Stream ended.');
      },
    );
  });

  await server.start();
  print('Server: Started on port 3002');

  // 2. Setup Client
  final client = AcWsClient(url: 'ws://localhost:3002');
  final socket = await client.connect();

  if (socket != null) {
    print('Client: Connected to server');

    // Simulate a live video stream (e.g. from a camera)
    final frameStreamController = StreamController<List<int>>();
    
    print('Client: Starting live video broadcast...');
    socket.emitStream(
      event: 'live_video',
      stream: frameStreamController.stream,
      metadata: {'codec': 'h264', 'fps': 30, 'resolution': '1920x1080'},
      binary: true, // Use high-performance binary events
    );

    // Simulate sending 60 "frames" (approx 2 seconds at 30 FPS)
    for (int i = 0; i < 60; i++) {
      await Future.delayed(Duration(milliseconds: 33)); // ~30 FPS
      // Create a dummy frame (1KB)
      final dummyFrame = Uint8List.fromList(List.generate(1024, (index) => (index + i) % 256));
      frameStreamController.add(dummyFrame);
      stdout.write('\rClient: Sending frame ${i + 1}');
    }

    print('\nClient: Finishing broadcast...');
    await frameStreamController.close();
  }

  await Future.delayed(Duration(seconds: 1));
  await client.disconnect();
  await server.stop();
  print('Example finished.');
}
