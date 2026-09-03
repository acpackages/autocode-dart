import 'dart:async';
import 'package:flutter/widgets.dart';
import 'ac_chat.dart';
import '../media/ac_chat_media_uploader.dart';
import '../crypto/ac_chat_crypto_provider.dart';

/// The central contract and API bridge for the `ac_chat` UI.
///
/// Fully generic and platform-agnostic. All methods, callbacks, and constructors
/// strictly use named parameters.
class AcChatApi {
  final AcChatTheme theme;

  // ── Synchronous Snapshot Getters ──────────────────────────────────────────
  final AcChatUser Function() getCurrentUser;
  final List<AcChatUser> Function() getUsers;
  final AcChatUser? Function({required String userId}) getUserById;
  final List<AcChatConversation> Function() getConversations;
  final List<AcChatConversationUser> Function({required String conversationId}) getConversationUsers;
  final List<AcChatMessage> Function({required String conversationId}) getMessages;

  // ── Reactive Streams ──────────────────────────────────────────────────────
  /// Stream of conversations for live list binding.
  final Stream<List<AcChatConversation>> Function()? watchConversations;

  /// Stream of messages for an active conversation screen.
  final Stream<List<AcChatMessage>> Function({required String conversationId})? watchMessages;

  /// Stream of active typing indicators (userId -> isTyping) in a conversation.
  final Stream<Map<String, bool>> Function({required String conversationId})? watchTyping;

  /// Stream of online/presence state for a given user.
  final Stream<bool> Function({required String userId})? watchUserOnlineStatus;

  // ── Mutations & Actions ───────────────────────────────────────────────────
  final void Function({required String conversationId}) markAsRead;
  final void Function({required AcChatMessage message}) sendMessage;
  final AcChatConversation Function({
    required AcChatConversation newConv,
    required String otherUserId,
  }) insertConversation;

  /// Creates a multi-user group conversation.
  final Future<AcChatConversation> Function({
    required String groupName,
    required List<String> memberUserIds,
    String? groupAvatar,
  })? createGroupConversation;

  /// Adds members to an existing group conversation.
  final Future<void> Function({
    required String conversationId,
    required List<String> userIds,
  })? addGroupMembers;

  /// Removes a member from an existing group conversation.
  final Future<void> Function({
    required String conversationId,
    required String userId,
  })? removeGroupMember;

  /// Dispatches an ephemeral typing status signal.
  final void Function({
    required String conversationId,
    required bool isTyping,
  })? sendTypingIndicator;

  /// Performs full-text or indexed searching across messages.
  final Future<List<AcChatMessage>> Function({
    required String query,
    String? conversationId,
  })? searchMessages;

  /// Applies a partial field update to a message.
  final void Function({
    required String messageId,
    required Map<String, dynamic> data,
  })? updateMessage;

  /// Edits message text.
  final Future<void> Function({
    required String messageId,
    required String newText,
  })? onEditMessage;

  /// Deletes a message (soft-delete).
  final Future<void> Function({
    required String messageId,
    required bool forEveryone,
  })? onDeleteMessage;

  /// Adds an emoji reaction to a message.
  final Future<void> Function({
    required String messageId,
    required String emoji,
  })? onAddReaction;

  // ── Media & Security Providers ────────────────────────────────────────────
  final AcChatMediaUploader? mediaUploader;
  final AcChatCryptoProvider? cryptoProvider;

  // ── UI Customization & Builders ───────────────────────────────────────────
  final bool enableGroupsAndStatuses;
  final Widget? Function({required BuildContext context, required AcChatMessage message})? customMessageBuilder;
  final void Function({required AcChatMessage message})? onMessageTap;

  final FutureOr<AcChatUser?> Function({required BuildContext context})? onNewContact;
  final FutureOr<void> Function({required BuildContext context})? onNewGroup;
  final List<AcChatUser> Function()? getContacts;
  final String? contactsSectionTitle;
  final String? newContactLabel;
  final String? newContactSubtitle;
  final String? newGroupLabel;
  final String? newGroupSubtitle;
  final FutureOr<List<AcChatUser>> Function({required String query})? onSearchRemoteUsers;

  final bool readOnly;
  final bool enableVideoCall;
  final bool enableVoiceCall;
  final bool showNewConversationButton;
  final bool searchConversations;
  final bool pinConversations;
  final bool showConversationMenu;
  final bool showOnlineStatus;

  final Widget? Function({
    required BuildContext context,
    required AcChatConversation conversation,
  })? customInputBuilder;

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
    this.watchConversations,
    this.watchMessages,
    this.watchTyping,
    this.watchUserOnlineStatus,
    this.createGroupConversation,
    this.addGroupMembers,
    this.removeGroupMember,
    this.sendTypingIndicator,
    this.searchMessages,
    this.updateMessage,
    this.onEditMessage,
    this.onDeleteMessage,
    this.onAddReaction,
    this.mediaUploader,
    this.cryptoProvider,
    this.enableGroupsAndStatuses = false,
    this.customMessageBuilder,
    this.onMessageTap,
    this.onNewContact,
    this.onNewGroup,
    this.getContacts,
    this.contactsSectionTitle,
    this.newContactLabel,
    this.newContactSubtitle,
    this.newGroupLabel,
    this.newGroupSubtitle,
    this.onSearchRemoteUsers,
    this.readOnly = false,
    this.enableVideoCall = false,
    this.enableVoiceCall = false,
    this.showNewConversationButton = false,
    this.searchConversations = true,
    this.pinConversations = false,
    this.showConversationMenu = true,
    this.showOnlineStatus = true,
    this.customInputBuilder,
  });
}
