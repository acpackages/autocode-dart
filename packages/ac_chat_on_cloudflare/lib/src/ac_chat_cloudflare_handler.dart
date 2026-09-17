import 'dart:typed_data';
import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:autocode/autocode.dart';
import 'package:http/http.dart' as http;

/// Lightweight Cloudflare Worker R2 media handler for ac_chat using AcHttp and http.Client.
class AcChatCloudflareHandler implements AcChatMediaHandler {
  final String baseUrl;
  final String Function()? getJwtToken;
  final AcChatApi? api;
  final AcHttp _http;
  final http.Client _client;

  AcChatCloudflareHandler({
    this.baseUrl = 'https://accountea-worker.softechcompany-com.workers.dev',
    this.getJwtToken,
    this.api,
    AcHttp? acHttp,
    http.Client? client,
  })  : _http = acHttp ?? AcHttp(),
        _client = client ?? http.Client();

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
      onProgress?.call(progress: 1.0);
      return url;
    } else {
      throw Exception('Upload failed [${result.responseCode.value}]: ${result.message} (${result.data})');
    }
  }

  @override
  Future<Uint8List> downloadMedia({
    required String url,
    void Function({required double progress})? onProgress,
  }) async {
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final fullUrl = url.startsWith('http://') || url.startsWith('https://')
        ? url
        : '$cleanBase/${url.replaceFirst(RegExp(r'^/+'), '')}';

    final token = getJwtToken?.call() ?? '';
    print(token);
    final request = http.Request('GET', Uri.parse(fullUrl));
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamedResponse = await _client.send(request);
    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      final totalBytes = streamedResponse.contentLength ?? 0;
      final chunks = <Uint8List>[];
      var receivedBytes = 0;

      await for (final chunk in streamedResponse.stream) {
        final c = chunk is Uint8List ? chunk : Uint8List.fromList(chunk);
        chunks.add(c);
        receivedBytes += c.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(progress: (receivedBytes / totalBytes).clamp(0.0, 1.0));
        }
      }

      final fullBytes = Uint8List(receivedBytes);
      var offset = 0;
      for (final c in chunks) {
        fullBytes.setRange(offset, offset + c.length, c);
        offset += c.length;
      }
      onProgress?.call(progress: 1.0);
      return fullBytes;
    } else {
      throw Exception('Download failed [${streamedResponse.statusCode}]: ${streamedResponse.reasonPhrase}');
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
