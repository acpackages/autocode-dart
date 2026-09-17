import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:autocode/autocode.dart';

import '../../ac_chat_core.dart';

/// The central strongly-typed API bridge for `ac_chat`.
///
/// Implemented by storage/transport providers (e.g. `AcChatSqlite`, `AcChatFirebase`)
/// to provide strongly-typed operations for all 12 chat domains.
///
/// Flutter-specific fields (theme, customMessageBuilder, customInputBuilder,
/// onNewContact, onNewGroup) live on the `AcChat` widget in the `ac_chat` package.
class AcChatApi {
  /// The visual theme for the chat UI.
  ///
  /// Typed as [dynamic] to keep [AcChatApi] Flutter-free in `ac_chat_core`.
  /// In the `ac_chat` Flutter package this is always an [AcChatTheme] instance,
  /// set automatically by [AcChat] widget upon construction.
  dynamic theme;

  AcChatMediaHandler? mediaHandler;
  String Function()? getAuthToken;
  AcChatCryptoProvider? cryptoProvider;
  AcChatConnectivityProvider? connectivityProvider;
  AcChatSyncChannel? channel;
  static AcLogger _logger = AcLogger(logMessages: true,logType: AcEnumLogType.console);
  AcLogger logger = AcLogger(logMessages: true,logType: AcEnumLogType.console);

  /// Active media uploads progress tracking (messageId -> progress 0.0 to 1.0).
  final Map<String, double> uploadProgress = {};
  final StreamController<({String messageId, double progress})> _uploadProgressController =
      StreamController<({String messageId, double progress})>.broadcast();

  /// Stream of upload progress updates for media attachments.
  Stream<({String messageId, double progress})> get onUploadProgress =>
      _uploadProgressController.stream;

  /// Reports current upload progress for [messageId] (clamped between 0.0 and 1.0).
  void reportUploadProgress({required String messageId, required double progress}) {
    final clamped = progress.clamp(0.0, 1.0);
    uploadProgress[messageId] = clamped;
    if (!_uploadProgressController.isClosed) {
      _uploadProgressController.add((messageId: messageId, progress: clamped));
    }
  }

  /// Clears upload progress tracking for [messageId] upon completion or failure.
  void clearUploadProgress({required String messageId}) {
    uploadProgress.remove(messageId);
    if (!_uploadProgressController.isClosed) {
      _uploadProgressController.add((messageId: messageId, progress: 1.0));
    }
  }

  /// Gets current upload progress for [messageId], if any.
  double? getUploadProgress({required String messageId}) => uploadProgress[messageId];

  String dataDirectory = 'chat_data';
  final String userId;

  // User & Identity
  bool enableOnlinePresence = true;
  bool enableLastSeen = true;
  bool enableUserProfileEditing = true;
  bool enableUserBlocking = false;

  // Conversations
  bool enableCreateNewContact = false;
  bool enableOneToOneConversations = true;
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
  bool enableMessageDisappearing = false;

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
  bool enableGroupUserAddRemove = true;
  bool enableGroupUserPermissions = true;
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
  bool enableConversationExport = false;
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

  // ── Pure-Dart UI callbacks (no BuildContext) ──────────────────────────────
  void Function({required AcChatMessage message})? onMessageTap;
  List<AcChatUser> Function()? getContacts;
  String? contactsSectionTitle;
  String? newContactLabel;
  String? newContactSubtitle;
  String? newGroupLabel;
  String? newGroupSubtitle;
  FutureOr<List<AcChatUser>> Function({String? query,List<String>? userIds})? onGetRemoteUsers;

