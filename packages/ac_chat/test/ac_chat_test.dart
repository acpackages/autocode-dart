import 'package:flutter_test/flutter_test.dart';
import 'package:ac_chat/ac_chat.dart';

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
    });
  });
}
