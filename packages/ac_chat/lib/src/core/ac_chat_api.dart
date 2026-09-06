import 'dart:async';
import 'dart:core';
import 'package:flutter/widgets.dart';
import '../../ac_chat.dart';

/// The central strongly-typed API bridge for `ac_chat`.
///
/// Implemented by storage/transport providers (e.g. `AcChatSqlite`, `AcChatFirebase`)
/// to provide strongly-typed operations for all 12 chat domains.
class AcChatApi {
  // AcChatApi config;
  AcChatTheme theme = AcChatTheme();

  AcChatMediaUploader? mediaUploader;
  AcChatCryptoProvider? cryptoProvider;
  AcChatConnectivityProvider? connectivityProvider;
  AcChatSyncChannel? channel;
  AcChat? cl;

  String dataDirectory = 'chat_data';

  // User & Identity
  bool enableOnlinePresence = true;
  bool enableLastSeen = true;
  bool enableUserProfileEditing = true;
  bool enableUserBlocking = false;

  // Conversations
  bool enableCreateNewContact = false;
  bool enableOneToOneConversations = true;
  bool enableGroupConversations = true;
  bool enableConversationPinning = true;
  bool enableConversationArchiving = true;
  bool enableConversationMuting = true;
  bool enableConversationDeletion = true;
  bool enableConversationHiding = true;
  bool enableConversationBlocking = false;
  bool enableConversationReporting = false;

  // Messaging
  bool isEndToEndEncrypted = false;
  bool enableTextMessaging = true;
  bool enableDeliveryReceipts = true;
  bool enableReadReceipts = true;
  bool enableMessageReplying = true;
  bool enableMessageForwarding = true;
  bool enableMessageEditing = true;
  bool enableMessageDeletingForMe = true;
  bool enableMessageDeletingForEveryone = true;
  bool enableMessageCopying = true;
  bool enableMessageStarring = false;
  bool enableStarredMessages = true;
  bool enableMessageReactions = true;

  // Attachments
  bool enableMediaAttachments = true;
  bool enableImageAttachments = true;
  bool enableLocationAttachments = false;
  bool enableLiveLocationAttachments = false;
  bool enableContactAttachments = false;
  bool enableVideoAttachments = true;
  bool enableDocumentAttachments = true;
  bool enableVoiceNotes = true;
  bool enableMediaAutoDownload = true;
  bool autoDownloadImages = true;
  bool autoDownloadVideos = false;
  bool autoDownloadDocuments = true;
  bool autoDownloadAudio = true;
  bool enableStatuses = false;
  bool enableMediaViewer = true;
  int maxAttachmentSizeBytes = 52428800; // 50 MB

  // Message interaction
  bool enableMentions = true;
  bool enableMultiSelect = true;
  bool enableBatchForwarding = true;
  bool enableBatchDeletion = true;
  bool enableBatchCopy = true;
  bool enableMessageSharing = true;
  bool enableInChatSearch = true;

  // Notifications
  bool enablePushNotifications = true;
  bool enableForegroundNotificationSuppression = true;
  bool enableMentionNotifications = true;
  bool enableBadgeCountSync = true;

  // Offline / synchronization
  bool enableOfflineCaching = true;
  bool enableOfflineOutbox = true;
  bool enableDeltaSync = true;
  int outboxMaxRetries = 5;
  Duration outboxRetryInterval = const Duration(seconds: 10);

  // Search
  bool enableConversationSearch = true;
  bool enableMessageFullTextSearch = true;
  bool enableSearchFilters = true;

  // Groups
  bool enableGroups = false;
  bool enableGroupAdminRoles = true;
  bool enableGroupMemberAddRemove = true;
  bool enableGroupMemberPermissions = true;
  bool enableGroupDetailsEditing = true;
  bool enableGroupLeave = true;
  bool enableGroupInviteLinks = true;
  bool enableGroupSystemMessages = true;
  int maxGroupParticipants = 256;

  // Security / privacy
  bool enableMessageOwnershipEnforcement = true;
  bool enableBlockedUserRestrictions = true;
  bool enableDataDeletionWipe = true;

  // UI / UX
  bool enableLazyLoadingPagination = true;
  bool enableStickyDateHeaders = true;
  bool enableUnreadMessagesSeparator = true;
  bool enableTypingIndicator = true;
  bool enableTyping = true;
  bool enableScrollToLatestFab = true;
  int messagesPageSize = 40;

