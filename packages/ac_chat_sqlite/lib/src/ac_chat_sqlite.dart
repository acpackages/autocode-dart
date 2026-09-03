import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:ac_chat/ac_chat.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'ac_chat_data_dictionary.dart';
import 'ac_chat_sqlite_config.dart';

// ─── Column name constants ──────────────────────────────────────────────────

abstract class _C {
  // users
  static const userId = 'user_id';
  static const name = 'name';
  static const username = 'username';
  static const email = 'email';
  static const phone = 'phone';
  static const avatar = 'avatar';

  // conversations
  static const conversationId = 'conversation_id';
  static const type = 'type';
  static const groupName = 'group_name';
  static const groupAvatar = 'group_avatar';
  static const lastMessage = 'last_message';
  static const lastMessageType = 'last_message_type';
  static const lastTime = 'last_time';
  static const unread = 'unread';
  static const isPinned = 'is_pinned';
  static const isMuted = 'is_muted';

  // conversation_members
  static const memberId = 'member_id';
  static const role = 'role';

  // messages
  static const messageId = 'message_id';
  static const senderId = 'sender_id';
  static const text = 'text';
  static const time = 'time';
  static const status = 'status';
  static const mediaCaption = 'media_caption';
  static const amount = 'amount';
  static const paymentNote = 'payment_note';
  static const duration = 'duration';
  static const fileName = 'file_name';
  static const fileSize = 'file_size';
  static const isDownloaded = 'is_downloaded';
  static const localPath = 'local_path';
  static const replyToId = 'reply_to_id';
  static const deliveredTime = 'delivered_time';
  static const readTime = 'read_time';
  static const isEdited = 'is_edited';
  static const editedTime = 'edited_time';
  static const isDeleted = 'is_deleted';
  static const reactionsJson = 'reactions_json';

  // outbox_messages
  static const outboxId = 'outbox_id';
  static const recipientIdsJson = 'recipient_ids_json';
  static const retryCount = 'retry_count';
  static const createdAt = 'created_at';
}

// ─── Table name constants ────────────────────────────────────────────────────

abstract class _T {
  static const users = 'users';
  static const conversations = 'conversations';
  static const conversationMembers = 'conversation_members';
  static const messages = 'messages';
  static const outboxMessages = 'outbox_messages';
  static const messagesFts = 'messages_fts';
}

/// Offline-first SQLite cache layer for `ac_chat`.
///
/// Strictly uses [AcSqlDbTable] for all schema persistence and CRUD operations.
/// Raw SQL statements are forbidden. Synchronous in-memory reads, background SQLite writes.
class AcChatSqlite {
  // ─── Constructor ───────────────────────────────────────────────────────

  AcChatSqlite({
    required String currentUserId,
    AcChatSyncChannel? channel,
    AcChatSqliteConfig? config,
    AcChatConnectivityProvider? connectivityProvider,
    AcChatMediaUploader? mediaUploader,
    AcChatCryptoProvider? cryptoProvider,
  })  : _currentUserId = currentUserId,
        _channel = channel,
        _config = config ?? const AcChatSqliteConfig(),
        _connectivityProvider = connectivityProvider,
        _mediaUploader = mediaUploader,
        _cryptoProvider = cryptoProvider;

  // ─── Private fields ────────────────────────────────────────────────────

  final String _currentUserId;
  AcChatSyncChannel? _channel;
  final AcChatSqliteConfig _config;
  final AcChatConnectivityProvider? _connectivityProvider;
  final AcChatMediaUploader? _mediaUploader;
  final AcChatCryptoProvider? _cryptoProvider;
  final _uuid = const Uuid();

  late AcSqliteDao _dao;

  late AcSqlDbTable _tblUsers;
  late AcSqlDbTable _tblConversations;
  late AcSqlDbTable _tblMembers;
  late AcSqlDbTable _tblMessages;
  late AcSqlDbTable _tblOutbox;
  late AcSqlDbTable _tblMessagesFts;

  bool _initialized = false;

  // ── In-memory state ────────────────────────────────────────────────────

  final List<AcChatUser> _users = [];
  final List<AcChatConversation> _conversations = [];
  final Map<String, List<AcChatConversationUser>> _members = {};
  final Map<String, List<AcChatMessage>?> _messages = {};
  final Map<String, AcChatUser> _userIndex = {};
  final Map<String, AcChatMessage> _messageIndex = {};
  final Map<String, AcChatConversation> _conversationIndex = {};

  // ── Reactive Stream Controllers ────────────────────────────────────────

  final StreamController<List<AcChatConversation>> _conversationsStreamCtrl =
      StreamController<List<AcChatConversation>>.broadcast();

  final Map<String, StreamController<List<AcChatMessage>>> _messagesStreamCtrls = {};
  final Map<String, StreamController<Map<String, bool>>> _typingStreamCtrls = {};
  final Map<String, Map<String, bool>> _typingState = {};
  final Map<String, StreamController<bool>> _presenceStreamCtrls = {};
  final Map<String, bool> _presenceState = {};

  StreamSubscription<bool>? _connectivitySub;
  Timer? _outboxDrainTimer;
  bool _isDrainingOutbox = false;

  VoidCallback? onDataChanged;

  /// Callback fired when an incoming message from another user is received and saved.
  void Function({required AcChatMessage message})? onMessageReceived;

