import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:uuid/uuid.dart';

import 'ac_chat_firebase_server_config.dart';
import 'firestore_rest_client.dart';

/// Server-side Firestore adapter for ac_chat.
///
/// Implements [AcChatSyncChannel] using the Firestore REST API so it can run
/// in pure-Dart server environments (e.g. accountea-pro-cloud) where
/// flutter/cloud_firestore is unavailable.
///
/// Uses the same `users/{userId}/updates/{updateId}` mailbox pattern as
/// [AcChatFirebase] (the Flutter client adapter) so both share the same
/// Firestore data model.
///
/// **`startListening` is not supported server-side** — the server does not
/// hold open real-time listeners. Clients listen directly via cloud_firestore.
class AcChatFirebaseServer implements AcChatSyncChannel {
  AcChatFirebaseServer({
    required this.firestore,
    required this.currentUserId,
    AcChatFirebaseServerConfig? config,
  }) : _config = config ?? const AcChatFirebaseServerConfig();

  final FirestoreRestClient firestore;
  final AcChatFirebaseServerConfig _config;

  String currentUserId;
  final _uuid = const Uuid();

  // ─── Mailbox path helpers ─────────────────────────────────────────────────
  String _updatePath(String userId, String updateId) =>
      '${_config.usersCollection}/$userId/${_config.updatesSubcollection}/$updateId';

  // ─── sendMessage ─────────────────────────────────────────────────────────
  @override
  Future<bool> sendMessage({
    required AcChatMessage message,
    required List<String> recipientIds,
    Map<String, dynamic>? notificationPayload,
  }) async {
    final targets = recipientIds
        .where((id) => id != currentUserId)
        .toList();
    if (targets.isEmpty) return true;

    final writes = <Map<String, dynamic>>[];

    for (final recipientId in targets) {
      final updateId = _uuid.v4();
      final payload = _messageToUpdatePayload(
        message,
        updateId: updateId,
        userIds: [currentUserId, ...targets],
        notificationPayload: notificationPayload,
      );
      writes.add(firestore.updateWrite(
        _updatePath(recipientId, updateId),
        payload,
      ));
    }

    await firestore.batchWrite(writes);
    return true;
  }

  // ─── createConversation ───────────────────────────────────────────────────
  @override
  Future<void> createConversation({
    required AcChatConversation conversation,
    List<String>? userIds,
    Map<String, dynamic>? notificationPayload,
  }) async {
    final effectiveUserIds = userIds ?? userIds ?? [];
    final allUsers = {
      currentUserId,
      ...effectiveUserIds,
      ...conversation.userIds,
    }.toList();

    conversation.userIds = allUsers;

    final writes = <Map<String, dynamic>>[];

    for (final recipientId in allUsers) {
      if (recipientId == currentUserId) continue;
      final updateId = _uuid.v4();
      final payload = <String, dynamic>{
        'updateId': updateId,
        'updateType': 'conversation',
        'conversationId': conversation.conversationId,
        'userIds': allUsers,
        'conversationName': conversation.conversationName,
        if (conversation.conversationAvatar != null)
          'conversationAvatar': conversation.conversationAvatar,
        if (conversation.conversationDescription != null)
          'conversationDescription': conversation.conversationDescription,
        'createdBy': conversation.createdBy,
        'createdAt': conversation.createdAt,
        'isGroup': conversation.type == 'group',
        'timestamp': conversation.lastTime,
        'lastTime': conversation.lastTime,
        'senderId': currentUserId,
        if (notificationPayload != null) 'notification': notificationPayload,
      };
      writes.add(firestore.updateWrite(
        _updatePath(recipientId, updateId),
        payload,
      ));
    }

    await firestore.batchWrite(writes);
  }

  // ─── notifyConversationRead ───────────────────────────────────────────────────────────
  @override
  Future<void> notifyConversationRead({
    required String conversationId,
    List<String>? messageIds,
  }) async {
    // Server does not track local read state — no-op or emit update to sender
    // if required. Override in subclass for custom behaviour.
  }

  // ─── notifyMessagesDelivered ──────────────────────────────────────────────────
  @override
  Future<void> notifyMessagesDelivered({
    required List<String> messageIds,
    required String conversationId,
    required String senderId,
  }) async {
    if (senderId == currentUserId || messageIds.isEmpty) return;
    final writes = <Map<String, dynamic>>[];
    final now = DateTime.now().toUtc();
    for (final messageId in messageIds) {
      final updateId = _uuid.v4();
      writes.add(firestore.updateWrite(
        _updatePath(senderId, updateId),
        {
          'updateId': updateId,
          'updateType': 'message_update',
          'messageId': messageId,
          'conversationId': conversationId,
          'status': 'delivered',
          'timestamp': now,
        },
      ));
    }
    if (writes.isNotEmpty) await firestore.batchWrite(writes);
  }

  Future<void> notifyMessageDelivered({
    required String messageId,
    required String conversationId,
    required String senderId,
  }) => notifyMessagesDelivered(
        messageIds: [messageId],
        conversationId: conversationId,
        senderId: senderId,
      );