  // Advanced
  bool enablePinnedMessages = true;
  bool enableSharedMediaGallery = true;
  bool enableChatExport = true;
  bool enableDisappearingMessages = false;
  bool enableMessageScheduling = false;
  bool enableBroadcastMessages = false;
  bool enableUserReporting = false;

  // Policies
  Duration editTimeWindow = const Duration(minutes: 15);
  Duration deleteForEveryoneWindow = const Duration(hours: 24);

  bool readOnly = false;
  bool enableVideoCall = false;
  bool enableVoiceCall = false;
  bool showNewConversationButton = true;
  bool showConversationMenu = false;

  // ── UI Customization & Builders ───────────────────────────────────────────
  Widget? Function(
      {required BuildContext context,
      required AcChatMessage message})? customMessageBuilder;
  void Function({required AcChatMessage message})? onMessageTap;
  FutureOr<AcChatUser?> Function({required BuildContext context})? onNewContact;
  FutureOr<void> Function({required BuildContext context})? onNewGroup;
  List<AcChatUser> Function()? getContacts;
  String? contactsSectionTitle;
  String? newContactLabel;
  String? newContactSubtitle;
  String? newGroupLabel;
  String? newGroupSubtitle;
  FutureOr<List<AcChatUser>> Function({required String query})?
      onSearchRemoteUsers;
  Widget? Function(
      {required BuildContext context,
      required AcChatConversation conversation})? customInputBuilder;

