/// Universal, configuration-driven feature system for `ac_chat`.
///
/// Every chat feature has an explicit configuration flag or limit. When a feature
/// is disabled, it is suppressed across UI, logic, local DB, outbox, network,
/// sync, and notifications.
class AcChatConfig {
  /// Root directory for all chat-local persistent data:
  /// - `databases/chat.db`
  /// - `media/images/`
  /// - `media/videos/`
  /// - `media/audio/`
  /// - `media/documents/`
  /// - `outbox/`
  final String chatDataDirectory;

  // ── User & Identity ───────────────────────────────────────────────────────
  final bool enableOnlinePresence;
  final bool enableLastSeen;
  final bool enableUserProfileEditing;
  final bool enableUserBlocking;

  // ── Conversations ─────────────────────────────────────────────────────────
  final bool enableOneToOneConversations;
  final bool enableGroupConversations;
  final bool enableConversationPinning;
  final bool enableConversationArchiving;
  final bool enableConversationMuting;
  final bool enableConversationDeletion;
  final bool enableConversationHiding;

  // ── Messaging ─────────────────────────────────────────────────────────────
  final bool enableTextMessaging;
  final bool enableDeliveryReceipts;
  final bool enableReadReceipts;
  final bool enableMessageReplying;
  final bool enableMessageForwarding;
  final bool enableMessageEditing;
  final bool enableMessageDeletingForMe;
  final bool enableMessageDeletingForEveryone;
  final bool enableMessageCopying;
  final bool enableStarredMessages;
  final bool enableMessageReactions;

  // ── Attachments ───────────────────────────────────────────────────────────
  final bool enableMediaAttachments;
  final bool enableImageAttachments;
  final bool enableVideoAttachments;
  final bool enableDocumentAttachments;
  final bool enableVoiceNotes;
  final bool enableMediaAutoDownload;
  final bool enableMediaViewer;
  final int maxAttachmentSizeBytes;

  // ── Message interaction ───────────────────────────────────────────────────
  final bool enableMentions;
  final bool enableMultiSelect;
  final bool enableBatchForwarding;
  final bool enableBatchDeletion;
  final bool enableBatchCopy;
  final bool enableMessageSharing;
  final bool enableInChatSearch;

  // ── Notifications ─────────────────────────────────────────────────────────
  final bool enablePushNotifications;
  final bool enableForegroundNotificationSuppression;
  final bool enableMentionNotifications;
  final bool enableBadgeCountSync;

  // ── Offline / synchronization ─────────────────────────────────────────────
  final bool enableOfflineCaching;
  final bool enableOfflineOutbox;
  final bool enableDeltaSync;
  final int outboxMaxRetries;
  final Duration outboxRetryInterval;

  // ── Search ────────────────────────────────────────────────────────────────
  final bool enableConversationSearch;
  final bool enableMessageFullTextSearch;
  final bool enableSearchFilters;

  // ── Groups ────────────────────────────────────────────────────────────────
  final bool enableGroupAdminRoles;
  final bool enableGroupMemberAddRemove;
  final bool enableGroupMemberPermissions;
  final bool enableGroupDetailsEditing;
  final bool enableGroupLeave;
  final bool enableGroupInviteLinks;
  final bool enableGroupSystemMessages;
  final int maxGroupParticipants;

  // ── Security / privacy ────────────────────────────────────────────────────
  final bool enableMessageOwnershipEnforcement;
  final bool enableBlockedUserRestrictions;
  final bool enableDataDeletionWipe;

  // ── UI / UX ───────────────────────────────────────────────────────────────
  final bool enableLazyLoadingPagination;
  final bool enableStickyDateHeaders;
  final bool enableUnreadMessagesSeparator;
  final bool enableTypingIndicators;
  final bool enableScrollToLatestFab;
  final int messagesPageSize;

