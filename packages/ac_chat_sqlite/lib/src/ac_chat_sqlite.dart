import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
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
  static const bio = 'bio';
  static const lastSeenUtc = 'last_seen_utc';
  static const isOnline = 'is_online';

  // conversations
  static const conversationId = 'conversation_id';
  static const type = 'type';
  static const groupName = 'group_name';
  static const groupDescription = 'group_description';
  static const groupAvatar = 'group_avatar';
  static const createdBy = 'created_by';
  static const createdAtUtc = 'created_at_utc';
  static const lastMessage = 'last_message';
  static const lastMessageType = 'last_message_type';
  static const lastTime = 'last_time';
  static const unread = 'unread';
  static const isPinned = 'is_pinned';
  static const isMuted = 'is_muted';
  static const disappearingDurationSeconds = 'disappearing_duration_seconds';

  // user_conversation_prefs
  static const unreadCount = 'unread_count';
  static const muteUntilUtc = 'mute_until_utc';
  static const isArchived = 'is_archived';
  static const isHidden = 'is_hidden';
  static const lastReadMessageId = 'last_read_message_id';
  static const lastReadTimeUtc = 'last_read_time_utc';

  // blocked_users
  static const blockedAtUtc = 'blocked_at_utc';

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
  static const filePath = 'file_path';
  static const fileUrl = 'file_url';
  static const replyToId = 'reply_to_id';
  static const deliveredTime = 'delivered_time';
  static const readTime = 'read_time';
  static const isEdited = 'is_edited';
  static const editedTime = 'edited_time';
  static const isDeleted = 'is_deleted';
  static const reactionsJson = 'reactions_json';
  static const isStarred = 'is_starred';
  static const mentionsJson = 'mentions_json';
  static const pinnedUntilUtc = 'pinned_until_utc';
  static const scheduledTimeUtc = 'scheduled_time_utc';
  static const expiresAtUtc = 'expires_at_utc';

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
  static const userConversationPrefs = 'user_conversation_prefs';
  static const blockedUsers = 'blocked_users';
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
  late AcSqlDbTable _tblUserPrefs;
  late AcSqlDbTable _tblBlockedUsers;
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
  final Set<String> _blockedUsers = {};
  final Map<String, AcChatConversationUser> _prefs = {};

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

  AcChatConfig get config => _config.chatConfig;
  AcChatMediaUploader? get mediaUploader => _mediaUploader;
  AcChatCryptoProvider? get cryptoProvider => _cryptoProvider;
  String? get dataDirectory => _config.dataDirectory;

  /// Returns the subdirectory path for the specified media [type] inside [dataDirectory].
  String getMediaDirectoryForType(String type) {
    final base = (_config.dataDirectory ?? 'media').replaceAll(RegExp(r'[/\\]+$'), '');
    final sub = switch (type.toLowerCase().trim()) {
      'image' || 'images' => 'images',
      'video' || 'videos' => 'videos',
      'audio' || 'audios' || 'voice' => 'audio',
      'document' || 'documents' || 'doc' || 'file' || 'files' => 'documents',
      _ => type.isNotEmpty ? type.toLowerCase().trim() : 'other',
    };
    return '$base/$sub';
  }

  /// Saves raw media bytes into the categorized subdirectory by [type] inside [dataDirectory].
  Future<String?> saveMediaFile({
    required String type,
    required String fileName,
    required Uint8List bytes,
    String? messageId,
  }) async {
    if (kIsWeb) return null;
    final dirPath = getMediaDirectoryForType(type);
    final dir = io.Directory(dirPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final name = safeName.isNotEmpty ? safeName : 'attachment';
    final targetPath = '$dirPath/$name';
    final file = io.File(targetPath);
    await file.writeAsBytes(bytes);
    return targetPath;
  }

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

    // Start periodic background drain timer using config interval
    if (config.enableOfflineOutbox) {
      _outboxDrainTimer = Timer.periodic(config.outboxRetryInterval, (_) {
        _drainOutbox();
      });
    }

    final ch = _channel;
    if (ch != null) {
      try {
        await ch.startListening(
          currentUserId: _currentUserId,
          onMessageReceived: ({required message}) => _handleIncomingMessage(message),
          onConversationChanged: ({required conversation, required members}) =>
              _handleConversationChanged(conversation, members),
          onUsersLoaded: ({required users}) => _handleUsersLoaded(users),
          onMessageStatusUpdated: ({required messageId, required conversationId, required status}) =>
              _handleMessageStatusUpdated(
                messageId: messageId,
                conversationId: conversationId,
                status: status,
              ),
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
  void startSync({required AcChatSyncChannel channel}) {
    if (identical(_channel, channel)) return;
    _channel = channel;
    channel.startListening(
      currentUserId: _currentUserId,
      onMessageReceived: ({required message}) => _handleIncomingMessage(message),
      onConversationChanged: ({required conversation, required members}) =>
          _handleConversationChanged(conversation, members),
      onUsersLoaded: ({required users}) => _handleUsersLoaded(users),
      onMessageStatusUpdated: ({required messageId, required conversationId, required status}) =>
          _handleMessageStatusUpdated(
            messageId: messageId,
            conversationId: conversationId,
            status: status,
          ),
      onTypingChanged: ({required conversationId, required userId, required isTyping}) =>
          _handleIncomingTyping(conversationId: conversationId, userId: userId, isTyping: isTyping),
      onUserPresenceChanged: ({required userId, required isOnline}) =>
          _handleIncomingPresence(userId: userId, isOnline: isOnline),
    ).catchError((Object e, StackTrace st) {
      _log('startSync error', e, st);
      return null;
    });
    if (config.enableOfflineOutbox) {
      _drainOutbox();
    }
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

  AcChatApi buildApi({AcChatConfig? config,required AcChatTheme theme,
  }) {

    return _AcChatSqliteApi(
      sqlite: this,
      theme: theme,
      config: config??AcChatConfig(),
      // enableVoiceCall: enableVoiceCall ?? false,
      // enableVideoCall: enableVideoCall ?? false,
      // showNewConversationButton: showNewConversationButton ?? true,
      // showConversationMenu: showConversationMenu ?? true,
      // onNewContact: onNewContact,
      // onNewGroup: onNewGroup,
      // getContacts: getContacts,
      // contactsSectionTitle: contactsSectionTitle,
      // newContactLabel: newContactLabel,
      // newContactSubtitle: newContactSubtitle,
      // newGroupLabel: newGroupLabel,
      // newGroupSubtitle: newGroupSubtitle,
      // onSearchRemoteUsers: onSearchRemoteUsers,
      // customMessageBuilder: customMessageBuilder,
      // onMessageTap: onMessageTap,
      // customInputBuilder: customInputBuilder,
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
    if (!config.enableTypingIndicators) return;
    final memberList = _members[conversationId] ?? [];
    final recipientIds = memberList
        .map((m) => m.userId)
        .where((id) => id != _currentUserId && !_blockedUsers.contains(id))
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

  AcChatUser getCurrentUser() {
    return _userIndex[_currentUserId] ??
        (AcChatUser()
          ..userId = _currentUserId
          ..name = 'Me');
  }

  List<AcChatUser> getUsers() {
    return List.unmodifiable(_users);
  }

  AcChatUser? getUserById({required String userId}) {
    return _userIndex[userId];
  }

  Future<void> saveUserProfile({required AcChatUser user}) async {
    await saveUser(user: user);
  }

  bool isUserBlocked({required String userId}) => _blockedUsers.contains(userId);

  List<String> getBlockedUserIds() => _blockedUsers.toList();

  Future<void> blockUser({required String userId}) async {
    if (userId.isEmpty) return;
    _blockedUsers.add(userId);
    try {
      await _tblBlockedUsers.saveRow(
        row: {
          _C.userId: userId,
          _C.blockedAtUtc: DateTime.now().millisecondsSinceEpoch,
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('blockUser error', e, st);
    }
    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> unblockUser({required String userId}) async {
    _blockedUsers.remove(userId);
    try {
      await _tblBlockedUsers.deleteRows(
        condition: '${_C.userId} = :uid',
        parameters: {':uid': userId},
      );
    } catch (e, st) {
      _log('unblockUser error', e, st);
    }
    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> reportUser({required String userId, required String reason}) async {
    _log('User reported: $userId for $reason', '', StackTrace.current);
  }

  List<AcChatConversation> getConversations() {
    return List.unmodifiable(_conversations);
  }

  AcChatConversationUser? getConversationPrefs({required String conversationId}) {
    return _prefs[conversationId];
  }

  Future<void> updateConversationPrefs({required AcChatConversationUser prefs}) async {
    _prefs[prefs.conversationId] = prefs;
    final conv = _conversationIndex[prefs.conversationId];
    if (conv != null) {
      conv.unread = prefs.unreadCount;
      conv.isPinned = prefs.isPinned;
      conv.isMuted = prefs.isMuted;
      conv.isArchived = prefs.isArchived;
      _sortConversations();
    }
    try {
      await _tblUserPrefs.saveRow(
        row: _userPrefsToRow(prefs),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('updateConversationPrefs error', e, st);
    }
    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> pinConversation({required String conversationId, required bool isPinned}) async {
    final pref = _prefs.putIfAbsent(
      conversationId,
      () => AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = _currentUserId,
    );
    pref.isPinned = isPinned;
    await updateConversationPrefs(prefs: pref);
  }

  Future<void> archiveConversation({required String conversationId, required bool isArchived}) async {
    final pref = _prefs.putIfAbsent(
      conversationId,
      () => AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = _currentUserId,
    );
    pref.isArchived = isArchived;
    await updateConversationPrefs(prefs: pref);
  }

  Future<void> muteConversation({required String conversationId, Duration? muteDuration, bool? muted}) async {
    final pref = _prefs.putIfAbsent(
      conversationId,
      () => AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = _currentUserId,
    );
    if (muted != null) {
      pref.isMuted = muted;
      pref.muteUntilUtc = muted ? DateTime.now().toUtc().add(const Duration(days: 3650)) : null;
    } else {
      pref.isMuted = muteDuration != null;
      pref.muteUntilUtc = muteDuration != null ? DateTime.now().toUtc().add(muteDuration) : null;
    }
    await updateConversationPrefs(prefs: pref);
  }

  Future<void> hideConversation({required String conversationId, required bool isHidden}) async {
    final pref = _prefs.putIfAbsent(
      conversationId,
      () => AcChatConversationUser()
        ..conversationId = conversationId
        ..userId = _currentUserId,
    );
    pref.isHidden = isHidden;
    await updateConversationPrefs(prefs: pref);
  }

  Future<void> deleteConversation({required String conversationId}) async {
    _conversations.removeWhere((c) => c.conversationId == conversationId);
    _conversationIndex.remove(conversationId);
    _members.remove(conversationId);
    _messages.remove(conversationId);
    _prefs.remove(conversationId);

    try {
      await _tblConversations.deleteRows(
        condition: '${_C.conversationId} = :cid',
        parameters: {':cid': conversationId},
      );
      await _tblMembers.deleteRows(
        condition: '${_C.conversationId} = :cid',
        parameters: {':cid': conversationId},
      );
      await _tblMessages.deleteRows(
        condition: '${_C.conversationId} = :cid',
        parameters: {':cid': conversationId},
      );
      await _tblUserPrefs.deleteRows(
        condition: '${_C.conversationId} = :cid',
        parameters: {':cid': conversationId},
      );
    } catch (e, st) {
      _log('deleteConversation error', e, st);
    }

    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  List<AcChatConversationUser> getConversationUsers({
    required String conversationId,
  }) {
    return List.unmodifiable(_members[conversationId] ?? []);
  }

  List<AcChatMessage> getMessages({required String conversationId}) {
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

  void sendMessage({required AcChatMessage message}) {
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
        .where((id) => id != _currentUserId && !_blockedUsers.contains(id))
        .toList();

    // 4. Save into Outbox (if offline outbox enabled)
    String? outboxId;
    if (config.enableOfflineOutbox) {
      outboxId = _uuid.v4();
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
    }

    _notifyMessagesChanged(conversationId: message.conversationId);
    _notifyConversationsChanged();
    onDataChanged?.call();

    // 5. Attempt transmission
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
        if (outboxId != null) {
          await _removeOutboxRow(outboxId: outboxId);
        }
        _notifyMessagesChanged(conversationId: message.conversationId);
        onDataChanged?.call();
      }).catchError((Object e) {
        _log('channel.sendMessage error (queued in outbox)', e, StackTrace.current);
      });
    } else {
      // Standalone mode: mark sent
      message.status = 'sent';
      await _updateMessageFields(
        messageId: message.messageId,
        fields: {_C.status: 'sent'},
      );
      if (outboxId != null) {
        await _removeOutboxRow(outboxId: outboxId);
      }
      _notifyMessagesChanged(conversationId: message.conversationId);
      onDataChanged?.call();
    }
  }

  Future<void> _drainOutbox() async {
    if (_isDrainingOutbox || _channel == null || !config.enableOfflineOutbox) return;
    _isDrainingOutbox = true;

    final maxRetries = config.outboxMaxRetries;

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
                _C.status: nextRetry >= maxRetries ? 'failed' : 'pending',
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

  void markAsRead({required String conversationId}) {
    final conv = _conversationIndex[conversationId];
    if (conv == null) return;

    conv.unread = 0;
    final pref = _prefs[conversationId];
    if (pref != null) {
      pref.unreadCount = 0;
      updateConversationPrefs(prefs: pref);
    }

    _updateConversationFields(
      conversationId: conversationId,
      fields: {_C.unread: 0},
    ).catchError((Object e) => null);

    final nowUtc = DateTime.now().toUtc();
    final nowMs = nowUtc.millisecondsSinceEpoch;

    // 1. Update in-memory messages and collect rows to save
    final msgs = _messages[conversationId];
    final rowsToSave = <Map<String, dynamic>>[];
    if (msgs != null) {
      for (final m in msgs) {
        if (m.senderId != _currentUserId && m.status != 'read') {
          m.status = 'read';
          m.readTime = nowUtc;
          rowsToSave.add(_messageToRow(m));
        }
      }
    }

    // 2. Persist in SQLite
    if (rowsToSave.isNotEmpty) {
      _tblMessages.saveRows(
        rows: rowsToSave,
        executeBeforeEvent: false,
        executeAfterEvent: false,
      ).catchError((Object e) => AcSqlDaoResult());
    } else {
      // If messages weren't cached in memory yet, update via query
      _tblMessages.getRows(
        condition: '${_C.conversationId} = :cid AND ${_C.senderId} != :uid AND ${_C.status} != :read',
        parameters: {':cid': conversationId, ':uid': _currentUserId, ':read': 'read'},
      ).then((res) {
        if (res.isSuccess() && res.rows.isNotEmpty) {
          final rows = <Map<String, dynamic>>[];
          for (final r in res.rows) {
            final rowMap = Map<String, dynamic>.from(r);
            rowMap[_C.status] = 'read';
            rowMap[_C.readTime] = nowMs;
            rows.add(rowMap);
          }
          _tblMessages.saveRows(
            rows: rows,
            executeBeforeEvent: false,
            executeAfterEvent: false,
          ).ignore();
        }
      }).catchError((Object e) {});
    }

    _notifyMessagesChanged(conversationId: conversationId);
    _notifyConversationsChanged();

    _channel?.markAsRead(
      conversationId: conversationId,
      currentUserId: _currentUserId,
    ).catchError((Object e) {
      _log('channel.markAsRead error', e, StackTrace.current);
      return null;
    });
  }

  AcChatConversation insertConversation({
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
    String? groupDescription,
  }) async {
    final convId = _uuid.v4();
    final allMembers = {_currentUserId, ...memberUserIds}.toList();
    final conv = AcChatConversation()
      ..conversationId = convId
      ..type = 'group'
      ..groupName = groupName
      ..groupDescription = groupDescription
      ..groupAvatar = groupAvatar
      ..createdBy = _currentUserId
      ..createdAtUtc = DateTime.now().toUtc()
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
          ..userId = uid
          ..role = uid == _currentUserId ? 'admin' : 'member')
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

  Future<void> updateGroupDetails({
    required String conversationId,
    String? groupName,
    String? groupAvatar,
    String? groupDescription,
  }) async {
    final conv = _conversationIndex[conversationId];
    if (conv == null) return;
    if (groupName != null) conv.groupName = groupName;
    if (groupAvatar != null) conv.groupAvatar = groupAvatar;
    if (groupDescription != null) conv.groupDescription = groupDescription;

    await _updateConversationFields(
      conversationId: conversationId,
      fields: {
        if (groupName != null) _C.groupName: groupName,
        if (groupAvatar != null) _C.groupAvatar: groupAvatar,
        if (groupDescription != null) _C.groupDescription: groupDescription,
      },
    );
    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> leaveGroup({required String conversationId}) async {
    await removeGroupMember(conversationId: conversationId, userId: _currentUserId);
  }

  Future<String> getGroupInviteLink({required String conversationId}) async {
    return 'https://chat.example.com/join/$conversationId';
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
    String? senderId,
    DateTime? startDateUtc,
    DateTime? endDateUtc,
    bool? hasAttachment,
  }) async {
    final trimmed = query.trim();

    try {
      final condParts = <String>[];
      final params = <String, dynamic>{};

      if (conversationId != null) {
        condParts.add('${_C.conversationId} = :cid');
        params[':cid'] = conversationId;
      }
      if (trimmed.isNotEmpty) {
        condParts.add('${_C.text} LIKE :q');
        params[':q'] = '%$trimmed%';
      }
      if (senderId != null && senderId.isNotEmpty) {
        condParts.add('${_C.senderId} = :sid');
        params[':sid'] = senderId;
      }
      if (startDateUtc != null) {
        condParts.add('${_C.time} >= :start');
        params[':start'] = startDateUtc.millisecondsSinceEpoch;
      }
      if (endDateUtc != null) {
        condParts.add('${_C.time} <= :end');
        params[':end'] = endDateUtc.millisecondsSinceEpoch;
      }
      if (hasAttachment == true) {
        condParts.add("(${_C.type} != 'text' AND ${_C.type} != 'system')");
      }

      final condition = condParts.isNotEmpty ? condParts.join(' AND ') : '1=1';

      final result = await _tblMessages.getRows(
        condition: condition,
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

  Future<void> editMessage({required String messageId, required String newText}) async {
    if (!config.enableMessageEditing) return;
    final msg = _messageIndex[messageId];
    if (msg == null) return;

    if (msg.senderId != _currentUserId) return;
    if (DateTime.now().toUtc().difference(msg.timeUtc) > config.editTimeWindow) return;

    msg.text = newText;
    msg.isEdited = true;
    msg.editedTime = DateTime.now().toUtc();

    await _updateMessageFields(
      messageId: messageId,
      fields: {
        _C.text: newText,
        _C.isEdited: 1,
        _C.editedTime: msg.editedTime!.millisecondsSinceEpoch,
      },
    );

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
      data: {'text': newText, 'isEdited': true, 'editedTime': msg.editedTime!.millisecondsSinceEpoch},
      recipientIds: recipientIds,
    );
  }

  Future<void> deleteMessageForMe({required String messageId}) async {
    if (!config.enableMessageDeletingForMe) return;
    final msg = _messageIndex[messageId];
    if (msg == null) return;

    final convMsgs = _messages[msg.conversationId];
    convMsgs?.removeWhere((m) => m.messageId == messageId);
    _messageIndex.remove(messageId);

    try {
      await _tblMessages.deleteRows(
        condition: '${_C.messageId} = :mid',
        parameters: {':mid': messageId},
      );
    } catch (e, st) {
      _log('deleteMessageForMe error', e, st);
    }

    _notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();
  }

  Future<void> deleteMessageForEveryone({required String messageId}) async {
    if (!config.enableMessageDeletingForEveryone) return;
    final msg = _messageIndex[messageId];
    if (msg == null) return;

    if (msg.senderId != _currentUserId) return;
    if (DateTime.now().toUtc().difference(msg.timeUtc) > config.deleteForEveryoneWindow) return;

    msg.isDeleted = true;
    msg.text = '';

    await _updateMessageFields(
      messageId: messageId,
      fields: {
        _C.isDeleted: 1,
        _C.text: '',
      },
    );

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
      data: {'isDeleted': true, 'text': ''},
      recipientIds: recipientIds,
    );
  }

  Future<void> addReaction({required String messageId, required String emoji}) async {
    if (!config.enableMessageReactions) return;
    final msg = _messageIndex[messageId];
    if (msg == null) return;

    final currentList = msg.reactions.putIfAbsent(emoji, () => []);
    if (!currentList.contains(_currentUserId)) {
      currentList.add(_currentUserId);
    }

    await _updateMessageFields(
      messageId: messageId,
      fields: {_C.reactionsJson: jsonEncode(msg.reactions)},
    );

    _notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();

    final memberList = _members[msg.conversationId] ?? [];
    final recipientIds = memberList.map((m) => m.userId).where((id) => id != _currentUserId).toList();
    _channel?.updateMessage(
      messageId: messageId,
      conversationId: msg.conversationId,
      data: {'reactions': msg.reactions},
      recipientIds: recipientIds,
    );
  }

  Future<void> removeReaction({required String messageId, required String emoji}) async {
    if (!config.enableMessageReactions) return;
    final msg = _messageIndex[messageId];
    if (msg == null) return;

    msg.reactions[emoji]?.remove(_currentUserId);
    if (msg.reactions[emoji]?.isEmpty ?? false) {
      msg.reactions.remove(emoji);
    }

    await _updateMessageFields(
      messageId: messageId,
      fields: {_C.reactionsJson: msg.reactions.isNotEmpty ? jsonEncode(msg.reactions) : null},
    );

    _notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();

    final memberList = _members[msg.conversationId] ?? [];
    final recipientIds = memberList.map((m) => m.userId).where((id) => id != _currentUserId).toList();
    _channel?.updateMessage(
      messageId: messageId,
      conversationId: msg.conversationId,
      data: {'reactions': msg.reactions},
      recipientIds: recipientIds,
    );
  }

  Future<void> setStarred({required String messageId, required bool isStarred}) async {
    if (!config.enableStarredMessages) return;
    final msg = _messageIndex[messageId];
    if (msg == null) return;
    msg.isStarred = isStarred;
    await _updateMessageFields(messageId: messageId, fields: {_C.isStarred: isStarred ? 1 : 0});
    _notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();
  }

  Future<void> pinMessage({required String messageId, Duration? duration}) async {
    if (!config.enablePinnedMessages) return;
    final msg = _messageIndex[messageId];
    if (msg == null) return;
    msg.pinnedUntilUtc = duration != null ? DateTime.now().toUtc().add(duration) : DateTime.now().toUtc().add(const Duration(days: 30));
    await _updateMessageFields(messageId: messageId, fields: {_C.pinnedUntilUtc: msg.pinnedUntilUtc?.millisecondsSinceEpoch});
    _notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();
  }

  Future<void> unpinMessage({required String messageId}) async {
    if (!config.enablePinnedMessages) return;
    final msg = _messageIndex[messageId];
    if (msg == null) return;
    msg.pinnedUntilUtc = null;
    await _updateMessageFields(messageId: messageId, fields: {_C.pinnedUntilUtc: null});
    _notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();
  }

  Future<void> forwardMessages({
    required List<String> messageIds,
    required String targetConversationId,
  }) async {
    if (!config.enableMessageForwarding) return;
    for (final id in messageIds) {
      final original = _messageIndex[id];
      if (original == null) continue;
      final forwarded = AcChatMessage()
        ..messageId = _uuid.v4()
        ..conversationId = targetConversationId
        ..senderId = _currentUserId
        ..type = original.type
        ..text = original.text
        ..time = DateTime.now().toUtc()
        ..fileName = original.fileName
        ..fileSize = original.fileSize
        ..localPath = original.localPath
        ..mediaCaption = original.mediaCaption;
      sendMessage(message: forwarded);
    }
  }

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

  Future<String> exportChat({required String conversationId, required bool asJson}) async {
    final msgs = getMessages(conversationId: conversationId);
    if (asJson) {
      final list = msgs.map((m) => m.toJson()).toList();
      return jsonEncode(list);
    } else {
      final sb = StringBuffer();
      for (final m in msgs) {
        final sender = _userIndex[m.senderId]?.name ?? m.senderId;
        sb.writeln('[${formatUtcIso(m.timeUtc)}] $sender: ${m.text}');
      }
      return sb.toString();
    }
  }

  Future<void> wipeAllData() async {
    try {
      await _tblMessages.deleteRows(condition: '1=1');
      await _tblConversations.deleteRows(condition: '1=1');
      await _tblMembers.deleteRows(condition: '1=1');
      await _tblUsers.deleteRows(condition: '1=1');
      await _tblOutbox.deleteRows(condition: '1=1');
      await _tblUserPrefs.deleteRows(condition: '1=1');
      await _tblBlockedUsers.deleteRows(condition: '1=1');
      await _tblMessagesFts.deleteRows(condition: '1=1');
    } catch (e, st) {
      _log('wipeAllData error', e, st);
    }

    _users.clear();
    _conversations.clear();
    _members.clear();
    _messages.clear();
    _userIndex.clear();
    _messageIndex.clear();
    _conversationIndex.clear();
    _blockedUsers.clear();
    _prefs.clear();

    if (!kIsWeb && _config.dataDirectory != null) {
      try {
        final dir = io.Directory(_config.dataDirectory!);
        if (dir.existsSync()) {
          dir.deleteSync(recursive: true);
        }
      } catch (_) {}
    }

    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  void updateMessage({
    required String messageId,
    required Map<String, dynamic> data,
  }) => _updateMessage(messageId: messageId, data: data);

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
    if (_blockedUsers.contains(message.senderId)) {
      _log('Incoming message suppressed from blocked user ${message.senderId}', '', StackTrace.current);
      return;
    }

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

    // Save received media into directories by type if dataDirectory is configured
    if (_config.dataDirectory != null &&
        _config.dataDirectory!.isNotEmpty &&
        message.type != 'text') {
      if (message.byteData != null && message.byteData!.isNotEmpty) {
        try {
          final fileName = message.fileName ??
              (message.text.isNotEmpty && !message.text.startsWith('http')
                  ? message.text.split(RegExp(r'[/\\]')).last
                  : '${message.messageId}.${_defaultExtensionForType(message.type)}');
          final savedPath = await saveMediaFile(
            type: message.type,
            fileName: fileName,
            bytes: message.byteData!,
            messageId: message.messageId,
          );
          if (savedPath != null) {
            message.localPath = savedPath;
            message.isDownloaded = true;
          }
        } catch (_) {}
      }
    }

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
        final pref = _prefs[message.conversationId];
        if (pref != null) {
          pref.unreadCount += 1;
          updateConversationPrefs(prefs: pref);
        }
        await _updateConversationFields(
          conversationId: message.conversationId,
          fields: {_C.unread: conv.unread},
        );
      }
      if (config.enableDeliveryReceipts) {
        _channel?.sendDeliveryReceipt(
          messageId: message.messageId,
          conversationId: message.conversationId,
          senderId: message.senderId,
        );
      }
      onMessageReceived?.call(message: message);
    }

    _notifyMessagesChanged(conversationId: message.conversationId);
    _notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> _handleMessageStatusUpdated({
    required String messageId,
    required String conversationId,
    required String status,
  }) async {
    var msg = _messageIndex[messageId];
    if (msg == null) {
      await _ensureMessagesLoaded(conversationId: conversationId);
      msg = _messageIndex[messageId];
    }
    if (msg != null) {
      msg.status = status;
      if (status == 'delivered') {
        msg.deliveredTime ??= DateTime.now();
      } else if (status == 'read') {
        msg.readTime ??= DateTime.now();
      }
      await _updateMessageFields(
        messageId: messageId,
        fields: {
          _C.status: msg.status,
          if (msg.deliveredTime != null)
            _C.deliveredTime: msg.deliveredTime!.millisecondsSinceEpoch,
          if (msg.readTime != null)
            _C.readTime: msg.readTime!.millisecondsSinceEpoch,
        },
      );
      _notifyMessagesChanged(conversationId: conversationId);
      onDataChanged?.call();
    }
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

    _sortConversations();
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
    _tblUserPrefs = AcSqlDbTable(
      tableName: _T.userConversationPrefs,
      dataDictionaryName: _config.dataDictionaryName,
      dao: _dao,
    );
    _tblBlockedUsers = AcSqlDbTable(
      tableName: _T.blockedUsers,
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
    // Load blocked users
    final blockedResult = await _tblBlockedUsers.getRows();
    _blockedUsers.clear();
    if (blockedResult.isSuccess()) {
      for (final row in blockedResult.rows) {
        _blockedUsers.add(row[_C.userId] as String);
      }
    }

    // Load users
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

    // Load conversation prefs
    final prefsResult = await _tblUserPrefs.getRows(
      condition: '${_C.userId} = :uid',
      parameters: {':uid': _currentUserId},
    );
    _prefs.clear();
    if (prefsResult.isSuccess()) {
      for (final row in prefsResult.rows) {
        final p = _rowToUserPrefs(row);
        _prefs[p.conversationId] = p;
      }
    }

    // Load conversations
    final convsResult = await _tblConversations.getRows(
      orderBy: '${_C.lastTime} DESC',
    );
    _conversations.clear();
    _conversationIndex.clear();
    if (convsResult.isSuccess()) {
      for (final row in convsResult.rows) {
        final c = _rowToConversation(row);

        // Migrate or sync user conversation prefs
        var pref = _prefs[c.conversationId];
        if (pref == null) {
          pref = AcChatConversationUser()
            ..conversationId = c.conversationId
            ..userId = _currentUserId
            ..unreadCount = c.unread
            ..isPinned = c.isPinned
            ..isMuted = c.isMuted;
          _prefs[c.conversationId] = pref;
          _tblUserPrefs.saveRow(
            row: _userPrefsToRow(pref),
            executeBeforeEvent: false,
            executeAfterEvent: false,
          ).ignore();
        }

        c.unread = pref.unreadCount;
        c.isPinned = pref.isPinned;
        c.isMuted = pref.isMuted;
        c.isArchived = pref.isArchived;

        _conversations.add(c);
        _conversationIndex[c.conversationId] = c;
      }
    }

    // Load members
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

    _sortConversations();
    await cleanExpiredMessages();
  }

  void _sortConversations() {
    _conversations.sort((a, b) {
      final pinA = a.isPinned ? 0 : 1;
      final pinB = b.isPinned ? 0 : 1;
      if (pinA != pinB) return pinA - pinB;
      return b.lastTimeUtc.compareTo(a.lastTimeUtc);
    });
  }

  Future<void> _ensureMessagesLoaded({required String conversationId}) async {
    if (_messages[conversationId] != null) return;
    await cleanExpiredMessages();

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
    _sortConversations();
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
      ..avatar = row[_C.avatar] as String?
      ..bio = row[_C.bio] as String?
      ..lastSeenUtc = row[_C.lastSeenUtc] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.lastSeenUtc] as int, isUtc: true)
          : null
      ..isOnline = ((row[_C.isOnline] as int?) ?? 0) == 1;
  }

  static Map<String, Object?> _userToRow(AcChatUser user) {
    return {
      _C.userId: user.userId,
      _C.name: user.name,
      _C.username: user.username,
      _C.email: user.email,
      _C.phone: user.phone,
      _C.avatar: user.avatar,
      _C.bio: user.bio,
      _C.lastSeenUtc: user.lastSeenUtc?.millisecondsSinceEpoch,
      _C.isOnline: user.isOnline ? 1 : 0,
    };
  }

  static AcChatConversation _rowToConversation(Map<String, dynamic> row) {
    return AcChatConversation()
      ..conversationId = row[_C.conversationId] as String
      ..type = (row[_C.type] as String?) ?? 'direct'
      ..groupName = row[_C.groupName] as String?
      ..groupDescription = row[_C.groupDescription] as String?
      ..groupAvatar = row[_C.groupAvatar] as String?
      ..createdBy = row[_C.createdBy] as String?
      ..createdAtUtc = row[_C.createdAtUtc] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.createdAtUtc] as int, isUtc: true)
          : DateTime.fromMillisecondsSinceEpoch(row[_C.lastTime] as int, isUtc: true)
      ..lastMessage = (row[_C.lastMessage] as String?) ?? ''
      ..lastMessageType = (row[_C.lastMessageType] as String?) ?? ''
      ..lastTime = DateTime.fromMillisecondsSinceEpoch(row[_C.lastTime] as int, isUtc: true)
      ..unread = (row[_C.unread] as int?) ?? 0
      ..isPinned = ((row[_C.isPinned] as int?) ?? 0) == 1
      ..isMuted = ((row[_C.isMuted] as int?) ?? 0) == 1
      ..disappearingDurationSeconds = row[_C.disappearingDurationSeconds] as int?;
  }

  static Map<String, Object?> _conversationToRow(AcChatConversation conv) {
    return {
      _C.conversationId: conv.conversationId,
      _C.type: conv.type,
      _C.groupName: conv.groupName,
      _C.groupDescription: conv.groupDescription,
      _C.groupAvatar: conv.groupAvatar,
      _C.createdBy: conv.createdBy,
      _C.createdAtUtc: conv.createdAtUtc.millisecondsSinceEpoch,
      _C.lastMessage: conv.lastMessage,
      _C.lastMessageType: conv.lastMessageType,
      _C.lastTime: conv.lastTimeUtc.millisecondsSinceEpoch,
      _C.unread: conv.unread,
      _C.isPinned: conv.isPinned ? 1 : 0,
      _C.isMuted: conv.isMuted ? 1 : 0,
      _C.disappearingDurationSeconds: conv.disappearingDurationSeconds,
    };
  }

  static AcChatConversationUser _rowToUserPrefs(Map<String, dynamic> row) {
    return AcChatConversationUser()
      ..conversationId = row[_C.conversationId] as String
      ..userId = row[_C.userId] as String
      ..unreadCount = (row[_C.unreadCount] as int?) ?? 0
      ..isPinned = ((row[_C.isPinned] as int?) ?? 0) == 1
      ..isMuted = ((row[_C.isMuted] as int?) ?? 0) == 1
      ..muteUntilUtc = row[_C.muteUntilUtc] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.muteUntilUtc] as int, isUtc: true)
          : null
      ..isArchived = ((row[_C.isArchived] as int?) ?? 0) == 1
      ..isHidden = ((row[_C.isHidden] as int?) ?? 0) == 1
      ..role = (row[_C.role] as String?) ?? 'member'
      ..lastReadMessageId = row[_C.lastReadMessageId] as String?
      ..lastReadTimeUtc = row[_C.lastReadTimeUtc] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.lastReadTimeUtc] as int, isUtc: true)
          : null;
  }

  static Map<String, Object?> _userPrefsToRow(AcChatConversationUser prefs) {
    return {
      _C.conversationId: prefs.conversationId,
      _C.userId: prefs.userId,
      _C.unreadCount: prefs.unreadCount,
      _C.isPinned: prefs.isPinned ? 1 : 0,
      _C.isMuted: prefs.isMuted ? 1 : 0,
      _C.muteUntilUtc: prefs.muteUntilUtc?.millisecondsSinceEpoch,
      _C.isArchived: prefs.isArchived ? 1 : 0,
      _C.isHidden: prefs.isHidden ? 1 : 0,
      _C.role: prefs.role,
      _C.lastReadMessageId: prefs.lastReadMessageId,
      _C.lastReadTimeUtc: prefs.lastReadTimeUtc?.millisecondsSinceEpoch,
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

    List<String> mentions = [];
    if (row[_C.mentionsJson] != null) {
      try {
        final decoded = jsonDecode(row[_C.mentionsJson] as String) as List;
        mentions = decoded.cast<String>();
      } catch (_) {}
    }

    return AcChatMessage()
      ..messageId = row[_C.messageId] as String
      ..conversationId = row[_C.conversationId] as String
      ..senderId = row[_C.senderId] as String
      ..type = (row[_C.type] as String?) ?? 'text'
      ..text = (row[_C.text] as String?) ?? ''
      ..time = DateTime.fromMillisecondsSinceEpoch(row[_C.time] as int, isUtc: true)
      ..status = (row[_C.status] as String?) ?? 'sent'
      ..mediaCaption = row[_C.mediaCaption] as String?
      ..amount = (row[_C.amount] as num?)?.toDouble()
      ..paymentNote = row[_C.paymentNote] as String?
      ..duration = row[_C.duration] as String?
      ..fileName = row[_C.fileName] as String?
      ..fileSize = row[_C.fileSize] as String?
      ..isDownloaded = ((row[_C.isDownloaded] as int?) ?? 0) == 1
      ..filePath = (row[_C.filePath] as String?) ?? (row[_C.localPath] as String?)
      ..fileUrl = row[_C.fileUrl] as String?
      ..localPath = (row[_C.filePath] as String?) ?? (row[_C.localPath] as String?)
      ..deliveredTime = row[_C.deliveredTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.deliveredTime] as int, isUtc: true)
          : null
      ..readTime = row[_C.readTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.readTime] as int, isUtc: true)
          : null
      ..isEdited = ((row[_C.isEdited] as int?) ?? 0) == 1
      ..editedTime = row[_C.editedTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.editedTime] as int, isUtc: true)
          : null
      ..isDeleted = ((row[_C.isDeleted] as int?) ?? 0) == 1
      ..reactions = reactions
      ..isStarred = ((row[_C.isStarred] as int?) ?? 0) == 1
      ..mentions = mentions
      ..pinnedUntilUtc = row[_C.pinnedUntilUtc] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.pinnedUntilUtc] as int, isUtc: true)
          : null
      ..scheduledTimeUtc = row[_C.scheduledTimeUtc] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.scheduledTimeUtc] as int, isUtc: true)
          : null
      ..expiresAtUtc = row[_C.expiresAtUtc] != null
          ? DateTime.fromMillisecondsSinceEpoch(row[_C.expiresAtUtc] as int, isUtc: true)
          : null
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
      _C.filePath: msg.filePath ?? msg.localPath,
      _C.fileUrl: msg.fileUrl,
      _C.localPath: msg.filePath ?? msg.localPath,
      _C.replyToId: msg.replyTo?.messageId,
      _C.deliveredTime: msg.deliveredTime?.millisecondsSinceEpoch,
      _C.readTime: msg.readTime?.millisecondsSinceEpoch,
      _C.isEdited: msg.isEdited ? 1 : 0,
      _C.editedTime: msg.editedTime?.millisecondsSinceEpoch,
      _C.isDeleted: msg.isDeleted ? 1 : 0,
      _C.reactionsJson: msg.reactions.isNotEmpty ? jsonEncode(msg.reactions) : null,
      _C.isStarred: msg.isStarred ? 1 : 0,
      _C.mentionsJson: msg.mentions.isNotEmpty ? jsonEncode(msg.mentions) : null,
      _C.pinnedUntilUtc: msg.pinnedUntilUtc?.millisecondsSinceEpoch,
      _C.scheduledTimeUtc: msg.scheduledTimeUtc?.millisecondsSinceEpoch,
      _C.expiresAtUtc: msg.expiresAtUtc?.millisecondsSinceEpoch,
    };
  }

  static String _defaultExtensionForType(String type) {
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

  /// Cleans up any expired disappearing messages from SQLite, in-memory state, and disk media files.
  Future<void> cleanExpiredMessages() async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    try {
      final expiredResult = await _tblMessages.getRows(
        condition: '${_C.expiresAtUtc} IS NOT NULL AND ${_C.expiresAtUtc} <= :now',
        parameters: {':now': nowMs},
      );

      if (expiredResult.isSuccess() && expiredResult.rows.isNotEmpty) {
        final expiredIds = <String>[];
        for (final row in expiredResult.rows) {
          final id = row[_C.messageId] as String?;
          if (id != null) expiredIds.add(id);

          final local = (row[_C.filePath] as String?) ?? (row[_C.localPath] as String?);
          if (local != null && local.isNotEmpty && !kIsWeb) {
            try {
              final f = io.File(local);
              if (f.existsSync()) {
                f.deleteSync();
              }
            } catch (_) {}
          }
        }

        await _tblMessages.deleteRows(
          condition: '${_C.expiresAtUtc} IS NOT NULL AND ${_C.expiresAtUtc} <= :now',
          parameters: {':now': nowMs},
        );

        final affectedConvs = <String>{};
        for (final id in expiredIds) {
          final msg = _messageIndex.remove(id);
          if (msg != null) {
            affectedConvs.add(msg.conversationId);
            _messages[msg.conversationId]?.removeWhere((m) => m.messageId == id);
          }
        }

        for (final convId in affectedConvs) {
          _notifyMessagesChanged(conversationId: convId);
        }
      }
    } catch (e, st) {
      _log('cleanExpiredMessages error', e, st);
    }
  }

  /// Downloads media file from [message.fileUrl] (or remote text url) and saves locally,
  /// updating the message record in SQLite and in-memory caches.
  Future<String?> downloadMedia({required AcChatMessage message}) async {
    final existingLocal = message.filePath ?? message.localPath;
    if (existingLocal != null && existingLocal.isNotEmpty && !kIsWeb) {
      final f = io.File(existingLocal);
      if (f.existsSync()) {
        return existingLocal;
      }
    }

    final url = (message.fileUrl != null && message.fileUrl!.startsWith('http'))
        ? message.fileUrl!
        : ((message.text.startsWith('http://') || message.text.startsWith('https://')) ? message.text : null);

    Uint8List? bytes = message.byteData;
    if (bytes == null || bytes.isEmpty) {
      if (url != null && !kIsWeb) {
        try {
          final request = await io.HttpClient().getUrl(Uri.parse(url));
          final response = await request.close();
          if (response.statusCode == 200) {
            final chunks = <Uint8List>[];
            await for (final chunk in response) {
              chunks.add(chunk is Uint8List ? chunk : Uint8List.fromList(chunk));
            }
            final totalLen = chunks.fold<int>(0, (sum, c) => sum + c.length);
            final fullBytes = Uint8List(totalLen);
            var offset = 0;
            for (final c in chunks) {
              fullBytes.setRange(offset, offset + c.length, c);
              offset += c.length;
            }
            bytes = fullBytes;
          }
        } catch (e, st) {
          _log('downloadMedia download error', e, st);
        }
      }
    }

    if (bytes == null || bytes.isEmpty) return null;

    final fileName = message.fileName ??
        (url != null
            ? url.split('?').first.split('/').last
            : 'media_${message.messageId}.${_defaultExtensionForType(message.type)}');

    final savedPath = await saveMediaFile(
      type: message.type,
      fileName: fileName,
      bytes: bytes,
      messageId: message.messageId,
    );

    if (savedPath != null) {
      message.filePath = savedPath;
      message.localPath = savedPath;
      message.isDownloaded = true;
      await _updateMessageFields(
        messageId: message.messageId,
        fields: {
          _C.filePath: savedPath,
          _C.localPath: savedPath,
          _C.isDownloaded: 1,
        },
      );
      _notifyMessagesChanged(conversationId: message.conversationId);
      onDataChanged?.call();
    }

    return savedPath;
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

/// Concrete strongly-typed [AcChatApi] delegating to an underlying [AcChatSqlite] instance.
class _AcChatSqliteApi implements AcChatApi {
  final AcChatSqlite sqlite;
  @override
  final AcChatTheme theme;
  @override
  final AcChatConfig config;

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
  final Widget? Function({required BuildContext context, required AcChatMessage message})? customMessageBuilder;
  @override
  final void Function({required AcChatMessage message})? onMessageTap;
  @override
  final Widget? Function({required BuildContext context, required AcChatConversation conversation})? customInputBuilder;

  final bool _enableVoiceCall;
  final bool _enableVideoCall;
  final bool _showNewConversationButton;
  final bool _showConversationMenu;

  _AcChatSqliteApi({
    required this.sqlite,
    required this.theme,
    required this.config,
    bool enableVoiceCall = false,
    bool enableVideoCall = false,
    bool showNewConversationButton = true,
    bool showConversationMenu = true,
    this.onNewContact,
    this.onNewGroup,
    this.getContacts,
    this.contactsSectionTitle,
    this.newContactLabel,
    this.newContactSubtitle,
    this.newGroupLabel,
    this.newGroupSubtitle,
    this.onSearchRemoteUsers,
    this.customMessageBuilder,
    this.onMessageTap,
    this.customInputBuilder,
  })  : _enableVoiceCall = enableVoiceCall,
        _enableVideoCall = enableVideoCall,
        _showNewConversationButton = showNewConversationButton,
        _showConversationMenu = showConversationMenu;

  @override
  bool get enableGroups => config.enableGroupConversations;
  @override
  bool get enableStatus => config.enableStatus;
  @override
  bool get enableGroupsAndStatuses => config.enableGroupConversations;
  @override
  bool get enableTyping => config.enableTextMessaging;
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
  bool get readOnly => !config.enableTextMessaging;
  @override
  bool get enableVideoCall => _enableVideoCall;
  @override
  bool get enableVoiceCall => _enableVoiceCall;
  @override
  bool get showNewConversationButton => _showNewConversationButton;
  @override
  bool get showConversationMenu => _showConversationMenu;

  @override
  AcChatUser getCurrentUser() => sqlite.getCurrentUser();

  @override
  List<AcChatUser> getUsers() => sqlite.getUsers();

  @override
  AcChatUser? getUserById({required String userId}) => sqlite.getUserById(userId: userId);

  @override
  Future<void> saveUserProfile({required AcChatUser user}) => sqlite.saveUserProfile(user: user);

  @override
  bool isUserBlocked({required String userId}) => sqlite.isUserBlocked(userId: userId);

  @override
  List<String> getBlockedUserIds() => sqlite.getBlockedUserIds();

  @override
  Future<void> blockUser({required String userId}) => sqlite.blockUser(userId: userId);

  @override
  Future<void> unblockUser({required String userId}) => sqlite.unblockUser(userId: userId);

  @override
  Future<void> reportUser({required String userId, required String reason}) =>
      sqlite.reportUser(userId: userId, reason: reason);

  @override
  Stream<bool>? watchUserOnlineStatus({required String userId}) =>
      config.enableOnlinePresence ? sqlite.watchUserOnlineStatus(userId: userId) : null;

  @override
  List<AcChatConversation> getConversations() => sqlite.getConversations();

  @override
  Stream<List<AcChatConversation>>? watchConversations() => sqlite.watchConversations();

  @override
  AcChatConversationUser? getConversationPrefs({required String conversationId}) =>
      sqlite.getConversationPrefs(conversationId: conversationId);

  @override
  Future<void> updateConversationPrefs({required AcChatConversationUser prefs}) =>
      sqlite.updateConversationPrefs(prefs: prefs);

  @override
  List<AcChatConversationUser> getConversationUsers({required String conversationId}) =>
      sqlite.getConversationUsers(conversationId: conversationId);

  @override
  AcChatConversation insertConversation({
    required AcChatConversation newConv,
    required String otherUserId,
  }) =>
      sqlite.insertConversation(newConv: newConv, otherUserId: otherUserId);

  @override
  Future<void> pinConversation({required String conversationId, required bool isPinned}) =>
      sqlite.pinConversation(conversationId: conversationId, isPinned: isPinned);

  @override
  Future<void> archiveConversation({required String conversationId, required bool isArchived}) =>
      sqlite.archiveConversation(conversationId: conversationId, isArchived: isArchived);

  @override
  Future<void> muteConversation({required String conversationId, Duration? muteDuration, bool? muted}) =>
      sqlite.muteConversation(conversationId: conversationId, muteDuration: muteDuration, muted: muted);

  @override
  Future<void> deleteConversation({required String conversationId}) =>
      sqlite.deleteConversation(conversationId: conversationId);

  @override
  Future<void> hideConversation({required String conversationId, required bool isHidden}) =>
      sqlite.hideConversation(conversationId: conversationId, isHidden: isHidden);

  @override
  Future<AcChatConversation> createGroupConversation({
    required String groupName,
    required List<String> memberUserIds,
    String? groupAvatar,
    String? groupDescription,
  }) =>
      sqlite.createGroupConversation(
        groupName: groupName,
        memberUserIds: memberUserIds,
        groupAvatar: groupAvatar,
        groupDescription: groupDescription,
      );

  @override
  Future<void> addGroupMembers({required String conversationId, required List<String> userIds}) =>
      sqlite.addGroupMembers(conversationId: conversationId, userIds: userIds);

  @override
  Future<void> removeGroupMember({required String conversationId, required String userId}) =>
      sqlite.removeGroupMember(conversationId: conversationId, userId: userId);

  @override
  Future<void> updateGroupDetails({
    required String conversationId,
    String? groupName,
    String? groupAvatar,
    String? groupDescription,
  }) =>
      sqlite.updateGroupDetails(
        conversationId: conversationId,
        groupName: groupName,
        groupAvatar: groupAvatar,
        groupDescription: groupDescription,
      );

  @override
  Future<void> leaveGroup({required String conversationId}) =>
      sqlite.leaveGroup(conversationId: conversationId);

  @override
  Future<String> getGroupInviteLink({required String conversationId}) =>
      sqlite.getGroupInviteLink(conversationId: conversationId);

  @override
  List<AcChatMessage> getMessages({required String conversationId}) =>
      sqlite.getMessages(conversationId: conversationId);

  @override
  Stream<List<AcChatMessage>>? watchMessages({required String conversationId}) =>
      sqlite.watchMessages(conversationId: conversationId);

  @override
  void sendMessage({required AcChatMessage message}) =>
      sqlite.sendMessage(message: message);

  @override
  void updateMessage({
    required String messageId,
    required Map<String, dynamic> data,
  }) => sqlite.updateMessage(messageId: messageId, data: data);

  @override
  Future<void> editMessage({required String messageId, required String newText}) =>
      sqlite.editMessage(messageId: messageId, newText: newText);

  @override
  Future<void> deleteMessageForMe({required String messageId}) =>
      sqlite.deleteMessageForMe(messageId: messageId);

  @override
  Future<void> deleteMessageForEveryone({required String messageId}) =>
      sqlite.deleteMessageForEveryone(messageId: messageId);

  @override
  Future<void> addReaction({required String messageId, required String emoji}) =>
      sqlite.addReaction(messageId: messageId, emoji: emoji);

  @override
  Future<void> removeReaction({required String messageId, required String emoji}) =>
      sqlite.removeReaction(messageId: messageId, emoji: emoji);

  @override
  Future<void> setStarred({required String messageId, required bool isStarred}) =>
      sqlite.setStarred(messageId: messageId, isStarred: isStarred);

  @override
  Future<void> pinMessage({required String messageId, Duration? duration}) =>
      sqlite.pinMessage(messageId: messageId, duration: duration);

  @override
  Future<void> unpinMessage({required String messageId}) =>
      sqlite.unpinMessage(messageId: messageId);

  @override
  void markAsRead({required String conversationId}) =>
      sqlite.markAsRead(conversationId: conversationId);

  @override
  void sendTypingIndicator({required String conversationId, required bool isTyping}) =>
      sqlite.sendTypingIndicator(conversationId: conversationId, isTyping: isTyping);

  @override
  Stream<Map<String, bool>>? watchTyping({required String conversationId}) =>
      config.enableTypingIndicators ? sqlite.watchTyping(conversationId: conversationId) : null;

  @override
  Future<void> forwardMessages({
    required List<String> messageIds,
    required String targetConversationId,
  }) =>
      sqlite.forwardMessages(
        messageIds: messageIds,
        targetConversationId: targetConversationId,
      );

  @override
  Future<void> deleteMessagesBatch({
    required List<String> messageIds,
    required bool forEveryone,
  }) =>
      sqlite.deleteMessagesBatch(
        messageIds: messageIds,
        forEveryone: forEveryone,
      );

  @override
  Future<List<AcChatMessage>> searchMessages({
    required String query,
    String? conversationId,
    String? senderId,
    DateTime? startDateUtc,
    DateTime? endDateUtc,
    bool? hasAttachment,
  }) =>
      sqlite.searchMessages(
        query: query,
        conversationId: conversationId,
        senderId: senderId,
        startDateUtc: startDateUtc,
        endDateUtc: endDateUtc,
        hasAttachment: hasAttachment,
      );

  @override
  AcChatMediaUploader? get mediaUploader => sqlite.mediaUploader;

  @override
  AcChatCryptoProvider? get cryptoProvider => sqlite.cryptoProvider;

  @override
  String? get dataDirectory => sqlite.dataDirectory;

  @override
  Future<String?> downloadMedia({required AcChatMessage message}) =>
      sqlite.downloadMedia(message: message);

  @override
  Future<String> exportChat({required String conversationId, required bool asJson}) =>
      sqlite.exportChat(conversationId: conversationId, asJson: asJson);

  @override
  Future<void> wipeAllData() => sqlite.wipeAllData();
}