  AcChatApi({
    this.theme = const AcChatTheme(),
    this.mediaUploader,
    this.cryptoProvider,
    this.connectivityProvider,
    this.channel,
    this.dataDirectory = "chat",

    // User & Identity
    this.enableOnlinePresence = true,
    this.enableLastSeen = true,
    this.enableUserProfileEditing = true,
    this.enableUserBlocking = false,

    // Conversations
    this.enableCreateNewContact = false,
    this.enableOneToOneConversations = true,
    this.enableGroupConversations = true,
    this.enableConversationPinning = true,
    this.enableConversationArchiving = true,
    this.enableConversationMuting = true,
    this.enableConversationDeletion = true,
    this.enableConversationHiding = true,
    this.enableConversationBlocking = false,
    this.enableConversationReporting = false,

    // Messaging
    this.isEndToEndEncrypted = false,
    this.enableTextMessaging = true,
    this.enableDeliveryReceipts = true,
    this.enableReadReceipts = true,
    this.enableMessageReplying = true,
    this.enableMessageForwarding = true,
    this.enableMessageEditing = true,
    this.enableMessageDeletingForMe = true,
    this.enableMessageDeletingForEveryone = true,
    this.enableMessageCopying = true,
    this.enableMessageStarring = false,
    this.enableStarredMessages = true,
    this.enableMessageReactions = true,

    // Attachments
    this.enableMediaAttachments = true,
    this.enableImageAttachments = true,
    this.enableLocationAttachments = false,
    this.enableLiveLocationAttachments = false,
    this.enableContactAttachments = false,
    this.enableVideoAttachments = true,
    this.enableDocumentAttachments = true,
    this.enableVoiceNotes = true,
    this.enableMediaAutoDownload = true,
    this.autoDownloadImages = true,
    this.autoDownloadVideos = false,
    this.autoDownloadDocuments = true,
    this.autoDownloadAudio = true,
    this.enableStatuses = false,
    this.enableMediaViewer = true,
    this.maxAttachmentSizeBytes = 52428800,

    // Message interaction
    this.enableMentions = true,
    this.enableMultiSelect = true,
    this.enableBatchForwarding = true,
    this.enableBatchDeletion = true,
    this.enableBatchCopy = true,
    this.enableMessageSharing = true,
    this.enableInChatSearch = true,

    // Notifications
    this.enablePushNotifications = true,
    this.enableForegroundNotificationSuppression = true,
    this.enableMentionNotifications = true,
    this.enableBadgeCountSync = true,

    // Offline / synchronization
    this.enableOfflineCaching = true,
    this.enableOfflineOutbox = true,
    this.enableDeltaSync = true,
    this.outboxMaxRetries = 5,
    this.outboxRetryInterval = const Duration(seconds: 10),

    // Search
    this.enableConversationSearch = true,
    this.enableMessageFullTextSearch = true,
    this.enableSearchFilters = true,

    // Groups
    this.enableGroups = false,
    this.enableGroupAdminRoles = true,
    this.enableGroupMemberAddRemove = true,
    this.enableGroupMemberPermissions = true,
    this.enableGroupDetailsEditing = true,
    this.enableGroupLeave = true,
    this.enableGroupInviteLinks = true,
    this.enableGroupSystemMessages = true,
    this.maxGroupParticipants = 50,

    // Security / privacy
    this.enableMessageOwnershipEnforcement = true,
    this.enableBlockedUserRestrictions = true,
    this.enableDataDeletionWipe = true,

    // UI / UX
    this.enableLazyLoadingPagination = true,
    this.enableStickyDateHeaders = true,
    this.enableUnreadMessagesSeparator = true,
    this.enableTypingIndicator = true,
    this.enableTyping = true,
    this.enableScrollToLatestFab = true,
    this.messagesPageSize = 50,

    // Advanced
    this.enablePinnedMessages = true,
    this.enableSharedMediaGallery = true,
    this.enableChatExport = true,
    this.enableDisappearingMessages = false,
    this.enableMessageScheduling = false,
    this.enableBroadcastMessages = false,
    this.enableUserReporting = false,

    // Policies
    this.editTimeWindow = const Duration(minutes: 15),
    this.deleteForEveryoneWindow = const Duration(hours: 24),
    this.readOnly = false,
    this.enableVideoCall = false,
    this.enableVoiceCall = false,
    this.showNewConversationButton = true,
    this.showConversationMenu = false,
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

    this.getCurrentUser = _getCurrentUser,
    this.getUsers = _getUsers,
    this.getUserById = _getUserById,
    this.saveUserProfile = _saveUserProfile,
    this.blockUser = _blockUser,
    this.unblockUser = _unblockUser,
    this.getBlockedUserIds = _getBlockedUserIds,
    this.isUserBlocked = _isUserBlocked,
    this.reportUser = _reportUser,
    this.watchUserOnlineStatus = _watchUserOnlineStatus,
    // ── Conversations ─────────────────────────────────────────────────────────
    this.getConversations = _getConversations,
    this.watchConversations = _watchConversations,
    this.getConversationPrefs = _getConversationPrefs,
    this.updateConversationPrefs = _updateConversationPrefs,
    this.getConversationUsers = _getConversationUsers,
    this.insertConversation = _insertConversation,
    this.pinConversation = _pinConversation,
    this.archiveConversation = _archiveConversation,
    this.muteConversation = _muteConversation,
    this.deleteConversation = _deleteConversation,
    this.hideConversation = _hideConversation,
    // ── Groups ────────────────────────────────────────────────────────────────
    this.createGroupConversation = _createGroupConversation,
    this.addGroupMembers = _addGroupMembers,
    this.removeGroupMember = _removeGroupMember,
    this.updateGroupDetails = _updateGroupDetails,
    this.leaveGroup = _leaveGroup,
    this.getGroupInviteLink = _getGroupInviteLink,
    // ── Messaging ─────────────────────────────────────────────────────────────
    this.getMessages = _getMessages,
    this.watchMessages = _watchMessages,
    this.sendMessage = _sendMessage,
    this.updateMessage = _updateMessage,
    this.editMessage = _editMessage,
    this.deleteMessageForMe = _deleteMessageForMe,
    this.deleteMessageForEveryone = _deleteMessageForEveryone,
    this.addReaction = _addReaction,
    this.removeReaction = _removeReaction,
    this.setStarred = _setStarred,
    this.pinMessage = _pinMessage,
    this.unpinMessage = _unpinMessage,
    this.markAsRead = _markAsRead,
    this.sendTypingIndicator = _sendTypingIndicator,
    this.watchTyping = _watchTyping,
    this.forwardMessages = _forwardMessages,
    this.deleteMessagesBatch = _deleteMessagesBatch,
    // ── Search ────────────────────────────────────────────────────────────────
    this.searchMessages = _searchMessages,
    this.downloadMedia = _downloadMedia,
    this.exportChat = _exportChat,
    this.wipeAllData = _wipeAllData,
    // this.insertConversation = _insertConversation,
    // this.watchConversations = _watchConversations,
    // this.watchUserOnlineStatus = _watchUserOnlineStatus,
    // this.createGroupConversation = _createGroupConversation,
    // this.addGroupMembers = _addGroupMembers,
    // this.removeGroupMember = _removeGroupMember,
    // this.onEditMessage,
    // this.onDeleteMessage,
    // this.onAddReaction,
    // this.searchConversations,
    // this.pinConversations,
    // this.showOnlineStatus,
  }) {
  }



