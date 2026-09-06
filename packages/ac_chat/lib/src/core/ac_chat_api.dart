import 'dart:async';
import 'package:flutter/widgets.dart';
import 'ac_chat_config.dart';
import '../common/chat_colors.dart';
import '../media/ac_chat_media_uploader.dart';
import '../crypto/ac_chat_crypto_provider.dart';
import '../models/ac_chat_user.dart';
import '../models/ac_chat_conversation.dart';
import '../models/ac_chat_conversation_user.dart';
import '../models/ac_chat_message.dart';

/// The central strongly-typed API bridge for `ac_chat`.
///
/// Implemented by storage/transport providers (e.g. `AcChatSqlite`, `AcChatFirebase`)
/// to provide strongly-typed operations for all 12 chat domains.
abstract class AcChatApi {
  AcChatConfig get config;
  AcChatTheme get theme;

  // ── User & Identity ───────────────────────────────────────────────────────
  AcChatUser getCurrentUser();
  List<AcChatUser> getUsers();
  AcChatUser? getUserById({required String userId});
  Future<void> saveUserProfile({required AcChatUser user});
  Future<void> blockUser({required String userId});
  Future<void> unblockUser({required String userId});
  List<String> getBlockedUserIds();
  bool isUserBlocked({required String userId});
  Future<void> reportUser({required String userId, required String reason});
  Stream<bool>? watchUserOnlineStatus({required String userId});

  // ── Conversations ─────────────────────────────────────────────────────────
  List<AcChatConversation> getConversations();
  Stream<List<AcChatConversation>>? watchConversations();
  AcChatConversationUser? getConversationPrefs({required String conversationId});
  Future<void> updateConversationPrefs({required AcChatConversationUser prefs});
  List<AcChatConversationUser> getConversationUsers({required String conversationId});
  AcChatConversation insertConversation({
    required AcChatConversation newConv,
    required String otherUserId,
  });
  Future<void> pinConversation({required String conversationId, required bool isPinned});
  Future<void> archiveConversation({required String conversationId, required bool isArchived});
  Future<void> muteConversation({required String conversationId, Duration? muteDuration, bool? muted});
  Future<void> deleteConversation({required String conversationId});
  Future<void> hideConversation({required String conversationId, required bool isHidden});

  // ── Groups ────────────────────────────────────────────────────────────────
  Future<AcChatConversation> createGroupConversation({
    required String groupName,
    required List<String> memberUserIds,
    String? groupAvatar,
    String? groupDescription,
  });
  Future<void> addGroupMembers({required String conversationId, required List<String> userIds});
  Future<void> removeGroupMember({required String conversationId, required String userId});
  Future<void> updateGroupDetails({
    required String conversationId,
    String? groupName,
    String? groupAvatar,
    String? groupDescription,
  });
  Future<void> leaveGroup({required String conversationId});
  Future<String> getGroupInviteLink({required String conversationId});

  // ── Messaging ─────────────────────────────────────────────────────────────
  List<AcChatMessage> getMessages({required String conversationId});
  Stream<List<AcChatMessage>>? watchMessages({required String conversationId});
  void sendMessage({required AcChatMessage message});
  void updateMessage({required String messageId, required Map<String, dynamic> data});
  Future<void> editMessage({required String messageId, required String newText});
  Future<void> deleteMessageForMe({required String messageId});
  Future<void> deleteMessageForEveryone({required String messageId});
  Future<void> addReaction({required String messageId, required String emoji});
  Future<void> removeReaction({required String messageId, required String emoji});
  Future<void> setStarred({required String messageId, required bool isStarred});
  Future<void> pinMessage({required String messageId, required Duration? duration});
  Future<void> unpinMessage({required String messageId});
  void markAsRead({required String conversationId});
  void sendTypingIndicator({required String conversationId, required bool isTyping});
  Stream<Map<String, bool>>? watchTyping({required String conversationId});
  Future<void> forwardMessages({
    required List<String> messageIds,
    required String targetConversationId,
  });
  Future<void> deleteMessagesBatch({
    required List<String> messageIds,
    required bool forEveryone,
  });

