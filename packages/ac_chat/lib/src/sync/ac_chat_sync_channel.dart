import '../models/ac_chat_message.dart';
import '../models/ac_chat_conversation.dart';
import '../models/ac_chat_conversation_user.dart';
import '../models/ac_chat_user.dart';

/// Transport interface for syncing chat data with a remote backend.
///
/// Designed to be decoupled from any specific transport technology (Firebase,
/// Supabase, WebSocket, custom REST, etc.). All methods, callbacks, and parameters
/// strictly use named parameters.
abstract class AcChatSyncChannel {
  /// Sends a new message to the remote transport targeting [recipientIds].
  Future<void> sendMessage({
    required AcChatMessage message,
    required List<String> recipientIds,
    Map<String, dynamic>? notificationPayload,
  });

  /// Persists a newly created conversation on the remote backend targeting [memberIds].
  Future<void> createConversation({
    required AcChatConversation conversation,
    required List<String> memberIds,
    Map<String, dynamic>? notificationPayload,
  });

  /// Marks a conversation as read and dispatches read signaling.
  Future<void> markAsRead({
    required String conversationId,
    required String currentUserId,
    List<String>? messageIds,
  });

  /// Sends a delivery receipt back to the original message sender.
  Future<void> sendDeliveryReceipt({
    required String messageId,
    required String conversationId,
    required String senderId,
  });

  /// Sends a read receipt back to the original message sender.
  Future<void> sendReadReceipt({
    required String conversationId,
    required String senderId,
    required List<String> messageIds,
  });

  /// Sends an ephemeral typing status signal to [recipientIds].
  Future<void> sendTypingIndicator({
    required String conversationId,
    required List<String> recipientIds,
    required bool isTyping,
  });

  /// Applies a partial update to a message on the remote transport.
  Future<void> updateMessage({
    required String messageId,
    required String conversationId,
    required Map<String, dynamic> data,
    required List<String> recipientIds,
  });

  /// Acknowledges receipt and persistence of a mailbox update, allowing the
  /// transport channel to prune the update document.
  Future<void> acknowledgeUpdate({
    required String updateId,
  });

  /// Adds new members to an existing group conversation.
  Future<void> addGroupMembers({
    required String conversationId,
    required List<String> memberIds,
  }) async {}

  /// Removes a member from an existing group conversation.
  Future<void> removeGroupMember({
    required String conversationId,
    required String userId,
  }) async {}

  /// Starts listening for remote events.
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
  });

  /// Stops all remote listeners and releases resources.
  Future<void> stopListening();
}