  // ─── notifyMessagesRead ──────────────────────────────────────────────────────
  @override
  Future<void> notifyMessagesRead({
    required String conversationId,
    required String senderId,
    required List<String> messageIds,
  }) async {
    if (senderId == currentUserId) return;
    final updateId = _uuid.v4();
    await firestore.batchWrite([
      firestore.updateWrite(
        _updatePath(senderId, updateId),
        {
          'updateId': updateId,
          'updateType': 'read',
          'conversationId': conversationId,
          'messageIds': messageIds,
          'readerId': currentUserId,
          'timestamp': DateTime.now().toUtc(),
        },
      ),
    ]);
  }

  // ─── sendTypingIndicator ──────────────────────────────────────────────────
  @override
  Future<void> sendTypingIndicator({
    required String conversationId,
    required List<String> recipientIds,
    required bool isTyping,
  }) async {
    final writes = <Map<String, dynamic>>[];
    for (final recipientId in recipientIds) {
      if (recipientId == currentUserId) continue;
      final updateId = _uuid.v4();
      writes.add(firestore.updateWrite(
        _updatePath(recipientId, updateId),
        {
          'updateId': updateId,
          'updateType': 'typing',
          'conversationId': conversationId,
          'senderId': currentUserId,
          'isTyping': isTyping,
          'timestamp': DateTime.now().toUtc(),
        },
      ));
    }
    if (writes.isNotEmpty) await firestore.batchWrite(writes);
  }

  // ─── updateMessage ────────────────────────────────────────────────────────
  @override
  Future<void> updateMessage({
    required String messageId,
    required String conversationId,
    required Map<String, dynamic> data,
    required List<String> recipientIds,
  }) async {
    final writes = <Map<String, dynamic>>[];
    for (final recipientId in recipientIds) {
      if (recipientId == currentUserId) continue;
      final updateId = _uuid.v4();
      writes.add(firestore.updateWrite(
        _updatePath(recipientId, updateId),
        {
          'updateId': updateId,
          'updateType': 'message_update',
          'messageId': messageId,
          'conversationId': conversationId,
          'timestamp': DateTime.now().toUtc(),
          ...data,
        },
      ));
    }
    if (writes.isNotEmpty) await firestore.batchWrite(writes);
  }

  // ─── acknowledgeUpdate ───────────────────────────────────────────────────
  @override
  Future<void> acknowledgeUpdate({required String updateId}) async {
    await firestore.deleteDocument(
      _updatePath(currentUserId, updateId),
    );
  }

  // ─── updateConversation ───────────────────────────────────────────────────
  @override
  Future<void> updateConversation({
    required AcChatConversation conversation,
  }) async {
    final targets = conversation.userIds.where((id) => id != currentUserId).toList();
    final writes = <Map<String, dynamic>>[];

    for (final recipientId in targets) {
      final updateId = _uuid.v4();
      final payload = <String, dynamic>{
        'updateId': updateId,
        'updateType': 'conversation',
        'conversationId': conversation.conversationId,
        'userIds': conversation.userIds,
        'conversationName': conversation.conversationName,
        if (conversation.conversationAvatar != null)
          'conversationAvatar': conversation.conversationAvatar,
        if (conversation.conversationDescription != null)
          'conversationDescription': conversation.conversationDescription,
        'createdBy': conversation.createdBy,
        'createdAt': conversation.createdAt,
        'isGroup': conversation.type == 'group',
        'timestamp': conversation.lastTime,
        'lastTime': conversation.lastTime,
        'senderId': currentUserId,
      };
      writes.add(firestore.updateWrite(
        _updatePath(recipientId, updateId),
        payload,
      ));
    }

    if (writes.isNotEmpty) await firestore.batchWrite(writes);
  }

  // ─── updateConversationUser ───────────────────────────────────────────────
  @override
  Future<void> updateConversationUser({
    required AcChatConversationUser conversationUser,
  }) async {
    final updateId = _uuid.v4();
    await firestore.batchWrite([
      firestore.updateWrite(
        _updatePath(conversationUser.userId, updateId),
        {
          'updateId': updateId,
          'updateType': 'conversation_user_update',
          'conversationId': conversationUser.conversationId,
          'userId': conversationUser.userId,
          'role': conversationUser.role,
          'is_pinned': conversationUser.isPinned,
          'is_muted': conversationUser.isMuted,
          'is_archived': conversationUser.isArchived,
          'unread_count': conversationUser.unreadCount,
          'timestamp': DateTime.now().toUtc(),
          'senderId': currentUserId,
        },
      ),
    ]);
  }

