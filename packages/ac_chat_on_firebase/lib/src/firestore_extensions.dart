import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore ↔ Dart model conversion helpers for `ac_chat_on_firebase`.
///
/// All Firestore field name constants are defined here as `static const`
/// strings to prevent typos and provide a single source of truth.
class FirestoreExtensions {
  // ─── User field names ──────────────────────────────────────────────────────

  static const String fUserId = 'user_id';
  static const String fName = 'name';
  static const String fUsername = 'username';
  static const String fEmail = 'email';
  static const String fPhone = 'phone';
  static const String fAvatar = 'avatar';
  static const String fBio = 'bio';
  static const String fLastSeen = 'last_seen';
  static const String fIsOnline = 'is_online';

  // ─── Conversation field names ──────────────────────────────────────────────

  static const String fUserIds = 'user_ids';
  static const String fIsGroup = 'is_group';
  static const String fConversationName = 'conversation_name';
  static const String fGroupName = 'group_name'; // backward compatibility alias
  static const String fConversationAvatar = 'conversation_avatar';
  static const String fConversationDescription = 'conversation_description';
  static const String fCreatedBy = 'created_by';
  static const String fCreatedAt = 'created_at';
  static const String fLastMessage = 'last_message';
  static const String fLastMessageType = 'last_message_type';
  static const String fLastTime = 'last_time';
  static const String fIsPinned = 'is_pinned';
  static const String fIsMuted = 'is_muted';
  static const String fDisappearingDurationSeconds = 'disappearing_duration_seconds';

  // ─── User/ConversationUser field names ───────────────────────────────────

  static const String fConversationId = 'conversation_id';
  static const String fUnread = 'unread';

  // ─── Message field names ───────────────────────────────────────────────────

  static const String fMessageId = 'message_id';
  static const String fSenderId = 'sender_id';
  static const String fType = 'type';
  static const String fText = 'text';
  static const String fTime = 'time';
  static const String fStatus = 'status';
  static const String fMediaCaption = 'media_caption';
  static const String fAmount = 'amount';
  static const String fPaymentNote = 'payment_note';
  static const String fDuration = 'duration';
  static const String fFileName = 'file_name';
  static const String fFileSize = 'file_size';
  static const String fReplyToId = 'reply_to_id';
  static const String fDeliveredTime = 'delivered_time';
  static const String fReadTime = 'read_time';
  static const String fEditedTime = 'edited_time';
  static const String fReactions = 'reactions';
  static const String fMentions = 'mentions';
  static const String fIsStarred = 'is_starred';
  static const String fPinnedUntil = 'pinned_until';
  static const String fScheduledTime = 'scheduled_time';
  static const String fExpiresAt = 'expires_at';
  static const String fIsDeleted = 'is_deleted';
  static const String fFilePath = 'file_path';
  static const String fFileUrl = 'file_url';

  // ─── User Update field names ───────────────────────────────────────────────

  static const String fUpdateId = 'update_id';
  static const String fUpdateType = 'type';
  static const String fMessageType = 'message_type';
  static const String fTimestamp = 'timestamp';
  static const String fData = 'data';

  // ── Constructors ──────────────────────────────────────────────────────────

  FirestoreExtensions._(); // prevent instantiation — static helpers only

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static DateTime _parseUtc(dynamic raw, {DateTime? fallback}) {
    if (raw == null) return fallback ?? DateTime.now().toUtc();
    if (raw is Timestamp) return raw.toDate().toUtc();
    if (raw is DateTime) return raw.toUtc();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
    if (raw is String) return parseUtc(raw);
    return fallback ?? DateTime.now().toUtc();
  }

  static DateTime? _parseNullableUtc(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate().toUtc();
    if (raw is DateTime) return raw.toUtc();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
    if (raw is String) return parseUtcOrNull(raw);
    return null;
  }

  // ─── AcChatUser ───────────────────────────────────────────────────────────

