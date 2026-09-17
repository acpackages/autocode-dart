import 'dart:io' as io;
import 'dart:typed_data';
import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Concrete implementation of [AcChatMediaHandler] targeting Firebase Storage.
/// Strictly uses named parameters across all methods.
class AcChatFirebaseStorageHandler implements AcChatMediaHandler {
  final FirebaseStorage _storage;
  final String storagePathPrefix;
  final AcChatApi? api;

  AcChatFirebaseStorageHandler({
    FirebaseStorage? storage,
    this.storagePathPrefix = 'chat_media',
    this.api,
  }) : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadMedia({
    required String conversationId,
    required String messageId,
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
    void Function({required double progress})? onProgress,
  }) async {
    if (api != null && bytes.lengthInBytes > api!.maxAttachmentSizeBytes) {
      throw ArgumentError(
        'Attachment size (${bytes.lengthInBytes} bytes) exceeds configured limit (${api!.maxAttachmentSizeBytes} bytes)',
      );
    }

    final cleanPrefix = storagePathPrefix.isEmpty ? '' : '$storagePathPrefix/';
    final path = '$cleanPrefix$conversationId/$messageId/$fileName';
    final ref = _storage.ref().child(path);

    final metadata = mimeType != null ? SettableMetadata(contentType: mimeType) : null;
    final uploadTask = ref.putData(bytes, metadata);
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        if (event.totalBytes > 0) {
          onProgress(progress: (event.bytesTransferred / event.totalBytes).clamp(0.0, 1.0));
        }
      });
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    onProgress?.call(progress: 1.0);
    return downloadUrl;
  }

  @override
  Future<Uint8List> downloadMedia({
    required String url,
    void Function({required double progress})? onProgress,
  }) async {
    if (url.startsWith('gs://')) {
      try {
        final ref = _storage.refFromURL(url);
        final bytes = await ref.getData();
        if (bytes != null) {
          onProgress?.call(progress: 1.0);
          return bytes;
        }
      } catch (_) {}
    }

    if (!kIsWeb) {
      final request = await io.HttpClient().getUrl(Uri.parse(url));
      final token = api?.getAuthToken?.call();
      if (token != null && token.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $token');
      }

      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final contentLength = response.contentLength;
        final chunks = <Uint8List>[];
        var received = 0;

        await for (final chunk in response) {
          final c = chunk is Uint8List ? chunk : Uint8List.fromList(chunk);
          chunks.add(c);
          received += c.length;
          if (contentLength > 0 && onProgress != null) {
            onProgress(progress: (received / contentLength).clamp(0.0, 1.0));
          }
        }

        final fullBytes = Uint8List(received);
        var offset = 0;
        for (final c in chunks) {
          fullBytes.setRange(offset, offset + c.length, c);
          offset += c.length;
        }
        onProgress?.call(progress: 1.0);
        return fullBytes;
      } else {
        throw Exception('Download failed [${response.statusCode}]');
      }
    } else {
      throw UnsupportedError('downloadMedia on web is not supported via dart:io');
    }
  }

  @override
  Future<void> deleteMedia({
    required String conversationId,
    required String messageId,
    required String fileName,
  }) async {
    final cleanPrefix = storagePathPrefix.isEmpty ? '' : '$storagePathPrefix/';
    final path = '$cleanPrefix$conversationId/$messageId/$fileName';
    final ref = _storage.ref().child(path);
    await ref.delete();
  }
}