  late Future<AcChatUser> Function() getCurrentUser;
  late Future<List<AcChatUser>> Function() getUsers;
  late Future<AcChatUser?> Function({required String userId}) getUserById;
  late Future<void> Function({required AcChatUser user}) saveUserProfile;
  late Future<void> Function({required String userId}) blockUser;
  late Future<void> Function({required String userId}) unblockUser;
  late Future<List<String>> Function() getBlockedUserIds;
  late Future<bool> Function({required String userId}) isUserBlocked;
  late Future<void> Function({required String userId, required String reason}) reportUser;
  late Future<Stream<bool>?> Function({required String userId}) watchUserOnlineStatus;
  // ── Conversations ─────────────────────────────────────────────────────────
  late Future<List<AcChatConversation>> Function() getConversations;
  late Future<Stream<List<AcChatConversation>>?> Function() watchConversations;
  late Future<AcChatConversationUser?> Function({required String conversationId}) getConversationPrefs;
  late Future<void> Function({required AcChatConversationUser prefs}) updateConversationPrefs;
  late Future<List<AcChatConversationUser>> Function({required String conversationId}) getConversationUsers;
  late Future<AcChatConversation> Function({required AcChatConversation newConversation,required String otherUserId}) insertConversation;
  late Future<void> Function({required String conversationId, required bool isPinned}) pinConversation;
  late Future<void> Function({required String conversationId, required bool isArchived}) archiveConversation;
  late Future<void> Function({required String conversationId,Duration? muteDuration,bool? muted}) muteConversation;
  late Future<void> Function({required String conversationId}) deleteConversation;
  late Future<void> Function({required String conversationId, required bool isHidden}) hideConversation;
  // ── Groups ────────────────────────────────────────────────────────────────
  late Future<AcChatConversation> Function({required String groupName,required List<String> memberUserIds,String? groupAvatar,String? groupDescription}) createGroupConversation;
  late Future<void> Function({required String conversationId, required List<String> userIds}) addGroupMembers;
  late Future<void> Function({required String conversationId, required String userId}) removeGroupMember;
  late Future<void> Function({required String conversationId,String? groupName,String? groupAvatar,String? groupDescription,}) updateGroupDetails;
  late Future<void> Function({required String conversationId}) leaveGroup;
  late Future<String> Function({required String conversationId}) getGroupInviteLink;
  // ── Messaging ─────────────────────────────────────────────────────────────
  late Future<List<AcChatMessage>> Function({required String conversationId}) getMessages;
  late Future<Stream<List<AcChatMessage>>?> Function({required String conversationId}) watchMessages;
  late Future<void> Function({required AcChatMessage message}) sendMessage;
  late Future<void> Function({required String messageId, required Map<String, dynamic> data}) updateMessage;
  late Future<void> Function({required String messageId, required String newText}) editMessage;
  late Future<void> Function({required String messageId}) deleteMessageForMe;
  late Future<void> Function({required String messageId}) deleteMessageForEveryone;
  late Future<void> Function({required String messageId, required String emoji}) addReaction;
  late Future<void> Function({required String messageId, required String emoji}) removeReaction;
  late Future<void> Function({required String messageId, required bool isStarred}) setStarred;
  late Future<void> Function({required String messageId, required Duration? duration}) pinMessage;
  late Future<void> Function({required String messageId}) unpinMessage;
  late Future<void> Function({required String conversationId}) markAsRead;
  late Future<void> Function({required String conversationId, required bool isTyping}) sendTypingIndicator;
  late Future<Stream<Map<String, bool>>?> Function({required String conversationId}) watchTyping;
  late Future<void> Function({required List<String> messageIds,required String targetConversationId}) forwardMessages;
  late Future<void> Function({required List<String> messageIds,required bool forEveryone}) deleteMessagesBatch;
  // ── Search ────────────────────────────────────────────────────────────────
  late Future<List<AcChatMessage>>  Function({required String query,String? conversationId, String? senderId, DateTime? startDateUtc, DateTime? endDateUtc,bool? hasAttachment, }) searchMessages;
  late Future<String?> Function({required AcChatMessage message}) downloadMedia;
  // ── Export & Wipe ─────────────────────────────────────────────────────────
  late Future<String>  Function({required String conversationId, required bool asJson}) exportChat;
  late Future<void> Function() wipeAllData;

