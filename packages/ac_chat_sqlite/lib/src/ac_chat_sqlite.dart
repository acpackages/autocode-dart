import 'dart:developer' as developer;

import 'package:ac_chat/ac_chat.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';
import 'package:flutter/foundation.dart';
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
  static const lastMessage = 'last_message';
  static const lastMessageType = 'last_message_type';
  static const lastTime = 'last_time';
  static const unread = 'unread';
  static const isPinned = 'is_pinned';
  static const isMuted = 'is_muted';

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
}

// ─── Table name constants ────────────────────────────────────────────────────

abstract class _T {
  static const users = 'users';
  static const conversations = 'conversations';
  static const conversationMembers = 'conversation_members';
  static const messages = 'messages';
}

/// Offline-first SQLite cache layer for `ac_chat`.
///
/// [AcChatSqlite] keeps an in-memory copy of all users, conversations,
/// members, and lazily loaded messages. **All UI reads come from memory**
/// (synchronous). SQLite is the persistent source of truth and is always
/// written before in-memory state is updated.
///
/// Database schema creation and migrations are handled automatically by
/// [AcSqlDbSchemaManager] using the [kAcChatDataDictionaryJson] data
/// dictionary. CRUD operations use [AcSqlDbTable] DAOs backed by
/// [AcSqliteDao].
///
/// An optional [AcChatSyncChannel] (e.g. `AcChatFirebase`) handles remote
/// message transport. The package works fully offline when no channel is
/// provided.
///
/// ## Typical setup
///
/// ```dart
/// final dir = await getApplicationDocumentsDirectory();
/// final sqlite = AcChatSqlite(
///   currentUserId: 'user_123',
///   channel: AcChatFirebase(currentUserId: 'user_123'),
///   config: AcChatSqliteConfig(databasePath: '${dir.path}/ac_chat.db'),
/// );
/// sqlite.onDataChanged = () => setState(() {});
/// await sqlite.initialize();
/// final api = sqlite.buildApi(AcChatTheme.dark());
/// ```
class AcChatSqlite {
  // ─── Constructor ───────────────────────────────────────────────────────

  /// Creates an [AcChatSqlite] instance.
  ///
  /// [currentUserId] must match the authenticated user's ID.
  ///
  /// [channel] is optional. When `null`, the instance operates fully offline.
  ///
  /// [config] allows overriding the database path and data-dictionary name.
  AcChatSqlite({
    required String currentUserId,
    AcChatSyncChannel? channel,
    AcChatSqliteConfig? config,
  })  : _currentUserId = currentUserId,
        _channel = channel,
        _config = config ?? const AcChatSqliteConfig();

  // ─── Private fields ────────────────────────────────────────────────────

  final String _currentUserId;
  AcChatSyncChannel? _channel;   // mutable — can be attached post-init via startFirebaseSync()
  final AcChatSqliteConfig _config;
  final _uuid = const Uuid();

  /// The DAO that owns the SQLite connection.
  late AcSqliteDao _dao;

  /// Per-table high-level DAO objects.
  late AcSqlDbTable _tblUsers;
  late AcSqlDbTable _tblConversations;
  late AcSqlDbTable _tblMembers;
  late AcSqlDbTable _tblMessages;

  bool _initialized = false;

  // ── In-memory state ────────────────────────────────────────────────────

  final List<AcChatUser> _users = [];
  final List<AcChatConversation> _conversations = [];
  final Map<String, List<AcChatConversationUser>> _members = {};

  /// Per-conversation message list. A `null` value means messages have NOT
  /// yet been loaded for that conversation from SQLite.
  final Map<String, List<AcChatMessage>?> _messages = {};

  /// O(1) user lookup.
  final Map<String, AcChatUser> _userIndex = {};

  /// O(1) message lookup — used for reply resolution and deduplication.
  final Map<String, AcChatMessage> _messageIndex = {};