  // ── Advanced ──────────────────────────────────────────────────────────────
  final bool enablePinnedMessages;
  final bool enableSharedMediaGallery;
  final bool enableChatExport;
  final bool enableDisappearingMessages;
  final bool enableMessageScheduling;
  final bool enableBroadcastMessages;
  final bool enableUserReporting;

  // ── Policies ──────────────────────────────────────────────────────────────
  final Duration editTimeWindow;
  final Duration deleteForEveryoneWindow;

  const AcChatConfig({
    this.chatDataDirectory = 'chat_data',

    // User & Identity
    this.enableOnlinePresence = true,
    this.enableLastSeen = true,
    this.enableUserProfileEditing = true,
    this.enableUserBlocking = true,

    // Conversations
    this.enableOneToOneConversations = true,
    this.enableGroupConversations = true,
    this.enableConversationPinning = true,
    this.enableConversationArchiving = true,
    this.enableConversationMuting = true,
    this.enableConversationDeletion = true,
    this.enableConversationHiding = true,

    // Messaging
    this.enableTextMessaging = true,
    this.enableDeliveryReceipts = true,
    this.enableReadReceipts = true,
    this.enableMessageReplying = true,
    this.enableMessageForwarding = true,
    this.enableMessageEditing = true,
    this.enableMessageDeletingForMe = true,
    this.enableMessageDeletingForEveryone = true,
    this.enableMessageCopying = true,
    this.enableStarredMessages = true,
    this.enableMessageReactions = true,

    // Attachments
    this.enableMediaAttachments = true,
    this.enableImageAttachments = true,
    this.enableVideoAttachments = true,
    this.enableDocumentAttachments = true,
    this.enableVoiceNotes = true,
    this.enableMediaAutoDownload = true,
    this.enableMediaViewer = true,
    this.maxAttachmentSizeBytes = 52428800, // 50 MB

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
    this.enableGroupAdminRoles = true,
    this.enableGroupMemberAddRemove = true,
    this.enableGroupMemberPermissions = true,
    this.enableGroupDetailsEditing = true,
    this.enableGroupLeave = true,
    this.enableGroupInviteLinks = true,
    this.enableGroupSystemMessages = true,
    this.maxGroupParticipants = 256,

    // Security / privacy
    this.enableMessageOwnershipEnforcement = true,
    this.enableBlockedUserRestrictions = true,
    this.enableDataDeletionWipe = true,

    // UI / UX
    this.enableLazyLoadingPagination = true,
    this.enableStickyDateHeaders = true,
    this.enableUnreadMessagesSeparator = true,
    this.enableTypingIndicators = true,
    this.enableScrollToLatestFab = true,
    this.messagesPageSize = 40,

    // Advanced
    this.enablePinnedMessages = true,
    this.enableSharedMediaGallery = true,
    this.enableChatExport = true,
    this.enableDisappearingMessages = false,
    this.enableMessageScheduling = false,
    this.enableBroadcastMessages = false,
    this.enableUserReporting = true,

    // Policies
    this.editTimeWindow = const Duration(minutes: 15),
    this.deleteForEveryoneWindow = const Duration(hours: 24),
  });

