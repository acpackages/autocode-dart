import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'ac_web_socket.dart';

extension AcWebSocketFileTransfer on AcWebSocket {
  /// Sends a file in chunks with a progress callback (VM only).
  Future<void> sendFile({
    required File file,
    String event = 'file',
    Map<String, dynamic>? metadata,
    void Function(double progress)? onProgress,
    int chunkSize = 64 * 1024,
  }) async {
    final int totalSize = await file.length();
    final String name = file.path.split(Platform.pathSeparator).last;
    final String transferId = "${DateTime.now().millisecondsSinceEpoch}_$id";

    // 1. Send start
    await emit(event: event, data: {
      'action': 'start',
      'transferId': transferId,
      'name': name,
      'size': totalSize,
      'metadata': metadata,
    });

    // 2. Send chunks
    final RandomAccessFile raf = await file.open(mode: FileMode.read);
    try {
      int sent = 0;
      while (sent < totalSize) {
        final int length = (totalSize - sent) < chunkSize ? (totalSize - sent) : chunkSize;
        final List<int> buffer = await raf.read(length);

        await emit(event: event, data: {
          'action': 'chunk',
          'transferId': transferId,
          'data': base64Encode(buffer),
        });

        sent += length;
        if (onProgress != null) {
          onProgress(sent / totalSize);
        }
      }
    } finally {
      await raf.close();
    }

    // 3. Send end
    await emit(event: event, data: {
      'action': 'end',
      'transferId': transferId,
    });
  }
}