  // ── Search ────────────────────────────────────────────────────────────────
  Future<List<AcChatMessage>> searchMessages({
    required String query,
    String? conversationId,
    String? senderId,
    DateTime? startDateUtc,
    DateTime? endDateUtc,
    bool? hasAttachment,
  });

  // ── Media & Providers ─────────────────────────────────────────────────────
  AcChatMediaUploader? get mediaUploader;
  AcChatCryptoProvider? get cryptoProvider;
  String? get dataDirectory;
  Future<String?> downloadMedia({required AcChatMessage message});

  // ── Export & Wipe ─────────────────────────────────────────────────────────
  Future<String> exportChat({required String conversationId, required bool asJson});
  Future<void> wipeAllData();

  // ── UI Customization & Builders ───────────────────────────────────────────
  Widget? Function({required BuildContext context, required AcChatMessage message})? get customMessageBuilder;
  void Function({required AcChatMessage message})? get onMessageTap;
  FutureOr<AcChatUser?> Function({required BuildContext context})? get onNewContact;
  FutureOr<void> Function({required BuildContext context})? get onNewGroup;
  List<AcChatUser> Function()? get getContacts;
  String? get contactsSectionTitle;
  String? get newContactLabel;
  String? get newContactSubtitle;
  String? get newGroupLabel;
  String? get newGroupSubtitle;
  FutureOr<List<AcChatUser>> Function({required String query})? get onSearchRemoteUsers;
  Widget? Function({required BuildContext context, required AcChatConversation conversation})? get customInputBuilder;

  // ── Convenience Feature Getters (forwarding to config) ────────────────────
  bool get enableGroups => config.enableGroupConversations;
  bool get enableStatus => config.enableStatus;
  bool get enableGroupsAndStatuses => config.enableStatus;
  bool get enableTyping => config.enableTextMessaging;
  bool get enableTypingIndicator => config.enableTypingIndicators;
  bool get pinConversations => config.enableConversationPinning;
  bool get searchConversations => config.enableConversationSearch;
  bool get showOnlineStatus => config.enableOnlinePresence;
  int get maxGroupParticipants => config.maxGroupParticipants;
  bool get readOnly => !config.enableTextMessaging;
  bool get enableVideoCall => false;
  bool get enableVoiceCall => false;
  bool get showNewConversationButton => true;
  bool get showConversationMenu => true;

