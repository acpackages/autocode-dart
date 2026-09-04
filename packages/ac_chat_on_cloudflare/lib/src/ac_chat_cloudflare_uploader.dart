import 'dart:typed_data';
import 'package:ac_chat/ac_chat.dart';
import 'package:autocode/autocode.dart';

/// Lightweight Cloudflare Worker R2 media uploader for ac_chat using AcHttp.
class AcChatCloudflareUploader implements AcChatMediaUploader {
  final String baseUrl;
  final String Function()? getJwtToken;
  final AcChatConfig? config;
  final AcHttp _http;

  AcChatCloudflareUploader({
    this.baseUrl = 'https://accountea-worker.softechcompany-com.workers.dev',
    this.getJwtToken,
    this.config,
    AcHttp? http,
  }) : _http = http ?? AcHttp();

  @override
  Future<String> uploadMedia({
    required String conversationId,
    required String messageId,
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
    void Function({required double progress})? onProgress,
  }) async {
    if (config != null && bytes.lengthInBytes > config!.maxAttachmentSizeBytes) {
      throw ArgumentError(
        'Attachment size (${bytes.lengthInBytes} bytes) exceeds configured limit (${config!.maxAttachmentSizeBytes} bytes)',
      );
    }

    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_.\-]'), '_');
    final url = '$cleanBase/user/chat/conversations/$conversationId/$messageId/$safeName';
    final token = getJwtToken?.call() ?? '';

    final headers = <String, String>{
      'Content-Type': mimeType ?? 'application/octet-stream',
      'Content-Length': bytes.lengthInBytes.toString(),
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final result = await _http.put(
      url: url,
      data: bytes,
      headers: headers,
    );

    if (result.isSuccess()) {
      return url;
    } else {
      throw Exception('Upload failed [${result.responseCode.value}]: ${result.message} (${result.data})');
    }
  }

  @override
  Future<void> deleteMedia({
    required String conversationId,
    required String messageId,
    required String fileName,
  }) async {
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_.\-]'), '_');
    final url = '$cleanBase/user/chat/conversations/$conversationId/$messageId/$safeName';
    final token = getJwtToken?.call() ?? '';

    final headers = <String, String>{
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final result = await _http.delete(
      url: url,
      headers: headers,
    );

    if (!result.isSuccess()) {
      throw Exception('Delete failed [${result.responseCode.value}]: ${result.message} (${result.data})');
    }
  }
}