  /// O(1) conversation lookup.
  final Map<String, AcChatConversation> _conversationIndex = {};

  // ─── Public API ────────────────────────────────────────────────────────

  /// Set this to `() => setState(() {})` in your [StatefulWidget] to trigger
  /// UI rebuilds whenever data changes.
  VoidCallback? onDataChanged;

  // ─── Lifecycle ─────────────────────────────────────────────────────────

  /// Opens (or creates) the SQLite database, loads initial data, and starts
  /// channel listeners (if a channel was provided).
  ///
  /// Messages are **not** loaded here — they are loaded lazily per
  /// conversation on first access.
  ///
  /// Call this once before [buildApi].
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

    final ch = _channel;
    if (ch != null) {
      try {
        await ch.startListening(
          currentUserId: _currentUserId,
          onMessageReceived: _handleIncomingMessage,
          onConversationChanged: _handleConversationChanged,
          onUsersLoaded: _handleUsersLoaded,
        );
      } catch (e, st) {
        _log('channel startListening error', e, st);
      }
    }
  }

  /// Returns a fully wired [AcChatApi] backed by the in-memory SQLite cache.
  ///
  /// Call [initialize] before calling this method.
  AcChatApi buildApi(AcChatTheme theme) {
    return AcChatApi(
      theme: theme,
      getCurrentUser: _getCurrentUser,
      getUsers: _getUsers,
      getUserById: _getUserById,
      getConversations: _getConversations,
      getConversationUsers: _getConversationUsers,
      markAsRead: _markAsRead,
      insertConversation: _insertConversation,
      getMessages: _getMessages,
      sendMessage: _sendMessage,
      enableGroupsAndStatuses: true,
      updateMessage: _updateMessage,
    );
  }

  /// Attaches [channel] to this already-initialised instance and starts
  /// listening for remote events.
  ///
  /// Use this for the **offline-first** pattern: call [initialize] first
  /// (which loads SQLite data immediately with no network dependency), then
  /// call [startFirebaseSync] in the background to layer on Firestore sync:
  ///
  /// ```dart
  /// await sqlite.initialize();               // instant — reads local DB
  /// sqlite.startFirebaseSync(channel);       // background — non-blocking
  /// ```
  ///
  /// Safe to call multiple times — subsequent calls with the same channel
  /// are silently ignored. Any errors from [AcChatSyncChannel.startListening]
  /// are caught and logged so the app never crashes if Firestore is
  /// unavailable.
  void startFirebaseSync(AcChatSyncChannel channel) {
    // Ignore if we already have this channel attached.
    if (identical(_channel, channel)) return;

    _attachAndListen(channel).catchError((Object e) {
      _log('startFirebaseSync error', e, StackTrace.current);
      return null;
    });
  }

  Future<void> _attachAndListen(AcChatSyncChannel channel) async {
    // Assign the channel first so _sendMessage / _markAsRead / _insertConversation
    // etc. start routing through Firestore from this point on.
    _channel = channel;
    await channel.startListening(
      currentUserId: _currentUserId,
      onMessageReceived: _handleIncomingMessage,
      onConversationChanged: _handleConversationChanged,
      onUsersLoaded: _handleUsersLoaded,
    );
  }

  /// Closes the SQLite database and stops all channel listeners.
  ///
  /// This method is `async`. Call with `unawaited()` from `State.dispose()`
  /// since `State.dispose()` is synchronous:
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   unawaited(_sqlite.dispose());
  ///   super.dispose();
  /// }
  /// ```
  Future<void> dispose() async {
    final ch = _channel;
    if (ch != null) {
      try {
        await ch.stopListening();
      } catch (e, st) {
        _log('channel stopListening error', e, st);
      }
    }
    try {
      await _dao.close();
    } catch (e, st) {
      _log('dao close error', e, st);
    }
  }

  // ─── Database setup ────────────────────────────────────────────────────

  /// Registers the data dictionary, configures the global [AcSqlDatabase]
  /// settings, and runs [AcSqlDbSchemaManager.initDatabase] to create or
  /// migrate the schema.
  Future<void> _openDatabase() async {
    // 1. Register the schema with AcDataDictionary.
    AcDataDictionary.registerDataDictionaryJsonString(
      jsonString: kAcChatDataDictionaryJson,
      dataDictionaryName: _config.dataDictionaryName,
    );

    // 2. Configure the global ac_sql settings for SQLite.
    AcSqlDatabase.databaseType = AcEnumSqlDatabaseType.sqlite;
    AcSqlDatabase.sqlConnection = AcSqlConnection(
      database: _config.databasePath,
    );

    // 3. Build the DAO and table helpers.
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

    // 4. Create / migrate the schema from the data dictionary.
    final schemaManager = AcSqlDbSchemaManager(
      dataDictionaryName: _config.dataDictionaryName,
      dao: _dao,
    );
    // Disable features not supported by SQLite.
    schemaManager.ignoreFunctions = true;
    schemaManager.ignoreStoredProcedures = true;

    final initResult = await schemaManager.initDatabase();
    if (!initResult.isSuccess()) {
      throw StateError(
        'AcChatSqlite: schema init failed — ${initResult.message}',
      );
    }
  }

  // ─── Initial data loading ──────────────────────────────────────────────

  Future<void> _loadInitialData() async {
    // Load users.
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

    // Load conversations (newest first).
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

    // Load all members.
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

    // Restore memberIds on each conversation from the members map.
    for (final conv in _conversations) {
      final memberList = _members[conv.conversationId] ?? [];
      conv.memberIds = memberList.map((m) => m.userId).toList();
    }

    // _messages starts empty — loaded lazily per conversation.
  }

  // ─── Lazy message loading ──────────────────────────────────────────────

  /// Loads messages for [conversationId] from SQLite if not already loaded.
  Future<void> _ensureMessagesLoaded(String conversationId) async {
    if (_messages[conversationId] != null) return;

    try {
      final result = await _tblMessages.getRows(
        condition: '${_C.conversationId} = :conversationId',
        parameters: {':conversationId': conversationId},
        orderBy: '${_C.time} ASC',
      );
      final msgs = <AcChatMessage>[];
      if (result.isSuccess()) {
        for (final row in result.rows) {
          final m = _rowToMessage(row, (id) => _messageIndex[id]);
          msgs.add(m);
          _messageIndex[m.messageId] = m;
        }
      }
      _messages[conversationId] = msgs;
    } catch (e, st) {
      _log('_ensureMessagesLoaded[$conversationId] error', e, st);
      _messages[conversationId] = [];
    }
  }

  // ─── AcChatApi callback implementations ───────────────────────────────

  AcChatUser _getCurrentUser() {
    return _userIndex[_currentUserId] ??
        (AcChatUser()..userId = _currentUserId);
  }

  List<AcChatUser> _getUsers() {
    return _users.where((u) => u.userId != _currentUserId).toList();
  }

  AcChatUser? _getUserById(String userId) {
    return _userIndex[userId];
  }

  List<AcChatConversation> _getConversations() {
    return List.unmodifiable(_conversations);
  }

  List<AcChatConversationUser> _getConversationUsers(String conversationId) {
    return List.unmodifiable(_members[conversationId] ?? []);
  }

  /// Returns messages for [conversationId] in ascending time order.
  ///
  /// If messages have not yet been loaded for this conversation they are
  /// fetched from SQLite in the background and [onDataChanged] is called
  /// when the load completes. Returns `[]` for the first call.
  List<AcChatMessage> _getMessages(String conversationId) {
    final cached = _messages[conversationId];
    if (cached != null) {
      return List.unmodifiable(cached);
    }

    // Kick off a background load — the next rebuild will have data.
    _ensureMessagesLoaded(conversationId).then((_) {
      onDataChanged?.call();
    }).catchError((Object e) {
      _log(
        '_getMessages background load error for $conversationId',
        e,
        StackTrace.current,
      );
      return null;
    });
    return const [];
  }

  /// Sends [newMsg] optimistically: writes to SQLite and memory first,
  /// then delegates to the channel.
  void _sendMessage(AcChatMessage newMsg) {
    if (newMsg.messageId.isEmpty) {
      newMsg.messageId = _uuid.v4();
    }
    newMsg.status = 'sending';

    // Fire-and-forget — never block the UI thread.
    _sendMessageAsync(newMsg).catchError((Object e) {
      _log('sendMessage async error', e, StackTrace.current);
      return null;
    });
  }

  Future<void> _sendMessageAsync(AcChatMessage msg) async {
    // 1. Persist to SQLite.
    await _upsertMessage(msg);

    // 2. Ensure message list is loaded for this conversation.
    await _ensureMessagesLoaded(msg.conversationId);

    // 3. Append to in-memory list.
    _messages[msg.conversationId]!.add(msg);
    _messageIndex[msg.messageId] = msg;

    // 4. Update conversation metadata in memory.
    _updateConversationLastMessage(msg);

    // 5. Persist conversation last-message fields.
    await _updateConversationFields(
      msg.conversationId,
      {
        _C.lastMessage: msg.text,
        _C.lastMessageType: msg.type,
        _C.lastTime: msg.time.millisecondsSinceEpoch,
      },
    );

    // 6. Notify UI.
    onDataChanged?.call();

    // 7. Delegate to channel or mark as sent immediately.
    final ch = _channel;
    if (ch != null) {
      ch.sendMessage(msg).catchError((Object e) {
        _log('channel.sendMessage error', e, StackTrace.current);
        msg.status = 'failed';
        _updateMessageFields(msg.messageId, {_C.status: 'failed'})
            .catchError((Object e2) => null);
        onDataChanged?.call();
        return null;
      });
    } else {
      // Fully offline — mark sent immediately.
      msg.status = 'sent';
      await _updateMessageFields(msg.messageId, {_C.status: 'sent'});
      onDataChanged?.call();
    }
  }

  /// Sets `unread = 0` for the conversation identified by [conversationId].
  void _markAsRead(String conversationId) {
    final conv = _conversationIndex[conversationId];
    if (conv == null) return;

    conv.unread = 0;
    final idx =
        _conversations.indexWhere((c) => c.conversationId == conversationId);
    if (idx >= 0) _conversations[idx].unread = 0;

    _updateConversationFields(conversationId, {_C.unread: 0})
        .catchError((Object e) => null);

    _channel
        ?.markAsRead(conversationId, _currentUserId)
        .catchError((Object e) {
      _log('channel.markAsRead error', e, StackTrace.current);
      return null;
    });
  }

  /// Creates a new conversation in SQLite and memory, then delegates to
  /// the channel.
  AcChatConversation _insertConversation(
    AcChatConversation newConv,
    String otherUserId,
  ) {
    if (newConv.conversationId.isEmpty) {
      newConv.conversationId = _uuid.v4();
    }
    newConv.memberIds = [_currentUserId, otherUserId];
    newConv.lastTime = DateTime.now();

    _insertConversationAsync(newConv, otherUserId).catchError((Object e) {
      _log('insertConversation async error', e, StackTrace.current);
      return null;
    });

    // Optimistic local insert.
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

    onDataChanged?.call();
    return newConv;
  }

  Future<void> _insertConversationAsync(
    AcChatConversation conv,
    String otherUserId,
  ) async {
    await _upsertConversation(conv);
    await _insertMember(conv.conversationId, _currentUserId);
    await _insertMember(conv.conversationId, otherUserId);

    _channel?.createConversation(conv, otherUserId).catchError((Object e) {
      _log('channel.createConversation error', e, StackTrace.current);
      return null;
    });
  }

  /// Applies a partial [data] update to the message identified by [messageId].
  void _updateMessage(String messageId, Map<String, dynamic> data) {
    final msg = _messageIndex[messageId];
    if (msg == null) return;

    if (data.containsKey('status')) msg.status = data['status'] as String;
    if (data.containsKey('text')) msg.text = data['text'] as String;
    if (data.containsKey('localPath')) {
      msg.localPath = data['localPath'] as String?;
    }
    if (data.containsKey('isDownloaded')) {
      msg.isDownloaded = data['isDownloaded'] as bool;
    }

    _updateMessageFields(msg.messageId, _dataToMessageFields(data))
        .catchError((Object e) => null);

    onDataChanged?.call();

    _channel
        ?.updateMessage(messageId, msg.conversationId, data)
        .catchError((Object e) {
      _log('channel.updateMessage error', e, StackTrace.current);
      return null;
    });
  }

  // ─── Incoming channel events ───────────────────────────────────────────

  Future<void> _handleIncomingMessage(AcChatMessage message) async {
    final existing = _messageIndex[message.messageId];
    if (existing != null) {
      // Dedup — only update status if it changed.
      if (existing.status != message.status) {
        existing.status = message.status;
        await _updateMessageFields(
          message.messageId,
          {_C.status: message.status},
        );
        onDataChanged?.call();
      }
      return;
    }

    // Genuinely new message from another user.
    await _ensureMessagesLoaded(message.conversationId);

    await _upsertMessage(message);
    _messages[message.conversationId]?.add(message);
    _messageIndex[message.messageId] = message;

    _updateConversationLastMessage(message);
    await _updateConversationFields(
      message.conversationId,
      {
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
          message.conversationId,
          {_C.unread: conv.unread},
        );
      }
    }

    onDataChanged?.call();
  }

  Future<void> _handleConversationChanged(
    AcChatConversation conversation,
    List<AcChatConversationUser> members,
  ) async {
    final convId = conversation.conversationId;
    conversation.memberIds = members.map((m) => m.userId).toList();

    if (!_conversationIndex.containsKey(convId)) {
      await _upsertConversation(conversation);
      for (final m in members) {
        await _insertMember(convId, m.userId);
      }
      _conversations.insert(0, conversation);
      _conversationIndex[convId] = conversation;
      _members[convId] = members;
    } else {
      await _upsertConversation(conversation);
      _conversationIndex[convId] = conversation;
      final idx =
          _conversations.indexWhere((c) => c.conversationId == convId);
      if (idx >= 0) _conversations[idx] = conversation;
      _members[convId] = members;
    }

    onDataChanged?.call();
  }

  Future<void> _handleUsersLoaded(List<AcChatUser> users) async {
    for (final user in users) {
      await _upsertUser(user);
    }
    _users.clear();
    _userIndex.clear();
    for (final user in users) {
      _users.add(user);
      _userIndex[user.userId] = user;
    }
    onDataChanged?.call();
  }

  // ─── SQLite persistence helpers ────────────────────────────────────────

  Future<void> _upsertUser(AcChatUser user) async {
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

  Future<void> _upsertConversation(AcChatConversation conv) async {
    try {
      await _tblConversations.saveRow(
        row: _conversationToRow(conv),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('_upsertConversation error', e, st);
    }
  }

  /// Inserts a conversation-member row, silently ignoring duplicates.
  Future<void> _insertMember(String conversationId, String userId) async {
    try {
      await _dao.executeStatement(
        statement: 'INSERT OR IGNORE INTO ${_T.conversationMembers}'
            ' (${_C.conversationId}, ${_C.userId})'
            ' VALUES (:conversationId, :userId)',
        parameters: {
          ':conversationId': conversationId,
          ':userId': userId,
        },
        operation: AcEnumDDRowOperation.insert,
      );
    } catch (e, st) {
      _log('_insertMember error', e, st);
    }
  }

  Future<void> _upsertMessage(AcChatMessage msg) async {
    try {
      await _tblMessages.saveRow(
        row: _messageToRow(msg),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      _log('_upsertMessage error', e, st);
    }
  }

  Future<void> _updateConversationFields(
    String conversationId,
    Map<String, Object?> fields,
  ) async {
    if (fields.isEmpty) return;
    try {
      final setClauses = fields.keys.map((k) => '$k = :$k').join(', ');
      final params = <String, dynamic>{
        ':${_C.conversationId}': conversationId,
        for (final e in fields.entries) ':${e.key}': e.value,
      };
      await _dao.executeStatement(
        statement: 'UPDATE ${_T.conversations} SET $setClauses'
            ' WHERE ${_C.conversationId} = :${_C.conversationId}',
        parameters: params,
        operation: AcEnumDDRowOperation.update,
      );
    } catch (e, st) {
      _log('_updateConversationFields error', e, st);
    }
  }

  Future<void> _updateMessageFields(
    String messageId,
    Map<String, Object?> fields,
  ) async {
    if (fields.isEmpty) return;
    try {
      final setClauses = fields.keys.map((k) => '$k = :$k').join(', ');
      final params = <String, dynamic>{
        ':${_C.messageId}': messageId,
        for (final e in fields.entries) ':${e.key}': e.value,
      };
      await _dao.executeStatement(
        statement: 'UPDATE ${_T.messages} SET $setClauses'
            ' WHERE ${_C.messageId} = :${_C.messageId}',
        parameters: params,
        operation: AcEnumDDRowOperation.update,
      );
    } catch (e, st) {
      _log('_updateMessageFields error', e, st);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  void _updateConversationLastMessage(AcChatMessage msg) {
    final conv = _conversationIndex[msg.conversationId];
    if (conv == null) return;
    conv.lastMessage = msg.text;
    conv.lastMessageType = msg.type;
    conv.lastTime = msg.time;
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
    return fields;
  }

  // ─── Row <-> model converters ──────────────────────────────────────────

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
      ..lastMessage = (row[_C.lastMessage] as String?) ?? ''
      ..lastMessageType = (row[_C.lastMessageType] as String?) ?? ''
      ..lastTime =
          DateTime.fromMillisecondsSinceEpoch(row[_C.lastTime] as int)
      ..unread = (row[_C.unread] as int?) ?? 0
      ..isPinned = ((row[_C.isPinned] as int?) ?? 0) == 1
      ..isMuted = ((row[_C.isMuted] as int?) ?? 0) == 1;
  }

  static Map<String, Object?> _conversationToRow(AcChatConversation conv) {
    return {
      _C.conversationId: conv.conversationId,
      _C.type: conv.type,
      _C.groupName: conv.groupName,
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
    final resolvedReply =
        replyToIdVal != null ? replyResolver(replyToIdVal) : null;

    return AcChatMessage()
      ..messageId = row[_C.messageId] as String
      ..conversationId = row[_C.conversationId] as String
      ..senderId = row[_C.senderId] as String
      ..type = (row[_C.type] as String?) ?? 'text'
      ..text = (row[_C.text] as String?) ?? ''
      ..time =
          DateTime.fromMillisecondsSinceEpoch(row[_C.time] as int)
      ..status = (row[_C.status] as String?) ?? 'sent'
      ..mediaCaption = row[_C.mediaCaption] as String?
      ..amount = (row[_C.amount] as num?)?.toDouble()
      ..paymentNote = row[_C.paymentNote] as String?
      ..duration = row[_C.duration] as String?
      ..fileName = row[_C.fileName] as String?
      ..fileSize = row[_C.fileSize] as String?
      ..isDownloaded = ((row[_C.isDownloaded] as int?) ?? 0) == 1
      ..localPath = row[_C.localPath] as String?
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
    };
  }

  // ─── Logging ───────────────────────────────────────────────────────────

  void _log(String message, Object error, StackTrace stackTrace) {
    developer.log(
      message,
      name: 'AcChatSqlite',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