  /// Factory constructor for building a delegate-based [AcChatApi] instance.
  factory AcChatApi({
    AcChatConfig config,
    required AcChatTheme theme,
    required AcChatUser Function() getCurrentUser,
    required List<AcChatUser> Function() getUsers,
    required AcChatUser? Function({required String userId}) getUserById,
    required List<AcChatConversation> Function() getConversations,
    required List<AcChatConversationUser> Function({required String conversationId}) getConversationUsers,
    required List<AcChatMessage> Function({required String conversationId}) getMessages,
    required void Function({required String conversationId}) markAsRead,
    required void Function({required AcChatMessage message}) sendMessage,
    required AcChatConversation Function({
      required AcChatConversation newConv,
      required String otherUserId,
    }) insertConversation,
    Stream<List<AcChatConversation>> Function()? watchConversations,
    Stream<List<AcChatMessage>> Function({required String conversationId})? watchMessages,
    Stream<Map<String, bool>> Function({required String conversationId})? watchTyping,
    Stream<bool> Function({required String userId})? watchUserOnlineStatus,
    Future<AcChatConversation> Function({
      required String groupName,
      required List<String> memberUserIds,
      String? groupAvatar,
    })? createGroupConversation,
    Future<void> Function({
      required String conversationId,
      required List<String> userIds,
    })? addGroupMembers,
    Future<void> Function({
      required String conversationId,
      required String userId,
    })? removeGroupMember,
    void Function({
      required String conversationId,
      required bool isTyping,
    })? sendTypingIndicator,
    Future<List<AcChatMessage>> Function({
      required String query,
      String? conversationId,
    })? searchMessages,
    void Function({
      required String messageId,
      required Map<String, dynamic> data,
    })? updateMessage,
    Future<void> Function({
      required String messageId,
      required String newText,
    })? onEditMessage,
    Future<void> Function({
      required String messageId,
      required bool forEveryone,
    })? onDeleteMessage,
    Future<void> Function({
      required String messageId,
      required String emoji,
    })? onAddReaction,
    AcChatMediaUploader? mediaUploader,
    AcChatCryptoProvider? cryptoProvider,
    String? dataDirectory,
    Widget? Function({required BuildContext context, required AcChatMessage message})? customMessageBuilder,
    void Function({required AcChatMessage message})? onMessageTap,
    FutureOr<AcChatUser?> Function({required BuildContext context})? onNewContact,
    FutureOr<void> Function({required BuildContext context})? onNewGroup,
    List<AcChatUser> Function()? getContacts,
    String? contactsSectionTitle,
    String? newContactLabel,
    String? newContactSubtitle,
    String? newGroupLabel,
    String? newGroupSubtitle,
    FutureOr<List<AcChatUser>> Function({required String query})? onSearchRemoteUsers,
    Widget? Function({
      required BuildContext context,
      required AcChatConversation conversation,
    })? customInputBuilder,
    bool? enableVideoCall,
    bool? enableVoiceCall,
    bool? showNewConversationButton,
    bool? searchConversations,
    bool? pinConversations,
    bool? showConversationMenu,
    bool? showOnlineStatus,
    bool? enableTypingIndicator,
    bool? enableTyping,
    bool? enableGroups,
    bool? enableStatus,
    bool? enableGroupsAndStatuses,
    int? maxGroupParticipants,
    bool? readOnly,
  }) = _DelegatedAcChatApi;
}

class _DelegatedAcChatApi implements AcChatApi {
  @override
  final AcChatConfig config;

  @override
  final AcChatTheme theme;

  final AcChatUser Function() _getCurrentUser;
  final List<AcChatUser> Function() _getUsers;
  final AcChatUser? Function({required String userId}) _getUserById;
  final List<AcChatConversation> Function() _getConversations;
  final List<AcChatConversationUser> Function({required String conversationId}) _getConversationUsers;
  final List<AcChatMessage> Function({required String conversationId}) _getMessages;
  final void Function({required String conversationId}) _markAsRead;
  final void Function({required AcChatMessage message}) _sendMessage;
  final AcChatConversation Function({
    required AcChatConversation newConv,
    required String otherUserId,
  }) _insertConversation;

  final Stream<List<AcChatConversation>> Function()? _watchConversations;
  final Stream<List<AcChatMessage>> Function({required String conversationId})? _watchMessages;
  final Stream<Map<String, bool>> Function({required String conversationId})? _watchTyping;
  final Stream<bool> Function({required String userId})? _watchUserOnlineStatus;
  final Future<AcChatConversation> Function({
    required String groupName,
    required List<String> memberUserIds,
    String? groupAvatar,
  })? _createGroupConversation;
  final Future<void> Function({
    required String conversationId,
    required List<String> userIds,
  })? _addGroupMembers;
  final Future<void> Function({
    required String conversationId,
    required String userId,
  })? _removeGroupMember;
  final void Function({
    required String conversationId,
    required bool isTyping,
  })? _sendTypingIndicator;
  final Future<List<AcChatMessage>> Function({
    required String query,
    String? conversationId,
  })? _searchMessages;
  final void Function({
    required String messageId,
    required Map<String, dynamic> data,
  })? _updateMessage;
  final Future<void> Function({
    required String messageId,
    required String newText,
  })? _onEditMessage;
  final Future<void> Function({
    required String messageId,
    required bool forEveryone,
  })? _onDeleteMessage;
  final Future<void> Function({
    required String messageId,
    required String emoji,
  })? _onAddReaction;