  /// Converts a Firestore document snapshot into an [AcChatUser].
  static AcChatUser userFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final user = AcChatUser();
    user.userId = doc.id;
    user.name = (data[fName] as String?) ?? '';
    user.username = (data[fUsername] as String?) ?? '';
    user.email = (data[fEmail] as String?) ?? '';
    user.phone = data[fPhone] as String?;
    user.avatar = data[fAvatar] as String?;
    user.bio = data[fBio] as String?;
    user.isOnline = (data[fIsOnline] as bool?) ?? false;
    user.lastSeen = _parseNullableUtc(data[fLastSeen]);
    return user;
  }

  /// Converts a Firestore [QueryDocumentSnapshot] into an [AcChatUser].
  static AcChatUser userFromQueryDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final user = AcChatUser();
    user.userId = doc.id;
    user.name = (data[fName] as String?) ?? '';
    user.username = (data[fUsername] as String?) ?? '';
    user.email = (data[fEmail] as String?) ?? '';
    user.phone = data[fPhone] as String?;
    user.avatar = data[fAvatar] as String?;
    user.bio = data[fBio] as String?;
    user.isOnline = (data[fIsOnline] as bool?) ?? false;
    user.lastSeen = _parseNullableUtc(data[fLastSeen]);
    return user;
  }

  /// Serializes an [AcChatUser] to a Firestore-compatible map.
  static Map<String, dynamic> userToFirestore(AcChatUser user) {
    return {
      fUserId: user.userId,
      fName: user.name,
      fUsername: user.username,
      fEmail: user.email,
      if (user.phone != null) fPhone: user.phone,
      if (user.avatar != null) fAvatar: user.avatar,
      if (user.bio != null && user.bio!.isNotEmpty) fBio: user.bio,
      if (user.lastSeen != null) fLastSeen: Timestamp.fromDate(user.lastSeen!),
      fIsOnline: user.isOnline,
    };
  }

  // ─── AcChatConversation ────────────────────────────────────────────────────

  /// Converts a Firestore document snapshot into an [AcChatConversation].
  static AcChatConversation conversationFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    int unread = 0,
  }) {
    final data = doc.data() ?? {};
    final conv = AcChatConversation();
    conv.conversationId = doc.id;

    final isGroup = data[fIsGroup] as bool? ?? false;
    conv.type = isGroup ? 'group' : 'direct';

    conv.conversationName = (data[fConversationName] ?? data[fGroupName]) as String?;
    conv.conversationAvatar = (data[fConversationAvatar] ?? data['avatar'] ?? data['group_avatar']) as String?;
    conv.conversationDescription = (data[fConversationDescription] ?? data['description'] ?? data['group_description']) as String?;
    conv.createdBy = (data[fCreatedBy] as String?) ?? '';
    conv.createdAt = _parseUtc(data[fCreatedAt] ?? data['created_at_utc']);

    final rawIds = data[fUserIds];
    if (rawIds is List) {
      conv.userIds = rawIds.map((e) => e.toString()).toList();
    }

    conv.lastMessage = (data[fLastMessage] as String?) ?? '';
    conv.lastMessageType = (data[fLastMessageType] as String?) ?? '';
    conv.lastTime = _parseUtc(data[fLastTime] ?? data['last_time_utc']);

    conv.isPinned = data[fIsPinned] as bool? ?? false;
    conv.isMuted = data[fIsMuted] as bool? ?? false;
    conv.unread = unread;
    conv.disappearingDurationSeconds =
        (data[fDisappearingDurationSeconds] as int?) ?? (data['disappearing_duration'] as int?);

    return conv;
  }

  /// Converts a Firestore [QueryDocumentSnapshot] into an [AcChatConversation].
  static AcChatConversation conversationFromQueryDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    int unread = 0,
  }) {
    final data = doc.data();
    final conv = AcChatConversation();
    conv.conversationId = doc.id;

    final isGroup = data[fIsGroup] as bool? ?? false;
    conv.type = isGroup ? 'group' : 'direct';

    conv.conversationName = (data[fConversationName] ?? data[fGroupName]) as String?;
    conv.conversationAvatar = (data[fConversationAvatar] ?? data['avatar'] ?? data['group_avatar']) as String?;
    conv.conversationDescription = (data[fConversationDescription] ?? data['description'] ?? data['group_description']) as String?;
    conv.createdBy = (data[fCreatedBy] as String?) ?? '';
    conv.createdAt = _parseUtc(data[fCreatedAt] ?? data['created_at_utc']);

    final rawIds = data[fUserIds];
    if (rawIds is List) {
      conv.userIds = rawIds.map((e) => e.toString()).toList();
    }

    conv.lastMessage = (data[fLastMessage] as String?) ?? '';
    conv.lastMessageType = (data[fLastMessageType] as String?) ?? '';
    conv.lastTime = _parseUtc(data[fLastTime] ?? data['last_time_utc']);

    conv.isPinned = data[fIsPinned] as bool? ?? false;
    conv.isMuted = data[fIsMuted] as bool? ?? false;
    conv.unread = unread;
    conv.disappearingDurationSeconds =
        (data[fDisappearingDurationSeconds] as int?) ?? (data['disappearing_duration'] as int?);

    return conv;
  }

  /// Serializes an [AcChatConversation] to a Firestore-compatible map.
  static Map<String, dynamic> conversationToFirestore(
    AcChatConversation conv,
  ) {
    return {
      fUserIds: conv.userIds,
      fIsGroup: conv.type == 'group',
      fConversationName: conv.conversationName,
      fConversationAvatar: conv.conversationAvatar,
      fConversationDescription: conv.conversationDescription,
      fCreatedBy: conv.createdBy,
      fCreatedAt: Timestamp.fromDate(conv.createdAt),
      fLastMessage: conv.lastMessage,
      fLastMessageType: conv.lastMessageType,
      fLastTime: Timestamp.fromDate(conv.lastTime),
      fIsPinned: conv.isPinned,
      fIsMuted: conv.isMuted,
      if (conv.disappearingDurationSeconds != null)
        fDisappearingDurationSeconds: conv.disappearingDurationSeconds,
    };
  }

  // ─── AcChatConversationUser ────────────────────────────────────────────────

  /// Converts a Firestore [QueryDocumentSnapshot] (from the `users` subcollection)
  /// into an [AcChatConversationUser].
  static AcChatConversationUser conversationUserFromQueryDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String conversationId,
  ) {
    final cu = AcChatConversationUser();
    cu.conversationId = conversationId;
    cu.userId = doc.id;
    return cu;
  }

  /// Returns the `unread` counter from a user document snapshot (defaulting to 0).
  static int unreadFromUserDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String currentUserId,
  ) {
    if (doc.id == currentUserId) {
      return (doc.data()[fUnread] as int?) ?? 0;
    }
    return 0;
  }

  // ─── AcChatMessage ────────────────────────────────────────────────────────

  /// Converts a Firestore document snapshot into an [AcChatMessage].
  static AcChatMessage messageFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    AcChatMessage? resolvedReplyTo,
  }) {
    final data = doc.data() ?? {};
    final msg = AcChatMessage();
    msg.messageId = doc.id;
    msg.conversationId = (data[fConversationId] as String?) ?? '';
    msg.senderId = (data[fSenderId] as String?) ?? '';
    msg.type = (data[fType] as String?) ?? 'text';
    msg.text = (data[fText] as String?) ?? '';
    msg.time = _parseUtc(data[fTime] ?? data[fTimestamp]);
    msg.status = (data[fStatus] as String?) ?? 'sent';
    msg.mediaCaption = data[fMediaCaption] as String?;

    msg.duration = data[fDuration] as String?;
    msg.fileName = data[fFileName] as String?;
    msg.fileSize = data[fFileSize] as String?;

    msg.deliveredTime = _parseNullableUtc(data[fDeliveredTime]);
    msg.readTime = _parseNullableUtc(data[fReadTime]);
    msg.editedTime = _parseNullableUtc(data[fEditedTime]);
    msg.pinnedUntil = _parseNullableUtc(data[fPinnedUntil]);
    msg.scheduledTime = _parseNullableUtc(data[fScheduledTime]);
    msg.expiresAt = _parseNullableUtc(data[fExpiresAt]);
    msg.isStarred = (data[fIsStarred] as bool?) ?? false;
    msg.isDeleted = (data[fIsDeleted] as bool?) ?? false;

    final rawReactions = data[fReactions];
    if (rawReactions is Map) {
      msg.reactions = rawReactions.map((k, v) => MapEntry(
            k.toString(),
            (v as List).map((e) => e.toString()).toList(),
          ));
    }

    final rawMentions = data[fMentions];
    if (rawMentions is List) {
      msg.mentions = rawMentions.map((e) => e.toString()).toList();
    }

    // isDownloaded and localPath are device-local — not stored in Firestore.
    // For receiver, localPath is null by default until downloaded.
    msg.isDownloaded = false;
    msg.fileUrl = (data[fFileUrl] as String?) ?? (data['fileUrl'] as String?);
    msg.localPath = null;
    msg.replyTo = resolvedReplyTo;

    return msg;
  }

  /// Converts a Firestore [QueryDocumentSnapshot] into an [AcChatMessage].
  static AcChatMessage messageFromQueryDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    AcChatMessage? resolvedReplyTo,
  }) {
    final data = doc.data();
    final msg = AcChatMessage();
    msg.messageId = doc.id;
    msg.conversationId = (data[fConversationId] as String?) ?? '';
    msg.senderId = (data[fSenderId] as String?) ?? '';
    msg.type = (data[fType] as String?) ?? 'text';
    msg.text = (data[fText] as String?) ?? '';
    msg.time = _parseUtc(data[fTime] ?? data[fTimestamp]);
    msg.status = (data[fStatus] as String?) ?? 'sent';
    msg.mediaCaption = data[fMediaCaption] as String?;
    msg.duration = data[fDuration] as String?;
    msg.fileName = data[fFileName] as String?;
    msg.fileSize = data[fFileSize] as String?;

    msg.deliveredTime = _parseNullableUtc(data[fDeliveredTime]);
    msg.readTime = _parseNullableUtc(data[fReadTime]);
    msg.editedTime = _parseNullableUtc(data[fEditedTime]);
    msg.pinnedUntil = _parseNullableUtc(data[fPinnedUntil]);
    msg.scheduledTime = _parseNullableUtc(data[fScheduledTime]);
    msg.expiresAt = _parseNullableUtc(data[fExpiresAt]);
    msg.isStarred = (data[fIsStarred] as bool?) ?? false;
    msg.isDeleted = (data[fIsDeleted] as bool?) ?? false;

    final rawReactions = data[fReactions];
    if (rawReactions is Map) {
      msg.reactions = rawReactions.map((k, v) => MapEntry(
            k.toString(),
            (v as List).map((e) => e.toString()).toList(),
          ));
    }

    final rawMentions = data[fMentions];
    if (rawMentions is List) {
      msg.mentions = rawMentions.map((e) => e.toString()).toList();
    }

    msg.isDownloaded = false;
    msg.fileUrl = (data[fFileUrl] as String?) ?? (data['fileUrl'] as String?) ;
    msg.localPath = null;
    msg.replyTo = resolvedReplyTo;

    return msg;
  }

  /// Serializes an [AcChatMessage] to a Firestore-compatible map.
  static Map<String, dynamic> messageToFirestore(AcChatMessage msg) {
    return {
      fMessageId: msg.messageId,
      fConversationId: msg.conversationId,
      fSenderId: msg.senderId,
      fType: msg.type,
      fText: msg.text,
      fTime: Timestamp.fromDate(msg.time),
      fStatus: msg.status,
      if (msg.mediaCaption != null) fMediaCaption: msg.mediaCaption,
      if (msg.duration != null) fDuration: msg.duration,
      if (msg.fileName != null) fFileName: msg.fileName,
      if (msg.fileSize != null) fFileSize: msg.fileSize,
      if (msg.replyTo?.messageId != null) fReplyToId: msg.replyTo!.messageId,
      if (msg.deliveredTime != null) fDeliveredTime: Timestamp.fromDate(msg.deliveredTime!),
      if (msg.readTime != null) fReadTime: Timestamp.fromDate(msg.readTime!),
      if (msg.editedTime != null) fEditedTime: Timestamp.fromDate(msg.editedTime!),
      if (msg.pinnedUntil != null) fPinnedUntil: Timestamp.fromDate(msg.pinnedUntil!),
      if (msg.scheduledTime != null) fScheduledTime: Timestamp.fromDate(msg.scheduledTime!),
      if (msg.expiresAt != null) fExpiresAt: Timestamp.fromDate(msg.expiresAt!),
      if (msg.fileUrl != null) fFileUrl: msg.fileUrl,
      if (msg.reactions.isNotEmpty) fReactions: msg.reactions,
      if (msg.mentions.isNotEmpty) fMentions: msg.mentions,
      if (msg.isStarred) fIsStarred: true,
      if (msg.isDeleted) fIsDeleted: true,
    };
  }

  // ─── Direct User Updates Mailbox Helpers ────────────────────────────────────

  /// Serializes an [AcChatMessage] into a self-contained update document payload
  /// for `users/{userId}/updates/{updateId}` without needing a conversations collection.
  static Map<String, dynamic> messageToUpdatePayload(
    AcChatMessage msg, {
    List<String>? userIds,
    String? conversationName,
    String? groupName,
    bool isGroup = false,
  }) {
    final effectiveName = conversationName ?? groupName;
    return {
      fUpdateId: msg.messageId,
      fUpdateType: AcChatUpdateType.message,
      fMessageType: msg.type,
      fConversationId: msg.conversationId,
      fMessageId: msg.messageId,
      fSenderId: msg.senderId,
      fText: msg.text,
      fTime: Timestamp.fromDate(msg.time),
      fTimestamp: Timestamp.fromDate(msg.time),
      fStatus: msg.status,
      if (msg.mediaCaption != null) fMediaCaption: msg.mediaCaption,
      if (msg.duration != null) fDuration: msg.duration,
      if (msg.fileName != null) fFileName: msg.fileName,
      if (msg.fileSize != null) fFileSize: msg.fileSize,
      if (msg.replyTo?.messageId != null) fReplyToId: msg.replyTo!.messageId,
      if (userIds != null) fUserIds: userIds,
      if (effectiveName != null) ...{
        fConversationName: effectiveName,
        fGroupName: effectiveName,
      },
      fIsGroup: isGroup,
      if (msg.fileUrl != null) fFileUrl: msg.fileUrl,
      if (msg.reactions.isNotEmpty) fReactions: msg.reactions,
      if (msg.mentions.isNotEmpty) fMentions: msg.mentions,
      if (msg.isStarred) fIsStarred: true,
      if (msg.deliveredTime != null) fDeliveredTime: Timestamp.fromDate(msg.deliveredTime!),
      if (msg.readTime != null) fReadTime: Timestamp.fromDate(msg.readTime!),
      if (msg.editedTime != null) fEditedTime: Timestamp.fromDate(msg.editedTime!),
    };
  }

  /// Deserializes an [AcChatMessage] directly from an update document map.
  static AcChatMessage messageFromUpdateData(
    Map<String, dynamic> data, {
    String? docId,
    AcChatMessage? resolvedReplyTo,
  }) {
    final msg = AcChatMessage();
    msg.messageId = (data[fMessageId] as String?) ?? docId ?? '';
    msg.conversationId = (data[fConversationId] as String?) ?? '';
    msg.senderId = (data[fSenderId] as String?) ?? '';

    final rawType = (data[fMessageType] as String?) ?? (data[fType] as String?) ?? 'text';
    msg.type = rawType == 'message' ? 'text' : rawType;
    msg.text = (data[fText] as String?) ?? '';
    msg.time = _parseUtc(data[fTime] ?? data[fTimestamp]);
    msg.status = (data[fStatus] as String?) ?? 'sent';
    msg.mediaCaption = data[fMediaCaption] as String?;
    msg.duration = data[fDuration] as String?;
    msg.fileName = data[fFileName] as String?;
    msg.fileSize = data[fFileSize] as String?;

    msg.deliveredTime = _parseNullableUtc(data[fDeliveredTime]);
    msg.readTime = _parseNullableUtc(data[fReadTime]);
    msg.editedTime = _parseNullableUtc(data[fEditedTime]);
    msg.pinnedUntil = _parseNullableUtc(data[fPinnedUntil]);
    msg.scheduledTime = _parseNullableUtc(data[fScheduledTime]);
    msg.expiresAt = _parseNullableUtc(data[fExpiresAt]);
    msg.isStarred = (data[fIsStarred] as bool?) ?? false;
    msg.isDeleted = (data[fIsDeleted] as bool?) ?? false;

    final rawReactions = data[fReactions];
    if (rawReactions is Map) {
      msg.reactions = rawReactions.map((k, v) => MapEntry(
            k.toString(),
            (v as List).map((e) => e.toString()).toList(),
          ));
    }

    final rawMentions = data[fMentions];
    if (rawMentions is List) {
      msg.mentions = rawMentions.map((e) => e.toString()).toList();
    }

    msg.isDownloaded = false;
    msg.fileUrl = (data[fFileUrl] as String?) ?? (data['fileUrl'] as String?);
    msg.localPath = null;
    msg.replyTo = resolvedReplyTo;

    return msg;
  }

  /// Deserializes an [AcChatConversation] directly from an update document map.
  static AcChatConversation conversationFromUpdateData(
    Map<String, dynamic> data,
  ) {
    final conv = AcChatConversation();
    conv.conversationId = (data[fConversationId] as String?) ?? '';
    final isGroup = data[fIsGroup] as bool? ?? false;
    conv.type = isGroup ? 'group' : 'direct';

    conv.conversationName = (data[fConversationName] ?? data[fGroupName]) as String?;
    conv.conversationAvatar = (data[fConversationAvatar] ?? data['avatar'] ?? data['group_avatar']) as String?;
    conv.conversationDescription = (data[fConversationDescription] ?? data['description'] ?? data['group_description']) as String?;
    conv.createdBy = (data[fCreatedBy] as String?) ?? '';
    conv.createdAt = _parseUtc(data[fCreatedAt] ?? data['created_at_utc'] ?? data[fTime] ?? data[fTimestamp] ?? data[fLastTime]);

    final rawIds = data[fUserIds];
    if (rawIds is List) {
      conv.userIds = rawIds.map((e) => e.toString()).toList();
    }

    conv.lastMessage =
        (data[fText] as String?) ?? (data[fLastMessage] as String?) ?? '';
    final rawType = (data[fMessageType] as String?) ?? (data[fLastMessageType] as String?) ?? 'text';
    conv.lastMessageType = rawType == 'message' ? 'text' : rawType;

    conv.lastTime = _parseUtc(data[fTime] ?? data[fTimestamp] ?? data[fLastTime] ?? data['last_time_utc']);

    conv.isPinned = data[fIsPinned] as bool? ?? false;
    conv.isMuted = data[fIsMuted] as bool? ?? false;
    conv.unread = (data[fUnread] as int?) ?? 0;
    conv.disappearingDurationSeconds =
        (data[fDisappearingDurationSeconds] as int?) ?? (data['disappearing_duration'] as int?);

    return conv;
  }
}

/// Constants representing user channel update types in Firestore.
abstract class AcChatUpdateType {
  static const String message = 'message';
  static const String conversation = 'conversation';
  static const String messageUpdate = 'message_update';
  static const String read = 'read';
}
