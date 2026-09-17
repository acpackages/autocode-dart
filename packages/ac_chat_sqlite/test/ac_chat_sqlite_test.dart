import 'package:test/test.dart';
import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:ac_chat_sqlite/ac_chat_sqlite.dart';

void main() {
  group('AcChatSqlite Direct DB Operations (cacheRows = false)', () {
    late AcChatSqlite chat;

    setUp(() async {
      chat = AcChatSqlite(
        cacheRows: false,
        databasePath: ':memory:',
      );
      await chat.initialize();
    });

    tearDown(() async {
      await chat.dispose();
    });

    test('User CRUD and blocking', () async {
      final user = AcChatUser()
        ..userId = 'bob'
        ..name = 'Bob Smith';
      await chat.saveUser(user: user);

      final retrieved = await chat.getUserById(userId: 'bob');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Bob Smith'));

      final allUsers = await chat.getUsers();
      expect(allUsers.any((u) => u.userId == 'bob'), isTrue);

      // Block user
      expect(await chat.isUserBlocked(userId: 'bob'), isFalse);
      await chat.blockUser(userId: 'bob');
      expect(await chat.isUserBlocked(userId: 'bob'), isTrue);
      expect(await chat.getBlockedUserIds(), contains('bob'));

      // Unblock user
      await chat.unblockUser(userId: 'bob');
      expect(await chat.isUserBlocked(userId: 'bob'), isFalse);
    });

    test('insertConversation with multiple userIds', () async {
      final conv = AcChatConversation()
        ..type = 'group'
        ..conversationName = 'Project Team';

      final created = await chat.insertConversation(
        conversation: conv,
        userIds: ['alice', 'bob', 'charlie'],
      );

      expect(created.conversationId, isNotEmpty);
      expect(created.userIds, containsAll(['alice', 'bob', 'charlie']));

      // Verify getConversations
      final convs = await chat.getConversations();
      expect(convs.length, equals(1));
      expect(convs.first.conversationName, equals('Project Team'));

      final byId = await chat.getConversationById(conversationId: created.conversationId);
      expect(byId, isNotNull);
      expect(byId!.conversationId, equals(created.conversationId));

      // Verify getConversationUsers
      final users = await chat.getConversationUsers(conversationId: created.conversationId);
      expect(users.map((u) => u.userId), containsAll(['alice', 'bob', 'charlie']));

      // Add user
      await chat.addConversationUsers(
        conversationId: created.conversationId,
        userIds: ['david'],
      );
      final updatedUsers = await chat.getConversationUsers(conversationId: created.conversationId);
      expect(updatedUsers.map((u) => u.userId), contains('david'));

      // Remove user
      await chat.removeConversationUsers(
        conversationId: created.conversationId,
        userId: 'david',
      );
      final remainingUsers = await chat.getConversationUsers(conversationId: created.conversationId);
      expect(remainingUsers.map((u) => u.userId), isNot(contains('david')));
    });

    test('Conversation preferences', () async {
      final conv = AcChatConversation()
        ..type = 'direct';
      final created = await chat.insertConversation(
        conversation: conv,
        userIds: ['alice', 'bob'],
      );

      await chat.pinConversation(conversationId: created.conversationId, isPinned: true);
      var pref = await chat.getConversationPref(conversationId: created.conversationId);
      expect(pref, isNotNull);
      expect(pref!.isPinned, isTrue);

      await chat.archiveConversation(conversationId: created.conversationId, isArchived: true);
      pref = await chat.getConversationPref(conversationId: created.conversationId);
      expect(pref!.isArchived, isTrue);
    });

    test('Message operations and search', () async {
      final conv = AcChatConversation()..type = 'direct';
      final created = await chat.insertConversation(
        conversation: conv,
        userIds: ['alice', 'bob'],
      );

      final msg1 = AcChatMessage()
        ..conversationId = created.conversationId
        ..senderId = 'alice'
        ..text = 'Hello Bob!'
        ..time = DateTime.now().toUtc();
      await chat.sendMessage(message: msg1);

      final msg2 = AcChatMessage()
        ..conversationId = created.conversationId
        ..senderId = 'bob'
        ..text = 'Hi Alice, how are you?'
        ..time = DateTime.now().toUtc().add(const Duration(seconds: 1));
      await chat.sendMessage(message: msg2);

      // getMessages
      final messages = await chat.getMessages(conversationId: created.conversationId);
      expect(messages.length, equals(2));
      expect(messages.first.text, equals('Hello Bob!'));

      // searchMessages
      final searchResults = await chat.searchMessages(
        query: 'Alice',
        conversationId: created.conversationId,
      );
      expect(searchResults.length, equals(1));
      expect(searchResults.first.text, contains('Hi Alice'));

      // Reactions
      chat.api.enableMessageReactions = true;
      await chat.addReaction(messageId: msg1.messageId, emoji: '👍');
      var updatedMsg = await chat.getMessageById(messageId: msg1.messageId);
      expect(updatedMsg!.reactions['👍'], contains('alice'));

      await chat.removeReaction(messageId: msg1.messageId, emoji: '👍');
      updatedMsg = await chat.getMessageById(messageId: msg1.messageId);
      expect(updatedMsg!.reactions['👍'], isNull);

      // Edit message
      await chat.editMessage(messageId: msg1.messageId, newText: 'Hello Robert!');
      updatedMsg = await chat.getMessageById(messageId: msg1.messageId);
      expect(updatedMsg!.text, equals('Hello Robert!'));
      expect(updatedMsg.isEdited, isTrue);

      // Read receipt
      await chat.notifyConversationRead(conversationId: created.conversationId);
      updatedMsg = await chat.getMessageById(messageId: msg2.messageId);
      expect(updatedMsg!.status, equals('read'));

      // Delete message for me
      await chat.deleteMessageForMe(messageId: msg1.messageId);
      final afterDelete = await chat.getMessageById(messageId: msg1.messageId);
      expect(afterDelete, isNull);
    });

    test('wipeAllData cleans all tables', () async {
      final user = AcChatUser()..userId = 'bob'..name = 'Bob';
      await chat.saveUser(user: user);

      final conv = AcChatConversation()..type = 'direct';
      await chat.insertConversation(conversation: conv, userIds: ['alice', 'bob']);

      await chat.wipeAllData();

      expect(await chat.getUsers(), isEmpty);
      expect(await chat.getConversations(), isEmpty);
    });
  });

  group('AcChatSqlite Dynamic Caching (cacheRows = true)', () {
    late AcChatSqlite chat;

    setUp(() async {
      chat = AcChatSqlite(
        cacheRows: true,
        databasePath: ':memory:',
      );
      await chat.initialize();
    });

    tearDown(() async {
      await chat.dispose();
    });

    test('Dynamic cache returns cached rows and handles updates', () async {
      final user = AcChatUser()
        ..userId = 'charlie'
        ..name = 'Charlie Brown';
      await chat.saveUser(user: user);

      // Retrieval from cache
      final retrieved = await chat.getUserById(userId: 'charlie');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Charlie Brown'));

      // Create conversation with cache active
      final conv = AcChatConversation()
        ..type = 'direct';
      final created = await chat.insertConversation(
        conversation: conv,
        userIds: ['alice', 'charlie'],
      );

      final convs = await chat.getConversations();
      expect(convs.any((c) => c.conversationId == created.conversationId), isTrue);

      // Send message with cache active
      final msg = AcChatMessage()
        ..conversationId = created.conversationId
        ..senderId = 'alice'
        ..text = 'Cached message test'
        ..time = DateTime.now().toUtc();
      await chat.sendMessage(message: msg);

      final msgs = await chat.getMessages(conversationId: created.conversationId);
      expect(msgs.length, equals(1));
      expect(msgs.first.text, equals('Cached message test'));
    });
  });

  group('AcChatSqliteChannelSync Integration', () {
    late AcChatSqlite chat;
    late MockChatSyncChannel channel;

    setUp(() async {
      channel = MockChatSyncChannel();
      chat = AcChatSqlite(
        cacheRows: false,
        channel: channel,
        databasePath: ':memory:',
      );
      await chat.initialize();
    });

    tearDown(() async {
      await chat.dispose();
    });

    test('Incoming message from channel is saved and triggers streams', () async {
      final incoming = AcChatMessage()
        ..messageId = 'msg_remote_1'
        ..conversationId = 'conv_sync_1'
        ..senderId = 'bob'
        ..text = 'Hello from remote'
        ..time = DateTime.now().toUtc();

      channel.onMessageReceived?.call(message: incoming);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final msg = await chat.getMessageById(messageId: 'msg_remote_1');
      expect(msg, isNotNull);
      expect(msg!.text, equals('Hello from remote'));
    });

    test('onMessageFlushed marks message as sent', () async {
      final msg = AcChatMessage()
        ..messageId = 'msg_to_flush'
        ..conversationId = 'conv_sync_2'
        ..senderId = 'alice'
        ..text = 'Flushed message'
        ..status = 'sending'
        ..time = DateTime.now().toUtc();
      await chat.upsertMessage(message: msg);

      await channel.onMessageFlushed!(
        messageId: 'msg_to_flush',
        conversationId: 'conv_sync_2',
      );

      final flushed = await chat.getMessageById(messageId: 'msg_to_flush');
      expect(flushed!.status, equals('sent'));
    });
  });
}

