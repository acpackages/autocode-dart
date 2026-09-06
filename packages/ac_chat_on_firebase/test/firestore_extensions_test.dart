import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat_on_firebase/src/firestore_extensions.dart';

void main() {
  group('FirestoreExtensions Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('AcChatUser serialization and deserialization', () async {
      final user = AcChatUser()
        ..userId = 'user1@example.com'
        ..name = 'Alice'
        ..username = 'alice'
        ..email = 'alice@example.com'
        ..phone = '1234567890'
        ..avatar = 'https://example.com/avatar.png';

      final map = FirestoreExtensions.userToFirestore(user);
      expect(map[FirestoreExtensions.fUserId], equals('user1@example.com'));
      expect(map[FirestoreExtensions.fName], equals('Alice'));
      expect(map[FirestoreExtensions.fUsername], equals('alice'));
      expect(map[FirestoreExtensions.fPhone], equals('1234567890'));

      await fakeFirestore.collection('users').doc(user.userId).set(map);
      final doc = await fakeFirestore.collection('users').doc(user.userId).get();

      final fromDoc = FirestoreExtensions.userFromDoc(doc);
      expect(fromDoc.userId, equals(user.userId));
      expect(fromDoc.name, equals('Alice'));
      expect(fromDoc.phone, equals('1234567890'));
      expect(fromDoc.avatar, equals('https://example.com/avatar.png'));
    });

    test('AcChatConversation serialization and deserialization', () async {
      final conv = AcChatConversation()
        ..conversationId = 'conv_123'
        ..type = 'direct'
        ..memberIds = ['alice@example.com', 'bob@example.com']
        ..lastMessage = 'Hello Bob'
        ..lastMessageType = 'text'
        ..lastTime = DateTime(2026, 9, 3, 10, 0)
        ..isPinned = true
        ..isMuted = false
        ..unread = 2;

      final map = FirestoreExtensions.conversationToFirestore(conv);
      expect(map[FirestoreExtensions.fMemberIds], contains('alice@example.com'));
      expect(map[FirestoreExtensions.fMemberIds], contains('bob@example.com'));
      expect(map[FirestoreExtensions.fIsGroup], isFalse);
      expect(map[FirestoreExtensions.fLastMessage], equals('Hello Bob'));

      await fakeFirestore.collection('conversations').doc(conv.conversationId).set(map);
      final doc = await fakeFirestore.collection('conversations').doc(conv.conversationId).get();

      final fromDoc = FirestoreExtensions.conversationFromDoc(doc, unread: 2);
      expect(fromDoc.conversationId, equals('conv_123'));
      expect(fromDoc.type, equals('direct'));
      expect(fromDoc.memberIds.length, equals(2));
      expect(fromDoc.lastMessage, equals('Hello Bob'));
      expect(fromDoc.isPinned, isTrue);
      expect(fromDoc.unread, equals(2));
    });

    test('AcChatMessage serialization and deserialization', () async {
      final msg = AcChatMessage()
        ..messageId = 'msg_001'
        ..conversationId = 'conv_123'
        ..senderId = 'alice@example.com'
        ..type = 'text'
        ..text = 'Important update'
        ..time = DateTime(2026, 9, 3, 10, 15)
        ..status = 'sent';

      final map = FirestoreExtensions.messageToFirestore(msg);
      expect(map[FirestoreExtensions.fMessageId], equals('msg_001'));
      expect(map[FirestoreExtensions.fConversationId], equals('conv_123'));
      expect(map[FirestoreExtensions.fSenderId], equals('alice@example.com'));
      expect(map[FirestoreExtensions.fText], equals('Important update'));

      await fakeFirestore
          .collection('conversations')
          .doc('conv_123')
          .collection('messages')
          .doc(msg.messageId)
          .set(map);

      final doc = await fakeFirestore
          .collection('conversations')
          .doc('conv_123')
          .collection('messages')
          .doc(msg.messageId)
          .get();

      final fromDoc = FirestoreExtensions.messageFromDoc(doc);
      expect(fromDoc.messageId, equals('msg_001'));
      expect(fromDoc.conversationId, equals('conv_123'));
      expect(fromDoc.senderId, equals('alice@example.com'));
      expect(fromDoc.text, equals('Important update'));
      expect(fromDoc.status, equals('sent'));
    });

    test('AcChatUpdateType constants check', () {
      expect(AcChatUpdateType.message, equals('message'));
      expect(AcChatUpdateType.conversation, equals('conversation'));
      expect(AcChatUpdateType.messageUpdate, equals('message_update'));
      expect(AcChatUpdateType.read, equals('read'));
    });

    test('messageToUpdatePayload and messageFromUpdateData roundtrip', () {
      final msg = AcChatMessage()
        ..messageId = 'msg_up_1'
        ..conversationId = 'conv_direct_1'
        ..senderId = 'alice@example.com'
        ..type = 'text'
        ..text = 'Direct update payload'
        ..time = DateTime(2026, 9, 3, 10, 30)
        ..status = 'sent'
        ..amount = 450.0;

      final payload = FirestoreExtensions.messageToUpdatePayload(
        msg,
        memberIds: ['alice@example.com', 'bob@example.com'],
        groupName: null,
        isGroup: false,
      );

      expect(payload[FirestoreExtensions.fUpdateId], equals('msg_up_1'));
      expect(payload[FirestoreExtensions.fUpdateType], equals(AcChatUpdateType.message));
      expect(payload[FirestoreExtensions.fMessageType], equals('text'));
      expect(payload[FirestoreExtensions.fText], equals('Direct update payload'));
      expect(payload[FirestoreExtensions.fAmount], equals(450.0));
      expect(payload[FirestoreExtensions.fMemberIds], contains('bob@example.com'));

      final restoredMsg = FirestoreExtensions.messageFromUpdateData(payload);
      expect(restoredMsg.messageId, equals('msg_up_1'));
      expect(restoredMsg.conversationId, equals('conv_direct_1'));
      expect(restoredMsg.senderId, equals('alice@example.com'));
      expect(restoredMsg.type, equals('text'));
      expect(restoredMsg.text, equals('Direct update payload'));
      expect(restoredMsg.amount, equals(450.0));

      final restoredConv = FirestoreExtensions.conversationFromUpdateData(payload);
      expect(restoredConv.conversationId, equals('conv_direct_1'));
      expect(restoredConv.type, equals('direct'));
      expect(restoredConv.memberIds.length, equals(2));
      expect(restoredConv.lastMessage, equals('Direct update payload'));
      expect(restoredConv.lastMessageType, equals('text'));
    });

    test('filePath and fileUrl serialization and deserialization in message', () {
      final msg = AcChatMessage()
        ..messageId = 'msg_media_1'
        ..conversationId = 'conv_media'
        ..senderId = 'alice@example.com'
        ..type = 'image'
        ..text = 'Beautiful sunset'
        ..filePath = '/local/path/to/image.png'
        ..fileUrl = 'https://r2.cloudflare.com/image.png';

      final firestoreMap = FirestoreExtensions.messageToFirestore(msg);
      expect(firestoreMap[FirestoreExtensions.fFilePath], equals('/local/path/to/image.png'));
      expect(firestoreMap[FirestoreExtensions.fFileUrl], equals('https://r2.cloudflare.com/image.png'));
      expect(firestoreMap[FirestoreExtensions.fText], equals('Beautiful sunset'));

      final updatePayload = FirestoreExtensions.messageToUpdatePayload(msg);
      expect(updatePayload[FirestoreExtensions.fFilePath], equals('/local/path/to/image.png'));
      expect(updatePayload[FirestoreExtensions.fFileUrl], equals('https://r2.cloudflare.com/image.png'));

      final fromUpdate = FirestoreExtensions.messageFromUpdateData(updatePayload);
      expect(fromUpdate.filePath, equals('/local/path/to/image.png'));
      expect(fromUpdate.fileUrl, equals('https://r2.cloudflare.com/image.png'));
      expect(fromUpdate.text, equals('Beautiful sunset'));
    });

    test('disappearingDurationSeconds serialization and deserialization in conversation', () {
      final conv = AcChatConversation()
        ..conversationId = 'conv_disappear'
        ..type = 'direct'
        ..disappearingDurationSeconds = 86400;

      final map = FirestoreExtensions.conversationToFirestore(conv);
      expect(map[FirestoreExtensions.fDisappearingDurationSeconds], equals(86400));

      final updateData = {
        FirestoreExtensions.fConversationId: 'conv_disappear',
        FirestoreExtensions.fDisappearingDurationSeconds: 86400,
      };
      final fromUpdate = FirestoreExtensions.conversationFromUpdateData(updateData);
      expect(fromUpdate.disappearingDurationSeconds, equals(86400));
    });
  });
}
