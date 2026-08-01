import 'ac_chat.dart';
import '../common/chat_colors.dart';
import '../common/mock_data.dart' as mock;

class AcChatApi {
  final AcChatTheme theme;
  final AcChatUser Function() getCurrentUser;
  final List<AcChatUser> Function() getUsers;
  final AcChatUser? Function(String userId) getUserById;
  final List<AcChatConversation> Function() getConversations;
  final List<AcChatConversationUser> Function(String conversationId) getConversationUsers;
  final void Function(String conversationId) markAsRead;
  final AcChatConversation Function(AcChatConversation newConv, String otherUserId) insertConversation;
  final List<AcChatMessage> Function(String conversationId) getMessages;
  final void Function(AcChatMessage newMsg) sendMessage;
  final bool enableGroupsAndStatuses;

  AcChatApi({
    required this.theme,
    required this.getCurrentUser,
    required this.getUsers,
    required this.getUserById,
    required this.getConversations,
    required this.getConversationUsers,
    required this.markAsRead,
    required this.insertConversation,
    required this.getMessages,
    required this.sendMessage,
    this.enableGroupsAndStatuses = false,
  });

  // Mock implementation factory
  factory AcChatApi.mock({required AcChatTheme theme, bool enableGroupsAndStatuses = false}) {
    return AcChatApi(
      theme: theme,
      enableGroupsAndStatuses: enableGroupsAndStatuses,
      getCurrentUser: () => AcChatUser.instanceFromJson(jsonData: mock.currentUser),
      getUsers: () => mock.users.map((u) => AcChatUser.instanceFromJson(jsonData: u)).toList(),
      getUserById: (userId) => mock.getUserById(userId),
      getConversations: () => mock.chats.map((c) => AcChatConversation.instanceFromJson(jsonData: c)).toList(),
      getConversationUsers: (conversationId) => mock.getConversationUsers(conversationId),
      markAsRead: (conversationId) {
        final idx = mock.chats.indexWhere((c) => c['id'].toString() == conversationId);
        if (idx != -1) {
          mock.chats[idx] = {...mock.chats[idx], 'unread': 0};
        }
      },
      insertConversation: (newConv, otherUserId) => mock.insertConversation(newConv, otherUserId),
      getMessages: (conversationId) {
        final list = mock.messages
            .where((m) => m['chatId'].toString() == conversationId)
            .map((m) => AcChatMessage.instanceFromJson(jsonData: m))
            .toList();
        list.sort((a, b) => a.time.compareTo(b.time));
        return list;
      },
      sendMessage: (newMsg) => mock.insertMessage(newMsg),
    );
  }
}
