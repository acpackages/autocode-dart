import 'dart:typed_data';
import 'package:ac_chat/ac_chat.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Concrete implementation of [AcChatMediaUploader] targeting Firebase Storage.
/// Strictly uses named parameters across all methods.
class AcChatFirebaseStorageUploader implements AcChatMediaUploader {
  final FirebaseStorage _storage;
  final String storagePathPrefix;
  final AcChatApi? api;

  AcChatFirebaseStorageUploader({
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
          onProgress(progress: event.bytesTransferred / event.totalBytes);
        }
      });
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
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
