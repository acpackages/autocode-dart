import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat/src/chat_profile_screen.dart';
import 'package:ac_chat/src/new_chat_screen.dart';
import 'package:ac_chat/src/components/conversation/conversation.dart';
import 'package:ac_chat/src/components/conversation/conversation_media_tabs.dart';

AcChatApi makeTestApi({
  AcChatUser? currentUser,
  List<AcChatUser>? users,
  List<AcChatConversation>? conversations,
  List<AcChatMessage>? messages,
  bool enableTypingIndicator = true,
  bool enableTyping = true,
  bool enableGroups = true,
  int maxGroupParticipants = 50,
  bool enableGroupsAndStatuses = true,
  void Function({required String conversationId, required bool isTyping})? sendTypingIndicator,
  Future<void> Function({required String conversationId, required List<String> userIds})? addGroupMembers,
  Future<AcChatConversation> Function({required String groupName, required List<String> memberUserIds, String? groupAvatar})? createGroupConversation,
  FutureOr<List<AcChatUser>> Function({required String query})? onSearchRemoteUsers,
}) {
  final me = currentUser ?? (AcChatUser()..userId = 'me'..name = 'Current User');
  final allUsers = users ?? [me];
  final allConvs = conversations ?? [];
  final allMsgs = messages ?? [];

  return AcChatApi(
    theme: const AcChatTheme(isDark: false),
    getCurrentUser: () => me,
    getUsers: () => allUsers,
    getUserById: ({required String userId}) {
      try {
        return allUsers.firstWhere((u) => u.userId == userId);
      } catch (_) {
        return null;
      }
    },
    getConversations: () => allConvs,
    getConversationUsers: ({required String conversationId}) => [],
    markAsRead: ({required String conversationId}) {},
    insertConversation: ({required AcChatConversation newConv, required String otherUserId}) => newConv,
    getMessages: ({required String conversationId}) =>
        allMsgs.where((m) => m.conversationId == conversationId).toList(),
    sendMessage: ({required AcChatMessage message}) {},
    enableTypingIndicator: enableTypingIndicator,
    enableTyping: enableTyping,
    enableGroups: enableGroups,
    maxGroupParticipants: maxGroupParticipants,
    enableGroupsAndStatuses: enableGroupsAndStatuses,
    sendTypingIndicator: sendTypingIndicator,
    addGroupMembers: addGroupMembers,
    createGroupConversation: createGroupConversation,
    onSearchRemoteUsers: onSearchRemoteUsers,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AcChatMessage Tests', () {
    test('serialization and receipts with named parameters', () {
      final now = DateTime(2026, 9, 3, 12, 0);
      final msg = AcChatMessage()
        ..messageId = 'm_001'
        ..conversationId = 'c_001'
        ..senderId = 'alice'
        ..text = 'Hello World'
        ..status = 'delivered'
        ..deliveredTime = now
        ..reactions = {'❤️': ['bob']};

      final json = msg.toJson();
      expect(json['messageId'], equals('m_001'));
      expect(json['status'], equals('delivered'));
      expect(json['deliveredTime'], equals(now.millisecondsSinceEpoch));

      final restored = AcChatMessage.instanceFromJson(jsonData: json);
      expect(restored.messageId, equals('m_001'));
      expect(restored.status, equals('delivered'));
      expect(restored.reactions['❤️'], contains('bob'));
    });
  });

  group('AcChatConversation Tests', () {
    test('serialization with group properties and memberIds', () {
      final conv = AcChatConversation()
        ..conversationId = 'grp_1'
        ..type = 'group'
        ..groupName = 'Core Team'
        ..memberIds = ['u1', 'u2', 'u3'];

      final json = conv.toJson();
      expect(json['conversationId'], equals('grp_1'));
      expect(json['memberIds'], equals(['u1', 'u2', 'u3']));

      final restored = AcChatConversation.instanceFromJson(jsonData: json);
      expect(restored.conversationId, equals('grp_1'));
      expect(restored.type, equals('group'));
      expect(restored.groupName, equals('Core Team'));
      expect(restored.memberIds.length, equals(3));
    });
  });

  group('AcChatApi Contract Tests', () {
    test('instantiates with strictly named parameters', () {
      final currentUser = AcChatUser()
        ..userId = 'user_me'
        ..name = 'My User';

      final api = AcChatApi(
        theme: const AcChatTheme(isDark: false),
        getCurrentUser: () => currentUser,
        getUsers: () => [currentUser],
        getUserById: ({required String userId}) => currentUser,
        getConversations: () => [],
        getConversationUsers: ({required String conversationId}) => [],
        markAsRead: ({required String conversationId}) {},
        insertConversation: ({required AcChatConversation newConv, required String otherUserId}) => newConv,
        getMessages: ({required String conversationId}) => [],
        sendMessage: ({required AcChatMessage message}) {},
      );

      expect(api.getCurrentUser().userId, equals('user_me'));
      expect(api.getConversations(), isEmpty);
      expect(api.enableTypingIndicator, isTrue);
      expect(api.enableTyping, isTrue);
      expect(api.enableGroups, isTrue);
      expect(api.maxGroupParticipants, equals(50));
    });
  });

  group('Requirement 1: Typing Control Tests', () {
    testWidgets('InputBar TextField is disabled with hint when enableTyping is false', (tester) async {
      final chat = AcChatConversation()..conversationId = 'c1';
      final api = makeTestApi(enableTyping: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Conversation(
              chat: chat,
              api: api,
            ),
          ),
        ),
      );
      await tester.pump();

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);
      final textField = tester.widget<TextField>(textFieldFinder);
      expect(textField.enabled, isFalse);
      expect(textField.decoration?.hintText, equals('Typing is disabled'));
    });

    testWidgets('sendTypingIndicator is not triggered when enableTypingIndicator is false', (tester) async {
      var typingTriggered = false;
      final chat = AcChatConversation()..conversationId = 'c1';
      final api = makeTestApi(
        enableTypingIndicator: false,
        sendTypingIndicator: ({required conversationId, required isTyping}) {
          typingTriggered = true;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Conversation(
              chat: chat,
              api: api,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      expect(typingTriggered, isFalse);
    });
  });

  group('Requirement 2: Unified Chats Tab & Group Configuration', () {
    testWidgets('TabBar has only CHATS and STATUS tabs when enableGroupsAndStatuses is true', (tester) async {
      final directConv = AcChatConversation()
        ..conversationId = 'c_direct'
        ..type = 'direct'
        ..lastTime = DateTime(2026, 9, 3, 10);
      final groupConv = AcChatConversation()
        ..conversationId = 'c_group'
        ..type = 'group'
        ..groupName = 'Project X'
        ..lastTime = DateTime(2026, 9, 3, 11);

      final api = makeTestApi(
        enableGroupsAndStatuses: true,
        enableGroups: true,
        conversations: [directConv, groupConv],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AcChat(api: api),
        ),
      );
      await tester.pump();

      expect(find.text('CHATS'), findsOneWidget);
      expect(find.text('STATUS'), findsOneWidget);
      expect(find.text('GROUPS'), findsNothing);

      // Both direct chat and group chat should be rendered in the list
      expect(find.text('Project X'), findsOneWidget);
    });

    testWidgets('enableGroups == false filters out group conversations', (tester) async {
      final directConv = AcChatConversation()
        ..conversationId = 'c_direct'
        ..type = 'direct'
        ..lastTime = DateTime(2026, 9, 3, 10);
      final groupConv = AcChatConversation()
        ..conversationId = 'c_group'
        ..type = 'group'
        ..groupName = 'Secret Project'
        ..lastTime = DateTime(2026, 9, 3, 11);

      final api = makeTestApi(
        enableGroupsAndStatuses: false,
        enableGroups: false,
        conversations: [directConv, groupConv],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AcChat(api: api),
        ),
      );
      await tester.pump();

      expect(find.text('Secret Project'), findsNothing);
    });

    testWidgets('NewChatScreen hides New Group option when enableGroups is false', (tester) async {
      final api = makeTestApi(enableGroups: false);

      await tester.pumpWidget(
        MaterialApp(
          home: NewChatScreen(api: api),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Group'), findsNothing);
      expect(find.text('New Contact'), findsOneWidget);
    });

    testWidgets('NewChatScreen enforces maxGroupParticipants limit and shows counter', (tester) async {
      final userA = AcChatUser()..userId = 'u_a'..name = 'User A';
      final userB = AcChatUser()..userId = 'u_b'..name = 'User B';
      final userC = AcChatUser()..userId = 'u_c'..name = 'User C';

      final api = makeTestApi(
        enableGroups: true,
        maxGroupParticipants: 2,
        users: [
          AcChatUser()..userId = 'me'..name = 'Me',
          userA,
          userB,
          userC,
        ],
        createGroupConversation: ({required groupName, required memberUserIds, groupAvatar}) async {
          return AcChatConversation()..conversationId = 'g1';
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NewChatScreen(api: api),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "New Group"
      await tester.tap(find.text('New Group'));
      await tester.pumpAndSettle();

      // Counter should show 0 / 2
      expect(find.text('0 / 2'), findsOneWidget);

      // Select User A (1 / 2)
      await tester.tap(find.text('User A'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 2'), findsOneWidget);

      // Select User B (2 / 2)
      await tester.tap(find.text('User B'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);

      // Attempt to select User C (exceeds limit of 2)
      await tester.tap(find.text('User C'));
      await tester.pumpAndSettle();

      expect(find.text('Maximum of 2 participants allowed'), findsOneWidget);
      expect(find.text('2 / 2'), findsOneWidget);
    });
  });

  group('Requirement 4 & 5: Profile Screens, Hero Tags & Self Exclusion', () {
    testWidgets('NewChatScreen excludes self account in local contacts and remote search', (tester) async {
      final me = AcChatUser()..userId = 'me'..name = 'Me';
      final other = AcChatUser()..userId = 'other'..name = 'Other User';

      final api = makeTestApi(
        currentUser: me,
        users: [me, other],
        onSearchRemoteUsers: ({required query}) async {
          return [me, AcChatUser()..userId = 'remote_1'..name = 'Remote 1'];
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NewChatScreen(api: api),
        ),
      );
      await tester.pumpAndSettle();

      // Local contacts should not display "Me"
      expect(find.text('Me'), findsNothing);
      expect(find.text('Other User'), findsOneWidget);

      // Remote search
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Remote 1'), findsOneWidget);
      expect(find.text('Me'), findsNothing);
    });

    testWidgets('ChatProfileScreen falls back to memberIds and uses avatar-profile tag in embedded mode', (tester) async {
      final other = AcChatUser()..userId = 'u2'..name = 'Bob Doe';
      final chat = AcChatConversation()
        ..conversationId = 'c_direct_fallback'
        ..type = 'direct'
        ..memberIds = ['me', 'u2'];

      final api = makeTestApi(
        currentUser: AcChatUser()..userId = 'me'..name = 'Me',
        users: [AcChatUser()..userId = 'me'..name = 'Me', other],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatProfileScreen(
            chat: chat,
            api: api,
            isEmbedded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Participant name resolved via chat.memberIds fallback
      expect(find.text('Bob Doe'), findsOneWidget);

      // Hero tag should be avatar-profile-c_direct_fallback
      final heroFinder = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'avatar-profile-c_direct_fallback',
      );
      expect(heroFinder, findsOneWidget);
    });

    testWidgets('ConversationMediaTabs retrieves messages using named argument conversationId', (tester) async {
      final chat = AcChatConversation()..conversationId = 'c_media';
      final msg = AcChatMessage()
        ..messageId = 'm1'
        ..conversationId = 'c_media'
        ..type = 'text'
        ..text = 'https://example.com'
        ..isDownloaded = true;

      final api = makeTestApi(
        messages: [msg],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversationMediaTabs(
              chat: chat,
              ct: api.theme,
              api: api,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tab bar for media, docs, links rendered without error
      expect(find.text('Media'), findsOneWidget);
      expect(find.text('Docs'), findsOneWidget);
      expect(find.text('Links'), findsOneWidget);
    });
  });

  group('Enterprise Architecture & 12-Domain Tests', () {
    test('AcChatConfig defaults, copyWith, and allDisabled', () {
      const config = AcChatConfig();
      expect(config.chatDataDirectory, equals('chat_data'));
      expect(config.enableOneToOneConversations, isTrue);
      expect(config.enableGroupConversations, isTrue);
      expect(config.maxGroupParticipants, equals(256));
      expect(config.enableMessageReactions, isTrue);
      expect(config.enableOfflineOutbox, isTrue);
      expect(config.outboxMaxRetries, equals(5));

      final disabled = AcChatConfig.allDisabled();
      expect(disabled.enableOneToOneConversations, isFalse);
      expect(disabled.enableGroupConversations, isFalse);
      expect(disabled.enableMessageReactions, isFalse);
      expect(disabled.enableOfflineOutbox, isFalse);

      final custom = config.copyWith(maxGroupParticipants: 100, enableMediaViewer: false);
      expect(custom.maxGroupParticipants, equals(100));
      expect(custom.enableMediaViewer, isFalse);
      expect(custom.enableOneToOneConversations, isTrue);
    });

    test('UtcUtils strict UTC guarantee and wire format ending in Z', () {
      final now = DateTime.now();
      final utcNow = nowUtc();
      expect(utcNow.isUtc, isTrue);

      final parsedEpoch = parseUtc(1725364800000);
      expect(parsedEpoch.isUtc, isTrue);
      expect(parsedEpoch.millisecondsSinceEpoch, equals(1725364800000));

      final isoString = formatUtcIso(now);
      expect(isoString.endsWith('Z'), isTrue);

      final parsedIso = parseUtc(isoString);
      expect(parsedIso.isUtc, isTrue);

      expect(parseUtcOrNull(null), isNull);
      expect(parseUtcOrNull('   '), isNull);
      expect(parseUtcOrNull(isoString)?.isUtc, isTrue);
    });

    test('AcChatConversation agnostic fields, alias fallback, and UTC timestamps', () {
      final conv = AcChatConversation()
        ..conversationId = 'conv_agnostic'
        ..conversationName = 'General Discussion'
        ..conversationAvatar = 'https://example.com/avatar.jpg'
        ..conversationDescription = 'Main chatroom'
        ..createdBy = 'admin_user'
        ..createdAtUtc = DateTime.utc(2026, 1, 1)
        ..lastTimeUtc = DateTime.utc(2026, 9, 3, 14, 30);

      expect(conv.groupName, equals('General Discussion'));
      expect(conv.groupAvatar, equals('https://example.com/avatar.jpg'));
      expect(conv.groupDescription, equals('Main chatroom'));
      expect(conv.createdAtUtc.isUtc, isTrue);
      expect(conv.lastTimeUtc.isUtc, isTrue);

      final json = conv.toJson();
      expect(json['conversationName'], equals('General Discussion'));
      expect(json['groupName'], equals('General Discussion'));
      expect(json['conversationAvatar'], equals('https://example.com/avatar.jpg'));
      expect(json['conversationDescription'], equals('Main chatroom'));
      expect(json['createdBy'], equals('admin_user'));

      final restored = AcChatConversation.instanceFromJson(jsonData: json);
      expect(restored.conversationName, equals('General Discussion'));
      expect(restored.groupName, equals('General Discussion'));
      expect(restored.conversationAvatar, equals('https://example.com/avatar.jpg'));
      expect(restored.conversationDescription, equals('Main chatroom'));
      expect(restored.createdBy, equals('admin_user'));
      expect(restored.createdAtUtc.isUtc, isTrue);
    });

    test('AcChatConversationUser preferences serialization roundtrip', () {
      final pref = AcChatConversationUser()
        ..conversationId = 'conv_pref_1'
        ..userId = 'user_alice'
        ..unreadCount = 7
        ..isPinned = true
        ..isMuted = true
        ..muteUntilUtc = DateTime.utc(2026, 9, 10)
        ..isArchived = true
        ..isHidden = false
        ..role = 'admin'
        ..lastReadMessageId = 'msg_last_read'
        ..lastReadTimeUtc = DateTime.utc(2026, 9, 3, 12, 0);

      final json = pref.toJson();
      expect(json['conversationId'], equals('conv_pref_1'));
      expect(json['userId'], equals('user_alice'));
      expect(json['unreadCount'], equals(7));
      expect(json['isPinned'], isTrue);
      expect(json['isMuted'], isTrue);
      expect(json['isArchived'], isTrue);
      expect(json['role'], equals('admin'));

      final restored = AcChatConversationUser.instanceFromJson(jsonData: json);
      expect(restored.conversationId, equals('conv_pref_1'));
      expect(restored.userId, equals('user_alice'));
      expect(restored.unreadCount, equals(7));
      expect(restored.isPinned, isTrue);
      expect(restored.isMuted, isTrue);
      expect(restored.muteUntilUtc?.isUtc, isTrue);
      expect(restored.lastReadTimeUtc?.isUtc, isTrue);
    });

    test('AcChatMessage extended 12-domain fields roundtrip', () {
      final msg = AcChatMessage()
        ..messageId = 'm_full'
        ..conversationId = 'conv_1'
        ..senderId = 'alice'
        ..text = 'Important update'
        ..isStarred = true
        ..reactions = {'👍': ['bob', 'charlie'], '❤️': ['dave']}
        ..mentions = ['bob', 'charlie']
        ..timeUtc = DateTime.utc(2026, 9, 3, 10, 0)
        ..deliveredTimeUtc = DateTime.utc(2026, 9, 3, 10, 1)
        ..readTimeUtc = DateTime.utc(2026, 9, 3, 10, 2)
        ..editedTimeUtc = DateTime.utc(2026, 9, 3, 10, 3)
        ..pinnedUntilUtc = DateTime.utc(2026, 9, 10)
        ..scheduledTimeUtc = DateTime.utc(2026, 9, 4, 9, 0)
        ..expiresAtUtc = DateTime.utc(2026, 9, 5, 0, 0);

      final json = msg.toJson();
      expect(json['isStarred'], isTrue);
      expect(json['reactions']['👍'], contains('bob'));
      expect(json['mentions'], contains('charlie'));

      final restored = AcChatMessage.instanceFromJson(jsonData: json);
      expect(restored.isStarred, isTrue);
      expect(restored.reactions['👍']?.length, equals(2));
      expect(restored.mentions, equals(['bob', 'charlie']));
      expect(restored.timeUtc.isUtc, isTrue);
      expect(restored.deliveredTimeUtc?.isUtc, isTrue);
      expect(restored.readTimeUtc?.isUtc, isTrue);
      expect(restored.editedTimeUtc?.isUtc, isTrue);
      expect(restored.pinnedUntilUtc?.isUtc, isTrue);
      expect(restored.scheduledTimeUtc?.isUtc, isTrue);
      expect(restored.expiresAtUtc?.isUtc, isTrue);
    });
  });
}