  @override
  final AcChatMediaUploader? mediaUploader;
  @override
  final AcChatCryptoProvider? cryptoProvider;
  @override
  final String? dataDirectory;
  @override
  final Widget? Function({required BuildContext context, required AcChatMessage message})? customMessageBuilder;
  @override
  final void Function({required AcChatMessage message})? onMessageTap;
  @override
  final FutureOr<AcChatUser?> Function({required BuildContext context})? onNewContact;
  @override
  final FutureOr<void> Function({required BuildContext context})? onNewGroup;
  @override
  final List<AcChatUser> Function()? getContacts;
  @override
  final String? contactsSectionTitle;
  @override
  final String? newContactLabel;
  @override
  final String? newContactSubtitle;
  @override
  final String? newGroupLabel;
  @override
  final String? newGroupSubtitle;
  @override
  final FutureOr<List<AcChatUser>> Function({required String query})? onSearchRemoteUsers;
  @override
  final Widget? Function({
    required BuildContext context,
    required AcChatConversation conversation,
  })? customInputBuilder;

  final Set<String> _blockedUsers = {};
  final Map<String, AcChatConversationUser> _prefs = {};
  final bool _enableTyping;
  final bool _readOnly;
  final bool _enableVideoCall;
  final bool _enableVoiceCall;
  final bool _showNewConversationButton;
  final bool _showConversationMenu;
  final bool _enableGroupsAndStatuses;

  _DelegatedAcChatApi({
    AcChatConfig? config,
    required this.theme,
    required AcChatUser Function() getCurrentUser,
    required List<AcChatUser> Function() getUsers,
    required AcChatUser? Function({required String userId}) getUserById,
    required List<AcChatConversation> Function() getConversations,
    required List<AcChatConversationUser> Function({required String conversationId}) getConversationUsers,
    required List<AcChatMessage> Function({required String conversationId}) getMessages,
    required void Function({required String conversationId}) markAsRead,
    required void Function({required AcChatMessage message}) sendMessage,
    required AcChatConversation Function({
      required AcChatConversation newConv,
      required String otherUserId,
    }) insertConversation,
    Stream<List<AcChatConversation>> Function()? watchConversations,
    Stream<List<AcChatMessage>> Function({required String conversationId})? watchMessages,
    Stream<Map<String, bool>> Function({required String conversationId})? watchTyping,
    Stream<bool> Function({required String userId})? watchUserOnlineStatus,
    Future<AcChatConversation> Function({
      required String groupName,
      required List<String> memberUserIds,
      String? groupAvatar,
    })? createGroupConversation,
    Future<void> Function({
      required String conversationId,
      required List<String> userIds,
    })? addGroupMembers,
    Future<void> Function({
      required String conversationId,
      required String userId,
    })? removeGroupMember,
    void Function({
      required String conversationId,
      required bool isTyping,
    })? sendTypingIndicator,
    Future<List<AcChatMessage>> Function({
      required String query,
      String? conversationId,
    })? searchMessages,
    void Function({
      required String messageId,
      required Map<String, dynamic> data,
    })? updateMessage,
    Future<void> Function({
      required String messageId,
      required String newText,
    })? onEditMessage,
    Future<void> Function({
      required String messageId,
      required bool forEveryone,
    })? onDeleteMessage,
    Future<void> Function({
      required String messageId,
      required String emoji,
    })? onAddReaction,
    this.mediaUploader,
    this.cryptoProvider,
    this.dataDirectory,
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
    this.customInputBuilder,
    bool? enableVideoCall,
    bool? enableVoiceCall,
    bool? showNewConversationButton,
    bool? searchConversations,
    bool? pinConversations,
    bool? showConversationMenu,
    bool? showOnlineStatus,
    bool? enableTypingIndicator,
    bool? enableTyping,
    bool? enableGroups,
    bool? enableStatus,
    bool? enableGroupsAndStatuses,
    int? maxGroupParticipants,
    bool? readOnly,
  })  : _getCurrentUser = getCurrentUser,
        _getUsers = getUsers,
        _getUserById = getUserById,
        _getConversations = getConversations,
        _getConversationUsers = getConversationUsers,
        _getMessages = getMessages,
        _markAsRead = markAsRead,
        _sendMessage = sendMessage,
        _insertConversation = insertConversation,
        _watchConversations = watchConversations,
        _watchMessages = watchMessages,
        _watchTyping = watchTyping,
        _watchUserOnlineStatus = watchUserOnlineStatus,
        _createGroupConversation = createGroupConversation,
        _addGroupMembers = addGroupMembers,
        _removeGroupMember = removeGroupMember,
        _sendTypingIndicator = sendTypingIndicator,
        _searchMessages = searchMessages,
        _updateMessage = updateMessage,
        _onEditMessage = onEditMessage,
        _onDeleteMessage = onDeleteMessage,
        _onAddReaction = onAddReaction,
        _enableTyping = enableTyping ?? true,
        _readOnly = readOnly ?? false,
        _enableVideoCall = enableVideoCall ?? false,
        _enableVoiceCall = enableVoiceCall ?? false,
        _showNewConversationButton = showNewConversationButton ?? true,
        _showConversationMenu = showConversationMenu ?? true,
        _enableGroupsAndStatuses = enableGroupsAndStatuses ?? true,
        config = config ??
            AcChatConfig(
              enableTypingIndicators: enableTypingIndicator ?? true,
              enableTextMessaging: !(readOnly ?? false),
              enableGroupConversations: enableGroups ?? true,
              enableStatus: enableStatus ?? (enableGroupsAndStatuses ?? false),
              maxGroupParticipants: maxGroupParticipants ?? 50,
              enableConversationPinning: pinConversations ?? true,
              enableConversationSearch: searchConversations ?? true,
              enableOnlinePresence: showOnlineStatus ?? true,
            );

