import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat_on_cloudflare/ac_chat_on_cloudflare.dart';
import 'package:autocode/autocode.dart';

class MockAcHttp extends AcHttp {
  String? lastUrl;
  AcEnumHttpMethod? lastMethod;
  dynamic lastData;
  Map<String, String>? lastHeaders;
  AcHttpResult nextResult = AcHttpResult();

  @override
  Future<AcHttpResult> request({
    required String url,
    AcEnumHttpMethod method = AcEnumHttpMethod.get,
    Map<String, dynamic>? queryParams,
    dynamic data,
    Map<String, String>? headers,
  }) async {
    lastUrl = url;
    lastMethod = method;
    lastData = data;
    lastHeaders = headers;
    return nextResult;
  }
}

void main() {
  group('AcChatCloudflareUploader Tests', () {
    late MockAcHttp mockHttp;
    late AcChatCloudflareUploader uploader;

    setUp(() {
      mockHttp = MockAcHttp();
      uploader = AcChatCloudflareUploader(
        baseUrl: 'https://accountea-worker.softechcompany-com.workers.dev/',
        getJwtToken: () => 'test_jwt_token',
        http: mockHttp,
      );
    });

    test('uploadMedia formats URL correctly and passes headers and raw bytes', () async {
      mockHttp.nextResult = AcHttpResult()
        ..setSuccess()
        ..responseCode = AcEnumHttpResponseCode.created;

      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final url = await uploader.uploadMedia(
        conversationId: 'conv123',
        messageId: 'msg456',
        fileName: 'my image #1.png',
        bytes: testBytes,
        mimeType: 'image/png',
      );

      expect(
        url,
        equals('https://accountea-worker.softechcompany-com.workers.dev/user/chat/conversations/conv123/msg456/my_image__1.png'),
      );
      expect(mockHttp.lastMethod, equals(AcEnumHttpMethod.put));
      expect(mockHttp.lastData, equals(testBytes));
      expect(mockHttp.lastHeaders?['Content-Type'], equals('image/png'));
      expect(mockHttp.lastHeaders?['Content-Length'], equals('5'));
      expect(mockHttp.lastHeaders?['Authorization'], equals('Bearer test_jwt_token'));
    });

    test('uploadMedia throws exception when request fails', () async {
      mockHttp.nextResult = AcHttpResult()
        ..setFailure(message: 'Forbidden')
        ..responseCode = AcEnumHttpResponseCode.forbidden;

      expect(
        () => uploader.uploadMedia(
          conversationId: 'conv123',
          messageId: 'msg456',
          fileName: 'doc.pdf',
          bytes: Uint8List(10),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteMedia sends DELETE request with authorization header', () async {
      mockHttp.nextResult = AcHttpResult()
        ..setSuccess()
        ..responseCode = AcEnumHttpResponseCode.ok;

      await uploader.deleteMedia(
        conversationId: 'conv123',
        messageId: 'msg456',
        fileName: 'test.png',
      );

      expect(mockHttp.lastMethod, equals(AcEnumHttpMethod.delete));
      expect(
        mockHttp.lastUrl,
        equals('https://accountea-worker.softechcompany-com.workers.dev/user/chat/conversations/conv123/msg456/test.png'),
      );
      expect(mockHttp.lastHeaders?['Authorization'], equals('Bearer test_jwt_token'));
    });

    test('uploadMedia rejects attachments exceeding maxAttachmentSizeBytes', () async {
      final limitedUploader = AcChatCloudflareUploader(
        http: mockHttp,
        api: AcChatApi(
          maxAttachmentSizeBytes: 100,
        ),
      );

      expect(
        () => limitedUploader.uploadMedia(
          conversationId: 'conv123',
          messageId: 'msg456',
          fileName: 'oversized.dat',
          bytes: Uint8List(101),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
