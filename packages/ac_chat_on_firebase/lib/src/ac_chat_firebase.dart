import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:uuid/uuid.dart';

import 'ac_chat_firebase_config.dart';
import 'firestore_extensions.dart';

/// Firebase backend adapter for `ac_chat` using **pure user updates mailbox**.
///
/// Designed to satisfy [AcChatSyncChannel] for `ac_chat_sqlite` as well as
/// functioning as a standalone `AcChatApi` provider if desired.
///
/// Every chat event (messages, metadata, updates, typing, read receipts) is
/// delivered directly to recipient user mailboxes: `users/{userId}/updates/{updateId}`.
/// All methods strictly use named parameters.
class AcChatFirebase implements AcChatSyncChannel {
  // ─── Constructor ──────────────────────────────────────────────────────────

  AcChatFirebase({
    required String currentUserId,
    FirebaseApp? app,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    AcChatFirebaseConfig? config,
  })  : _currentUserId = currentUserId,
        _config = config ?? const AcChatFirebaseConfig() {
    if (firestore != null) {
      _firestore = firestore;
    } else if (app != null) {
      _firestore = FirebaseFirestore.instanceFor(app: app);
    } else {
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (_) {}
    }

    if (storage != null) {
      _storage = storage;
    } else if (app != null) {
      _storage = FirebaseStorage.instanceFor(app: app);
    } else {
      try {
        _storage = FirebaseStorage.instance;
      } catch (_) {}
    }
  }

  // ─── Private fields ────────────────────────────────────────────────────────

  String _currentUserId;
  final AcChatFirebaseConfig _config;

  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;

  /// Exposes the configured [FirebaseStorage] instance.
  FirebaseStorage get storage => _storage;

  final _uuid = const Uuid();

  // ── In-memory state ────────────────────────────────────────────────────────

  final List<AcChatUser> _users = [];
  final List<AcChatConversation> _conversations = [];
  final Map<String, List<AcChatConversationUser>> _members = {};
  final Map<String, List<AcChatMessage>> _messages = {};

  final Map<String, AcChatUser> _userIndex = {};
  final Map<String, AcChatMessage> _messageIndex = {};
  final Map<String, AcChatConversation> _conversationIndex = {};

  final Set<String> _processedUpdateIds = {};
  final Set<String> _knownMessageIds = {};

  final List<StreamSubscription> _subscriptions = [];
  bool _initialized = false;

  // ── Channel callbacks ──────────────────────────────────────────────────────

  void Function({required AcChatMessage message})? _onMessageReceived;
  void Function({
    required AcChatConversation conversation,
    required List<AcChatConversationUser> members,
  })? _onConversationChanged;
  void Function({required List<AcChatUser> users})? _onUsersLoaded;
  void Function({
    required String messageId,
    required String conversationId,
    required String status,
  })? _onMessageStatusUpdated;
  void Function({
    required String conversationId,
    required String userId,
    required bool isTyping,
  })? _onTypingChanged;
  void Function({
    required String userId,
    required bool isOnline,
  })? _onUserPresenceChanged;

  bool get _isChannelMode => _onMessageReceived != null;

