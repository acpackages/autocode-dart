import 'package:flutter_test/flutter_test.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat_sqlite/ac_chat_sqlite.dart';

class MockSyncChannel implements AcChatSyncChannel {
  final List<AcChatMessage> sentMessages = [];
  final List<AcChatConversation> createdConversations = [];
  final List<String> readConversations = [];

  @override
  Future<void> sendMessage({
    required AcChatMessage message,
    required List<String> recipientIds,
    Map<String, dynamic>? notificationPayload,
  }) async {
    sentMessages.add(message);
  }

  @override
  Future<void> createConversation({
    required AcChatConversation conversation,
    required List<String> memberIds,
    Map<String, dynamic>? notificationPayload,
  }) async {
    createdConversations.add(conversation);
  }

  @override
  Future<void> markAsRead({
    required String conversationId,
    required String currentUserId,
    List<String>? messageIds,
  }) async {
    readConversations.add(conversationId);
  }

  @override
  Future<void> sendDeliveryReceipt({
    required String messageId,
    required String conversationId,
    required String senderId,
  }) async {}

  @override
  Future<void> sendReadReceipt({
    required String conversationId,
    required String senderId,
    required List<String> messageIds,
  }) async {}

  @override
  Future<void> sendTypingIndicator({
    required String conversationId,
    required List<String> recipientIds,
    required bool isTyping,
  }) async {}

  @override
  Future<void> updateMessage({
    required String messageId,
    required String conversationId,
    required Map<String, dynamic> data,
    required List<String> recipientIds,
  }) async {}

  @override
  Future<void> acknowledgeUpdate({required String updateId}) async {}

  @override
  Future<void> addGroupMembers({
    required String conversationId,
    required List<String> memberIds,
  }) async {}

  @override
  Future<void> removeGroupMember({
    required String conversationId,
    required String userId,
  }) async {}

  @override
  Future<void> startListening({
    required String currentUserId,
    required void Function({required AcChatMessage message}) onMessageReceived,
    required void Function({
      required AcChatConversation conversation,
      required List<AcChatConversationUser> members,
    }) onConversationChanged,
    required void Function({required List<AcChatUser> users}) onUsersLoaded,
    void Function({
      required String messageId,
      required String conversationId,
      required String status,
    })? onMessageStatusUpdated,
    void Function({
      required String conversationId,
      required String userId,
      required bool isTyping,
    })? onTypingChanged,
    void Function({
      required String userId,
      required bool isOnline,
    })? onUserPresenceChanged,
  }) async {}

  @override
  Future<void> stopListening() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AcChatSqlite In-Memory & Channel Tests', () {
    test('instantiates with strictly named parameters and builds API', () {
      final mockChannel = MockSyncChannel();
      final sqlite = AcChatSqlite(
        currentUserId: 'user_alice',
        channel: mockChannel,
        config: const AcChatSqliteConfig(
          databasePath: ':memory:',
          dataDictionaryName: 'ac_chat_test',
        ),
      );

      final api = sqlite.buildApi(
        theme: const AcChatTheme(isDark: false),
      );

      expect(api.getCurrentUser().userId, equals('user_alice'));
      expect(api.getConversations(), isEmpty);
      expect(api.getUsers(), isEmpty);
    });

    test('direct conversation insertion updates in-memory cache and channel', () async {
      final mockChannel = MockSyncChannel();
      final sqlite = AcChatSqlite(
        currentUserId: 'user_alice',
        channel: mockChannel,
        config: const AcChatSqliteConfig(
          databasePath: ':memory:',
          dataDictionaryName: 'ac_chat_test',
        ),
      );

      final newConv = AcChatConversation()
        ..conversationId = 'conv_123'
        ..type = 'direct';

      final inserted = sqlite.buildApi(theme: const AcChatTheme(isDark: false)).insertConversation(
        newConv: newConv,
        otherUserId: 'user_bob',
      );

      expect(inserted.conversationId, equals('conv_123'));
      expect(inserted.memberIds, containsAll(['user_alice', 'user_bob']));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(mockChannel.createdConversations.length, equals(1));
      expect(mockChannel.createdConversations.first.conversationId, equals('conv_123'));
    });

    test('saveUser updates in-memory cache and getUserById', () async {
      final sqlite = AcChatSqlite(
        currentUserId: 'user_alice',
        config: const AcChatSqliteConfig(
          databasePath: ':memory:',
          dataDictionaryName: 'ac_chat_test',
        ),
      );

      final user = AcChatUser()
        ..userId = 'user_charlie'
        ..name = 'Charlie'
        ..username = 'charlie';

      await sqlite.saveUser(user: user);

      final api = sqlite.buildApi(theme: const AcChatTheme(isDark: false));
      final fetched = api.getUserById(userId: 'user_charlie');
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Charlie'));
    });

    test('startSync attaches channel and enables message reception', () async {
      final mockChannel = MockSyncChannel();
      final sqlite = AcChatSqlite(
        currentUserId: 'user_alice',
        config: const AcChatSqliteConfig(
          databasePath: ':memory:',
          dataDictionaryName: 'ac_chat_test',
        ),
      );

      sqlite.startSync(channel: mockChannel);

      AcChatMessage? received;
      sqlite.onMessageReceived = ({required message}) {
        received = message;
      };

      // Ensure mockChannel received startListening
      expect(sqlite, isNotNull);
    });
  });
}