  AcChatApi({
    required this.userId,
    this.mediaHandler,
    this.cryptoProvider,
    this.connectivityProvider,
    this.channel,
    this.dataDirectory = "chat",

    // User & Identity
    this.enableOnlinePresence = false,
    this.enableLastSeen = false,
    this.enableUserProfileEditing = true,
    this.enableUserBlocking = false,

    // Conversations
    this.enableCreateNewContact = false,
    this.enableOneToOneConversations = true,
    this.enableConversationPinning = false,
    this.enableConversationArchiving = false,
    this.enableConversationMuting = false,
    this.enableConversationDeletion = true,
    this.enableConversationHiding = false,
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
    this.enableMessageCopying = false,
    this.enableMessageStarring = false,
    this.enableMessageDisappearing = false,
    this.enableStarredMessages = false,
    this.enableMessageReactions = false,

    // Attachments
    this.enableMediaAttachments = true,
    this.enableImageAttachments = true,
    this.enableLocationAttachments = false,
    this.enableLiveLocationAttachments = false,
    this.enableContactAttachments = false,
    this.enableVideoAttachments = false,
    this.enableDocumentAttachments = false,
    this.enableVoiceNotes = true,
    this.enableMediaAutoDownload = false,
    this.autoDownloadImages = false,
    this.autoDownloadVideos = false,
    this.autoDownloadDocuments = true,
    this.autoDownloadAudio = true,
    this.enableStatuses = false,
    this.enableMediaViewer = true,
    this.maxAttachmentSizeBytes = 52428800,

    // Message interaction
    this.enableMentions = false,
    this.enableMultiSelect = false,
    this.enableBatchForwarding = false,
    this.enableBatchDeletion = false,
    this.enableBatchCopy = false,
    this.enableMessageSharing = false,
    this.enableInChatSearch = true,

    // Notifications
    this.enablePushNotifications = false,
    this.enableForegroundNotificationSuppression = true,
    this.enableMentionNotifications = false,
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
    this.enableSearchFilters = false,

    // Groups
    this.enableGroups = false,
    this.enableGroupAdminRoles = false,
    this.enableGroupUserAddRemove = false,
    this.enableGroupUserPermissions = false,
    this.enableGroupDetailsEditing = false,
    this.enableGroupLeave = false,
    this.enableGroupInviteLinks = false,
    this.enableGroupSystemMessages = false,
    this.maxGroupParticipants = 50,

    // Security / privacy
    this.enableMessageOwnershipEnforcement = true,
    this.enableBlockedUserRestrictions = true,
    this.enableDataDeletionWipe = true,

    // UI / UX
    this.enableLazyLoadingPagination = true,
    this.enableStickyDateHeaders = true,
    this.enableUnreadMessagesSeparator = true,
    this.enableTypingIndicator = false,
    this.enableTyping = true,
    this.enableScrollToLatestFab = true,
    this.messagesPageSize = 50,

    // Advanced
    this.enablePinnedMessages = false,
    this.enableSharedMediaGallery = true,
    this.enableConversationExport = false,
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



    this.onMessageTap,
    this.getContacts,
    this.contactsSectionTitle,
    this.newContactLabel,
    this.newContactSubtitle,
    this.newGroupLabel,
    this.newGroupSubtitle,
    this.onGetRemoteUsers,

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
    this.addConversationUsers = _addConversationUsers,
    this.removeConversationUsers = _removeConversationUsers,
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
    this.notifyConversationRead = _notifyConversationRead,
    this.sendTypingIndicator = _sendTypingIndicator,
    this.watchTyping = _watchTyping,
    this.forwardMessages = _forwardMessages,
    this.deleteMessagesBatch = _deleteMessagesBatch,
    // ── Search ────────────────────────────────────────────────────────────────
    this.searchMessages = _searchMessages,
    this.downloadMedia = _downloadMedia,
    this.exportChat = _exportChat,
    this.wipeAllData = _wipeAllData,
    // ── Outbox cache ──────────────────────────────────────────────────────────
    this.storeUpdateInCache = _defaultStoreUpdateInCache,
    this.getUpdatesFromCache = _defaultGetUpdatesFromCache,
    this.removeUpdateFromCache = _defaultRemoveUpdateFromCache,
  });