  @override
  bool get enableGroups => config.enableGroupConversations;
  @override
  bool get enableStatus => config.enableStatus;
  @override
  bool get enableGroupsAndStatuses => _enableGroupsAndStatuses && config.enableStatus;
  @override
  bool get enableTyping => _enableTyping;
  @override
  bool get enableTypingIndicator => config.enableTypingIndicators;
  @override
  bool get pinConversations => config.enableConversationPinning;
  @override
  bool get searchConversations => config.enableConversationSearch;
  @override
  bool get showOnlineStatus => config.enableOnlinePresence;
  @override
  int get maxGroupParticipants => config.maxGroupParticipants;
  @override
  bool get readOnly => _readOnly;
  @override
  bool get enableVideoCall => _enableVideoCall;
  @override
  bool get enableVoiceCall => _enableVoiceCall;
  @override
  bool get showNewConversationButton => _showNewConversationButton;
  @override
  bool get showConversationMenu => _showConversationMenu;

  @override
  AcChatUser getCurrentUser() => _getCurrentUser();

  @override
  List<AcChatUser> getUsers() => _getUsers();

  @override
  AcChatUser? getUserById({required String userId}) => _getUserById(userId: userId);

  @override
  Future<void> saveUserProfile({required AcChatUser user}) async {}

  @override
  Future<void> blockUser({required String userId}) async {
    _blockedUsers.add(userId);
  }

  @override
  Future<void> unblockUser({required String userId}) async {
    _blockedUsers.remove(userId);
  }

  @override
  List<String> getBlockedUserIds() => _blockedUsers.toList();

  @override
  bool isUserBlocked({required String userId}) => _blockedUsers.contains(userId);

  @override
  Future<void> reportUser({required String userId, required String reason}) async {}

  @override
  Stream<bool>? watchUserOnlineStatus({required String userId}) =>
      config.enableOnlinePresence ? _watchUserOnlineStatus?.call(userId: userId) : null;

