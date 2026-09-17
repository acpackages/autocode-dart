import '../models/ac_chat_message.dart';
import '../models/ac_chat_conversation.dart';
import '../models/ac_chat_conversation_user.dart';

/// Transport interface for syncing chat data with a remote backend.
///
/// Designed to be decoupled from any specific transport technology (Firebase,
/// Supabase, WebSocket, custom REST, etc.). All methods, callbacks, and parameters
/// strictly use named parameters.
abstract class AcChatSyncChannel {

  Future<void> Function({required String messageId, required String conversationId})? onMessageFlushed;

  /// Acknowledges receipt and persistence of a mailbox update, allowing the
  /// transport channel to prune the update document.
  // Future<void> acknowledgeUpdate({
  //   required String updateId,
  // });

  /// Adds new members to an existing group conversation.
  Future<void> addConversationUsers({
    required String conversationId,
    required List<String> userIds,
  }) async {}

  /// Persists a newly created conversation on the remote backend targeting [userIds].
  Future<void> createConversation({
    required AcChatConversation conversation,
    required List<String> userIds,
    Map<String, dynamic>? notificationPayload,
  });

  /// Marks a conversation as read and dispatches read signaling.
  Future<void> notifyConversationRead({
    required String conversationId,
    List<String>? messageIds,
  });

  /// Sends a delivery receipt back to the original message sender.
  Future<void> notifyMessagesDelivered({
    required List<String> messageIds,
    required String conversationId,
    required String senderId,
  });

  /// Sends a read receipt back to the original message sender.
  Future<void> notifyMessagesRead({
    required String conversationId,
    required String senderId,
    required List<String> messageIds,
  });

  /// Removes a user from an existing group conversation.
  Future<void> removeConversationUsers({
    required String conversationId,
    required List<String> userIds,
  }) async {}

  /// Sends a new message to the remote transport targeting [recipientIds].
  /// Returns `true` if sent immediately via socket, `false` if cached for later.
  Future<bool> sendMessage({
    required AcChatMessage message,
    required List<String> recipientIds,
    Map<String, dynamic>? notificationPayload,
  });

  /// Sends an ephemeral typing status signal to [recipientIds].
  Future<void> sendTypingIndicator({
    required String conversationId,
    required List<String> recipientIds,
    required bool isTyping,
  });

  /// Persists a newly created conversation on the remote backend targeting [userIds].
  Future<void> updateConversation({
    required AcChatConversation conversation,
  });

  Future<void> updateConversationUser({required AcChatConversationUser conversationUser});

  /// Applies a partial update to a message on the remote transport.
  Future<void> updateMessage({
    required String messageId,
    required String conversationId,
    required Map<String, dynamic> data,
    required List<String> recipientIds,
  });

  /// Starts listening for remote events.
  Future<void> startListening({
    required String currentUserId,
    required void Function({required String conversationId,required List<String> userIds}) onConversationUsersRemoved,
    required void Function({required String conversationId,required String receiverId,required List<String> messageIds}) onConversationRead,
    required void Function({required AcChatConversation conversation}) onConversationUpdate,
    required void Function({required AcChatConversationUser conversationUser}) onConversationUserUpdate,
    required void Function({required List<String> messageIds,required String conversationId,required String receiverId}) onMessagesDelivered,
    required void Function({required List<String> messageIds,required String conversationId,required String receiverId}) onMessagesRead,
    required void Function({required AcChatMessage message}) onMessageReceived,
    required void Function({required Map<String, dynamic> updateData,required String messageId,required String conversationId}) onMessageUpdate,
    required void Function({required AcChatConversation conversation,required List<String> userIds}) onNewConversation,
    required void Function({required String conversationId,required List<String> userIds}) onNewConversationUsers,
    void Function({required String conversationId,required String userId,required bool isTyping,})? onUserTyping
  });

  /// Stops all remote listeners and releases resources.
  Future<void> stopListening();
}