class MockChatSyncChannel implements AcChatSyncChannel {
  void Function({required AcChatMessage message})? onMessageReceived;
  void Function({required String conversationId, required String receiverId, required List<String> messageIds})? onConversationRead;
  void Function({required String conversationId, required List<String> userIds})? onConversationUsersRemoved;
  void Function({required AcChatConversation conversation})? onConversationUpdate;
  void Function({required AcChatConversationUser conversationUser})? onConversationUserUpdate;
  void Function({required List<String> messageIds, required String conversationId, required String receiverId})? onMessagesDelivered;
  void Function({required List<String> messageIds, required String conversationId, required String receiverId})? onMessagesRead;
  void Function({required Map<String, dynamic> updateData, required String messageId, required String conversationId})? onMessageUpdate;
  void Function({required AcChatConversation conversation, required List<String> userIds})? onNewConversation;
  void Function({required String conversationId, required List<String> userIds})? onNewConversationUsers;
  void Function({required String conversationId, required String userId, required bool isTyping})? onUserTyping;

  @override
  Future<void> Function({required String conversationId, required String messageId})? onMessageFlushed;

  @override
  Future<void> startListening({
    required String currentUserId,
    required void Function({required String conversationId, required List<String> userIds}) onConversationUsersRemoved,
    required void Function({required String conversationId, required String receiverId, required List<String> messageIds}) onConversationRead,
    required void Function({required AcChatConversation conversation}) onConversationUpdate,
    required void Function({required AcChatConversationUser conversationUser}) onConversationUserUpdate,
    required void Function({required List<String> messageIds, required String conversationId, required String receiverId}) onMessagesDelivered,
    required void Function({required List<String> messageIds, required String conversationId, required String receiverId}) onMessagesRead,
    required void Function({required AcChatMessage message}) onMessageReceived,
    required void Function({required Map<String, dynamic> updateData, required String messageId, required String conversationId}) onMessageUpdate,
    required void Function({required AcChatConversation conversation, required List<String> userIds}) onNewConversation,
    required void Function({required String conversationId, required List<String> userIds}) onNewConversationUsers,
    void Function({required String conversationId, required String userId, required bool isTyping})? onUserTyping,
  }) async {
    this.onMessageReceived = onMessageReceived;
    this.onConversationRead = onConversationRead;
    this.onConversationUsersRemoved = onConversationUsersRemoved;
    this.onConversationUpdate = onConversationUpdate;
    this.onConversationUserUpdate = onConversationUserUpdate;
    this.onMessagesDelivered = onMessagesDelivered;
    this.onMessagesRead = onMessagesRead;
    this.onMessageUpdate = onMessageUpdate;
    this.onNewConversation = onNewConversation;
    this.onNewConversationUsers = onNewConversationUsers;
    this.onUserTyping = onUserTyping;
  }