  @override
  List<AcChatConversation> getConversations() => _getConversations();

  @override
  Stream<List<AcChatConversation>>? watchConversations() => _watchConversations?.call();

  @override
  AcChatConversationUser? getConversationPrefs({required String conversationId}) =>
      _prefs[conversationId];

  @override
  Future<void> updateConversationPrefs({required AcChatConversationUser prefs}) async {
    _prefs[prefs.conversationId] = prefs;
  }

  @override
  List<AcChatConversationUser> getConversationUsers({required String conversationId}) =>
      _getConversationUsers(conversationId: conversationId);

  @override
  AcChatConversation insertConversation({
    required AcChatConversation newConv,
    required String otherUserId,
  }) =>
      _insertConversation(newConv: newConv, otherUserId: otherUserId);

  @override
  Future<void> pinConversation({required String conversationId, required bool isPinned}) async {
    final p = _prefs.putIfAbsent(
      conversationId,
      () => AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = getCurrentUser().userId,
    );
    p.isPinned = isPinned;
  }

  @override
  Future<void> archiveConversation({required String conversationId, required bool isArchived}) async {
    final p = _prefs.putIfAbsent(
      conversationId,
      () => AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = getCurrentUser().userId,
    );
    p.isArchived = isArchived;
  }

  @override
  Future<void> muteConversation({required String conversationId, Duration? muteDuration, bool? muted}) async {
    final p = _prefs.putIfAbsent(
      conversationId,
      () => AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = getCurrentUser().userId,
    );
    if (muted != null) {
      p.isMuted = muted;
      p.muteUntilUtc = muted ? DateTime.now().toUtc().add(const Duration(days: 3650)) : null;
    } else {
      p.isMuted = muteDuration != null;
      p.muteUntilUtc = muteDuration != null ? DateTime.now().toUtc().add(muteDuration) : null;
    }
  }

  @override
  Future<void> deleteConversation({required String conversationId}) async {}

  @override
  Future<void> hideConversation({required String conversationId, required bool isHidden}) async {
    final p = _prefs.putIfAbsent(
      conversationId,
      () => AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = getCurrentUser().userId,
    );
    p.isHidden = isHidden;
  }

  @override
  Future<AcChatConversation> createGroupConversation({
    required String groupName,
    required List<String> memberUserIds,
    String? groupAvatar,
    String? groupDescription,
  }) async {
    if (_createGroupConversation != null) {
      return await _createGroupConversation(
        groupName: groupName,
        memberUserIds: memberUserIds,
        groupAvatar: groupAvatar,
      );
    }
    return AcChatConversation()
      ..type = 'group'
      ..conversationName = groupName
      ..memberIds = memberUserIds;
  }

  @override
  Future<void> addGroupMembers({required String conversationId, required List<String> userIds}) async {
    if (_addGroupMembers != null) {
      await _addGroupMembers(conversationId: conversationId, userIds: userIds);
    }
  }

  @override
  Future<void> removeGroupMember({required String conversationId, required String userId}) async {
    if (_removeGroupMember != null) {
      await _removeGroupMember(conversationId: conversationId, userId: userId);
    }
  }

  @override
  Future<void> updateGroupDetails({
    required String conversationId,
    String? groupName,
    String? groupAvatar,
    String? groupDescription,
  }) async {}

  @override
  Future<void> leaveGroup({required String conversationId}) async {
    await removeGroupMember(conversationId: conversationId, userId: getCurrentUser().userId);
  }

  @override
  Future<String> getGroupInviteLink({required String conversationId}) async =>
      'https://chat.example.com/join/$conversationId';

  @override
  List<AcChatMessage> getMessages({required String conversationId}) =>
      _getMessages(conversationId: conversationId);

  @override
  Stream<List<AcChatMessage>>? watchMessages({required String conversationId}) =>
      _watchMessages?.call(conversationId: conversationId);

