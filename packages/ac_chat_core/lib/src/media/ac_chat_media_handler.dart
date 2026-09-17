import 'dart:typed_data';

/// Abstract interface for handling chat media upload, download, and management.
///
/// Implementations handle platform-specific storage mechanics (Cloudflare R2,
/// Firebase Storage, S3, etc.) while the core chat engine calls this interface.
abstract class AcChatMediaHandler {
  /// Uploads [bytes] to the backend and returns the public download URL.
  ///
  /// [conversationId] — identifies the conversation this media belongs to.
  /// [messageId]      — the message ID, used to construct a deterministic path.
  /// [fileName]       — original filename (used for Content-Type resolution).
  /// [bytes]          — raw binary content to upload.
  /// [mimeType]       — optional MIME type.
  /// [onProgress]     — optional callback for upload progress (0.0 to 1.0).
  Future<String> uploadMedia({
    required String conversationId,
    required String messageId,
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
    void Function({required double progress})? onProgress,
  });

  /// Downloads media binary content from [url].
  ///
  /// [url]        — remote media URL to download.
  /// [onProgress] — optional callback for download progress (0.0 to 1.0).
  Future<Uint8List> downloadMedia({
    required String url,
    void Function({required double progress})? onProgress,
  });

  /// Deletes media identified by [conversationId], [messageId], and [fileName].
  Future<void> deleteMedia({
    required String conversationId,
    required String messageId,
    required String fileName,
  });
}