  late Future<AcChatUser?> Function() getCurrentUser;
  late Future<List<AcChatUser>> Function() getUsers;
  late Future<AcChatUser?> Function({required String userId}) getUserById;
  late Future<void> Function({required AcChatUser user}) saveUserProfile;
  late Future<void> Function({required String userId}) blockUser;
  late Future<void> Function({required String userId}) unblockUser;
  late Future<List<String>> Function() getBlockedUserIds;
  late Future<bool> Function({required String userId}) isUserBlocked;
  late Future<void> Function({required String userId, required String reason}) reportUser;
  late Future<Stream<bool>?> Function({required String userId}) watchUserOnlineStatus;
  late Future<List<AcChatConversation>> Function() getConversations;
  late Future<Stream<List<AcChatConversation>>?> Function() watchConversations;
  late Future<AcChatConversationUser?> Function({required String conversationId}) getConversationPrefs;
  late Future<void> Function({required AcChatConversationUser prefs}) updateConversationPrefs;
  late Future<List<AcChatConversationUser>> Function({required String conversationId}) getConversationUsers;
  late FutureOr<AcChatConversation> Function({AcChatConversation? newConversation, required String otherUserId}) insertConversation;
  late Future<void> Function({required String conversationId, required bool isPinned}) pinConversation;
  late Future<void> Function({required String conversationId, required bool isArchived}) archiveConversation;
  late Future<void> Function({required String conversationId, Duration? muteDuration, bool? muted}) muteConversation;
  late Future<void> Function({required String conversationId}) deleteConversation;
  late Future<void> Function({required String conversationId, required bool isHidden}) hideConversation;
  late Future<void> Function({required String conversationId, required List<String> userIds}) addConversationUsers;
  late Future<void> Function({required String conversationId, required String userId}) removeConversationUsers;
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
  late Future<void> Function({required String conversationId}) notifyConversationRead;
  late Future<void> Function({required String conversationId, required bool isTyping}) sendTypingIndicator;
  late Future<Stream<Map<String, bool>>?> Function({required String conversationId}) watchTyping;
  late Future<void> Function({required List<String> messageIds, required String targetConversationId}) forwardMessages;
  late Future<void> Function({required List<String> messageIds, required bool forEveryone}) deleteMessagesBatch;
  late Future<List<AcChatMessage>> Function({required String query, String? conversationId, String? senderId, DateTime? startDateUtc, DateTime? endDateUtc, bool? hasAttachment}) searchMessages;
  late Future<String?> Function({required AcChatMessage message, void Function({required double progress})? onProgress}) downloadMedia;
  late Future<String> Function({required String conversationId, required bool asJson}) exportChat;
  late Future<void> Function() wipeAllData;
  late Future<void> Function({required Map<String, dynamic> envelope}) storeUpdateInCache;
  late Future<List<Map<String, dynamic>>> Function() getUpdatesFromCache;
  late Future<void> Function({required int updateId}) removeUpdateFromCache;

  String getMediaDirectoryForType({required String type}) {
    final base = dataDirectory.replaceAll(RegExp(r'[/\\]+$'), '');
    final sub = switch (type.toLowerCase().trim()) {
      'image' || 'images' => 'images',
      'video' || 'videos' => 'videos',
      'audio' || 'audios' || 'voice' => 'audio',
      'document' || 'documents' || 'doc' || 'file' || 'files' => 'documents',
      _ => type.isNotEmpty ? type.toLowerCase().trim() : 'other',
    };
    return '$base/$sub';
  }

  Future<String?> saveMediaFile({required String type,required String fileName,required Uint8List bytes,String? messageId}) async {
    final dirPath = getMediaDirectoryForType(type:type);
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final name = safeName.isNotEmpty ? safeName : 'attachment';
    final targetPath = '$dirPath/$name';
    final file = File(targetPath);
    await file.writeAsBytes(bytes);
    return targetPath;
  }

