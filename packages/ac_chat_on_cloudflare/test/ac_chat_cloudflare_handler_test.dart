import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:ac_chat_on_cloudflare/ac_chat_on_cloudflare.dart';
import 'package:autocode/autocode.dart';
import 'package:http/http.dart' as http;

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

class MockHttpClient extends http.BaseClient {
  http.StreamedResponse Function(http.BaseRequest request)? handler;
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    if (handler != null) {
      return handler!(request);
    }
    return http.StreamedResponse(
      Stream.value(Uint8List.fromList([1, 2, 3])),
      200,
      contentLength: 3,
    );
  }
}

void main() {
  group('AcChatCloudflareHandler Tests', () {
    late MockAcHttp mockHttp;
    late MockHttpClient mockClient;
    late AcChatCloudflareHandler handler;

    setUp(() {
      mockHttp = MockAcHttp();
      mockClient = MockHttpClient();
      handler = AcChatCloudflareHandler(
        baseUrl: 'https://accountea-worker.softechcompany-com.workers.dev/',
        getJwtToken: () => 'test_jwt_token',
        acHttp: mockHttp,
        client: mockClient,
      );
    });

    test('uploadMedia formats URL correctly and passes headers and raw bytes', () async {
      mockHttp.nextResult = AcHttpResult()
        ..setSuccess()
        ..responseCode = AcEnumHttpResponseCode.created;

      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final url = await handler.uploadMedia(
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
        () => handler.uploadMedia(
          conversationId: 'conv123',
          messageId: 'msg456',
          fileName: 'doc.pdf',
          bytes: Uint8List(10),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('downloadMedia streams response and reports progress', () async {
      final payload = Uint8List.fromList([10, 20, 30, 40]);
      mockClient.handler = (req) {
        return http.StreamedResponse(
          Stream.fromIterable([
            Uint8List.fromList([10, 20]),
            Uint8List.fromList([30, 40]),
          ]),
          200,
          contentLength: 4,
          headers: {'content-type': 'application/octet-stream'},
        );
      };

      final progressList = <double>[];
      final downloaded = await handler.downloadMedia(
        url: 'https://accountea-worker.softechcompany-com.workers.dev/user/chat/conversations/conv123/msg456/test.png',
        onProgress: ({required double progress}) {
          progressList.add(progress);
        },
      );

      expect(downloaded, equals(payload));
      expect(mockClient.lastRequest?.headers['Authorization'], equals('Bearer test_jwt_token'));
      expect(progressList.isNotEmpty, isTrue);
      expect(progressList.last, equals(1.0));
    });

    test('downloadMedia throws exception on non-200 status', () async {
      mockClient.handler = (req) {
        return http.StreamedResponse(
          Stream.value(Uint8List(0)),
          404,
          reasonPhrase: 'Not Found',
        );
      };

      expect(
        () => handler.downloadMedia(
          url: 'https://accountea-worker.softechcompany-com.workers.dev/user/chat/conversations/conv123/msg456/notfound.png',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteMedia sends DELETE request with authorization header', () async {
      mockHttp.nextResult = AcHttpResult()
        ..setSuccess()
        ..responseCode = AcEnumHttpResponseCode.ok;

      await handler.deleteMedia(
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
      final limitedHandler = AcChatCloudflareHandler(
        acHttp: mockHttp,
        api: AcChatApi(
          userId: '',
          maxAttachmentSizeBytes: 100,
        ),
      );

      expect(
        () => limitedHandler.uploadMedia(
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