  // ─── addConversationUsers ────────────────────────────────────────────────
  @override
  Future<void> addConversationUsers({
    required String conversationId,
    required List<String> userIds,
  }) async {
    final writes = <Map<String, dynamic>>[];
    for (final userId in userIds) {
      final updateId = _uuid.v4();
      writes.add(firestore.updateWrite(
        _updatePath(userId, updateId),
        {
          'updateId': updateId,
          'updateType': 'new_conversation_users',
          'conversationId': conversationId,
          'userIds': [...userIds, currentUserId],
          'isGroup': true,
          'senderId': currentUserId,
          'timestamp': DateTime.now().toUtc(),
        },
      ));
    }
    if (writes.isNotEmpty) await firestore.batchWrite(writes);
  }

  // Future<void> addConversationUsers({
  //   required String conversationId,
  //   required List<String> userIds,
  // }) => addConversationUsers(
  //       conversationId: conversationId,
  //       userIds: userIds,
  //     );

  // ─── removeConversationUsers ─────────────────────────────────────────────
  @override
  Future<void> removeConversationUsers({
    required String conversationId,
    required List<String> userIds,
  }) async {
    final writes = <Map<String, dynamic>>[];
    for (final userId in userIds) {
      final updateId = _uuid.v4();
      writes.add(firestore.updateWrite(
        _updatePath(userId, updateId),
        {
          'updateId': updateId,
          'updateType': 'removed_from_conversation',
          'conversationId': conversationId,
          'userId': userId,
          'timestamp': DateTime.now().toUtc(),
          'senderId': currentUserId,
        },
      ));
    }
    if (writes.isNotEmpty) await firestore.batchWrite(writes);
  }

  // Future<void> removeConversationUsers({
  //   required String conversationId,
  //   required String userId,
  // }) => removeConversationUsers(
  //       conversationId: conversationId,
  //       userIds: [userId],
  //     );

  // ─── startListening / stopListening ──────────────────────────────────────
  /// NOT SUPPORTED on the server.
  ///
  /// The server does not open real-time Firestore listeners. Flutter clients
  /// listen directly via cloud_firestore. Throws [UnsupportedError].
  @override
  Future<void> startListening({
    required String currentUserId,
    void Function({required String conversationId, required List<String> userIds})? onConversationUsersRemoved,
    void Function({required String conversationId, required String receiverId, required List<String> messageIds})? onConversationRead,
    void Function({required AcChatConversation conversation})? onConversationUpdate,
    void Function({required AcChatConversationUser conversationUser})? onConversationUserUpdate,
    void Function({required List<String> messageIds, required String conversationId, required String receiverId})? onMessagesDelivered,
    void Function({required List<String> messageIds, required String conversationId, required String receiverId})? onMessagesRead,
    required void Function({required AcChatMessage message}) onMessageReceived,
    void Function({required Map<String, dynamic> updateData, required String messageId, required String conversationId})? onMessageUpdate,
    void Function({required AcChatConversation conversation, required List<String> userIds})? onNewConversation,
    void Function({required String conversationId, required List<String> userIds})? onNewConversationUsers,
    void Function({required String conversationId, required String userId, required bool isTyping})? onUserTyping,
    void Function({
      required AcChatConversation conversation,
      required List<AcChatConversationUser> users,
    })? onConversationChanged,
    void Function({required List<AcChatUser> users})? onUsersLoaded,
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
  }) {
    throw UnsupportedError(
      'AcChatFirebaseServer does not support startListening. '
      'Use the Flutter client adapter (AcChatFirebase) for real-time listening.',
    );
  }

  @override
  Future<void> stopListening() async {
    // No-op — server never started listening.
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  Map<String, dynamic> _messageToUpdatePayload(
    AcChatMessage msg, {
    required String updateId,
    List<String>? userIds,
    bool isGroup = false,
    Map<String, dynamic>? notificationPayload,
  }) {
    return {
      'updateId': updateId,
      'updateType': 'message',
      'messageType': msg.type,
      'conversationId': msg.conversationId,
      'messageId': msg.messageId,
      'senderId': msg.senderId,
      'text': msg.text,
      'time': msg.time,
      'timestamp': msg.time,
      'status': msg.status,
      if (msg.mediaCaption != null) 'mediaCaption': msg.mediaCaption,
      if (msg.duration != null) 'duration': msg.duration,
      if (msg.fileName != null) 'fileName': msg.fileName,
      if (msg.fileSize != null) 'fileSize': msg.fileSize,
      if (msg.replyTo?.messageId != null) 'replyToId': msg.replyTo!.messageId,
      if (userIds != null) 'userIds': userIds,
      'isGroup': isGroup,
      if (msg.fileUrl != null) 'fileUrl': msg.fileUrl,
      if (msg.reactions.isNotEmpty) 'reactions': msg.reactions,
      if (msg.mentions.isNotEmpty) 'mentions': msg.mentions,
      if (msg.isStarred) 'isStarred': true,
      if (msg.deliveredTime != null) 'deliveredTime': msg.deliveredTime,
      if (msg.readTime != null) 'readTime': msg.readTime,
      if (msg.editedTime != null) 'editedTime': msg.editedTime,
      if (notificationPayload != null) 'notification': notificationPayload,
    };
  }

  @override
  Future<void> Function({required String conversationId, required String messageId})? onMessageFlushed;
}