  // ─── Lifecycle ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _openDatabase();
      await _loadInitialData();
    } catch (e, st) {
      _log('initialize error', e, st);
      rethrow;
    }

    // Bind connectivity-aware outbox draining
    final conn = _connectivityProvider;
    if (conn != null) {
      _connectivitySub = conn.watchIsOnline().listen((isOnline) {
        if (isOnline) {
          _drainOutbox();
        }
      });
    }

    // Start periodic background drain timer (every 30s)
    _outboxDrainTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _drainOutbox();
    });

    final ch = _channel;
    if (ch != null) {
      try {
        await ch.startListening(
          currentUserId: _currentUserId,
          onMessageReceived: ({required message}) => _handleIncomingMessage(message),
          onConversationChanged: ({required conversation, required members}) =>
              _handleConversationChanged(conversation, members),
          onUsersLoaded: ({required users}) => _handleUsersLoaded(users),
          onTypingChanged: ({required conversationId, required userId, required isTyping}) =>
              _handleIncomingTyping(conversationId: conversationId, userId: userId, isTyping: isTyping),
          onUserPresenceChanged: ({required userId, required isOnline}) =>
              _handleIncomingPresence(userId: userId, isOnline: isOnline),
        );
      } catch (e, st) {
        _log('channel startListening error', e, st);
      }
    }
  }

  Future<void> dispose() async {
    _connectivitySub?.cancel();
    _outboxDrainTimer?.cancel();
    await _conversationsStreamCtrl.close();
    for (final ctrl in _messagesStreamCtrls.values) {
      await ctrl.close();
    }
    for (final ctrl in _typingStreamCtrls.values) {
      await ctrl.close();
    }
    for (final ctrl in _presenceStreamCtrls.values) {
      await ctrl.close();
    }
  }

  /// Attaches [channel] to this instance (post-initialization) and starts
  /// listening for remote mailbox updates asynchronously.
  /// Automatically triggers an outbox drain once attached.
  void startSync({required AcChatSyncChannel channel}) {
    if (identical(_channel, channel)) return;
    _channel = channel;
    channel.startListening(
      currentUserId: _currentUserId,
      onMessageReceived: ({required message}) => _handleIncomingMessage(message),
      onConversationChanged: ({required conversation, required members}) =>
          _handleConversationChanged(conversation, members),
      onUsersLoaded: ({required users}) => _handleUsersLoaded(users),
      onTypingChanged: ({required conversationId, required userId, required isTyping}) =>
          _handleIncomingTyping(conversationId: conversationId, userId: userId, isTyping: isTyping),
      onUserPresenceChanged: ({required userId, required isOnline}) =>
          _handleIncomingPresence(userId: userId, isOnline: isOnline),
    ).catchError((Object e, StackTrace st) {
      _log('startSync error', e, st);
      return null;
    });
    _drainOutbox();
  }

  /// Persists a user/contact into SQLite and updates the in-memory cache.
  Future<void> saveUser({required AcChatUser user}) async {
    await _upsertUser(user: user);
    final idx = _users.indexWhere((u) => u.userId == user.userId);
    if (idx >= 0) {
      _users[idx] = user;
    } else {
      _users.add(user);
    }
    _userIndex[user.userId] = user;
    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  // ─── Public API Builder ────────────────────────────────────────────────

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
      getUserById: _getUserById,
      getConversations: _getConversations,
      getConversationUsers: _getConversationUsers,
      getMessages: _getMessages,
      sendMessage: _sendMessage,
      markAsRead: _markAsRead,
      insertConversation: _insertConversation,
      updateMessage: _updateMessage,
      watchConversations: watchConversations,
      watchMessages: watchMessages,
      watchTyping: watchTyping,
      watchUserOnlineStatus: watchUserOnlineStatus,
      sendTypingIndicator: sendTypingIndicator,
      createGroupConversation: createGroupConversation,
      addGroupMembers: addGroupMembers,
      removeGroupMember: removeGroupMember,
      searchMessages: searchMessages,
      mediaUploader: _mediaUploader,
      cryptoProvider: _cryptoProvider,
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

  // ─── Reactive Streams ──────────────────────────────────────────────────

  Stream<List<AcChatConversation>> watchConversations() {
    return _conversationsStreamCtrl.stream;
  }

  Stream<List<AcChatMessage>> watchMessages({required String conversationId}) {
    return _messagesStreamCtrls
        .putIfAbsent(
          conversationId,
          () => StreamController<List<AcChatMessage>>.broadcast(),
        )
        .stream;
  }

  Stream<Map<String, bool>> watchTyping({required String conversationId}) {
    return _typingStreamCtrls
        .putIfAbsent(
          conversationId,
          () => StreamController<Map<String, bool>>.broadcast(),
        )
        .stream;
  }

  Stream<bool> watchUserOnlineStatus({required String userId}) {
    return _presenceStreamCtrls
        .putIfAbsent(
          userId,
          () => StreamController<bool>.broadcast(),
        )
        .stream;
  }

  Future<void> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    final memberList = _members[conversationId] ?? [];
    final recipientIds = memberList
        .map((m) => m.userId)
        .where((id) => id != _currentUserId)
        .toList();

    _channel?.sendTypingIndicator(
      conversationId: conversationId,
      isTyping: isTyping,
      recipientIds: recipientIds,
    ).catchError((Object e) {
      _log('sendTypingIndicator error', e, StackTrace.current);
      return null;
    });
  }

  // ─── In-Memory Read Getters ────────────────────────────────────────────

  AcChatUser _getCurrentUser() {
    return _userIndex[_currentUserId] ??
        (AcChatUser()
          ..userId = _currentUserId
          ..name = 'Me');
  }

  List<AcChatUser> _getUsers() {
    return List.unmodifiable(_users);
  }

  AcChatUser? _getUserById({required String userId}) {
    return _userIndex[userId];
  }

  List<AcChatConversation> _getConversations() {
    return List.unmodifiable(_conversations);
  }

  List<AcChatConversationUser> _getConversationUsers({
    required String conversationId,
  }) {
    return List.unmodifiable(_members[conversationId] ?? []);
  }

  List<AcChatMessage> _getMessages({required String conversationId}) {
    final cached = _messages[conversationId];
    if (cached != null) {
      return List.unmodifiable(cached);
    }

    _ensureMessagesLoaded(conversationId: conversationId).then((_) {
      _notifyMessagesChanged(conversationId: conversationId);
      onDataChanged?.call();
    }).catchError((Object e) {
      _log('_getMessages background load error for $conversationId', e, StackTrace.current);
      return null;
    });
    return const [];
  }

  // ─── Sending and Outbox Pipeline ───────────────────────────────────────

  void _sendMessage({required AcChatMessage message}) {
    if (message.messageId.isEmpty) {
      message.messageId = _uuid.v4();
    }
    message.status = 'sending';

    _sendMessageAsync(message: message).catchError((Object e) {
      _log('sendMessage async error', e, StackTrace.current);
      return null;
    });
  }

  Future<void> _sendMessageAsync({required AcChatMessage message}) async {
    await _ensureMessagesLoaded(conversationId: message.conversationId);

    // 1. Optimistic memory update
    _messages[message.conversationId]!.add(message);
    _messageIndex[message.messageId] = message;
    _updateConversationLastMessage(message: message);

    // 2. Persist to SQLite using AcSqlDbTable
    await _upsertMessage(message: message);
    await _updateConversationFields(
      conversationId: message.conversationId,
      fields: {
        _C.lastMessage: message.text,
        _C.lastMessageType: message.type,
        _C.lastTime: message.time.millisecondsSinceEpoch,
      },
    );

    // 3. Resolve recipients
    final memberList = _members[message.conversationId] ?? [];
    final recipientIds = memberList
        .map((m) => m.userId)
        .where((id) => id != _currentUserId)
        .toList();

    // 4. Save into Outbox
    final outboxId = _uuid.v4();
    await _tblOutbox.saveRow(
      row: {
        _C.outboxId: outboxId,
        _C.messageId: message.messageId,
        _C.conversationId: message.conversationId,
        _C.recipientIdsJson: jsonEncode(recipientIds),
        _C.retryCount: 0,
        _C.createdAt: DateTime.now().millisecondsSinceEpoch,
        _C.status: 'pending',
      },
      executeBeforeEvent: false,
      executeAfterEvent: false,
    );

    _notifyMessagesChanged(conversationId: message.conversationId);
    _notifyConversationsChanged();
    onDataChanged?.call();

    // 5. Attempt immediate channel transmission
    final ch = _channel;
    if (ch != null) {
      ch.sendMessage(
        message: message,
        recipientIds: recipientIds,
      ).then((_) async {
        message.status = 'sent';
        await _updateMessageFields(
          messageId: message.messageId,
          fields: {_C.status: 'sent'},
        );
        await _removeOutboxRow(outboxId: outboxId);
        _notifyMessagesChanged(conversationId: message.conversationId);
        onDataChanged?.call();
      }).catchError((Object e) {
        _log('channel.sendMessage transient error (queued in outbox)', e, StackTrace.current);
      });
    } else {
      // Offline mode: mark sent
      message.status = 'sent';
      await _updateMessageFields(
        messageId: message.messageId,
        fields: {_C.status: 'sent'},
      );
      await _removeOutboxRow(outboxId: outboxId);
      _notifyMessagesChanged(conversationId: message.conversationId);
      onDataChanged?.call();
    }
  }

  Future<void> _drainOutbox() async {
    if (_isDrainingOutbox || _channel == null) return;
    _isDrainingOutbox = true;

    try {
      final outboxResult = await _tblOutbox.getRows(
        condition: '${_C.status} = :status',
        parameters: {':status': 'pending'},
        orderBy: '${_C.createdAt} ASC',
      );

      if (outboxResult.isSuccess()) {
        for (final row in outboxResult.rows) {
          final outboxId = row[_C.outboxId] as String;
          final msgId = row[_C.messageId] as String;
          final convId = row[_C.conversationId] as String;
          final recipsJson = row[_C.recipientIdsJson] as String;
          final retryCount = (row[_C.retryCount] as int?) ?? 0;

          final msg = _messageIndex[msgId];
          if (msg == null) {
            await _removeOutboxRow(outboxId: outboxId);
            continue;
          }

          List<String> recipientIds = [];
          try {
            recipientIds = (jsonDecode(recipsJson) as List).cast<String>();
          } catch (_) {}

          try {
            await _channel!.sendMessage(
              message: msg,
              recipientIds: recipientIds,
            );
            msg.status = 'sent';
            await _updateMessageFields(
              messageId: msg.messageId,
              fields: {_C.status: 'sent'},
            );
            await _removeOutboxRow(outboxId: outboxId);
            _notifyMessagesChanged(conversationId: convId);
          } catch (e) {
            final nextRetry = retryCount + 1;
            await _tblOutbox.saveRow(
              row: {
                _C.outboxId: outboxId,
                _C.messageId: msgId,
                _C.conversationId: convId,
                _C.recipientIdsJson: recipsJson,
                _C.retryCount: nextRetry,
                _C.createdAt: row[_C.createdAt],
                _C.status: nextRetry > 5 ? 'failed' : 'pending',
              },
              executeBeforeEvent: false,
              executeAfterEvent: false,
            );
          }
        }
      }
    } catch (e, st) {
      _log('_drainOutbox error', e, st);
    } finally {
      _isDrainingOutbox = false;
    }
  }

  Future<void> _removeOutboxRow({required String outboxId}) async {
    try {
      await _tblOutbox.deleteRows(
        condition: '${_C.outboxId} = :outboxId',
        parameters: {':outboxId': outboxId},
      );
    } catch (e, st) {
      _log('_removeOutboxRow error', e, st);
    }
  }

  void _markAsRead({required String conversationId}) {
    final conv = _conversationIndex[conversationId];
    if (conv == null) return;

    conv.unread = 0;
    final idx = _conversations.indexWhere((c) => c.conversationId == conversationId);
    if (idx >= 0) _conversations[idx].unread = 0;

    _updateConversationFields(
      conversationId: conversationId,
      fields: {_C.unread: 0},
    ).catchError((Object e) => null);

    _notifyConversationsChanged();

    _channel?.markAsRead(
      conversationId: conversationId,
      currentUserId: _currentUserId,
    ).catchError((Object e) {
      _log('channel.markAsRead error', e, StackTrace.current);
      return null;
    });
  }

  AcChatConversation _insertConversation({
    required AcChatConversation newConv,
    required String otherUserId,
  }) {
    if (newConv.conversationId.isEmpty) {
      newConv.conversationId = _uuid.v4();
    }
    newConv.memberIds = [_currentUserId, otherUserId];
    newConv.lastTime = DateTime.now();

    _insertConversationAsync(newConv: newConv, otherUserId: otherUserId).catchError((Object e) {
      _log('insertConversation async error', e, StackTrace.current);
      return null;
    });

    _conversationIndex[newConv.conversationId] = newConv;
    _conversations.insert(0, newConv);

    final members = [
      AcChatConversationUser()
        ..conversationId = newConv.conversationId
        ..userId = _currentUserId,
      AcChatConversationUser()
        ..conversationId = newConv.conversationId
        ..userId = otherUserId,
    ];
    _members[newConv.conversationId] = members;
    _messages[newConv.conversationId] = [];

    _notifyConversationsChanged();
    onDataChanged?.call();
    return newConv;
  }

  Future<void> _insertConversationAsync({
    required AcChatConversation newConv,
    required String otherUserId,
  }) async {
    await _upsertConversation(conversation: newConv);
    await _insertMember(
      conversationId: newConv.conversationId,
      userId: _currentUserId,
    );
    await _insertMember(
      conversationId: newConv.conversationId,
      userId: otherUserId,
    );

    _channel?.createConversation(
      conversation: newConv,
      memberIds: [_currentUserId, otherUserId],
    ).catchError((Object e) {
      _log('channel.createConversation error', e, StackTrace.current);
      return null;
    });
  }

  Future<AcChatConversation> createGroupConversation({
    required String groupName,
    required List<String> memberUserIds,
    String? groupAvatar,
  }) async {
    final convId = _uuid.v4();
    final allMembers = {_currentUserId, ...memberUserIds}.toList();
    final conv = AcChatConversation()
      ..conversationId = convId
      ..type = 'group'
      ..groupName = groupName
      ..groupAvatar = groupAvatar
      ..memberIds = allMembers
      ..lastMessage = 'Group created'
      ..lastMessageType = 'system'
      ..lastTime = DateTime.now()
      ..unread = 0;

    await _upsertConversation(conversation: conv);
    for (final uid in allMembers) {
      await _insertMember(
        conversationId: convId,
        userId: uid,
        role: uid == _currentUserId ? 'admin' : 'member',
      );
    }

    _conversationIndex[convId] = conv;
    _conversations.insert(0, conv);

    final convUsers = allMembers
        .map((uid) => AcChatConversationUser()
          ..conversationId = convId
          ..userId = uid)
        .toList();
    _members[convId] = convUsers;
    _messages[convId] = [];

    _notifyConversationsChanged();
    onDataChanged?.call();

    _channel?.createConversation(
      conversation: conv,
      memberIds: allMembers,
    ).catchError((Object e) {
      _log('channel.createConversation error', e, StackTrace.current);
      return null;
    });

    return conv;
  }

  Future<void> addGroupMembers({
    required String conversationId,
    required List<String> userIds,
  }) async {
    final conv = _conversationIndex[conversationId];
    if (conv == null) return;

    for (final uid in userIds) {
      await _insertMember(conversationId: conversationId, userId: uid);
      if (!conv.memberIds.contains(uid)) {
        conv.memberIds.add(uid);
      }
      _members[conversationId]?.add(
        AcChatConversationUser()
          ..conversationId = conversationId
          ..userId = uid,
      );
    }

    _notifyConversationsChanged();
    onDataChanged?.call();

    _channel?.addGroupMembers(
      conversationId: conversationId,
      memberIds: userIds,
    ).catchError((Object e) {
      _log('channel.addGroupMembers error', e, StackTrace.current);
      return null;
    });
  }

  Future<void> removeGroupMember({
    required String conversationId,
    required String userId,
  }) async {
    final conv = _conversationIndex[conversationId];
    if (conv == null) return;

    conv.memberIds.remove(userId);
    _members[conversationId]?.removeWhere((m) => m.userId == userId);

    try {
      await _tblMembers.deleteRows(
        condition: '${_C.conversationId} = :cid AND ${_C.userId} = :uid',
        parameters: {':cid': conversationId, ':uid': userId},
      );
    } catch (e, st) {
      _log('removeGroupMember error', e, st);
    }

    _notifyConversationsChanged();
    onDataChanged?.call();

    _channel?.removeGroupMember(
      conversationId: conversationId,
      userId: userId,
    ).catchError((Object e) {
      _log('channel.removeGroupMember error', e, StackTrace.current);
      return null;
    });
  }

  Future<List<AcChatMessage>> searchMessages({
    required String query,
    String? conversationId,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final cond = conversationId != null
          ? '${_C.conversationId} = :cid AND ${_C.text} LIKE :q'
          : '${_C.text} LIKE :q';
      final params = <String, dynamic>{
        ':q': '%$trimmed%',
        if (conversationId != null) ':cid': conversationId,
      };
      final result = await _tblMessages.getRows(
        condition: cond,
        parameters: params,
        orderBy: '${_C.time} DESC',
      );
      if (result.isSuccess()) {
        return result.rows
            .map((r) => _rowToMessage(r, (id) => _messageIndex[id]))
            .toList();
      }
    } catch (e, st) {
      _log('searchMessages error', e, st);
    }
    return [];
  }

  void _updateMessage({
    required String messageId,
    required Map<String, dynamic> data,
  }) {
    final msg = _messageIndex[messageId];
    if (msg == null) return;

    if (data.containsKey('status')) msg.status = data['status'] as String;
    if (data.containsKey('text')) msg.text = data['text'] as String;
    if (data.containsKey('localPath')) msg.localPath = data['localPath'] as String?;
    if (data.containsKey('isDownloaded')) msg.isDownloaded = data['isDownloaded'] as bool;
    if (data.containsKey('deliveredTime')) {
      final dt = data['deliveredTime'];
      msg.deliveredTime = dt is DateTime ? dt : DateTime.fromMillisecondsSinceEpoch(dt as int);
    }
    if (data.containsKey('readTime')) {
      final rt = data['readTime'];
      msg.readTime = rt is DateTime ? rt : DateTime.fromMillisecondsSinceEpoch(rt as int);
    }

    _updateMessageFields(
      messageId: msg.messageId,
      fields: _dataToMessageFields(data),
    ).catchError((Object e) => null);

    _notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();

    final memberList = _members[msg.conversationId] ?? [];
    final recipientIds = memberList
        .map((m) => m.userId)
        .where((id) => id != _currentUserId)
        .toList();

    _channel?.updateMessage(
      messageId: messageId,
      conversationId: msg.conversationId,
      data: data,
      recipientIds: recipientIds,
    ).catchError((Object e) {
      _log('channel.updateMessage error', e, StackTrace.current);
      return null;
    });
  }

  // ─── Incoming Channel Handlers ─────────────────────────────────────────

  Future<void> _handleIncomingMessage(AcChatMessage message) async {
    final existing = _messageIndex[message.messageId];
    if (existing != null) {
      var changed = false;
      if (existing.status != message.status) {
        existing.status = message.status;
        changed = true;
      }
      if (message.deliveredTime != null && existing.deliveredTime != message.deliveredTime) {
        existing.deliveredTime = message.deliveredTime;
        changed = true;
      }
      if (message.readTime != null && existing.readTime != message.readTime) {
        existing.readTime = message.readTime;
        changed = true;
      }
      if (changed) {
        await _updateMessageFields(
          messageId: message.messageId,
          fields: {
            _C.status: existing.status,
            if (existing.deliveredTime != null)
              _C.deliveredTime: existing.deliveredTime!.millisecondsSinceEpoch,
            if (existing.readTime != null)
              _C.readTime: existing.readTime!.millisecondsSinceEpoch,
          },
        );
        _notifyMessagesChanged(conversationId: message.conversationId);
        onDataChanged?.call();
      }
      return;
    }

    await _ensureMessagesLoaded(conversationId: message.conversationId);
    await _upsertMessage(message: message);

    _messages[message.conversationId]?.add(message);
    _messageIndex[message.messageId] = message;

    _updateConversationLastMessage(message: message);
    await _updateConversationFields(
      conversationId: message.conversationId,
      fields: {
        _C.lastMessage: message.text,
        _C.lastMessageType: message.type,
        _C.lastTime: message.time.millisecondsSinceEpoch,
      },
    );

    if (message.senderId != _currentUserId) {
      final conv = _conversationIndex[message.conversationId];
      if (conv != null) {
        conv.unread += 1;
        await _updateConversationFields(
          conversationId: message.conversationId,
          fields: {_C.unread: conv.unread},
        );
      }
      onMessageReceived?.call(message: message);
    }

    _notifyMessagesChanged(conversationId: message.conversationId);
    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> _handleConversationChanged(
    AcChatConversation conversation,
    List<AcChatConversationUser> members,
  ) async {
    final convId = conversation.conversationId;
    conversation.memberIds = members.map((m) => m.userId).toList();

    await _upsertConversation(conversation: conversation);
    for (final m in members) {
      await _insertMember(conversationId: convId, userId: m.userId);
    }

    if (!_conversationIndex.containsKey(convId)) {
      _conversations.insert(0, conversation);
      _conversationIndex[convId] = conversation;
      _members[convId] = members;
    } else {
      _conversationIndex[convId] = conversation;
      final idx = _conversations.indexWhere((c) => c.conversationId == convId);
      if (idx >= 0) _conversations[idx] = conversation;
      _members[convId] = members;
    }

    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> _handleUsersLoaded(List<AcChatUser> users) async {
    for (final user in users) {
      await _upsertUser(user: user);
    }
    _users.clear();
    _userIndex.clear();
    for (final user in users) {
      _users.add(user);
      _userIndex[user.userId] = user;
    }
    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  void _handleIncomingTyping({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) {
    final state = _typingState.putIfAbsent(conversationId, () => {});
    state[userId] = isTyping;
    _typingStreamCtrls[conversationId]?.add(Map.unmodifiable(state));
  }

  void _handleIncomingPresence({
    required String userId,
    required bool isOnline,
  }) {
    _presenceState[userId] = isOnline;
    _presenceStreamCtrls[userId]?.add(isOnline);
  }

  // ─── Stream Notification Helpers ───────────────────────────────────────

  void _notifyConversationsChanged() {
    _conversationsStreamCtrl.add(List.unmodifiable(_conversations));
  }

  void _notifyMessagesChanged({required String conversationId}) {
    final list = _messages[conversationId];
    if (list != null) {
      _messagesStreamCtrls[conversationId]?.add(List.unmodifiable(list));
    }
  }

  // ─── SQLite DB & CRUD (No Raw SQL) ────────────────────────────────────

  Future<void> _openDatabase() async {
    // 1. Register data dictionary schema
    AcDataDictionary.registerDataDictionaryJsonString(
      jsonString: kAcChatDataDictionaryJson,
      dataDictionaryName: _config.dataDictionaryName,
    );

    // 2. Global settings
    AcSqlDatabase.databaseType = AcEnumSqlDatabaseType.sqlite;
    AcSqlDatabase.sqlConnection = AcSqlConnection(
      database: _config.databasePath,
    );

    // 3. Build DAO and tables
    _dao = AcSqliteDao();
    await _dao.setSqlConnection(
      sqlConnection: AcSqlConnection(database: _config.databasePath),
    );

    _tblUsers = AcSqlDbTable(
      tableName: _T.users,
      dataDictionaryName: _config.dataDictionaryName,
      dao: _dao,
    );
    _tblConversations = AcSqlDbTable(
      tableName: _T.conversations,
      dataDictionaryName: _config.dataDictionaryName,
      dao: _dao,
    );
    _tblMembers = AcSqlDbTable(
      tableName: _T.conversationMembers,
      dataDictionaryName: _config.dataDictionaryName,
      dao: _dao,
    );
    _tblMessages = AcSqlDbTable(
      tableName: _T.messages,
      dataDictionaryName: _config.dataDictionaryName,
      dao: _dao,
    );
    _tblOutbox = AcSqlDbTable(
      tableName: _T.outboxMessages,
      dataDictionaryName: _config.dataDictionaryName,
      dao: _dao,
    );
    _tblMessagesFts = AcSqlDbTable(
      tableName: _T.messagesFts,
      dataDictionaryName: _config.dataDictionaryName,
      dao: _dao,
    );

    final schemaManager = AcSqlDbSchemaManager(
      dataDictionaryName: _config.dataDictionaryName,
      dao: _dao,
    );
    schemaManager.ignoreViews = true;
    schemaManager.ignoreFunctions = true;
    schemaManager.ignoreStoredProcedures = true;

    final initResult = await schemaManager.initDatabase();
    if (!initResult.isSuccess()) {
      throw StateError(
        'AcChatSqlite: schema init failed — ${initResult.message}',
      );
    }
  }

  Future<void> _loadInitialData() async {
    final usersResult = await _tblUsers.getRows();
    _users.clear();
    _userIndex.clear();
    if (usersResult.isSuccess()) {
      for (final row in usersResult.rows) {
        final u = _rowToUser(row);
        _users.add(u);
        _userIndex[u.userId] = u;
      }
    }

    final convsResult = await _tblConversations.getRows(
      orderBy: '${_C.lastTime} DESC',
    );
    _conversations.clear();
    _conversationIndex.clear();
    if (convsResult.isSuccess()) {
      for (final row in convsResult.rows) {
        final c = _rowToConversation(row);
        _conversations.add(c);
        _conversationIndex[c.conversationId] = c;
      }
    }

    final membersResult = await _tblMembers.getRows();
    _members.clear();
    if (membersResult.isSuccess()) {
      for (final row in membersResult.rows) {
        final convId = row[_C.conversationId] as String;
        final member = AcChatConversationUser()
          ..conversationId = convId
          ..userId = row[_C.userId] as String;
        _members.putIfAbsent(convId, () => []).add(member);
      }
    }

    for (final conv in _conversations) {
      final memberList = _members[conv.conversationId] ?? [];
      conv.memberIds = memberList.map((m) => m.userId).toList();
    }
  }

  Future<void> _ensureMessagesLoaded({required String conversationId}) async {
    if (_messages[conversationId] != null) return;

    try {
      final result = await _tblMessages.getRows(
        condition: '${_C.conversationId} = :conversationId',
        parameters: {':conversationId': conversationId},
        orderBy: '${_C.time} ASC',
      );

      final list = <AcChatMessage>[];
      if (result.isSuccess()) {
        for (final row in result.rows) {
          final m = _rowToMessage(row, (id) => _messageIndex[id]);
          list.add(m);
          _messageIndex[m.messageId] = m;
        }
      }
      _messages[conversationId] = list;
    } catch (e, st) {
      _log('_ensureMessagesLoaded error for $conversationId', e, st);
      _messages[conversationId] = [];
    }
  }

  Future<void> _upsertUser({required AcChatUser user}) async {
    try {
      await _tblUsers.saveRow(
        row: _userToRow(user),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('_upsertUser error', e, st);
    }
  }

  Future<void> _upsertConversation({required AcChatConversation conversation}) async {
    try {
      await _tblConversations.saveRow(
        row: _conversationToRow(conversation),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('_upsertConversation error', e, st);
    }
  }

  Future<void> _insertMember({
    required String conversationId,
    required String userId,
    String role = 'member',
  }) async {
    final memberId = '${conversationId}_$userId';
    try {
      await _tblMembers.saveRow(
        row: {
          _C.memberId: memberId,
          _C.conversationId: conversationId,
          _C.userId: userId,
          _C.role: role,
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('_insertMember error', e, st);
    }
  }

  Future<void> _upsertMessage({required AcChatMessage message}) async {
    try {
      await _tblMessages.saveRow(
        row: _messageToRow(message),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
      // Also update FTS table
      await _tblMessagesFts.saveRow(
        row: {
          _C.messageId: message.messageId,
          _C.conversationId: message.conversationId,
          _C.text: message.text,
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('_upsertMessage error', e, st);
    }
  }

  Future<void> _updateConversationFields({
    required String conversationId,
    required Map<String, Object?> fields,
  }) async {
    if (fields.isEmpty) return;
    try {
      final conv = _conversationIndex[conversationId];
      final row = conv != null
          ? _conversationToRow(conv)
          : <String, Object?>{_C.conversationId: conversationId};
      row.addAll(fields);
      await _tblConversations.saveRow(
        row: row,
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('_updateConversationFields error', e, st);
    }
  }

  Future<void> _updateMessageFields({
    required String messageId,
    required Map<String, Object?> fields,
  }) async {
    if (fields.isEmpty) return;
    try {
      final msg = _messageIndex[messageId];
      final row = msg != null
          ? _messageToRow(msg)
          : <String, Object?>{_C.messageId: messageId};
      row.addAll(fields);
      await _tblMessages.saveRow(
        row: row,
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('_updateMessageFields error', e, st);
    }
  }

  void _updateConversationLastMessage({required AcChatMessage message}) {
    final conv = _conversationIndex[message.conversationId];
    if (conv == null) return;
    conv.lastMessage = message.text;
    conv.lastMessageType = message.type;
    conv.lastTime = message.time;
    _conversations.sort((a, b) => b.lastTime.compareTo(a.lastTime));
  }

  Map<String, Object?> _dataToMessageFields(Map<String, dynamic> data) {
    final fields = <String, Object?>{};
    if (data.containsKey('status')) fields[_C.status] = data['status'];
    if (data.containsKey('text')) fields[_C.text] = data['text'];
    if (data.containsKey('localPath')) fields[_C.localPath] = data['localPath'];
    if (data.containsKey('isDownloaded')) {
      fields[_C.isDownloaded] = (data['isDownloaded'] as bool) ? 1 : 0;
    }
    if (data.containsKey('deliveredTime')) {
      final dt = data['deliveredTime'];
      fields[_C.deliveredTime] = dt is DateTime ? dt.millisecondsSinceEpoch : dt;
    }
    if (data.containsKey('readTime')) {
      final rt = data['readTime'];
      fields[_C.readTime] = rt is DateTime ? rt.millisecondsSinceEpoch : rt;
    }
    return fields;
  }

  // ─── Row Mappers ───────────────────────────────────────────────────────

  static AcChatUser _rowToUser(Map<String, dynamic> row) {
    return AcChatUser()
      ..userId = row[_C.userId] as String
      ..name = row[_C.name] as String
      ..username = (row[_C.username] as String?) ?? ''
      ..email = (row[_C.email] as String?) ?? ''
      ..phone = row[_C.phone] as String?
      ..avatar = row[_C.avatar] as String?;
  }

  static Map<String, Object?> _userToRow(AcChatUser user) {
    return {
      _C.userId: user.userId,
      _C.name: user.name,
      _C.username: user.username,
      _C.email: user.email,
      _C.phone: user.phone,
      _C.avatar: user.avatar,
    };
  }

  static AcChatConversation _rowToConversation(Map<String, dynamic> row) {
    return AcChatConversation()
      ..conversationId = row[_C.conversationId] as String
      ..type = (row[_C.type] as String?) ?? 'direct'
      ..groupName = row[_C.groupName] as String?
      ..groupAvatar = row[_C.groupAvatar] as String?
      ..lastMessage = (row[_C.lastMessage] as String?) ?? ''
      ..lastMessageType = (row[_C.lastMessageType] as String?) ?? ''
      ..lastTime = DateTime.fromMillisecondsSinceEpoch(row[_C.lastTime] as int)
      ..unread = (row[_C.unread] as int?) ?? 0
      ..isPinned = ((row[_C.isPinned] as int?) ?? 0) == 1
      ..isMuted = ((row[_C.isMuted] as int?) ?? 0) == 1;
  }

  static Map<String, Object?> _conversationToRow(AcChatConversation conv) {
    return {
      _C.conversationId: conv.conversationId,
      _C.type: conv.type,
      _C.groupName: conv.groupName,
      _C.groupAvatar: conv.groupAvatar,
      _C.lastMessage: conv.lastMessage,
      _C.lastMessageType: conv.lastMessageType,
      _C.lastTime: conv.lastTime.millisecondsSinceEpoch,
      _C.unread: conv.unread,
      _C.isPinned: conv.isPinned ? 1 : 0,
      _C.isMuted: conv.isMuted ? 1 : 0,
    };
  }

  static AcChatMessage _rowToMessage(
    Map<String, dynamic> row,
    AcChatMessage? Function(String replyToId) replyResolver,
  ) {
    final replyToIdVal = row[_C.replyToId] as String?;
    final resolvedReply = replyToIdVal != null ? replyResolver(replyToIdVal) : null;

    Map<String, List<String>> reactions = {};
    if (row[_C.reactionsJson] != null) {
      try {
        final decoded = jsonDecode(row[_C.reactionsJson] as String) as Map;
        reactions = decoded.map((k, v) => MapEntry(k.toString(), (v as List).cast<String>()));
      } catch (_) {}
    }

    return AcChatMessage()
      ..messageId = row[_C.messageId] as String
      ..conversationId = row[_C.conversationId] as String
      ..senderId = row[_C.senderId] as String
      ..type = (row[_C.type] as String?) ?? 'text'
      ..text = (row[_C.text] as String?) ?? ''
      ..time = DateTime.fromMillisecondsSinceEpoch(row[_C.time] as int)
      ..status = (row[_C.status] as String?) ?? 'sent'
      ..mediaCaption = row[_C.mediaCaption] as String?
      ..amount = (row[_C.amount] as num?)?.toDouble()
      ..paymentNote = row[_C.paymentNote] as String?
      ..duration = row[_C.duration] as String?
      ..fileName = row[_C.fileName] as String?
      ..fileSize = row[_C.fileSize] as String?
      ..isDownloaded = ((row[_C.isDownloaded] as int?) ?? 0) == 1
      ..localPath = row[_C.localPath] as String?
      ..deliveredTime = row[_C.deliveredTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.deliveredTime] as int)
          : null
      ..readTime = row[_C.readTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.readTime] as int)
          : null
      ..isEdited = ((row[_C.isEdited] as int?) ?? 0) == 1
      ..editedTime = row[_C.editedTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.editedTime] as int)
          : null
      ..isDeleted = ((row[_C.isDeleted] as int?) ?? 0) == 1
      ..reactions = reactions
      ..replyTo = resolvedReply;
  }

  static Map<String, Object?> _messageToRow(AcChatMessage msg) {
    return {
      _C.messageId: msg.messageId,
      _C.conversationId: msg.conversationId,
      _C.senderId: msg.senderId,
      _C.type: msg.type,
      _C.text: msg.text,
      _C.time: msg.time.millisecondsSinceEpoch,
      _C.status: msg.status,
      _C.mediaCaption: msg.mediaCaption,
      _C.amount: msg.amount,
      _C.paymentNote: msg.paymentNote,
      _C.duration: msg.duration,
      _C.fileName: msg.fileName,
      _C.fileSize: msg.fileSize,
      _C.isDownloaded: msg.isDownloaded ? 1 : 0,
      _C.localPath: msg.localPath,
      _C.replyToId: msg.replyTo?.messageId,
      _C.deliveredTime: msg.deliveredTime?.millisecondsSinceEpoch,
      _C.readTime: msg.readTime?.millisecondsSinceEpoch,
      _C.isEdited: msg.isEdited ? 1 : 0,
      _C.editedTime: msg.editedTime?.millisecondsSinceEpoch,
      _C.isDeleted: msg.isDeleted ? 1 : 0,
      _C.reactionsJson: msg.reactions.isNotEmpty ? jsonEncode(msg.reactions) : null,
    };
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    developer.log(
      message,
      name: 'AcChatSqlite',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
