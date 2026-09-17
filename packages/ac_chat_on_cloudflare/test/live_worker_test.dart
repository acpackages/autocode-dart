import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_chat_on_cloudflare/ac_chat_on_cloudflare.dart';
import 'package:autocode/autocode.dart';

void main() {
  test('Live Cloudflare Worker upload and retrieval verification', () async {
    final testPayload = {
      'userId': 'test_user_verify',
      'conversations': ['test_conv', '*'],
      'roles': ['admin'],
    };

    // Try fallback default secret
    final token = AcEncryption.generateToken(
      data: testPayload,
      secret: 'accountea-default-secret-change-in-prod',
      expiresInSeconds: 3600,
    );

    final handler = AcChatCloudflareHandler(
      baseUrl: 'https://accountea-worker.softechcompany-com.workers.dev',
      getJwtToken: () => token,
    );

    // Valid JPEG header magic bytes (FF D8 FF E0 ...)
    final jpegBytes = Uint8List.fromList([
      0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xff, 0xdb, 0x00, 0x43,
      0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
      0xff, 0xd9, // EOI
    ]);

    print('Uploading test image to Cloudflare Worker...');
    final uploadedUrl = await handler.uploadMedia(
      conversationId: 'test_conv',
      messageId: 'test_msg',
      fileName: 'test.jpg',
      bytes: jpegBytes,
      mimeType: 'image/jpeg',
    );

    print('Upload succeeded! URL: $uploadedUrl');
    expect(
      uploadedUrl,
      equals('https://accountea-worker.softechcompany-com.workers.dev/user/chat/conversations/test_conv/test_msg/test.jpg'),
    );

    print('Downloading uploaded media via handler.downloadMedia...');
    final progressList = <double>[];
    final downloadedBytes = await handler.downloadMedia(
      url: uploadedUrl,
      onProgress: ({required double progress}) {
        progressList.add(progress);
      },
    );

    print('Downloaded bytes: ${downloadedBytes.length}');
    expect(downloadedBytes, equals(jpegBytes));
    expect(progressList.isNotEmpty, isTrue);
  });
}