  VoidCallback? onDataChanged;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _loadUsers();
      await _setupUserChannelListener();
    } catch (e, st) {
      _log('initialize error', e, st);
      rethrow;
    }
  }

  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _initialized = false;
    _processedUpdateIds.clear();
    _knownMessageIds.clear();
  }

  // ─── AcChatSyncChannel Implementation ──────────────────────────────────────

  @override
  Future<void> sendMessage({
    required AcChatMessage message,
    required List<String> recipientIds,
    Map<String, dynamic>? notificationPayload,
  }) async {
    final targets = recipientIds.isNotEmpty
        ? recipientIds
        : (_members[message.conversationId]?.map((m) => m.userId).where((id) => id != _currentUserId).toList() ??
            _conversationIndex[message.conversationId]?.memberIds.where((id) => id != _currentUserId).toList() ??
            []);

    final conv = _conversationIndex[message.conversationId];
    final batch = _firestore.batch();

    for (final recipientId in targets) {
      if (recipientId == _currentUserId) continue;
      final updateId = _uuid.v4();
      final updateRef = _firestore
          .collection(_config.usersCollection)
          .doc(recipientId)
          .collection(_config.updatesSubcollection)
          .doc(updateId);

      final payload = FirestoreExtensions.messageToUpdatePayload(
        message,
        memberIds: conv?.memberIds ?? [_currentUserId, ...targets],
        groupName: conv?.groupName,
        isGroup: conv?.type == 'group',
      );
      payload[FirestoreExtensions.fUpdateId] = updateId;
      if (notificationPayload != null) {
        payload['notification'] = notificationPayload;
      }

      batch.set(updateRef, payload);
    }
    await batch.commit();
  }

  @override
  Future<void> createConversation({
    required AcChatConversation conversation,
    required List<String> memberIds,
    Map<String, dynamic>? notificationPayload,
  }) async {
    try {
      final allMembers = Set<String>.from(memberIds);
      if (_currentUserId.isNotEmpty) allMembers.add(_currentUserId);
      conversation.memberIds = allMembers.toList();

      _conversationIndex[conversation.conversationId] = conversation;
      _conversations.removeWhere((c) => c.conversationId == conversation.conversationId);
      _conversations.insert(0, conversation);
      _members[conversation.conversationId] = allMembers
          .map((uid) => AcChatConversationUser()
            ..conversationId = conversation.conversationId
            ..userId = uid)
          .toList();

      final batch = _firestore.batch();
      for (final recipientId in allMembers) {
        if (recipientId == _currentUserId) continue;
        final updateId = _uuid.v4();
        final updateRef = _firestore
            .collection(_config.usersCollection)
            .doc(recipientId)
            .collection(_config.updatesSubcollection)
            .doc(updateId);

        batch.set(updateRef, {
          FirestoreExtensions.fUpdateId: updateId,
          FirestoreExtensions.fUpdateType: AcChatUpdateType.conversation,
          FirestoreExtensions.fConversationId: conversation.conversationId,
          FirestoreExtensions.fMemberIds: allMembers.toList(),
          FirestoreExtensions.fGroupName: conversation.groupName,
          FirestoreExtensions.fIsGroup: conversation.type == 'group',
          FirestoreExtensions.fTimestamp: Timestamp.fromDate(conversation.lastTime),
          FirestoreExtensions.fSenderId: _currentUserId,
          if (notificationPayload != null) 'notification': notificationPayload,
        });
      }
      await batch.commit();
    } catch (e, st) {
      _log('createConversation error', e, st);
      rethrow;
    }
  }

  @override
  Future<void> markAsRead({
    required String conversationId,
    required String currentUserId,
    List<String>? messageIds,
  }) async {
    final conv = _conversationIndex[conversationId];
    if (conv != null) {
      conv.unread = 0;
      if (!_isChannelMode) {
        _notifyDataChanged();
      }
    }
  }

  @override
  Future<void> sendDeliveryReceipt({
    required String messageId,
    required String conversationId,
    required String senderId,
  }) async {
    if (senderId.isEmpty || senderId == _currentUserId) return;
    try {
      final updateId = _uuid.v4();
      await _firestore
          .collection(_config.usersCollection)
          .doc(senderId)
          .collection(_config.updatesSubcollection)
          .doc(updateId)
          .set({
        FirestoreExtensions.fUpdateId: updateId,
        FirestoreExtensions.fUpdateType: AcChatUpdateType.messageUpdate,
        FirestoreExtensions.fConversationId: conversationId,
        FirestoreExtensions.fMessageId: messageId,
        FirestoreExtensions.fSenderId: _currentUserId,
        FirestoreExtensions.fTimestamp: FieldValue.serverTimestamp(),
        FirestoreExtensions.fData: {
          FirestoreExtensions.fStatus: 'delivered',
          'delivered_time': DateTime.now().millisecondsSinceEpoch,
        },
      });
    } catch (e, st) {
      _log('sendDeliveryReceipt error', e, st);
    }
  }

  @override
  Future<void> sendReadReceipt({
    required String conversationId,
    required String senderId,
    required List<String> messageIds,
  }) async {
    if (senderId.isEmpty || senderId == _currentUserId || messageIds.isEmpty) return;
    try {
      final batch = _firestore.batch();
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      for (final msgId in messageIds) {
        final updateId = _uuid.v4();
        final updateRef = _firestore
            .collection(_config.usersCollection)
            .doc(senderId)
            .collection(_config.updatesSubcollection)
            .doc(updateId);

        batch.set(updateRef, {
          FirestoreExtensions.fUpdateId: updateId,
          FirestoreExtensions.fUpdateType: AcChatUpdateType.messageUpdate,
          FirestoreExtensions.fConversationId: conversationId,
          FirestoreExtensions.fMessageId: msgId,
          FirestoreExtensions.fSenderId: _currentUserId,
          FirestoreExtensions.fTimestamp: FieldValue.serverTimestamp(),
          FirestoreExtensions.fData: {
            FirestoreExtensions.fStatus: 'read',
            'read_time': nowMs,
          },
        });
      }
      await batch.commit();
    } catch (e, st) {
      _log('sendReadReceipt error', e, st);
    }
  }

  @override
  Future<void> sendTypingIndicator({
    required String conversationId,
    required List<String> recipientIds,
    required bool isTyping,
  }) async {
    try {
      final batch = _firestore.batch();
      for (final recipientId in recipientIds) {
        if (recipientId == _currentUserId) continue;
        final updateId = _uuid.v4();
        final updateRef = _firestore
            .collection(_config.usersCollection)
            .doc(recipientId)
            .collection(_config.updatesSubcollection)
            .doc(updateId);

        batch.set(updateRef, {
          FirestoreExtensions.fUpdateId: updateId,
          FirestoreExtensions.fUpdateType: 'typing',
          FirestoreExtensions.fConversationId: conversationId,
          FirestoreExtensions.fSenderId: _currentUserId,
          FirestoreExtensions.fTimestamp: FieldValue.serverTimestamp(),
          'is_typing': isTyping,
        });
      }
      await batch.commit();
    } catch (e, st) {
      _log('sendTypingIndicator error', e, st);
    }
  }

  @override
  Future<void> updateMessage({
    required String messageId,
    required String conversationId,
    required Map<String, dynamic> data,
    required List<String> recipientIds,
  }) async {
    try {
      final msg = _messageIndex[messageId];
      if (msg != null) {
        if (data.containsKey(FirestoreExtensions.fText)) {
          msg.text = data[FirestoreExtensions.fText] as String;
        }
        if (data.containsKey(FirestoreExtensions.fStatus)) {
          msg.status = data[FirestoreExtensions.fStatus] as String;
        }
      }

      final targets = recipientIds.isNotEmpty
          ? recipientIds
          : (_members[conversationId]?.map((m) => m.userId).where((id) => id != _currentUserId).toList() ?? []);

      final batch = _firestore.batch();
      for (final recipientId in targets) {
        if (recipientId == _currentUserId) continue;
        final updateId = _uuid.v4();
        final updateRef = _firestore
            .collection(_config.usersCollection)
            .doc(recipientId)
            .collection(_config.updatesSubcollection)
            .doc(updateId);

        batch.set(updateRef, {
          FirestoreExtensions.fUpdateId: updateId,
          FirestoreExtensions.fUpdateType: AcChatUpdateType.messageUpdate,
          FirestoreExtensions.fConversationId: conversationId,
          FirestoreExtensions.fMessageId: messageId,
          FirestoreExtensions.fSenderId: _currentUserId,
          FirestoreExtensions.fTimestamp: FieldValue.serverTimestamp(),
          FirestoreExtensions.fData: data,
        });
      }
      await batch.commit();
    } catch (e, st) {
      _log('updateMessage error', e, st);
    }
  }

  @override
  Future<void> addGroupMembers({
    required String conversationId,
    required List<String> memberIds,
  }) async {
    try {
      final batch = _firestore.batch();
      for (final recipientId in memberIds) {
        if (recipientId == _currentUserId) continue;
        final updateId = _uuid.v4();
        final updateRef = _firestore
            .collection(_config.usersCollection)
            .doc(recipientId)
            .collection(_config.updatesSubcollection)
            .doc(updateId);

        batch.set(updateRef, {
          FirestoreExtensions.fUpdateId: updateId,
          FirestoreExtensions.fUpdateType: AcChatUpdateType.conversation,
          FirestoreExtensions.fConversationId: conversationId,
          FirestoreExtensions.fMemberIds: memberIds,
          FirestoreExtensions.fTimestamp: FieldValue.serverTimestamp(),
          FirestoreExtensions.fSenderId: _currentUserId,
        });
      }
      await batch.commit();
    } catch (e, st) {
      _log('addGroupMembers error', e, st);
    }
  }

  @override
  Future<void> removeGroupMember({
    required String conversationId,
    required String userId,
  }) async {
    try {
      final updateId = _uuid.v4();
      await _firestore
          .collection(_config.usersCollection)
          .doc(userId)
          .collection(_config.updatesSubcollection)
          .doc(updateId)
          .set({
        FirestoreExtensions.fUpdateId: updateId,
        FirestoreExtensions.fUpdateType: 'removed_from_conversation',
        FirestoreExtensions.fConversationId: conversationId,
        FirestoreExtensions.fTimestamp: FieldValue.serverTimestamp(),
        FirestoreExtensions.fSenderId: _currentUserId,
      });
    } catch (e, st) {
      _log('removeGroupMember error', e, st);
    }
  }

  @override
  Future<void> acknowledgeUpdate({required String updateId}) async {
    try {
      await _firestore
          .collection(_config.usersCollection)
          .doc(_currentUserId)
          .collection(_config.updatesSubcollection)
          .doc(updateId)
          .delete();
    } catch (e, st) {
      _log('acknowledgeUpdate error', e, st);
    }
  }

  @override
  Future<void> startListening({
    required String currentUserId,
    required void Function({required AcChatMessage message}) onMessageReceived,
    required void Function({
      required AcChatConversation conversation,
      required List<AcChatConversationUser> members,
    }) onConversationChanged,
    required void Function({required List<AcChatUser> users}) onUsersLoaded,
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
  }) async {
    _currentUserId = currentUserId;
    _onMessageReceived = onMessageReceived;
    _onConversationChanged = onConversationChanged;
    _onUsersLoaded = onUsersLoaded;
    _onMessageStatusUpdated = onMessageStatusUpdated;
    _onTypingChanged = onTypingChanged;
    _onUserPresenceChanged = onUserPresenceChanged;

    await initialize();
  }

  @override
  Future<void> stopListening() async {
    dispose();
  }

  // ─── Firestore Data Loading ────────────────────────────────────────────────

  Future<void> _loadUsers() async {
    final col = _firestore.collection(_config.usersCollection);

    try {
      final snapshot = await col.get();
      _applyUsersSnapshot(snapshot.docs);
    } catch (e, st) {
      _log('initial users load error', e, st);
    }

    final sub = col.snapshots().listen(
      (snap) {
        _applyUsersSnapshot(snap.docs);
        if (_isChannelMode) {
          _onUsersLoaded?.call(users: List.unmodifiable(_users));
        } else {
          _notifyDataChanged();
        }
      },
      onError: (Object e, StackTrace st) => _log('users listener error', e, st),
    );
    _subscriptions.add(sub);
  }

  void _applyUsersSnapshot(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    _users.clear();
    _userIndex.clear();
    for (final doc in docs) {
      final user = FirestoreExtensions.userFromQueryDoc(doc);
      _users.add(user);
      _userIndex[user.userId] = user;
    }
  }

  Future<void> _setupUserChannelListener() async {
    if (_currentUserId.isEmpty) return;

    final userUpdatesCol = _firestore
        .collection(_config.usersCollection)
        .doc(_currentUserId)
        .collection(_config.updatesSubcollection)
        .orderBy(FirestoreExtensions.fTimestamp, descending: false)
        .limitToLast(_config.updatesPageSize);

    final sub = userUpdatesCol.snapshots().listen(
      (snap) {
        for (final change in snap.docChanges) {
          if (change.type == DocumentChangeType.added ||
              change.type == DocumentChangeType.modified) {
            final doc = change.doc;
            final updateId = doc.id;
            if (_processedUpdateIds.contains(updateId)) {
              continue;
            }
            _processedUpdateIds.add(updateId);

            _processIncomingUpdate(doc.data() ?? {}, updateId);

            if (_config.autoAcknowledgeUpdates) {
              acknowledgeUpdate(updateId: updateId);
            }
          }
        }
      },
      onError: (Object e, StackTrace st) =>
          _log('user updates listener error for $_currentUserId', e, st),
    );
    _subscriptions.add(sub);
  }

  void _processIncomingUpdate(Map<String, dynamic> data, String docId) {
    try {
      final type = data[FirestoreExtensions.fUpdateType] as String? ?? '';
      final convId = data[FirestoreExtensions.fConversationId] as String? ?? '';
      final msgId = (data[FirestoreExtensions.fMessageId] as String?) ?? docId;
      final senderId = data[FirestoreExtensions.fSenderId] as String?;

      if (convId.isEmpty && type != 'presence') return;

      if (type == 'typing') {
        final isTyping = data['is_typing'] as bool? ?? false;
        _onTypingChanged?.call(
          conversationId: convId,
          userId: senderId ?? '',
          isTyping: isTyping,
        );
        return;
      }

      if (type == 'presence') {
        final isOnline = data['is_online'] as bool? ?? false;
        _onUserPresenceChanged?.call(
          userId: senderId ?? '',
          isOnline: isOnline,
        );
        return;
      }

      // Ensure conversation exists in local memory
      AcChatConversation? conv = _conversationIndex[convId];
      if (conv == null && convId.isNotEmpty) {
        conv = FirestoreExtensions.conversationFromUpdateData(data);
        _conversationIndex[convId] = conv;
        _conversations.removeWhere((c) => c.conversationId == convId);
        _conversations.insert(0, conv);

        final memberList = conv.memberIds
            .map((uid) => AcChatConversationUser()
              ..conversationId = convId
              ..userId = uid)
            .toList();
        _members[convId] = memberList;

        if (_isChannelMode) {
          _onConversationChanged?.call(
            conversation: conv,
            members: memberList,
          );
        }
      }

      if (type == AcChatUpdateType.message || type == 'message') {
        if (_knownMessageIds.contains(msgId) && !_isChannelMode) {
          return;
        }

        final replyToId = data[FirestoreExtensions.fReplyToId] as String?;
        final resolvedReply = replyToId != null ? _messageIndex[replyToId] : null;

        final msg = FirestoreExtensions.messageFromUpdateData(
          data,
          docId: msgId,
          resolvedReplyTo: resolvedReply,
        );

        _upsertMessage(convId, msg);
        _knownMessageIds.add(msg.messageId);

        if (conv != null) {
          conv.lastMessage = msg.text;
          conv.lastMessageType = msg.type;
          conv.lastTime = msg.time;
          _conversations.sort((a, b) => b.lastTime.compareTo(a.lastTime));
        }

        if (_isChannelMode) {
          _onMessageReceived?.call(message: msg);
        } else {
          if (msg.senderId != _currentUserId && conv != null) {
            conv.unread += 1;
          }
          _notifyDataChanged();
        }
      } else if (type == AcChatUpdateType.conversation || type == 'conversation') {
        if (_isChannelMode && conv != null) {
          _onConversationChanged?.call(
            conversation: conv,
            members: _members[convId] ?? [],
          );
        } else {
          _notifyDataChanged();
        }
      } else if (type == AcChatUpdateType.messageUpdate || type == 'message_update') {
        final existingMsg = _messageIndex[msgId];
        final updatePayload = data[FirestoreExtensions.fData] as Map<String, dynamic>? ?? {};

        if (existingMsg != null) {
          if (updatePayload.containsKey(FirestoreExtensions.fText)) {
            existingMsg.text = updatePayload[FirestoreExtensions.fText] as String;
          }
          if (updatePayload.containsKey(FirestoreExtensions.fStatus)) {
            existingMsg.status = updatePayload[FirestoreExtensions.fStatus] as String;
          }
          _upsertMessage(convId, existingMsg);

          if (_isChannelMode) {
            _onMessageReceived?.call(message: existingMsg);
            if (updatePayload.containsKey(FirestoreExtensions.fStatus)) {
              _onMessageStatusUpdated?.call(
                messageId: msgId,
                conversationId: convId,
                status: updatePayload[FirestoreExtensions.fStatus] as String,
              );
            }
          } else {
            _notifyDataChanged();
          }
        }
      } else if (type == AcChatUpdateType.read || type == 'read') {
        if (senderId == _currentUserId && conv != null) {
          conv.unread = 0;
          if (!_isChannelMode) {
            _notifyDataChanged();
          }
        }
      }
    } catch (e, st) {
      _log('processIncomingUpdate error', e, st);
    }
  }

  void _upsertMessage(String convId, AcChatMessage msg) {
    final list = _messages[convId] ??= [];
    final idx = list.indexWhere((m) => m.messageId == msg.messageId);
    if (idx >= 0) {
      list[idx] = msg;
    } else {
      list.add(msg);
    }
    _messageIndex[msg.messageId] = msg;
  }

  // ─── Public API Builder (Standalone Mode) ──────────────────────────────

  AcChatApi buildApi({
    required AcChatTheme theme,
    FutureOr<AcChatUser?> Function({required BuildContext context})? onNewContact,
    FutureOr<void> Function({required BuildContext context})? onNewGroup,
    List<AcChatUser> Function()? getContacts,
    String? contactsSectionTitle,
    String? newContactLabel,
    String? newContactSubtitle,
    String? newGroupLabel,
    String? newGroupSubtitle,
    FutureOr<List<AcChatUser>> Function({required String query})? onSearchRemoteUsers,
    Widget? Function({required BuildContext context, required AcChatMessage message})? customMessageBuilder,
    void Function({required AcChatMessage message})? onMessageTap,
    Widget? Function({required BuildContext context, required AcChatConversation conversation})? customInputBuilder,
    bool? enableVideoCall,
    bool? enableVoiceCall,
    bool? showNewConversationButton,
    bool? searchConversations,
    bool? pinConversations,
    bool? showConversationMenu,
    bool? showOnlineStatus,
    bool? readOnly,
  }) {
    return AcChatApi(
      theme: theme,
      getCurrentUser: _getCurrentUser,
      getUsers: _getUsers,
      getUserById: ({required String userId}) => _getUserById(userId),
      getConversations: _getConversations,
      getConversationUsers: ({required String conversationId}) =>
          _getConversationUsers(conversationId),
      getMessages: ({required String conversationId}) =>
          _getMessages(conversationId),
      sendMessage: ({required AcChatMessage message}) =>
          _sendMessageStandalone(message),
      markAsRead: ({required String conversationId}) =>
          _markAsReadStandalone(conversationId),
      insertConversation: ({required AcChatConversation newConv, required String otherUserId}) =>
          _insertConversation(newConv, otherUserId),
      updateMessage: ({required String messageId, required Map<String, dynamic> data}) =>
          _updateMessageStandalone(messageId, data),
      onNewContact: onNewContact,
      onNewGroup: onNewGroup,
      getContacts: getContacts,
      contactsSectionTitle: contactsSectionTitle,
      newContactLabel: newContactLabel,
      newContactSubtitle: newContactSubtitle,
      newGroupLabel: newGroupLabel,
      newGroupSubtitle: newGroupSubtitle,
      onSearchRemoteUsers: onSearchRemoteUsers,
      customMessageBuilder: customMessageBuilder,
      onMessageTap: onMessageTap,
      customInputBuilder: customInputBuilder,
      enableVideoCall: enableVideoCall ?? true,
      enableVoiceCall: enableVoiceCall ?? true,
      showNewConversationButton: showNewConversationButton ?? true,
      searchConversations: searchConversations ?? true,
      pinConversations: pinConversations ?? true,
      showConversationMenu: showConversationMenu ?? true,
      showOnlineStatus: showOnlineStatus ?? true,
      readOnly: readOnly ?? false,
    );
  }

  AcChatUser _getCurrentUser() {
    return _userIndex[_currentUserId] ??
        (AcChatUser()
          ..userId = _currentUserId
          ..name = 'Me');
  }

  List<AcChatUser> _getUsers() => List.unmodifiable(_users);

  AcChatUser? _getUserById(String userId) => _userIndex[userId];

  List<AcChatConversation> _getConversations() => List.unmodifiable(_conversations);

  List<AcChatConversationUser> _getConversationUsers(String conversationId) =>
      List.unmodifiable(_members[conversationId] ?? []);

  List<AcChatMessage> _getMessages(String conversationId) =>
      List.unmodifiable(_messages[conversationId] ?? []);

  void _markAsReadStandalone(String conversationId) {
    _conversationIndex[conversationId]?.unread = 0;
    final idx = _conversations.indexWhere((c) => c.conversationId == conversationId);
    if (idx >= 0) _conversations[idx].unread = 0;
    _notifyDataChanged();
  }

  AcChatConversation _insertConversation(
    AcChatConversation newConv,
    String otherUserId,
  ) {
    if (newConv.conversationId.isEmpty) {
      newConv.conversationId = _uuid.v4();
    }
    final allMembers = {_currentUserId, otherUserId}.where((id) => id.isNotEmpty).toList();
    newConv.memberIds = allMembers;

    _conversationIndex[newConv.conversationId] = newConv;
    _conversations.insert(0, newConv);
    _members[newConv.conversationId] = allMembers
        .map((uid) => AcChatConversationUser()
          ..conversationId = newConv.conversationId
          ..userId = uid)
        .toList();
    _messages[newConv.conversationId] = [];

    createConversation(
      conversation: newConv,
      memberIds: allMembers,
    ).catchError((Object e) {
      _log('insertConversation error', e, StackTrace.current);
      return null;
    });

    _notifyDataChanged();
    return newConv;
  }

  void _sendMessageStandalone(AcChatMessage msg) {
    if (msg.messageId.isEmpty) {
      msg.messageId = _uuid.v4();
    }
    msg.status = 'sending';
    _upsertMessage(msg.conversationId, msg);
    _notifyDataChanged();

    sendMessage(
      message: msg,
      recipientIds: _members[msg.conversationId]?.map((m) => m.userId).where((id) => id != _currentUserId).toList() ?? [],
    ).then((_) {
      msg.status = 'sent';
      _upsertMessage(msg.conversationId, msg);
      _notifyDataChanged();
    }).catchError((Object e) {
      msg.status = 'failed';
      _upsertMessage(msg.conversationId, msg);
      _notifyDataChanged();
    });
  }

  void _updateMessageStandalone(String messageId, Map<String, dynamic> data) {
    final msg = _messageIndex[messageId];
    if (msg == null) return;

    updateMessage(
      messageId: messageId,
      conversationId: msg.conversationId,
      data: data,
      recipientIds: _members[msg.conversationId]?.map((m) => m.userId).where((id) => id != _currentUserId).toList() ?? [],
    ).catchError((Object e) {
      _log('updateMessage background error', e, StackTrace.current);
      return null;
    });
  }

  void _notifyDataChanged() {
    onDataChanged?.call();
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    developer.log(
      message,
      name: 'AcChatFirebase',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
