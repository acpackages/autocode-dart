import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:ac_chat_on_firebase/ac_chat_on_firebase.dart';

void main() {
  group('User-Based Firebase Chat Sync Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    final userA = 'userA@example.com';
    final userB = 'userB@example.com';
    final userC = 'userC@example.com';
    final userD = 'userD@example.com';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('New message A -> B: B receives the message via user channel', () async {
      final clientA = AcChatFirebase(
        currentUserId: userA,
        firestore: fakeFirestore,
      );

      final clientB = AcChatFirebase(
        currentUserId: userB,
        firestore: fakeFirestore,
      );

      final receivedMessagesB = <AcChatMessage>[];
      final changedConversationsB = <AcChatConversation>[];

      await clientB.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) {
          receivedMessagesB.add(message);
        },
        onConversationChanged: ({required conversation, required users}) {
          changedConversationsB.add(conversation);
        },
        onUsersLoaded: ({required users}) {},
      );

      // 1. Create conversation between A and B
      final conv = AcChatConversation()
        ..conversationId = 'conv_ab'
        ..type = 'direct'
        ..userIds = [userA, userB]
        ..lastMessage = ''
        ..lastMessageType = 'text'
        ..lastTime = DateTime.now();

      await clientA.createConversation(
        conversation: conv,
        userIds: [userA, userB],
      );

      // 2. Send message from A to B
      final message = AcChatMessage()
        ..messageId = 'msg_1'
        ..conversationId = 'conv_ab'
        ..senderId = userA
        ..type = 'text'
        ..text = 'Hello User B!'
        ..time = DateTime.now()
        ..status = 'sent';

      await clientA.sendMessage(
        message: message,
        recipientIds: [userB],
      );

      // Allow event loop to process stream snapshot
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedMessagesB.length, equals(1));
      expect(receivedMessagesB.first.messageId, equals('msg_1'));
      expect(receivedMessagesB.first.text, equals('Hello User B!'));
      expect(receivedMessagesB.first.senderId, equals(userA));

      // Verify userB updates subcollection received an update document
      final bUpdates = await fakeFirestore
          .collection('users')
          .doc(userB)
          .collection('updates')
          .get();
      expect(bUpdates.docs.isNotEmpty, isTrue);

      await clientB.stopListening();
    });

    test('Multiple messages A -> B (1, 2, 3): B receives all three', () async {
      final clientA = AcChatFirebase(
        currentUserId: userA,
        firestore: fakeFirestore,
      );

      final clientB = AcChatFirebase(
        currentUserId: userB,
        firestore: fakeFirestore,
      );

      final receivedMessagesB = <AcChatMessage>[];

      await clientB.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) => receivedMessagesB.add(message),
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      final conv = AcChatConversation()
        ..conversationId = 'conv_ab_multi'
        ..type = 'direct'
        ..userIds = [userA, userB]
        ..lastTime = DateTime.now();
      await clientA.createConversation(
        conversation: conv,
        userIds: [userA, userB],
      );

      // Send 3 messages rapidly
      for (int i = 1; i <= 3; i++) {
        final msg = AcChatMessage()
          ..messageId = 'msg_multi_$i'
          ..conversationId = 'conv_ab_multi'
          ..senderId = userA
          ..type = 'text'
          ..text = 'Message $i'
          ..time = DateTime.now()
          ..status = 'sent';
        await clientA.sendMessage(
          message: msg,
          recipientIds: [userB],
        );
      }

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedMessagesB.length, equals(3));
      expect(receivedMessagesB.map((m) => m.text).toList(),
          equals(['Message 1', 'Message 2', 'Message 3']));

      await clientB.stopListening();
    });

    test('Multiple senders (A -> B, C -> B, D -> B): B receives all updates', () async {
      final clientA = AcChatFirebase(currentUserId: userA, firestore: fakeFirestore);
      final clientC = AcChatFirebase(currentUserId: userC, firestore: fakeFirestore);
      final clientD = AcChatFirebase(currentUserId: userD, firestore: fakeFirestore);
      final clientB = AcChatFirebase(currentUserId: userB, firestore: fakeFirestore);

      final receivedMessagesB = <AcChatMessage>[];

      await clientB.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) => receivedMessagesB.add(message),
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      // Setup conversations
      await clientA.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_ab'..type = 'direct'..userIds = [userA, userB]..lastTime = DateTime.now(),
        userIds: [userA, userB],
      );
      await clientC.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_cb'..type = 'direct'..userIds = [userC, userB]..lastTime = DateTime.now(),
        userIds: [userC, userB],
      );
      await clientD.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_db'..type = 'direct'..userIds = [userD, userB]..lastTime = DateTime.now(),
        userIds: [userD, userB],
      );

      // Send messages from each sender
      await clientA.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_a'
          ..conversationId = 'conv_ab'
          ..senderId = userA
          ..type = 'text'
          ..text = 'From A'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userB],
      );

      await clientC.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_c'
          ..conversationId = 'conv_cb'
          ..senderId = userC
          ..type = 'text'
          ..text = 'From C'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userB],
      );

      await clientD.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_d'
          ..conversationId = 'conv_db'
          ..senderId = userD
          ..type = 'text'
          ..text = 'From D'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userB],
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedMessagesB.length, equals(3));
      final senderIds = receivedMessagesB.map((m) => m.senderId).toSet();
      expect(senderIds, containsAll([userA, userC, userD]));

      await clientB.stopListening();
    });

    test('Multiple conversations: delivered with correct conversation and message IDs', () async {
      final clientA = AcChatFirebase(currentUserId: userA, firestore: fakeFirestore);
      final clientB = AcChatFirebase(currentUserId: userB, firestore: fakeFirestore);

      final receivedMap = <String, String>{};

      await clientB.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) {
          receivedMap[message.messageId] = message.conversationId;
        },
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      await clientA.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_1'..type = 'direct'..userIds = [userA, userB]..lastTime = DateTime.now(),
        userIds: [userA, userB],
      );
      await clientA.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_2'..type = 'direct'..userIds = [userA, userB]..lastTime = DateTime.now(),
        userIds: [userA, userB],
      );

      await clientA.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_c1'
          ..conversationId = 'conv_1'
          ..senderId = userA
          ..type = 'text'
          ..text = 'Chat 1'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userB],
      );

      await clientA.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_c2'
          ..conversationId = 'conv_2'
          ..senderId = userA
          ..type = 'text'
          ..text = 'Chat 2'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userB],
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedMap['msg_c1'], equals('conv_1'));
      expect(receivedMap['msg_c2'], equals('conv_2'));

      await clientB.stopListening();
    });

    test('Duplicate events: repeated snapshots do not cause duplicate application events', () async {
      final clientA = AcChatFirebase(currentUserId: userA, firestore: fakeFirestore);
      final clientB = AcChatFirebase(currentUserId: userB, firestore: fakeFirestore);

      int receiveCount = 0;

      await clientB.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) {
          receiveCount++;
        },
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      await clientA.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_dedup'..type = 'direct'..userIds = [userA, userB]..lastTime = DateTime.now(),
        userIds: [userA, userB],
      );

      await clientA.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_unique'
          ..conversationId = 'conv_dedup'
          ..senderId = userA
          ..type = 'text'
          ..text = 'Unique message'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userB],
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(receiveCount, equals(1));

      // Re-triggering or querying does not redeliver already processed update
      await fakeFirestore
          .collection('users')
          .doc(userB)
          .collection('updates')
          .get();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(receiveCount, equals(1));

      await clientB.stopListening();
    });

    test('Listener lifecycle: stopListening releases resources and stops updates', () async {
      final clientA = AcChatFirebase(currentUserId: userA, firestore: fakeFirestore);
      final clientB = AcChatFirebase(currentUserId: userB, firestore: fakeFirestore);

      int count = 0;

      await clientB.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) => count++,
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      await clientA.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_lifecycle'..type = 'direct'..userIds = [userA, userB]..lastTime = DateTime.now(),
        userIds: [userA, userB],
      );

      await clientA.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_before_stop'
          ..conversationId = 'conv_lifecycle'
          ..senderId = userA
          ..type = 'text'
          ..text = 'Before stop'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userB],
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(count, equals(1));

      // Stop listening
      await clientB.stopListening();

      // Send another message
      await clientA.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_after_stop'
          ..conversationId = 'conv_lifecycle'
          ..senderId = userA
          ..type = 'text'
          ..text = 'After stop'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userB],
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(count, equals(1));
    });

    test('Authentication / user change: changing user ID properly routes updates', () async {
      final clientA = AcChatFirebase(currentUserId: userA, firestore: fakeFirestore);
      final client = AcChatFirebase(currentUserId: userB, firestore: fakeFirestore);

      final receivedByB = <String>[];
      final receivedByC = <String>[];

      // Initially userB
      await client.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) => receivedByB.add(message.messageId),
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      await clientA.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_ab_auth'..type = 'direct'..userIds = [userA, userB]..lastTime = DateTime.now(),
        userIds: [userA, userB],
      );

      await clientA.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_to_b'
          ..conversationId = 'conv_ab_auth'
          ..senderId = userA
          ..type = 'text'
          ..text = 'For B'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userB],
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(receivedByB, contains('msg_to_b'));

      // Now switch user to userC
      await client.stopListening();

      await client.startListening(
        currentUserId: userC,
        onMessageReceived: ({required message}) => receivedByC.add(message.messageId),
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      await clientA.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_ac_auth'..type = 'direct'..userIds = [userA, userC]..lastTime = DateTime.now(),
        userIds: [userA, userC],
      );

      await clientA.sendMessage(
        message: AcChatMessage()
          ..messageId = 'msg_to_c'
          ..conversationId = 'conv_ac_auth'
          ..senderId = userA
          ..type = 'text'
          ..text = 'For C'
          ..time = DateTime.now()
          ..status = 'sent',
        recipientIds: [userC],
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(receivedByC, contains('msg_to_c'));
      expect(receivedByB.length, equals(1)); // B didn't receive C's message

      await client.stopListening();
    });

    test('Message update: updating a message notifies recipient user channel', () async {
      final clientA = AcChatFirebase(currentUserId: userA, firestore: fakeFirestore);
      final clientB = AcChatFirebase(currentUserId: userB, firestore: fakeFirestore);

      final updatedMessages = <AcChatMessage>[];

      await clientB.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) => updatedMessages.add(message),
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      await clientA.createConversation(
        conversation: AcChatConversation()..conversationId = 'conv_update'..type = 'direct'..userIds = [userA, userB]..lastTime = DateTime.now(),
        userIds: [userA, userB],
      );

      final msg = AcChatMessage()
        ..messageId = 'msg_to_update'
        ..conversationId = 'conv_update'
        ..senderId = userA
        ..type = 'text'
        ..text = 'Original text'
        ..time = DateTime.now()
        ..status = 'sent';

      await clientA.sendMessage(
        message: msg,
        recipientIds: [userB],
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(updatedMessages.length, equals(1));

      // Now update the message
      await clientA.updateMessage(
        messageId: 'msg_to_update',
        conversationId: 'conv_update',
        data: {'text': 'Edited text'},
        recipientIds: [userB],
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(updatedMessages.length, equals(2));
      expect(updatedMessages.last.text, equals('Edited text'));

      await clientB.stopListening();
    });
  });
}
