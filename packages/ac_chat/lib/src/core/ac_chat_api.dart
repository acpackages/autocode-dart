import 'dart:async';
import 'ac_chat.dart';
import 'package:flutter/widgets.dart';

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
  final Widget? Function(BuildContext context, AcChatMessage message)? customMessageBuilder;
  final void Function(AcChatMessage message)? onMessageTap;

  /// Optional callback invoked when the user taps 'New Contact' in the new chat screen.
  /// Receives the [BuildContext] and can return a newly created [AcChatUser] to immediately start a chat.
  final FutureOr<AcChatUser?> Function(BuildContext context)? onNewContact;

  /// Optional callback invoked when the user taps 'New Group' in the new chat screen or menu.
  final FutureOr<void> Function(BuildContext context)? onNewGroup;

  /// Optional callback to retrieve the contact list for new chat creation.
  /// If not provided, [getUsers] is used.
  final List<AcChatUser> Function()? getContacts;

  /// Optional custom title for the contacts section in [NewChatScreen].
  final String? contactsSectionTitle;

  /// Optional custom label and subtitle for the new contact tile in [NewChatScreen].
  final String? newContactLabel;
  final String? newContactSubtitle;

  /// Optional custom label and subtitle for the new group tile in [NewChatScreen].
  final String? newGroupLabel;
  final String? newGroupSubtitle;

  /// When true, the standard send bar is hidden and users cannot compose
  /// new messages.  Use this for read-only views like a transaction log.
  final bool readOnly;

  // ── Feature flags / UI configuration ─────────────────────────────────────

  /// Show/hide the video-call icon button in the conversation app bar.
  /// Default: false.
  final bool enableVideoCall;

  /// Show/hide the voice-call icon button in the conversation app bar.
  /// Default: false.
  final bool enableVoiceCall;

  /// Show/hide the floating-action-button that starts a new conversation.
  /// Default: false.
  final bool showNewConversationButton;

  /// Show/hide the search input in the conversation list pane.
  /// Default: true.
  final bool searchConversations;

  /// Enable conversation-pinning UI (pin icon, pinned background highlight).
  /// Default: false.
  final bool pinConversations;

  /// Show/hide the ⋮ overflow menu in the conversation app bar.
  /// Default: true.
  final bool showConversationMenu;

  /// Show/hide the online-status indicator:
  ///   • green dot on avatar in the conversation list
  ///   • "Online" subtitle in the conversation header
  /// Default: true.
  final bool showOnlineStatus;

  /// Optional custom widget rendered at the bottom of a conversation in place
  /// of the standard [InputBar].
  ///
  /// Receives the current [BuildContext] and the active [AcChatConversation].
  /// Return a non-null [Widget] to override the default bar, or return `null`
  /// to fall back to the standard send bar (when [readOnly] is false).
  ///
  /// Example use: the Transactions screen injects an expense / income
  /// quick-entry form via this builder.
  final Widget? Function(BuildContext context, AcChatConversation conversation)? customInputBuilder;

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
    this.readOnly = false,
    // Feature flags
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
