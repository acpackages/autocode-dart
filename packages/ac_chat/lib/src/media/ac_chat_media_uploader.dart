import 'dart:typed_data';

/// Abstract interface for uploading media attachments to cloud/server storage
/// with strictly named parameters.
abstract class AcChatMediaUploader {
  Future<String> uploadMedia({
    required String conversationId,
    required String messageId,
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
    void Function({required double progress})? onProgress,
  });

  Future<void> deleteMedia({
    required String conversationId,
    required String messageId,
    required String fileName,
  });
}
