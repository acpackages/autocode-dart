import 'ac_chat.dart';
import '../common/chat_colors.dart';

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
  final void Function(String messageId, Map<String, dynamic> data)? updateMessage;

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
    this.updateMessage,
  });
}