  /// Factory creating an [AcChatConfig] where all feature flags are disabled.
  factory AcChatConfig.allDisabled({String chatDataDirectory = 'chat_data'}) {
    return AcChatConfig(
      chatDataDirectory: chatDataDirectory,
      enableOnlinePresence: false,
      enableLastSeen: false,
      enableUserProfileEditing: false,
      enableUserBlocking: false,
      enableOneToOneConversations: false,
      enableGroupConversations: false,
      enableConversationPinning: false,
      enableConversationArchiving: false,
      enableConversationMuting: false,
      enableConversationDeletion: false,
      enableConversationHiding: false,
      enableTextMessaging: false,
      enableDeliveryReceipts: false,
      enableReadReceipts: false,
      enableMessageReplying: false,
      enableMessageForwarding: false,
      enableMessageEditing: false,
      enableMessageDeletingForMe: false,
      enableMessageDeletingForEveryone: false,
      enableMessageCopying: false,
      enableStarredMessages: false,
      enableMessageReactions: false,
      enableMediaAttachments: false,
      enableImageAttachments: false,
      enableVideoAttachments: false,
      enableDocumentAttachments: false,
      enableVoiceNotes: false,
      enableMediaAutoDownload: false,
      enableMediaViewer: false,
      enableMentions: false,
      enableMultiSelect: false,
      enableBatchForwarding: false,
      enableBatchDeletion: false,
      enableBatchCopy: false,
      enableMessageSharing: false,
      enableInChatSearch: false,
      enablePushNotifications: false,
      enableForegroundNotificationSuppression: false,
      enableMentionNotifications: false,
      enableBadgeCountSync: false,
      enableOfflineCaching: false,
      enableOfflineOutbox: false,
      enableDeltaSync: false,
      enableConversationSearch: false,
      enableMessageFullTextSearch: false,
      enableSearchFilters: false,
      enableGroupAdminRoles: false,
      enableGroupMemberAddRemove: false,
      enableGroupMemberPermissions: false,
      enableGroupDetailsEditing: false,
      enableGroupLeave: false,
      enableGroupInviteLinks: false,
      enableGroupSystemMessages: false,
      enableMessageOwnershipEnforcement: false,
      enableBlockedUserRestrictions: false,
      enableDataDeletionWipe: false,
      enableLazyLoadingPagination: false,
      enableStickyDateHeaders: false,
      enableUnreadMessagesSeparator: false,
      enableTypingIndicators: false,
      enableScrollToLatestFab: false,
      enablePinnedMessages: false,
      enableSharedMediaGallery: false,
      enableChatExport: false,
      enableDisappearingMessages: false,
      enableMessageScheduling: false,
      enableBroadcastMessages: false,
      enableUserReporting: false,
    );
  }

