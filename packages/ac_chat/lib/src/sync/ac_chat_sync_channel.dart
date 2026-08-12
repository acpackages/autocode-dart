import '../models/ac_chat_message.dart';
import '../models/ac_chat_conversation.dart';
import '../models/ac_chat_conversation_user.dart';
import '../models/ac_chat_user.dart';

/// Transport interface for syncing chat data with a remote backend.
///
/// Implement this in any backend package (Firebase, REST, WebSocket, Supabase, etc.)
/// to connect it to a local caching layer such as `ac_chat_sqlite`.
///
/// Can also be used standalone: call [startListening] with callbacks,
/// then call [sendMessage] / [createConversation] as needed.
abstract class AcChatSyncChannel {
  /// Send a new message to the remote backend.
  ///
  /// The message already has a [AcChatMessage.messageId] assigned by the caller.
  Future<void> sendMessage(AcChatMessage message);

  /// Persist a newly created conversation on the remote backend.
  Future<void> createConversation(
    AcChatConversation conversation,
    String otherUserId,
  );

  /// Mark a conversation as read for [currentUserId] on the remote backend.
  Future<void> markAsRead(String conversationId, String currentUserId);

  /// Apply a partial update to a message on the remote backend.
  Future<void> updateMessage(
    String messageId,
    String conversationId,
    Map<String, dynamic> data,
  );

  /// Start listening for remote events.
  ///
  /// [currentUserId] identifies the local user.
  ///
  /// [onMessageReceived] is called for every new or updated message from the remote.
  ///
  /// [onConversationChanged] is called when a conversation is created or updated remotely.
  ///
  /// [onUsersLoaded] is called with the current user list from the remote backend.
  Future<void> startListening({
    required String currentUserId,
    required void Function(AcChatMessage message) onMessageReceived,
    required void Function(
      AcChatConversation conversation,
      List<AcChatConversationUser> members,
    ) onConversationChanged,
    required void Function(List<AcChatUser> users) onUsersLoaded,
  });

  /// Stop all remote listeners and release resources.
  Future<void> stopListening();
}
