import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ac_chat/ac_chat.dart';

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

  // ─── Conversation field names ──────────────────────────────────────────────

  static const String fMemberIds = 'member_ids';
  static const String fIsGroup = 'is_group';
  static const String fGroupName = 'group_name';
  static const String fLastMessage = 'last_message';
  static const String fLastMessageType = 'last_message_type';
  static const String fLastTime = 'last_time';
  static const String fIsPinned = 'is_pinned';
  static const String fIsMuted = 'is_muted';

  // ─── Member/ConversationUser field names ───────────────────────────────────

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

  // ── Constructors ──────────────────────────────────────────────────────────

  FirestoreExtensions._(); // prevent instantiation — static helpers only

  // ─── AcChatUser ───────────────────────────────────────────────────────────

  /// Converts a Firestore document snapshot into an [AcChatUser].
  ///
  /// The document ID is used as the [AcChatUser.userId].
  static AcChatUser userFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final user = AcChatUser();
    user.userId = doc.id;
    user.name = (data[fName] as String?) ?? '';
    user.username = (data[fUsername] as String?) ?? '';
    user.email = (data[fEmail] as String?) ?? '';
    user.phone = data[fPhone] as String?;
    user.avatar = data[fAvatar] as String?;
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
    };
  }

  // ─── AcChatConversation ────────────────────────────────────────────────────

  /// Converts a Firestore [QueryDocumentSnapshot] into an [AcChatConversation].
  ///
  /// Handles the [fIsGroup] → [AcChatConversation.type] mapping explicitly.
  /// The [unread] value must be supplied separately from the `members` subcollection.
  static AcChatConversation conversationFromQueryDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    int unread = 0,
  }) {
    final data = doc.data();
    final conv = AcChatConversation();
    conv.conversationId = doc.id;

    // Explicit is_group → type mapping (do NOT pass is_group to fromJson)
    final isGroup = data[fIsGroup] as bool? ?? false;
    conv.type = isGroup ? 'group' : 'direct';

    conv.groupName = data[fGroupName] as String?;

    final rawIds = data[fMemberIds];
    if (rawIds is List) {
      conv.memberIds = rawIds.map((e) => e.toString()).toList();
    }

    conv.lastMessage = (data[fLastMessage] as String?) ?? '';
    conv.lastMessageType = (data[fLastMessageType] as String?) ?? '';

    final rawTime = data[fLastTime];
    if (rawTime is Timestamp) {
      conv.lastTime = rawTime.toDate();
    } else if (rawTime is DateTime) {
      conv.lastTime = rawTime;
    }

    conv.isPinned = data[fIsPinned] as bool? ?? false;
    conv.isMuted = data[fIsMuted] as bool? ?? false;
    conv.unread = unread;

    return conv;
  }

  /// Serializes an [AcChatConversation] to a Firestore-compatible map.
  static Map<String, dynamic> conversationToFirestore(
    AcChatConversation conv,
  ) {
    return {
      fMemberIds: conv.memberIds,
      fIsGroup: conv.type == 'group',
      fGroupName: conv.groupName,
      fLastMessage: conv.lastMessage,
      fLastMessageType: conv.lastMessageType,
      fLastTime: Timestamp.fromDate(conv.lastTime),
      fIsPinned: conv.isPinned,
      fIsMuted: conv.isMuted,
    };
  }

  // ─── AcChatConversationUser ────────────────────────────────────────────────

  /// Converts a Firestore [QueryDocumentSnapshot] (from the `members` subcollection)
  /// into an [AcChatConversationUser].
  ///
  /// The document ID is used as the [AcChatConversationUser.userId].
  static AcChatConversationUser conversationUserFromQueryDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String conversationId,
  ) {
    final cu = AcChatConversationUser();
    cu.conversationId = conversationId;
    cu.userId = doc.id;
    return cu;
  }

  /// Returns the `unread` counter from a member document snapshot (defaulting to 0).
  static int unreadFromMemberDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String currentUserId,
  ) {
    if (doc.id == currentUserId) {
      return (doc.data()[fUnread] as int?) ?? 0;
    }
    return 0;
  }

  // ─── AcChatMessage ────────────────────────────────────────────────────────

  /// Converts a Firestore [QueryDocumentSnapshot] into an [AcChatMessage].
  ///
  /// [replyToId] is resolved externally using a message index to avoid
  /// recursive Firestore fetches.
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

    final rawTime = data[fTime];
    if (rawTime is Timestamp) {
      msg.time = rawTime.toDate();
    } else if (rawTime is DateTime) {
      msg.time = rawTime;
    }

    msg.status = (data[fStatus] as String?) ?? 'sent';
    msg.mediaCaption = data[fMediaCaption] as String?;

    final rawAmount = data[fAmount];
    if (rawAmount != null) {
      msg.amount = (rawAmount as num).toDouble();
    }

    msg.paymentNote = data[fPaymentNote] as String?;
    msg.duration = data[fDuration] as String?;
    msg.fileName = data[fFileName] as String?;
    msg.fileSize = data[fFileSize] as String?;

    // isDownloaded and localPath are device-local — not stored in Firestore.
    msg.isDownloaded = false;
    msg.localPath = null;

    // replyTo is resolved from the in-memory message index by the caller.
    msg.replyTo = resolvedReplyTo;

    return msg;
  }

  /// Serializes an [AcChatMessage] to a Firestore-compatible map.
  ///
  /// Device-local fields ([AcChatMessage.isDownloaded] and [AcChatMessage.localPath])
  /// are intentionally excluded.
  static Map<String, dynamic> messageToFirestore(AcChatMessage msg) {
    return {
      fMessageId: msg.messageId,
      fConversationId: msg.conversationId,
      fSenderId: msg.senderId,
      fType: msg.type,
      fText: msg.text,
      fTime: Timestamp.fromDate(msg.time),
      fStatus: msg.status,
      fMediaCaption: msg.mediaCaption,
      fAmount: msg.amount,
      fPaymentNote: msg.paymentNote,
      fDuration: msg.duration,
      fFileName: msg.fileName,
      fFileSize: msg.fileSize,
      fReplyToId: msg.replyTo?.messageId,
    };
  }
}
