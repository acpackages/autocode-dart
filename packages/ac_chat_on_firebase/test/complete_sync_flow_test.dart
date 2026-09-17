import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:ac_chat_on_firebase/ac_chat_on_firebase.dart';

void main() {
  group('End-to-End User-Based Chat Sync Flow', () {
    late FakeFirebaseFirestore fakeFirestore;
    final userA = 'alice@example.com';
    final userB = 'bob@example.com';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('Complete flow: Sender AcChatApi -> AcChatFirebase -> User Channel -> Recipient AcChatFirebase -> Callback', () async {
      // 1. Setup Sender (Alice) in Standalone AcChatFirebase mode
      final backendAlice = AcChatFirebase(
        currentUserId: userA,
        firestore: fakeFirestore,
      );
      await backendAlice.initialize();
      final apiAlice = backendAlice.buildApi(theme: const AcChatTheme(isDark: true),userId: '');

      // 2. Setup Recipient (Bob) in Channel Mode (as used by AcChatSqlite)
      final backendBob = AcChatFirebase(
        currentUserId: userB,
        firestore: fakeFirestore,
      );

      final bobReceivedMessages = <AcChatMessage>[];
      final bobConversations = <AcChatConversation>[];

      await backendBob.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) {
          bobReceivedMessages.add(message);
        },
        onConversationChanged: ({required conversation, required users}) {
          bobConversations.add(conversation);
        },
        onUsersLoaded: ({required users}) {},
      );

      // 3. Alice inserts a conversation with Bob via AcChatApi
      final conv = AcChatConversation()
        ..conversationId = 'conv_alice_bob'
        ..type = 'direct'
        ..userIds = [userA, userB]
        ..lastTime = DateTime.now();

      await apiAlice.insertConversation(
        newConversation: conv,
        otherUserId: userB,
      );

      // Allow conversation creation to propagate
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bobConversations.any((c) => c.conversationId == 'conv_alice_bob'), isTrue);

      // 4. Alice sends a message via AcChatApi
      final msg = AcChatMessage()
        ..messageId = 'msg_from_alice_1'
        ..conversationId = 'conv_alice_bob'
        ..senderId = userA
        ..type = 'text'
        ..text = 'Document #1042 has been generated'
        ..time = DateTime.now()
        ..status = 'sending';

      await apiAlice.sendMessage(message: msg);

      // 5. Allow message update via user channel to propagate to Bob
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bobReceivedMessages.length, equals(1));
      expect(bobReceivedMessages.first.messageId, equals('msg_from_alice_1'));
      expect(bobReceivedMessages.first.text, equals('Document #1042 has been generated'));
      expect(bobReceivedMessages.first.senderId, equals(userA));

      // 6. Verify Bob's updates subcollection contains the update notification
      final bobUpdateDocs = await fakeFirestore
          .collection('users')
          .doc(userB)
          .collection('updates')
          .get();

      expect(bobUpdateDocs.docs.length, greaterThanOrEqualTo(1));
      final updateDoc = bobUpdateDocs.docs.firstWhere(
        (d) => d.data()['message_id'] == 'msg_from_alice_1',
      );
      expect(updateDoc.data()['type'], equals(AcChatUpdateType.message));
      expect(updateDoc.data()['conversation_id'], equals('conv_alice_bob'));
      expect(updateDoc.data()['sender_id'], equals(userA));
      expect(updateDoc.data()['text'], equals('Document #1042 has been generated'));

      // 7. Verify that NO conversations collection was ever created or touched in Firestore
      final firestoreConversations =
          await fakeFirestore.collection('conversations').get();
      expect(firestoreConversations.docs, isEmpty);

      await backendBob.stopListening();
      backendAlice.dispose();
    });

    test('notifyConversationRead sends read receipt to Alice when Bob marks as read', () async {
      final backendAlice = AcChatFirebase(
        currentUserId: userA,
        firestore: fakeFirestore,
      );

      final aliceStatusUpdates = <Map<String, String>>[];
      await backendAlice.startListening(
        currentUserId: userA,
        onMessageReceived: ({required message}) {},
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
        onMessageStatusUpdated: ({required messageId, required conversationId, required status}) {
          aliceStatusUpdates.add({
            'messageId': messageId,
            'conversationId': conversationId,
            'status': status,
          });
        },
      );

      final backendBob = AcChatFirebase(
        currentUserId: userB,
        firestore: fakeFirestore,
      );

      final bobReceived = <AcChatMessage>[];
      await backendBob.startListening(
        currentUserId: userB,
        onMessageReceived: ({required message}) {
          bobReceived.add(message);
        },
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      // Create conversation
      final conv = AcChatConversation()
        ..conversationId = 'conv_ab_receipt'
        ..type = 'direct'
        ..userIds = [userA, userB]
        ..lastTime = DateTime.now();

      await backendAlice.createConversation(
        conversation: conv,
        userIds: [userA, userB],
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Alice sends message
      final msg = AcChatMessage()
        ..messageId = 'm_alice_read_test'
        ..conversationId = 'conv_ab_receipt'
        ..senderId = userA
        ..type = 'text'
        ..text = 'Hello Bob'
        ..time = DateTime.now()
        ..status = 'delivered';

      await backendAlice.sendMessage(
        message: msg,
        recipientIds: [userB],
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bobReceived.length, equals(1));

      // Bob marks as read
      await backendBob.notifyConversationRead(
        conversationId: 'conv_ab_receipt',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Alice should receive status update
      expect(aliceStatusUpdates.any((u) => u['messageId'] == 'm_alice_read_test' && u['status'] == 'read'), isTrue);

      await backendAlice.stopListening();
      await backendBob.stopListening();
    });

    test('buildApi forwards typing and group configuration parameters', () {
      final backend = AcChatFirebase(
        currentUserId: userA,
        firestore: fakeFirestore,
      );

      final defaultApi = backend.buildApi(theme: const AcChatTheme(isDark: false),userId: '');
      expect(defaultApi.enableTypingIndicator, isTrue);
      expect(defaultApi.enableTyping, isTrue);
      expect(defaultApi.enableGroups, isTrue);
      expect(defaultApi.maxGroupParticipants, equals(50));

      final customApi = backend.buildApi(
        theme: const AcChatTheme(isDark: false),
        userId: '',
        enableTypingIndicator: false,
        enableTyping: false,
        enableGroups: false,
        maxGroupParticipants: 30,
      );
      expect(customApi.enableTypingIndicator, isFalse);
      expect(customApi.enableTyping, isFalse);
      expect(customApi.enableGroups, isFalse);
      expect(customApi.maxGroupParticipants, equals(30));
    });

    test('messageUpdate parses delivered_time and read_time correctly', () async {
      final backend = AcChatFirebase(
        currentUserId: userA,
        firestore: fakeFirestore,
      );

      AcChatMessage? received;
      await backend.startListening(
        currentUserId: userA,
        onMessageReceived: ({required message}) {
          received = message;
        },
        onConversationChanged: ({required conversation, required users}) {},
        onUsersLoaded: ({required users}) {},
      );

      final now = DateTime.now();
      final nowEpoch = now.millisecondsSinceEpoch;

      // Simulate incoming message to Alice from userB
      await fakeFirestore
          .collection('users')
          .doc(userA)
          .collection('updates')
          .add({
        FirestoreExtensions.fUpdateId: 'u_msg_1',
        FirestoreExtensions.fUpdateType: AcChatUpdateType.message,
        FirestoreExtensions.fConversationId: 'conv_test',
        FirestoreExtensions.fMessageId: 'm_timestamp_test',
        FirestoreExtensions.fSenderId: userB,
        FirestoreExtensions.fText: 'Test message',
        FirestoreExtensions.fTimestamp: Timestamp.fromDate(now),
        FirestoreExtensions.fTime: Timestamp.fromDate(now),
        FirestoreExtensions.fStatus: 'sent',
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.messageId, equals('m_timestamp_test'));

      // Now send update with delivered_time and read_time to Alice's user channel
      await fakeFirestore
          .collection('users')
          .doc(userA)
          .collection('updates')
          .add({
        FirestoreExtensions.fUpdateId: 'u_msg_update_1',
        FirestoreExtensions.fUpdateType: AcChatUpdateType.messageUpdate,
        FirestoreExtensions.fConversationId: 'conv_test',
        FirestoreExtensions.fMessageId: 'm_timestamp_test',
        FirestoreExtensions.fSenderId: userB,
        FirestoreExtensions.fTimestamp: Timestamp.fromDate(now.add(const Duration(seconds: 1))),
        FirestoreExtensions.fData: {
          FirestoreExtensions.fStatus: 'read',
          'delivered_time': nowEpoch - 1000,
          'read_time': nowEpoch,
        },
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received!.status, equals('read'));
      expect(received!.deliveredTime, equals(DateTime.fromMillisecondsSinceEpoch(nowEpoch - 1000, isUtc: true)));
      expect(received!.readTime, equals(DateTime.fromMillisecondsSinceEpoch(nowEpoch, isUtc: true)));

      await backend.stopListening();
    });
  });
}
