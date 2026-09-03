import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ac_chat/ac_chat.dart';
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
      final apiAlice = backendAlice.buildApi(theme: const AcChatTheme(isDark: true));

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
        onConversationChanged: ({required conversation, required members}) {
          bobConversations.add(conversation);
        },
        onUsersLoaded: ({required users}) {},
      );

      // 3. Alice inserts a conversation with Bob via AcChatApi
      final conv = AcChatConversation()
        ..conversationId = 'conv_alice_bob'
        ..type = 'direct'
        ..memberIds = [userA, userB]
        ..lastTime = DateTime.now();

      apiAlice.insertConversation(
        newConv: conv,
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

      apiAlice.sendMessage(message: msg);

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
  });
}