  @override
  void sendMessage({required AcChatMessage message}) {
    if (!config.enableTextMessaging && message.type == 'text') return;
    if (!config.enableMediaAttachments && message.type != 'text' && message.type != 'system') return;
    _sendMessage(message: message);
  }

  @override
  void updateMessage({required String messageId, required Map<String, dynamic> data}) {
    _updateMessage?.call(messageId: messageId, data: data);
  }

  @override
  Future<void> editMessage({required String messageId, required String newText}) async {
    if (!config.enableMessageEditing) return;
    if (_onEditMessage != null) {
      await _onEditMessage(messageId: messageId, newText: newText);
    } else {
      _updateMessage?.call(messageId: messageId, data: {'text': newText, 'isEdited': true});
    }
  }

  @override
  Future<void> deleteMessageForMe({required String messageId}) async {
    if (!config.enableMessageDeletingForMe) return;
    if (_onDeleteMessage != null) {
      await _onDeleteMessage(messageId: messageId, forEveryone: false);
    }
  }

  @override
  Future<void> deleteMessageForEveryone({required String messageId}) async {
    if (!config.enableMessageDeletingForEveryone) return;
    if (_onDeleteMessage != null) {
      await _onDeleteMessage(messageId: messageId, forEveryone: true);
    } else {
      _updateMessage?.call(messageId: messageId, data: {'isDeleted': true, 'text': ''});
    }
  }

  @override
  Future<void> addReaction({required String messageId, required String emoji}) async {
    if (!config.enableMessageReactions) return;
    if (_onAddReaction != null) {
      await _onAddReaction(messageId: messageId, emoji: emoji);
    }
  }

  @override
  Future<void> removeReaction({required String messageId, required String emoji}) async {
    if (!config.enableMessageReactions) return;
  }

  @override
  Future<void> setStarred({required String messageId, required bool isStarred}) async {
    if (!config.enableStarredMessages) return;
    _updateMessage?.call(messageId: messageId, data: {'isStarred': isStarred});
  }

  @override
  Future<void> pinMessage({required String messageId, Duration? duration}) async {
    if (!config.enablePinnedMessages) return;
  }

  @override
  Future<void> unpinMessage({required String messageId}) async {
    if (!config.enablePinnedMessages) return;
  }

  @override
  void markAsRead({required String conversationId}) {
    if (!config.enableReadReceipts) return;
    _markAsRead(conversationId: conversationId);
  }

  @override
  void sendTypingIndicator({required String conversationId, required bool isTyping}) {
    if (!config.enableTypingIndicators) return;
    _sendTypingIndicator?.call(conversationId: conversationId, isTyping: isTyping);
  }

  @override
  Stream<Map<String, bool>>? watchTyping({required String conversationId}) =>
      config.enableTypingIndicators ? _watchTyping?.call(conversationId: conversationId) : null;

  @override
  Future<void> forwardMessages({
    required List<String> messageIds,
    required String targetConversationId,
  }) async {
    if (!config.enableMessageForwarding) return;
  }

  @override
  Future<void> deleteMessagesBatch({
    required List<String> messageIds,
    required bool forEveryone,
  }) async {
    for (final id in messageIds) {
      if (forEveryone) {
        await deleteMessageForEveryone(messageId: id);
      } else {
        await deleteMessageForMe(messageId: id);
      }
    }
  }

  @override
  Future<List<AcChatMessage>> searchMessages({
    required String query,
    String? conversationId,
    String? senderId,
    DateTime? startDateUtc,
    DateTime? endDateUtc,
    bool? hasAttachment,
  }) async {
    if (!config.enableMessageFullTextSearch && !config.enableInChatSearch) {
      return [];
    }
    if (_searchMessages != null) {
      return await _searchMessages(query: query, conversationId: conversationId);
    }
    return [];
  }

  @override
  Future<String?> downloadMedia({required AcChatMessage message}) async => message.localPath;

  @override
  Future<String> exportChat({required String conversationId, required bool asJson}) async => '';

  @override
  Future<void> wipeAllData() async {}
}