  AcChatConfig copyWith({
    String? chatDataDirectory,
    bool? enableOnlinePresence,
    bool? enableLastSeen,
    bool? enableUserProfileEditing,
    bool? enableUserBlocking,
    bool? enableOneToOneConversations,
    bool? enableGroupConversations,
    bool? enableConversationPinning,
    bool? enableConversationArchiving,
    bool? enableConversationMuting,
    bool? enableConversationDeletion,
    bool? enableConversationHiding,
    bool? enableTextMessaging,
    bool? enableDeliveryReceipts,
    bool? enableReadReceipts,
    bool? enableMessageReplying,
    bool? enableMessageForwarding,
    bool? enableMessageEditing,
    bool? enableMessageDeletingForMe,
    bool? enableMessageDeletingForEveryone,
    bool? enableMessageCopying,
    bool? enableStarredMessages,
    bool? enableMessageReactions,
    bool? enableMediaAttachments,
    bool? enableImageAttachments,
    bool? enableVideoAttachments,
    bool? enableDocumentAttachments,
    bool? enableVoiceNotes,
    bool? enableMediaAutoDownload,
    bool? enableMediaViewer,
    int? maxAttachmentSizeBytes,
    bool? enableMentions,
    bool? enableMultiSelect,
    bool? enableBatchForwarding,
    bool? enableBatchDeletion,
    bool? enableBatchCopy,
    bool? enableMessageSharing,
    bool? enableInChatSearch,
    bool? enablePushNotifications,
    bool? enableForegroundNotificationSuppression,
    bool? enableMentionNotifications,
    bool? enableBadgeCountSync,
    bool? enableOfflineCaching,
    bool? enableOfflineOutbox,
    bool? enableDeltaSync,
    int? outboxMaxRetries,
    Duration? outboxRetryInterval,
    bool? enableConversationSearch,
    bool? enableMessageFullTextSearch,
    bool? enableSearchFilters,
    bool? enableGroupAdminRoles,
    bool? enableGroupMemberAddRemove,
    bool? enableGroupMemberPermissions,
    bool? enableGroupDetailsEditing,
    bool? enableGroupLeave,
    bool? enableGroupInviteLinks,
    bool? enableGroupSystemMessages,
    int? maxGroupParticipants,
    bool? enableMessageOwnershipEnforcement,
    bool? enableBlockedUserRestrictions,
    bool? enableDataDeletionWipe,
    bool? enableLazyLoadingPagination,
    bool? enableStickyDateHeaders,
    bool? enableUnreadMessagesSeparator,
    bool? enableTypingIndicators,
    bool? enableScrollToLatestFab,
    int? messagesPageSize,
    bool? enablePinnedMessages,
    bool? enableSharedMediaGallery,
    bool? enableChatExport,
    bool? enableDisappearingMessages,
    bool? enableMessageScheduling,
    bool? enableBroadcastMessages,
    bool? enableUserReporting,
    Duration? editTimeWindow,
    Duration? deleteForEveryoneWindow,
  }) {
    return AcChatConfig(
      chatDataDirectory: chatDataDirectory ?? this.chatDataDirectory,
      enableOnlinePresence: enableOnlinePresence ?? this.enableOnlinePresence,
      enableLastSeen: enableLastSeen ?? this.enableLastSeen,
      enableUserProfileEditing: enableUserProfileEditing ?? this.enableUserProfileEditing,
      enableUserBlocking: enableUserBlocking ?? this.enableUserBlocking,
      enableOneToOneConversations: enableOneToOneConversations ?? this.enableOneToOneConversations,
      enableGroupConversations: enableGroupConversations ?? this.enableGroupConversations,
      enableConversationPinning: enableConversationPinning ?? this.enableConversationPinning,
      enableConversationArchiving: enableConversationArchiving ?? this.enableConversationArchiving,
      enableConversationMuting: enableConversationMuting ?? this.enableConversationMuting,
      enableConversationDeletion: enableConversationDeletion ?? this.enableConversationDeletion,
      enableConversationHiding: enableConversationHiding ?? this.enableConversationHiding,
      enableTextMessaging: enableTextMessaging ?? this.enableTextMessaging,
      enableDeliveryReceipts: enableDeliveryReceipts ?? this.enableDeliveryReceipts,
      enableReadReceipts: enableReadReceipts ?? this.enableReadReceipts,
      enableMessageReplying: enableMessageReplying ?? this.enableMessageReplying,
      enableMessageForwarding: enableMessageForwarding ?? this.enableMessageForwarding,
      enableMessageEditing: enableMessageEditing ?? this.enableMessageEditing,
      enableMessageDeletingForMe: enableMessageDeletingForMe ?? this.enableMessageDeletingForMe,
      enableMessageDeletingForEveryone: enableMessageDeletingForEveryone ?? this.enableMessageDeletingForEveryone,
      enableMessageCopying: enableMessageCopying ?? this.enableMessageCopying,
      enableStarredMessages: enableStarredMessages ?? this.enableStarredMessages,
      enableMessageReactions: enableMessageReactions ?? this.enableMessageReactions,
      enableMediaAttachments: enableMediaAttachments ?? this.enableMediaAttachments,
      enableImageAttachments: enableImageAttachments ?? this.enableImageAttachments,
      enableVideoAttachments: enableVideoAttachments ?? this.enableVideoAttachments,
      enableDocumentAttachments: enableDocumentAttachments ?? this.enableDocumentAttachments,
      enableVoiceNotes: enableVoiceNotes ?? this.enableVoiceNotes,
      enableMediaAutoDownload: enableMediaAutoDownload ?? this.enableMediaAutoDownload,
      enableMediaViewer: enableMediaViewer ?? this.enableMediaViewer,
      maxAttachmentSizeBytes: maxAttachmentSizeBytes ?? this.maxAttachmentSizeBytes,
      enableMentions: enableMentions ?? this.enableMentions,
      enableMultiSelect: enableMultiSelect ?? this.enableMultiSelect,
      enableBatchForwarding: enableBatchForwarding ?? this.enableBatchForwarding,
      enableBatchDeletion: enableBatchDeletion ?? this.enableBatchDeletion,
      enableBatchCopy: enableBatchCopy ?? this.enableBatchCopy,
      enableMessageSharing: enableMessageSharing ?? this.enableMessageSharing,
      enableInChatSearch: enableInChatSearch ?? this.enableInChatSearch,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableForegroundNotificationSuppression: enableForegroundNotificationSuppression ?? this.enableForegroundNotificationSuppression,
      enableMentionNotifications: enableMentionNotifications ?? this.enableMentionNotifications,
      enableBadgeCountSync: enableBadgeCountSync ?? this.enableBadgeCountSync,
      enableOfflineCaching: enableOfflineCaching ?? this.enableOfflineCaching,
      enableOfflineOutbox: enableOfflineOutbox ?? this.enableOfflineOutbox,
      enableDeltaSync: enableDeltaSync ?? this.enableDeltaSync,
      outboxMaxRetries: outboxMaxRetries ?? this.outboxMaxRetries,
      outboxRetryInterval: outboxRetryInterval ?? this.outboxRetryInterval,
      enableConversationSearch: enableConversationSearch ?? this.enableConversationSearch,
      enableMessageFullTextSearch: enableMessageFullTextSearch ?? this.enableMessageFullTextSearch,
      enableSearchFilters: enableSearchFilters ?? this.enableSearchFilters,
      enableGroupAdminRoles: enableGroupAdminRoles ?? this.enableGroupAdminRoles,
      enableGroupMemberAddRemove: enableGroupMemberAddRemove ?? this.enableGroupMemberAddRemove,
      enableGroupMemberPermissions: enableGroupMemberPermissions ?? this.enableGroupMemberPermissions,
      enableGroupDetailsEditing: enableGroupDetailsEditing ?? this.enableGroupDetailsEditing,
      enableGroupLeave: enableGroupLeave ?? this.enableGroupLeave,
      enableGroupInviteLinks: enableGroupInviteLinks ?? this.enableGroupInviteLinks,
      enableGroupSystemMessages: enableGroupSystemMessages ?? this.enableGroupSystemMessages,
      maxGroupParticipants: maxGroupParticipants ?? this.maxGroupParticipants,
      enableMessageOwnershipEnforcement: enableMessageOwnershipEnforcement ?? this.enableMessageOwnershipEnforcement,
      enableBlockedUserRestrictions: enableBlockedUserRestrictions ?? this.enableBlockedUserRestrictions,
      enableDataDeletionWipe: enableDataDeletionWipe ?? this.enableDataDeletionWipe,
      enableLazyLoadingPagination: enableLazyLoadingPagination ?? this.enableLazyLoadingPagination,
      enableStickyDateHeaders: enableStickyDateHeaders ?? this.enableStickyDateHeaders,
      enableUnreadMessagesSeparator: enableUnreadMessagesSeparator ?? this.enableUnreadMessagesSeparator,
      enableTypingIndicators: enableTypingIndicators ?? this.enableTypingIndicators,
      enableScrollToLatestFab: enableScrollToLatestFab ?? this.enableScrollToLatestFab,
      messagesPageSize: messagesPageSize ?? this.messagesPageSize,
      enablePinnedMessages: enablePinnedMessages ?? this.enablePinnedMessages,
      enableSharedMediaGallery: enableSharedMediaGallery ?? this.enableSharedMediaGallery,
      enableChatExport: enableChatExport ?? this.enableChatExport,
      enableDisappearingMessages: enableDisappearingMessages ?? this.enableDisappearingMessages,
      enableMessageScheduling: enableMessageScheduling ?? this.enableMessageScheduling,
      enableBroadcastMessages: enableBroadcastMessages ?? this.enableBroadcastMessages,
      enableUserReporting: enableUserReporting ?? this.enableUserReporting,
      editTimeWindow: editTimeWindow ?? this.editTimeWindow,
      deleteForEveryoneWindow: deleteForEveryoneWindow ?? this.deleteForEveryoneWindow,
    );
  }
}