  static Future<AcChatUser> _getCurrentUser() async {
    return AcChatUser();
  }
  static Future<List<AcChatUser>> _getUsers () async {
    return [];
  }
  static Future<AcChatUser?> _getUserById({required String userId}) async {
    return null;
  }
  static Future<void> _saveUserProfile({required AcChatUser user}) async {}
  static Future<void> _blockUser({required String userId}) async {}
  static Future<void> _unblockUser({required String userId}) async {}
  static Future<List<String>> _getBlockedUserIds() async {
    return [];
  }
  static Future<bool> _isUserBlocked({required String userId}) async {
    return false;
  }
  static Future<void> _reportUser(
      {required String userId, required String reason}) async {}
  static Future<Stream<bool>?> _watchUserOnlineStatus({required String userId}) async {
    return null;
  }
  // ── Conversations ─────────────────────────────────────────────────────────
  static Future<List<AcChatConversation>> _getConversations() async {
    return [];
  }
  static Future<Stream<List<AcChatConversation>>?> _watchConversations() async {
    return null;
  }
  static Future<AcChatConversationUser?> _getConversationPrefs({required String conversationId}) async {
    return null;
  }
  static Future<void> _updateConversationPrefs({required AcChatConversationUser prefs}) async {}
  static Future<List<AcChatConversationUser>> _getConversationUsers({required String conversationId}) async {
    return [];
  }
  static Future<AcChatConversation> _insertConversation({required AcChatConversation newConversation,required String otherUserId}) async {return newConversation;}
  static Future<void> _pinConversation(
      {required String conversationId, required bool isPinned}) async {}
  static Future<void> _archiveConversation(
      {required String conversationId, required bool isArchived}) async {}
  static Future<void> _muteConversation(
      {required String conversationId,
        Duration? muteDuration,
        bool? muted}) async {}
  static Future<void> _deleteConversation({required String conversationId}) async {}
  static Future<void> _hideConversation(
      {required String conversationId, required bool isHidden}) async {}
  // ── Groups ────────────────────────────────────────────────────────────────
  static Future<AcChatConversation> _createGroupConversation({
    required String groupName,
    required List<String> memberUserIds,
    String? groupAvatar,
    String? groupDescription,
  }) async {return AcChatConversation();}
  static Future<void> _addGroupMembers(
      {required String conversationId, required List<String> userIds}) async {}
  static Future<void> _removeGroupMember(
      {required String conversationId, required String userId}) async {}
  static Future<void> _updateGroupDetails({
    required String conversationId,
    String? groupName,
    String? groupAvatar,
    String? groupDescription,
  }) async {}
  static Future<void> _leaveGroup({required String conversationId}) async {}
  static Future<String> _getGroupInviteLink({required String conversationId}) async {
    return "";
  }
  // ── Messaging ─────────────────────────────────────────────────────────────
  static Future<List<AcChatMessage>> _getMessages({required String conversationId}) async {
    return [];
  }
  static Future<Stream<List<AcChatMessage>>?> _watchMessages({required String conversationId}) async {
    return null;
  }
  static Future<void> _sendMessage({required AcChatMessage message}) async {}
  static Future<void> _updateMessage(
      {required String messageId, required Map<String, dynamic> data}) async {}
  static Future<void> _editMessage({required String messageId, required String newText}) async {}
  static Future<void> _deleteMessageForMe({required String messageId}) async {}
  static Future<void> _deleteMessageForEveryone({required String messageId}) async {}
  static Future<void> _addReaction({required String messageId, required String emoji}) async {}
  static Future<void> _markAsRead({required String conversationId}) async{}
  static Future<void> _removeReaction({required String messageId, required String emoji}) async {}
  static Future<void> _setStarred({required String messageId, required bool isStarred}) async {}
  static Future<void> _pinMessage({required String messageId, required Duration? duration}) async {}
  static Future<void> _unpinMessage({required String messageId}) async {}
  static Future<void>  _sendTypingIndicator({required String conversationId, required bool isTyping}) async {}
  static Future<Stream<Map<String, bool>>?> _watchTyping({required String conversationId}) async {return null;}
  static Future<void> _forwardMessages({required List<String> messageIds,required String targetConversationId,}) async {}
  static Future<void> _deleteMessagesBatch({required List<String> messageIds,required bool forEveryone,}) async {}
  // ── Search ────────────────────────────────────────────────────────────────
  static Future<List<AcChatMessage>> _searchMessages({required String query,String? conversationId,String? senderId,DateTime? startDateUtc,DateTime? endDateUtc,bool? hasAttachment,}) async {return [];}
  static Future<String?> _downloadMedia({required AcChatMessage message}) async {return "";}
  // ── Export & Wipe ─────────────────────────────────────────────────────────
  static Future<String> _exportChat({required String conversationId, required bool asJson}) async {return "";}
  static Future<void> _wipeAllData() async {}
}
