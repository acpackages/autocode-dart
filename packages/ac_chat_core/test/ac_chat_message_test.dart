import 'package:test/test.dart';
import 'package:ac_chat_core/ac_chat_core.dart';

void main() {
  group('AcChatMessage tests', () {
    test('fromJson correctly sets isDownloaded and does not corrupt isStarred', () {
      final json = <String, dynamic>{
        'message_id': 'm1',
        'is_downloaded': 1,
        'local_path': '/storage/emulated/0/Download/photo.jpg',
        'is_starred': 0,
      };

      final msg = AcChatMessage.instanceFromJson(jsonData: json);
      expect(msg.isDownloaded, isTrue);
      expect(msg.isStarred, isFalse);
      expect(msg.localPath, equals('/storage/emulated/0/Download/photo.jpg'));
    });

    test('fromJson supports boolean and camelCase isDownloaded and localPath', () {
      final json = <String, dynamic>{
        'message_id': 'm2',
        'isDownloaded': true,
        'localPath': 'C:\\Downloads\\doc.pdf',
        'fileUrl': 'https://storage.example.com/doc.pdf',
      };

      final msg = AcChatMessage.instanceFromJson(jsonData: json);
      expect(msg.isDownloaded, isTrue);
      expect(msg.localPath, equals('C:\\Downloads\\doc.pdf'));
      expect(msg.fileUrl, equals('https://storage.example.com/doc.pdf'));
    });

    test('clone creates an independent copy and does not mutate original', () {
      final msg = AcChatMessage()
        ..messageId = 'm_orig'
        ..localPath = '/path/to/local.jpg'
        ..fileUrl = 'https://storage.example.com/remote.jpg'
        ..isDownloaded = true
        ..status = 'sent';

      final cloned = msg.clone();
      cloned.localPath = null;
      cloned.isDownloaded = false;
      cloned.status = 'sending';

      expect(msg.localPath, equals('/path/to/local.jpg'));
      expect(msg.isDownloaded, isTrue);
      expect(msg.status, equals('sent'));
      expect(msg.fileUrl, equals('https://storage.example.com/remote.jpg'));

      expect(cloned.localPath, isNull);
      expect(cloned.isDownloaded, isFalse);
      expect(cloned.status, equals('sending'));
      expect(cloned.fileUrl, equals('https://storage.example.com/remote.jpg'));
    });
  });

  group('AcChatApi tests', () {
    test('has mediaHandler field and downloadMedia signature', () async {
      final api = AcChatApi(userId: '');
      expect(api.mediaHandler, isNull);

      final msg = AcChatMessage()..messageId = 'm1';
      var progressCalled = false;
      final result = await api.downloadMedia(
        message: msg,
        onProgress: ({required double progress}) {
          progressCalled = true;
        },
      );
      expect(result, equals(''));
    });

    test('reports and clears upload progress correctly with stream', () async {
      final api = AcChatApi(userId: 'u1');
      final events = <({String messageId, double progress})>[];
      final sub = api.onUploadProgress.listen(events.add);

      api.reportUploadProgress(messageId: 'm1', progress: 0.25);
      api.reportUploadProgress(messageId: 'm1', progress: 0.75);
      expect(api.getUploadProgress(messageId: 'm1'), equals(0.75));

      api.clearUploadProgress(messageId: 'm1');
      expect(api.getUploadProgress(messageId: 'm1'), isNull);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events.length, equals(3));
      expect(events[0].progress, equals(0.25));
      expect(events[1].progress, equals(0.75));
      expect(events[2].progress, equals(1.0));

      await sub.cancel();
    });
  });
}