  @override
  Future<void> stopListening() async {}

  @override
  Future<bool> sendMessage({required AcChatMessage message, required List<String> recipientIds, Map<String, dynamic>? notificationPayload}) async => true;

  @override
  Future<void> createConversation({required AcChatConversation conversation, required List<String> userIds, Map<String, dynamic>? notificationPayload}) async {}

  @override
  Future<void> updateConversation({required AcChatConversation conversation}) async {}

  @override
  Future<void> updateConversationUser({required AcChatConversationUser conversationUser}) async {}

  @override
  Future<void> notifyConversationRead({required String conversationId,  List<String>? messageIds}) async {}

  @override
  Future<void> notifyMessagesDelivered({required List<String> messageIds, required String conversationId, required String senderId}) async {}

  @override
  Future<void> notifyMessagesRead({required List<String> messageIds, required String conversationId, required String senderId}) async {}

  @override
  Future<void> updateMessage({required String messageId, required String conversationId, required Map<String, dynamic> data, required List<String> recipientIds}) async {}

  @override
  Future<void> sendTypingIndicator({required String conversationId, required List<String> recipientIds, required bool isTyping}) async {}

  @override
  Future<void> addConversationUsers({required String conversationId, required List<String> userIds}) async {}

  @override
  Future<void> removeConversationUsers({required String conversationId, required List<String> userIds}) async {}
}

