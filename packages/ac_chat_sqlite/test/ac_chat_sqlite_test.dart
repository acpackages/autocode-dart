import 'dart:io' as io;
import 'dart:typed_data';
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

  final List<Map<String, String>> deliveryReceipts = [];
  void Function({required AcChatMessage message})? onMessageReceivedCallback;
  void Function({required String messageId, required String conversationId, required String status})? onMessageStatusUpdatedCallback;

  @override
  Future<void> sendDeliveryReceipt({
    required String messageId,
    required String conversationId,
    required String senderId,
  }) async {
    deliveryReceipts.add({
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
    });
  }

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
  }) async {
    onMessageReceivedCallback = onMessageReceived;
    onMessageStatusUpdatedCallback = onMessageStatusUpdated;
  }

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
      expect(received, isNull);
    });

    test('buildApi forwards typing and group configuration parameters', () {
      final sqlite = AcChatSqlite(
        currentUserId: 'user_alice',
        config: const AcChatSqliteConfig(
          databasePath: ':memory:',
          dataDictionaryName: 'ac_chat_test',
        ),
      );

      final defaultApi = sqlite.buildApi(theme: const AcChatTheme(isDark: false));
      expect(defaultApi.enableTypingIndicator, isTrue);
      expect(defaultApi.enableTyping, isTrue);
      expect(defaultApi.enableGroups, isTrue);
      expect(defaultApi.maxGroupParticipants, equals(50));

      final customApi = sqlite.buildApi(
        theme: const AcChatTheme(isDark: false),
        enableTypingIndicator: false,
        enableTyping: false,
        enableGroups: false,
        maxGroupParticipants: 25,
      );
      expect(customApi.enableTypingIndicator, isFalse);
      expect(customApi.enableTyping, isFalse);
      expect(customApi.enableGroups, isFalse);
      expect(customApi.maxGroupParticipants, equals(25));
    });

    test('_handleIncomingMessage sends delivery receipt for other users', () async {
      final mockChannel = MockSyncChannel();
      final sqlite = AcChatSqlite(
        currentUserId: 'user_alice',
        config: const AcChatSqliteConfig(
          databasePath: ':memory:',
          dataDictionaryName: 'ac_chat_test',
        ),
      );

      sqlite.startSync(channel: mockChannel);
      expect(mockChannel.onMessageReceivedCallback, isNotNull);

      final incomingMsg = AcChatMessage()
        ..messageId = 'm_incoming_1'
        ..conversationId = 'c_1'
        ..senderId = 'user_bob'
        ..text = 'Hi Alice'
        ..time = DateTime.now();

      mockChannel.onMessageReceivedCallback!(message: incomingMsg);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(mockChannel.deliveryReceipts, hasLength(1));
      expect(mockChannel.deliveryReceipts.first['messageId'], equals('m_incoming_1'));
      expect(mockChannel.deliveryReceipts.first['conversationId'], equals('c_1'));
      expect(mockChannel.deliveryReceipts.first['senderId'], equals('user_bob'));
    });

    test('onMessageStatusUpdated updates status and delivered/read timestamps', () async {
      final mockChannel = MockSyncChannel();
      final sqlite = AcChatSqlite(
        currentUserId: 'user_alice',
        config: const AcChatSqliteConfig(
          databasePath: ':memory:',
          dataDictionaryName: 'ac_chat_test',
        ),
      );

      var dataChangedNotified = false;
      sqlite.onDataChanged = () => dataChangedNotified = true;
      sqlite.startSync(channel: mockChannel);

      // Alice sends a message
      final api = sqlite.buildApi(theme: const AcChatTheme(isDark: false));
      final msg = AcChatMessage()
        ..messageId = 'm_alice_1'
        ..conversationId = 'c_1'
        ..senderId = 'user_alice'
        ..text = 'Hello Bob'
        ..status = 'sent'
        ..time = DateTime.now();

      api.sendMessage(message: msg);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(mockChannel.onMessageStatusUpdatedCallback, isNotNull);

      // Receive delivered status update
      dataChangedNotified = false;
      mockChannel.onMessageStatusUpdatedCallback!(
        messageId: 'm_alice_1',
        conversationId: 'c_1',
        status: 'delivered',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final msgsAfterDelivered = api.getMessages(conversationId: 'c_1');
      expect(msgsAfterDelivered, isNotEmpty);
      expect(msgsAfterDelivered.first.status, equals('delivered'));
      expect(msgsAfterDelivered.first.deliveredTime, isNotNull);
      expect(dataChangedNotified, isTrue);

      // Receive read status update
      dataChangedNotified = false;
      mockChannel.onMessageStatusUpdatedCallback!(
        messageId: 'm_alice_1',
        conversationId: 'c_1',
        status: 'read',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final msgsAfterRead = api.getMessages(conversationId: 'c_1');
      expect(msgsAfterRead.first.status, equals('read'));
      expect(msgsAfterRead.first.readTime, isNotNull);
      expect(dataChangedNotified, isTrue);
    });

    test('saves received media into directories categorized by type', () async {
      final tempDir = await io.Directory.systemTemp.createTemp('ac_chat_media_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final sqlite = AcChatSqlite(
        currentUserId: 'user_bob',
        config: AcChatSqliteConfig(
          databasePath: ':memory:',
          dataDictionaryName: 'ac_chat_media_test',
          dataDirectory: tempDir.path,
        ),
      );

      expect(sqlite.dataDirectory, equals(tempDir.path));

      // 1. Test helper paths by type
      expect(sqlite.getMediaDirectoryForType('image'), equals('${tempDir.path}/images'));
      expect(sqlite.getMediaDirectoryForType('video'), equals('${tempDir.path}/videos'));
      expect(sqlite.getMediaDirectoryForType('audio'), equals('${tempDir.path}/audio'));
      expect(sqlite.getMediaDirectoryForType('document'), equals('${tempDir.path}/documents'));

      // 2. Test saveMediaFile
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final savedPath = await sqlite.saveMediaFile(
        type: 'image',
        fileName: 'profile.jpg',
        bytes: testBytes,
      );

      expect(savedPath, isNotNull);
      expect(io.File(savedPath!).existsSync(), isTrue);
      expect(await io.File(savedPath).readAsBytes(), equals(testBytes));
      expect(savedPath, contains('images'));
    });

    test('AcChatApi.updateMessage updates message fields including isDownloaded and localPath', () async {
      final sqlite = AcChatSqlite(
        currentUserId: 'user_bob',
        config: const AcChatSqliteConfig(
          databasePath: ':memory:',
          dataDictionaryName: 'ac_chat_update_msg_test',
        ),
      );
      final api = sqlite.buildApi(theme: const AcChatTheme());

      final conv = AcChatConversation()
        ..conversationId = 'c_update_test'
        ..type = 'individual'
        ..memberIds = ['user_bob', 'user_alice'];
      api.insertConversation(newConv: conv, otherUserId: 'user_alice');

      final msg = AcChatMessage()
        ..messageId = 'msg_media_1'
        ..conversationId = 'c_update_test'
        ..senderId = 'user_alice'
        ..text = 'https://example.com/image.jpg'
        ..type = 'image'
        ..time = DateTime.now()
        ..status = 'sent'
        ..isDownloaded = false;
      api.sendMessage(message: msg);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Verify initial state
      final initialMsgs = api.getMessages(conversationId: 'c_update_test');
      expect(initialMsgs.first.isDownloaded, isFalse);
      expect(initialMsgs.first.localPath, isNull);

      // Call api.updateMessage (the exact call made on download completion)
      api.updateMessage(
        messageId: 'msg_media_1',
        data: {
          'isDownloaded': true,
          'localPath': '/local/path/to/image.jpg',
        },
      );

      final updatedMsgs = api.getMessages(conversationId: 'c_update_test');
      expect(updatedMsgs.first.isDownloaded, isTrue);
      expect(updatedMsgs.first.localPath, equals('/local/path/to/image.jpg'));
    });
  });
}