  static Future<AcChatUser> _getCurrentUser() async {
    _logger.error("[AcChatApi] Getting current user");
    return AcChatUser();
  }
  static Future<List<AcChatUser>> _getUsers() async {
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
  static Future<void> _reportUser({required String userId, required String reason}) async {}
  static Future<Stream<bool>?> _watchUserOnlineStatus({required String userId}) async {
    return null;
  }
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
  static Future<AcChatConversation> _insertConversation({AcChatConversation? newConversation, required String otherUserId}) async {
    return newConversation ?? AcChatConversation();
  }
  static Future<void> _pinConversation({required String conversationId, required bool isPinned}) async {}
  static Future<void> _archiveConversation({required String conversationId, required bool isArchived}) async {}
  static Future<void> _muteConversation({required String conversationId,Duration? muteDuration,bool? muted}) async {}
  static Future<void> _deleteConversation({required String conversationId}) async {}
  static Future<void> _hideConversation({required String conversationId, required bool isHidden}) async {}
  static Future<void> _addConversationUsers({required String conversationId, required List<String> userIds}) async {}
  static Future<void> _removeConversationUsers({required String conversationId, required String userId}) async {}
  static Future<List<AcChatMessage>> _getMessages({required String conversationId}) async {return [];}
  static Future<Stream<List<AcChatMessage>>?> _watchMessages({required String conversationId}) async {return null;}
  static Future<void> _sendMessage({required AcChatMessage message}) async {}
  static Future<void> _updateMessage({required String messageId, required Map<String, dynamic> data}) async {}
  static Future<void> _editMessage({required String messageId, required String newText}) async {}
  static Future<void> _deleteMessageForMe({required String messageId}) async {}
  static Future<void> _deleteMessageForEveryone({required String messageId}) async {}
  static Future<void> _addReaction({required String messageId, required String emoji}) async {}
  static Future<void> _notifyConversationRead({required String conversationId}) async {}
  static Future<void> _removeReaction({required String messageId, required String emoji}) async {}
  static Future<void> _setStarred({required String messageId, required bool isStarred}) async {}
  static Future<void> _pinMessage({required String messageId, required Duration? duration}) async {}
  static Future<void> _unpinMessage({required String messageId}) async {}
  static Future<void> _sendTypingIndicator({required String conversationId, required bool isTyping}) async {}
  static Future<Stream<Map<String, bool>>?> _watchTyping({required String conversationId}) async { return null; }
  static Future<void> _forwardMessages({required List<String> messageIds, required String targetConversationId}) async {}
  static Future<void> _deleteMessagesBatch({required List<String> messageIds, required bool forEveryone}) async {}
  static Future<List<AcChatMessage>> _searchMessages({required String query, String? conversationId, String? senderId, DateTime? startDateUtc, DateTime? endDateUtc, bool? hasAttachment}) async { return []; }
  static Future<String?> _downloadMedia({required AcChatMessage message, void Function({required double progress})? onProgress}) async { return ""; }
  static Future<String> _exportChat({required String conversationId, required bool asJson}) async { return ''; }
  static Future<void> _wipeAllData() async {}
  static Future<void> _defaultStoreUpdateInCache({required Map<String, dynamic> envelope}) async {}
  static Future<List<Map<String, dynamic>>> _defaultGetUpdatesFromCache() async => [];
  static Future<void> _defaultRemoveUpdateFromCache({required int updateId}) async {}

  static String defaultExtensionForType(String type) {
    switch (type.toLowerCase().trim()) {
      case 'image':
      case 'images':
        return 'jpg';
      case 'video':
      case 'videos':
        return 'mp4';
      case 'audio':
      case 'audios':
      case 'voice':
        return 'm4a';
      case 'document':
      case 'documents':
      case 'doc':
      case 'file':
      case 'files':
        return 'pdf';
      default:
        return 'bin';
    }
  }
}
