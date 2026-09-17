import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:ac_chat_sqlite/src/ac_chat_sqlite_channel_sync.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';

import 'ac_chat_data_dictionary.dart';

// sqlite3 never runs on web — define locally instead of importing flutter/foundation.
const bool _kIsWeb = false;

/// Offline-first SQLite cache layer for `ac_chat`.
///
/// Strictly uses [AcSqlDbTable] for all schema persistence and CRUD operations.
/// Raw SQL statements are forbidden. Synchronous in-memory reads, background SQLite writes.
class AcChatSqlite {
  AcChatMediaHandler? get mediaHandler => api.mediaHandler;
  AcChatCryptoProvider? get cryptoProvider => api.cryptoProvider;

  final AcChatApi api;
  final bool cacheRows;
  bool _isCached = false;
  AcChatUser? _currentUser;

  // Dynamic caches (active only when cacheRows == true && _isCached == true)
  final List<AcChatUser> _usersCache = [];
  final List<AcChatConversation> _conversationsCache = [];
  final List<AcChatConversationUser> _conversationUsersCache = [];
  final List<AcChatConversationUser> _conversationPrefsCache = [];
  final List<AcChatUser> _blockedUsersCache = [];
  final List<AcChatMessage> _messagesCache = [];

  String dataDictionaryName = "ac_chat";
  String databasePath = "chat.db";

  late AcSqliteDao _dao;

  late AcSqlDbTable tblUsers;
  late AcSqlDbTable tblConversations;
  late AcSqlDbTable tblConversationUsers;
  late AcSqlDbTable tblUserPrefs;
  late AcSqlDbTable tblBlockedUsers;
  late AcSqlDbTable tblMessages;
  late AcSqlDbTable tblUpdatesCache;
  late AcSqlDbTable tblMessagesFts;

  final StreamController<List<AcChatConversation>> conversationsStreamCtrl = StreamController<List<AcChatConversation>>.broadcast();
  final Map<String, StreamController<List<AcChatMessage>>> messagesStreamCtrls = {};
  final Map<String, StreamController<Map<String, bool>>> typingStreamCtrls = {};
  final Map<String, StreamController<bool>> presenceStreamCtrls = {};

  StreamSubscription<bool>? _connectivitySub;
  bool _initialized = false;

  void Function()? onDataChanged;
  void Function({required AcChatMessage message})? onMessageReceived;

  AcChatSqlite({
    this.cacheRows = false,
    AcChatApi? api,
    AcChatSyncChannel? channel,
    this.databasePath = "chat.db",
    String? dataDirectory,
  }) : api = api ?? AcChatApi(userId: '') {
    if (channel != null) {
      this.api.channel = channel;
    }
    if (dataDirectory != null) {
      this.api.dataDirectory = dataDirectory;
    }
    _setHandlers();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _openDatabase();
      if (cacheRows) {
        await _loadRows();
      }
      await cleanExpiredMessages();
    } catch (e, st) {
      log('initialize error', e, st);
      rethrow;
    }
    _setHandlers();
    await (AcChatSqliteChannelSync(chatSqlite: this)).initialize();
  }

  Future<void> dispose() async {
    _connectivitySub?.cancel();
    await conversationsStreamCtrl.close();
    for (final ctrl in messagesStreamCtrls.values) {
      await ctrl.close();
    }
    for (final ctrl in typingStreamCtrls.values) {
      await ctrl.close();
    }
    for (final ctrl in presenceStreamCtrls.values) {
      await ctrl.close();
    }
  }

  Future<void> _loadRows() async {
    _usersCache.clear();
    final usersResult = await tblUsers.getRows();
    if (usersResult.isSuccess()) {
      for (final row in usersResult.rows) {
        _usersCache.add(AcChatUser.instanceFromJson(jsonData: row));
      }
    }

    _blockedUsersCache.clear();
    final blockedResult = await tblBlockedUsers.getRows();
    if (blockedResult.isSuccess()) {
      for (final row in blockedResult.rows) {
        _blockedUsersCache.add(AcChatUser.instanceFromJson(jsonData: row));
      }
    }

    _conversationPrefsCache.clear();
    final prefsResult = await tblUserPrefs.getRows();
    if (prefsResult.isSuccess()) {
      for (final row in prefsResult.rows) {
        _conversationPrefsCache.add(AcChatConversationUser.instanceFromJson(jsonData: row));
      }
    }

    _conversationUsersCache.clear();
    final convUsersResult = await tblConversationUsers.getRows();
    if (convUsersResult.isSuccess()) {
      for (final row in convUsersResult.rows) {
        _conversationUsersCache.add(AcChatConversationUser.instanceFromJson(jsonData: row));
      }
    }

    _conversationsCache.clear();
    final convsResult = await tblConversations.getRows(
      orderBy: '${TblConversations.lastTime} DESC',
    );
    if (convsResult.isSuccess()) {
      for (final row in convsResult.rows) {
        _conversationsCache.add(AcChatConversation.instanceFromJson(jsonData: row));
      }
    }

    _messagesCache.clear();
    final msgsResult = await tblMessages.getRows(
      orderBy: '${TblMessages.time} ASC',
    );
    if (msgsResult.isSuccess()) {
      for (final row in msgsResult.rows) {
        _messagesCache.add(_rowToMessage(row));
      }
    }

    sortConversations();
    _isCached = true;
  }

  Future<void> sendTypingIndicator({required String conversationId, required bool isTyping}) async {
    if (!api.enableTypingIndicator) return;
    api.channel?.sendTypingIndicator(
      conversationId: conversationId,
      isTyping: isTyping,
      recipientIds: await getConversationRecipientIds(conversationId: conversationId),
    ).catchError((Object e) {
      log('sendTypingIndicator error', e, StackTrace.current);
      return null;
    });
  }

  Stream<List<AcChatConversation>> watchConversations() {
    return conversationsStreamCtrl.stream;
  }

  Stream<List<AcChatMessage>> watchMessages({required String conversationId}) {
    return messagesStreamCtrls
        .putIfAbsent(
          conversationId,
          () => StreamController<List<AcChatMessage>>.broadcast(),
        )
        .stream;
  }

  Stream<Map<String, bool>> watchTyping({required String conversationId}) {
    return typingStreamCtrls
        .putIfAbsent(
          conversationId,
          () => StreamController<Map<String, bool>>.broadcast(),
        )
        .stream;
  }

  Stream<bool> watchUserOnlineStatus({required String userId}) {
    return presenceStreamCtrls
        .putIfAbsent(
          userId,
          () => StreamController<bool>.broadcast(),
        )
        .stream;
  }

  // ─── User Related Methods ────────────────────────────────────────────────

  Future<void> blockUser({required String userId}) async {
    if (userId.isEmpty) return;
    try {
      await tblBlockedUsers.saveRow(
        row: {
          TblBlockedUsers.userId: userId,
          TblBlockedUsers.blockedAt: DateTime.now().toIso8601String(),
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      log('blockUser error', e, st);
    }
    if (cacheRows && _isCached) {
      _blockedUsersCache.add(AcChatUser()..userId = userId);
    }
    notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<List<String>> getBlockedUserIds() async {
    return (await getBlockedUsers()).map<String>((u) => u.userId).toList();
  }

  Future<List<AcChatUser>> getBlockedUsers({
    String? userId,
    String? condition,
    Map<String, dynamic>? parameters,
  }) async {
    if (cacheRows && _isCached) {
      var result = List<AcChatUser>.from(_blockedUsersCache);
      if (userId != null) {
        result = result.where((u) => u.userId == userId).toList();
      }
      return result;
    }

    List<AcChatUser> result = List<AcChatUser>.empty(growable: true);
    String whereCondition = "1=1";
    Map<String, dynamic> whereParameters = {};
    if (condition != null) {
      whereCondition += " AND $condition";
    }
    if (parameters != null) {
      whereParameters.addAll(parameters);
    }
    if (userId != null) {
      whereCondition += " AND ${TblBlockedUsers.userId} = @userId";
      whereParameters["@userId"] = userId;
    }
    var daoResult = await tblBlockedUsers.getRows(condition: whereCondition, parameters: whereParameters);
    if (daoResult.isSuccess() && daoResult.rows.isNotEmpty) {
      for (var row in daoResult.rows) {
        result.add(AcChatUser.instanceFromJson(jsonData: row));
      }
    }
    return result;
  }

  Future<AcChatUser?> getCurrentUser() async {
    // if (_currentUser != null) return _currentUser;
    var list = await getUsers(userId: api.userId);
    print("Getting current user : ${list.length}");
    _currentUser = list.isEmpty ? null : list.first;
    return _currentUser;
  }

  Future<AcChatUser?> getUserById({required String userId}) async {
    var list = await getUsers(userId: userId);
    return list.isEmpty ? null : list.first;
  }

  Future<List<AcChatUser>> getUsers({
    String? query,
    String? userId,
    String? condition,
    Map<String, dynamic>? parameters,
  }) async {
    if (cacheRows && _isCached) {
      var result = List<AcChatUser>.from(_usersCache);
      if (userId != null) {
        result = result.where((u) => u.userId == userId).toList();
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        result = result.where((u) => u.name.toLowerCase().contains(q) || u.userId.toLowerCase().contains(q)).toList();
      }
      return result;
    }

    List<AcChatUser> result = List<AcChatUser>.empty(growable: true);
    String whereCondition = "1=1";
    Map<String, dynamic> whereParameters = {};
    if (condition != null) {
      whereCondition += " AND $condition";
    }
    if (parameters != null) {
      whereParameters.addAll(parameters);
    }
    if (userId != null) {
      whereCondition += " AND ${TblUsers.userId} = @userId";
      whereParameters["@userId"] = userId;
    }
    if (query != null && query.isNotEmpty) {
      whereCondition += " AND (${TblUsers.name} LIKE @query OR ${TblUsers.userId} LIKE @query)";
      whereParameters["@query"] = "%$query%";
    }
    var daoResult = await tblUsers.getRows(condition: whereCondition, parameters: whereParameters);
    if (daoResult.isSuccess() && daoResult.rows.isNotEmpty) {
      for (var row in daoResult.rows) {
        result.add(AcChatUser.instanceFromJson(jsonData: row));
      }
    }
    return result;
  }

  Future<bool> isUserBlocked({required String userId}) async {
    return (await getBlockedUsers(userId: userId)).isNotEmpty;
  }

  Future<void> saveUser({required AcChatUser user}) async {
    await upsertUser(user: user);
    notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> unblockUser({required String userId}) async {
    try {
      await tblBlockedUsers.deleteRows(
        condition: '${TblBlockedUsers.userId} = :uid',
        parameters: {':uid': userId},
      );
    } catch (e, st) {
      log('unblockUser error', e, st);
    }
    if (cacheRows && _isCached) {
      _blockedUsersCache.removeWhere((u) => u.userId == userId);
    }
    notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> reportUser({required String userId, required String reason}) async {
    log('User reported: $userId for $reason', '', StackTrace.current);
  }

  // ─── Conversation Related Methods ────────────────────────────────────────

  Future<String> exportConversation({required String conversationId, required bool asJson}) async {
    final msgs = await getMessages(conversationId: conversationId);
    if (asJson) {
      final list = msgs.map((m) => m.toJson()).toList();
      return jsonEncode(list);
    } else {
      final sb = StringBuffer();
      for (final m in msgs) {
        final sender = (await getUserById(userId: m.senderId))?.name ?? m.senderId;
        sb.writeln('[${m.time.toUtc().toIso8601String()}] $sender: ${m.text}');
      }
      return sb.toString();
    }
  }

  Future<List<AcChatConversation>> getConversations({
    String? conversationId,
    String? userId,
    bool includeUsers = true,
    String? condition,
    Map<String, dynamic>? parameters,
    String? orderBy,
  }) async {
    if (cacheRows && _isCached) {
      var result = List<AcChatConversation>.from(_conversationsCache);
      if (conversationId != null) {
        result = result.where((c) => c.conversationId == conversationId).toList();
      }
      if (userId != null) {
        result = result.where((c) => c.userIds.contains(userId)).toList();
      }
      return result;
    }

    List<AcChatConversation> result = List<AcChatConversation>.empty(growable: true);
    String whereCondition = "1=1";
    Map<String, dynamic> whereParameters = {};
    if (condition != null) {
      whereCondition += " AND $condition";
    }
    if (parameters != null) {
      whereParameters.addAll(parameters);
    }
    if (conversationId != null) {
      whereCondition += " AND ${TblConversations.conversationId} = @conversationId";
      whereParameters["@conversationId"] = conversationId;
    }
    if (userId != null) {
      whereCondition += " AND ${TblConversations.conversationId} IN (SELECT ${TblConversationUsers.conversationId} FROM ${Tables.conversationUsers} WHERE ${TblConversationUsers.userId} = @userId)";
      whereParameters["@userId"] = userId;
    }
    var daoResult = await tblConversations.getRows(
      condition: whereCondition,
      parameters: whereParameters,
      orderBy: orderBy ?? '${TblConversations.lastTime} DESC',
    );
    if (daoResult.isSuccess() && daoResult.rows.isNotEmpty) {
      for (var row in daoResult.rows) {
        var conversation = AcChatConversation.instanceFromJson(jsonData: row);
        if (includeUsers) {
          print("[AcChatSqlite] getting conversation users");
          var conversationUsers = await getConversationUsers(
            conversationId: conversation.conversationId,
            excludeUserIds: [api.userId],
            includeUserDetails: true
          );
          print("[AcChatSqlite] conversation users : ");
          print(conversationUsers);
          conversation.otherUser = conversationUsers.isNotEmpty ? conversationUsers.first : null;
          print("[AcChatSqlite] other user : ");
          print(conversation.otherUser != null?conversation.otherUser!.toJson():null);
          print("[AcChatSqlite] other user's user row : ");
          print(conversation.otherUser != null?(conversation.otherUser!.user != null?conversation.otherUser!.user!.toJson():null):null);
          conversation.userIds = conversationUsers.map((u) => u.userId).toList();
        }
        result.add(conversation);
      }
    }
    return result;
  }

  Future<AcChatConversation?> getConversationById({required String conversationId}) async {
    var list = await getConversations(conversationId: conversationId);
    return list.isEmpty ? null : list.first;
  }

  Future<List<AcChatConversationUser>> getConversationPrefs({
    String? conversationId,
    String? userId,
    String? condition,
    Map<String, dynamic>? parameters,
  }) async {
    if (cacheRows && _isCached) {
      var result = List<AcChatConversationUser>.from(_conversationPrefsCache);
      if (conversationId != null) {
        result = result.where((p) => p.conversationId == conversationId).toList();
      }
      if (userId != null) {
        result = result.where((p) => p.userId == userId).toList();
      }
      return result;
    }

    List<AcChatConversationUser> result = List<AcChatConversationUser>.empty(growable: true);
    String whereCondition = "1=1";
    Map<String, dynamic> whereParameters = {};
    if (condition != null) {
      whereCondition += " AND $condition";
    }
    if (parameters != null) {
      whereParameters.addAll(parameters);
    }
    if (conversationId != null) {
      whereCondition += " AND ${TblUserConversationPrefs.conversationId} = @conversationId";
      whereParameters["@conversationId"] = conversationId;
    }
    if (userId != null) {
      whereCondition += " AND ${TblUserConversationPrefs.userId} = @prefUserId";
      whereParameters["@prefUserId"] = userId;
    }
    var daoResult = await tblUserPrefs.getRows(condition: whereCondition, parameters: whereParameters);
    if (daoResult.isSuccess() && daoResult.rows.isNotEmpty) {
      for (var row in daoResult.rows) {
        result.add(AcChatConversationUser.instanceFromJson(jsonData: row));
      }
    }
    return result;
  }

  Future<AcChatConversationUser?> getConversationPref({required String conversationId}) async {
    var list = await getConversationPrefs(
      conversationId: conversationId,
      userId: api.userId,
    );
    return list.isEmpty ? null : list.first;
  }

  Future<List<AcChatConversationUser>> getConversationUsers({
    String? conversationId,
    String? userId,
    List<String>? excludeUserIds,
    bool includeUserDetails = false,
    String? condition,
    Map<String, dynamic>? parameters,
  }) async {
    if (cacheRows && _isCached) {
      var result = List<AcChatConversationUser>.from(_conversationUsersCache);
      if (conversationId != null) {
        result = result.where((u) => u.conversationId == conversationId).toList();
      }
      if (userId != null) {
        result = result.where((u) => u.userId == userId).toList();
      }
      if (excludeUserIds != null && excludeUserIds.isNotEmpty) {
        result = result.where((u) => !excludeUserIds.contains(u.userId)).toList();
      }
      return result;
    }

    List<AcChatConversationUser> result = List<AcChatConversationUser>.empty(growable: true);
    String whereCondition = "1=1";
    Map<String, dynamic> whereParameters = {};
    if (condition != null) {
      whereCondition += " AND $condition";
    }
    if (parameters != null) {
      whereParameters.addAll(parameters);
    }
    if (conversationId != null) {
      whereCondition += " AND ${TblConversationUsers.conversationId} = @conversationId";
      whereParameters["@conversationId"] = conversationId;
    }
    if (userId != null) {
      whereCondition += " AND ${TblConversationUsers.userId} = @convUserId";
      whereParameters["@convUserId"] = userId;
    }
    if (excludeUserIds != null && excludeUserIds.isNotEmpty) {
      whereCondition += " AND ${TblConversationUsers.userId} NOT IN (@excludeIds)";
      whereParameters["@excludeIds"] = excludeUserIds;
    }
    var daoResult = await tblConversationUsers.getRows(condition: whereCondition, parameters: whereParameters);
    if (daoResult.isSuccess() && daoResult.rows.isNotEmpty) {
      for (var row in daoResult.rows) {
        var conversationUser = AcChatConversationUser.instanceFromJson(jsonData: row);
        result.add(conversationUser);
      }
    }
    if (includeUserDetails && result.isNotEmpty) {
      print("[AcChatSqlite] get users for conversation users : ");
      final userIds = result.map((u) => u.userId).toSet().toList();
      print("[AcChatSqlite] user ids : ${userIds.join(",")}");
      var usersList = await getUsers(condition: "${TblUsers.userId} IN (@uids)", parameters: {"@uids": userIds});
      print("[AcChatSqlite] received ${usersList.length} users");
      Map<String, AcChatUser> userMap = {for (var u in usersList) u.userId: u};
      for (var conversationUser in result) {
        conversationUser.user = userMap[conversationUser.userId];
      }
    }
    return result;
  }

  Future<List<String>> getConversationRecipientIds({required String conversationId}) async {
    var users = await getConversationUsers(
      conversationId: conversationId,
      excludeUserIds: [api.userId],
    );
    return users.map((u) => u.userId).toList();
  }

  Future<AcChatConversation> insertConversation({
    required AcChatConversation conversation,
    List<String>? userIds,
    String? otherUserId,
  }) async {
    if (conversation.conversationId.isEmpty) {
      conversation.conversationId = Autocode.uuid();
    }

    final allUserIds = <String>{api.userId};
    if (userIds != null) {
      allUserIds.addAll(userIds);
    }
    if (otherUserId != null && otherUserId.isNotEmpty) {
      allUserIds.add(otherUserId);
    }
    if (conversation.userIds.isNotEmpty) {
      allUserIds.addAll(conversation.userIds);
    }

    conversation.userIds = allUserIds.toList();
    conversation.lastTime = DateTime.now().toUtc();

    // 1. Save conversation
    await upsertConversation(conversation: conversation);

    // 2. Save conversation members in same method
    for (final uid in allUserIds) {
      await insertUser(
        conversationId: conversation.conversationId,
        userId: uid,
        role: uid == ((conversation.createdBy != null && conversation.createdBy!.isNotEmpty) ? conversation.createdBy : api.userId) ? 'admin' : 'user',
      );
    }

    // 3. Cache update
    if (cacheRows && _isCached) {
      _conversationsCache.removeWhere((c) => c.conversationId == conversation.conversationId);
      _conversationsCache.insert(0, conversation);
      for (final uid in allUserIds) {
        if (!_conversationUsersCache.any((u) => u.conversationId == conversation.conversationId && u.userId == uid)) {
          _conversationUsersCache.add(
            AcChatConversationUser()
              ..conversationId = conversation.conversationId
              ..userId = uid,
          );
        }
      }
    }

    // 4. Notify channel
    api.channel?.createConversation(
      conversation: conversation,
      userIds: allUserIds.toList(),
    ).catchError((Object e) {
      log('channel.createConversation error', e, StackTrace.current);
      return null;
    });

    notifyConversationsChanged();
    onDataChanged?.call();
    return conversation;
  }

  Future<void> addConversationUsers({
    required String conversationId,
    required List<String> userIds,
  }) async {
    for (final uid in userIds) {
      await insertUser(conversationId: conversationId, userId: uid);
    }

    if (cacheRows && _isCached) {
      final conv = _conversationsCache.where((c) => c.conversationId == conversationId).firstOrNull;
      if (conv != null) {
        for (final uid in userIds) {
          if (!conv.userIds.contains(uid)) conv.userIds.add(uid);
        }
      }
      for (final uid in userIds) {
        if (!_conversationUsersCache.any((u) => u.conversationId == conversationId && u.userId == uid)) {
          _conversationUsersCache.add(
            AcChatConversationUser()
              ..conversationId = conversationId
              ..userId = uid,
          );
        }
      }
    }

    notifyConversationsChanged();
    onDataChanged?.call();

    api.channel?.addConversationUsers(
      conversationId: conversationId,
      userIds: userIds,
    ).catchError((Object e) {
      log('channel.addConversationUsers error', e, StackTrace.current);
      return null;
    });
  }

  Future<void> removeConversationUsers({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await tblConversationUsers.deleteRows(
        condition: '${TblConversationUsers.conversationId} = :cid AND ${TblConversationUsers.userId} = :uid',
        parameters: {':cid': conversationId, ':uid': userId},
      );
    } catch (e, st) {
      log('removeConversationUsers error', e, st);
    }

    if (cacheRows && _isCached) {
      final conv = _conversationsCache.where((c) => c.conversationId == conversationId).firstOrNull;
      conv?.userIds.remove(userId);
      _conversationUsersCache.removeWhere((u) => u.conversationId == conversationId && u.userId == userId);
    }

    notifyConversationsChanged();
    onDataChanged?.call();

    api.channel?.removeConversationUsers(
      conversationId: conversationId,
      userIds: [userId],
    ).catchError((Object e) {
      log('channel.removeConversationUsers error', e, StackTrace.current);
      return null;
    });
  }

  Future<void> updateConversationPrefs({required AcChatConversationUser prefs}) async {
    if (cacheRows && _isCached) {
      _conversationPrefsCache.removeWhere((p) => p.conversationId == prefs.conversationId && p.userId == prefs.userId);
      _conversationPrefsCache.add(prefs);

      final conv = _conversationsCache.where((c) => c.conversationId == prefs.conversationId).firstOrNull;
      if (conv != null) {
        conv.unread = prefs.unreadCount;
        conv.isPinned = prefs.isPinned;
        conv.isMuted = prefs.isMuted;
        conv.isArchived = prefs.isArchived;
        sortConversations();
      }
    }

    try {
      await tblUserPrefs.saveRow(
        row: prefs.toJson(),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      log('updateConversationPrefs error', e, st);
    }
    notifyConversationsChanged();
    onDataChanged?.call();
  }

  Future<void> pinConversation({required String conversationId, required bool isPinned}) async {
    final pref = (await getConversationPref(conversationId: conversationId)) ??
        (AcChatConversationUser()
          ..conversationId = conversationId
          ..userId = api.userId);
    pref.isPinned = isPinned;
    await updateConversationPrefs(prefs: pref);
  }

  Future<void> archiveConversation({required String conversationId, required bool isArchived}) async {
    final pref = (await getConversationPref(conversationId: conversationId)) ??
        (AcChatConversationUser()
          ..conversationId = conversationId
          ..userId = api.userId);
    pref.isArchived = isArchived;
    await updateConversationPrefs(prefs: pref);
  }

  Future<void> muteConversation({required String conversationId, Duration? muteDuration, bool? muted}) async {
    final pref = (await getConversationPref(conversationId: conversationId)) ??
        (AcChatConversationUser()
          ..conversationId = conversationId
          ..userId = api.userId);
    if (muted != null) {
      pref.isMuted = muted;
      pref.muteUntil = muted ? DateTime.now().toUtc().add(const Duration(days: 3650)) : null;
    } else {
      pref.isMuted = muteDuration != null;
      pref.muteUntil = muteDuration != null ? DateTime.now().toUtc().add(muteDuration) : null;
    }
    await updateConversationPrefs(prefs: pref);
  }

  Future<void> hideConversation({required String conversationId, required bool isHidden}) async {
    final pref = (await getConversationPref(conversationId: conversationId)) ??
        (AcChatConversationUser()
          ..conversationId = conversationId
          ..userId = api.userId);
    pref.isHidden = isHidden;
    await updateConversationPrefs(prefs: pref);
  }

  Future<void> deleteConversation({required String conversationId}) async {
    if (cacheRows && _isCached) {
      _conversationsCache.removeWhere((c) => c.conversationId == conversationId);
      _conversationUsersCache.removeWhere((u) => u.conversationId == conversationId);
      _conversationPrefsCache.removeWhere((p) => p.conversationId == conversationId);
      _messagesCache.removeWhere((m) => m.conversationId == conversationId);
    }

    try {
      await tblConversations.deleteRows(
        condition: '${TblConversations.conversationId} = :cid',
        parameters: {':cid': conversationId},
      );
      await tblConversationUsers.deleteRows(
        condition: '${TblConversationUsers.conversationId} = :cid',
        parameters: {':cid': conversationId},
      );
      await tblMessages.deleteRows(
        condition: '${TblMessages.conversationId} = :cid',
        parameters: {':cid': conversationId},
      );
      await tblUserPrefs.deleteRows(
        condition: '${TblUserConversationPrefs.conversationId} = :cid',
        parameters: {':cid': conversationId},
      );
    } catch (e, st) {
      log('deleteConversation error', e, st);
    }

    notifyConversationsChanged();
    onDataChanged?.call();
  }

  // ─── Message Related Methods ─────────────────────────────────────────────

  Future<List<AcChatMessage>> getMessages({
    String? conversationId,
    String? messageId,
    String? senderId,
    String? condition,
    Map<String, dynamic>? parameters,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (cacheRows && _isCached) {
      var result = List<AcChatMessage>.from(_messagesCache);
      if (conversationId != null) {
        result = result.where((m) => m.conversationId == conversationId).toList();
      }
      if (messageId != null) {
        result = result.where((m) => m.messageId == messageId).toList();
      }
      if (senderId != null) {
        result = result.where((m) => m.senderId == senderId).toList();
      }
      return result;
    }

    List<AcChatMessage> result = List<AcChatMessage>.empty(growable: true);
    String whereCondition = "1=1";
    Map<String, dynamic> whereParameters = {};
    if (condition != null) {
      whereCondition += " AND $condition";
    }
    if (parameters != null) {
      whereParameters.addAll(parameters);
    }
    if (conversationId != null) {
      whereCondition += " AND ${TblMessages.conversationId} = @conversationId";
      whereParameters["@conversationId"] = conversationId;
    }
    if (messageId != null) {
      whereCondition += " AND ${TblMessages.messageId} = @messageId";
      whereParameters["@messageId"] = messageId;
    }
    if (senderId != null) {
      whereCondition += " AND ${TblMessages.senderId} = @senderId";
      whereParameters["@senderId"] = senderId;
    }
    int pageNumber = -1;
    int pageSize = -1;
    if (limit != null && limit > 0) {
      pageSize = limit;
      if (offset != null && offset >= 0) {
        pageNumber = (offset / limit).floor() + 1;
      } else {
        pageNumber = 1;
      }
    }
    var daoResult = await tblMessages.getRows(
      condition: whereCondition,
      parameters: whereParameters,
      orderBy: orderBy ?? '${TblMessages.time} ASC',
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    if (daoResult.isSuccess() && daoResult.rows.isNotEmpty) {
      for (var row in daoResult.rows) {
        result.add(_rowToMessage(row));
      }
    }
    return result;
  }

  Future<AcChatMessage?> getMessageById({required String messageId}) async {
    var list = await getMessages(messageId: messageId);
    return list.isEmpty ? null : list.first;
  }

  Future<void> sendMessage({required AcChatMessage message}) async {
    if (message.messageId.isEmpty) {
      message.messageId = Autocode.uuid();
    }
    message.status = 'sending';

    if (cacheRows && _isCached) {
      _messagesCache.removeWhere((m) => m.messageId == message.messageId);
      _messagesCache.add(message);
      updateConversationLastMessage(message: message);
    }

    await upsertMessage(message: message);
    await updateConversationFields(
      conversationId: message.conversationId,
      fields: {
        TblConversations.lastMessage: message.text,
        TblConversations.lastMessageType: message.type,
        TblConversations.lastTime: message.time.toIso8601String(),
      },
    );

    final recipientIds = await getConversationRecipientIds(conversationId: message.conversationId);

    notifyMessagesChanged(conversationId: message.conversationId);
    notifyConversationsChanged();
    onDataChanged?.call();

    final ch = api.channel;
    if (ch != null) {
      final remoteMessage = message.clone()
        ..localPath = null
        ..isDownloaded = false;
      ch.sendMessage(
        message: remoteMessage,
        recipientIds: recipientIds,
      ).then((wasSent) async {
        if (wasSent) {
          message.status = 'sent';
          await updateMessageFields(
            messageId: message.messageId,
            fields: {TblMessages.status: 'sent'},
          );
          notifyMessagesChanged(conversationId: message.conversationId);
          onDataChanged?.call();
        }
      }).catchError((Object e) {
        log('channel.sendMessage error', e, StackTrace.current);
      });
    } else {
      message.status = 'sent';
      await updateMessageFields(
        messageId: message.messageId,
        fields: {TblMessages.status: 'sent'},
      );
      notifyMessagesChanged(conversationId: message.conversationId);
      onDataChanged?.call();
    }
  }

  Future<void> notifyConversationRead({required String conversationId}) async {
    final pref = await getConversationPref(conversationId: conversationId);
    if (pref != null) {
      pref.unreadCount = 0;
      await updateConversationPrefs(prefs: pref);
    }

    await updateConversationFields(
      conversationId: conversationId,
      fields: {TblConversations.unread: 0},
    );

    final nowUtc = DateTime.now().toUtc();
    final nowMs = nowUtc.toIso8601String();

    if (cacheRows && _isCached) {
      for (final m in _messagesCache) {
        if (m.conversationId == conversationId && m.senderId != api.userId && m.status != 'read') {
          m.status = 'read';
          m.readTime = nowUtc;
        }
      }
    }

    var unreadRes = await tblMessages.getRows(
      condition: '${TblMessages.conversationId} = :cid AND ${TblMessages.senderId} != :uid AND ${TblMessages.status} != :read',
      parameters: {':cid': conversationId, ':uid': api.userId, ':read': 'read'},
    );
    if (unreadRes.isSuccess() && unreadRes.rows.isNotEmpty) {
      final rows = <Map<String, dynamic>>[];
      for (final r in unreadRes.rows) {
        final rowMap = Map<String, dynamic>.from(r);
        rowMap[TblMessages.status] = 'read';
        rowMap[TblMessages.readTime] = nowMs;
        rows.add(rowMap);
      }
      await tblMessages.saveRows(
        rows: rows,
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    }

    notifyMessagesChanged(conversationId: conversationId);
    notifyConversationsChanged();

    api.channel?.notifyConversationRead(
      conversationId: conversationId,
    ).catchError((Object e) {
      log('channel.notifyConversationRead error', e, StackTrace.current);
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
    final condParts = <String>[];
    final params = <String, dynamic>{};

    if (conversationId != null) {
      condParts.add('${TblMessages.conversationId} = :cid');
      params[':cid'] = conversationId;
    }
    if (trimmed.isNotEmpty) {
      condParts.add('${TblMessages.text} LIKE :q');
      params[':q'] = '%$trimmed%';
    }
    if (senderId != null && senderId.isNotEmpty) {
      condParts.add('${TblMessages.senderId} = :sid');
      params[':sid'] = senderId;
    }
    if (startDateUtc != null) {
      condParts.add('${TblMessages.time} >= :start');
      params[':start'] = startDateUtc.toIso8601String();
    }
    if (endDateUtc != null) {
      condParts.add('${TblMessages.time} <= :end');
      params[':end'] = endDateUtc.toIso8601String();
    }
    if (hasAttachment == true) {
      condParts.add("(${TblMessages.type} != 'text' AND ${TblMessages.type} != 'system')");
    }

    final condition = condParts.isNotEmpty ? condParts.join(' AND ') : '1=1';

    return getMessages(
      condition: condition,
      parameters: params,
      orderBy: '${TblMessages.time} DESC',
    );
  }

  Future<void> editMessage({required String messageId, required String newText}) async {
    if (!api.enableMessageEditing) return;
    final msg = await getMessageById(messageId: messageId);
    if (msg == null) return;

    if (msg.senderId != api.userId) return;
    if (DateTime.now().toUtc().difference(msg.time) > api.editTimeWindow) return;

    msg.text = newText;
    msg.isEdited = true;
    msg.editedTime = DateTime.now().toUtc();

    await updateMessageFields(
      messageId: messageId,
      fields: {
        TblMessages.text: newText,
        TblMessages.isEdited: 1,
        TblMessages.editedTime: msg.editedTime!.toIso8601String(),
      },
    );

    notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();

    final recipientIds = await getConversationRecipientIds(conversationId: msg.conversationId);

    api.channel?.updateMessage(
      messageId: messageId,
      conversationId: msg.conversationId,
      data: {TblMessages.text: newText, TblMessages.isEdited: true, TblMessages.editedTime: msg.editedTime!.toIso8601String()},
      recipientIds: recipientIds,
    );
  }

  Future<void> deleteMessageForMe({required String messageId}) async {
    if (!api.enableMessageDeletingForMe) return;
    final msg = await getMessageById(messageId: messageId);
    if (msg == null) return;

    if (cacheRows && _isCached) {
      _messagesCache.removeWhere((m) => m.messageId == messageId);
    }

    try {
      await tblMessages.deleteRows(
        condition: '${TblMessages.messageId} = :mid',
        parameters: {':mid': messageId},
      );
    } catch (e, st) {
      log('deleteMessageForMe error', e, st);
    }

    notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();
  }

  Future<void> deleteMessageForEveryone({required String messageId}) async {
    if (!api.enableMessageDeletingForEveryone) return;
    final msg = await getMessageById(messageId: messageId);
    if (msg == null) return;

    if (msg.senderId != api.userId) return;
    if (DateTime.now().toUtc().difference(msg.time) > api.deleteForEveryoneWindow) return;

    msg.isDeleted = true;
    msg.text = '';

    await updateMessageFields(
      messageId: messageId,
      fields: {
        TblMessages.isDeleted: 1,
        TblMessages.text: '',
      },
    );

    notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();

    final recipientIds = await getConversationRecipientIds(conversationId: msg.conversationId);

    api.channel?.updateMessage(
      messageId: messageId,
      conversationId: msg.conversationId,
      data: {TblMessages.isDeleted: 1, TblMessages.text: ''},
      recipientIds: recipientIds,
    );
  }

  Future<void> addReaction({required String messageId, required String emoji}) async {
    if (!api.enableMessageReactions) return;
    final msg = await getMessageById(messageId: messageId);
    if (msg == null) return;

    final currentList = msg.reactions.putIfAbsent(emoji, () => []);
    if (!currentList.contains(api.userId)) {
      currentList.add(api.userId);
    }

    await updateMessageFields(
      messageId: messageId,
      fields: {TblMessages.reactionsJson: jsonEncode(msg.reactions)},
    );

    notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();

    final recipientIds = await getConversationRecipientIds(conversationId: msg.conversationId);
    api.channel?.updateMessage(
      messageId: messageId,
      conversationId: msg.conversationId,
      data: {'reactions': msg.reactions},
      recipientIds: recipientIds,
    );
  }

  Future<void> removeReaction({required String messageId, required String emoji}) async {
    if (!api.enableMessageReactions) return;
    final msg = await getMessageById(messageId: messageId);
    if (msg == null) return;

    msg.reactions[emoji]?.remove(api.userId);
    if (msg.reactions[emoji]?.isEmpty ?? false) {
      msg.reactions.remove(emoji);
    }

    await updateMessageFields(
      messageId: messageId,
      fields: {TblMessages.reactionsJson: msg.reactions.isNotEmpty ? jsonEncode(msg.reactions) : null},
    );

    notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();

    final recipientIds = await getConversationRecipientIds(conversationId: msg.conversationId);
    api.channel?.updateMessage(
      messageId: messageId,
      conversationId: msg.conversationId,
      data: {'reactions': msg.reactions},
      recipientIds: recipientIds,
    );
  }

  Future<void> setStarred({required String messageId, required bool isStarred}) async {
    if (!api.enableStarredMessages) return;
    final msg = await getMessageById(messageId: messageId);
    if (msg == null) return;
    msg.isStarred = isStarred;
    await updateMessageFields(messageId: messageId, fields: {TblMessages.isStarred: isStarred ? 1 : 0});
    notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();
  }

  Future<void> pinMessage({required String messageId, Duration? duration}) async {
    if (!api.enablePinnedMessages) return;
    final msg = await getMessageById(messageId: messageId);
    if (msg == null) return;
    msg.pinnedUntil = duration != null ? DateTime.now().toUtc().add(duration) : DateTime.now().toUtc().add(const Duration(days: 30));
    await updateMessageFields(messageId: messageId, fields: {TblMessages.pinnedUntil: msg.pinnedUntil?.toIso8601String()});
    notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();
  }

  Future<void> unpinMessage({required String messageId}) async {
    if (!api.enablePinnedMessages) return;
    final msg = await getMessageById(messageId: messageId);
    if (msg == null) return;
    msg.pinnedUntil = null;
    await updateMessageFields(messageId: messageId, fields: {TblMessages.pinnedUntil: null});
    notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();
  }

  Future<void> forwardMessages({
    required List<String> messageIds,
    required String targetConversationId,
  }) async {
    if (!api.enableMessageForwarding) return;
    for (final id in messageIds) {
      final original = await getMessageById(messageId: id);
      if (original == null) continue;
      final forwarded = AcChatMessage()
        ..messageId = Autocode.uuid()
        ..conversationId = targetConversationId
        ..senderId = api.userId
        ..type = original.type
        ..text = original.text
        ..time = DateTime.now().toUtc()
        ..fileName = original.fileName
        ..fileSize = original.fileSize
        ..fileUrl = original.fileUrl
        ..localPath = original.localPath
        ..mediaCaption = original.mediaCaption;
      await sendMessage(message: forwarded);
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

  Future<void> updateMessage({
    required String messageId,
    required Map<String, dynamic> data,
  }) async {
    final msg = await getMessageById(messageId: messageId);
    if (msg == null) return;

    if (data.containsKey(TblMessages.status)) msg.status = data[TblMessages.status] as String;
    if (data.containsKey(TblMessages.text)) msg.text = data[TblMessages.text] as String;
    final localPathVal = data[TblMessages.localPath] ?? data['localPath'];
    if (localPathVal != null || data.containsKey(TblMessages.localPath) || data.containsKey('localPath')) {
      msg.localPath = localPathVal as String?;
    }
    final isDownloadedVal = data[TblMessages.isDownloaded] ?? data['isDownloaded'];
    if (isDownloadedVal != null) {
      msg.isDownloaded = isDownloadedVal == true || isDownloadedVal == 1;
    }
    if (data.containsKey(TblMessages.deliveredTime)) {
      final dt = data[TblMessages.deliveredTime];
      msg.deliveredTime = dt is DateTime ? dt : DateTime.parse(dt);
    }
    if (data.containsKey(TblMessages.readTime)) {
      final rt = data[TblMessages.readTime];
      msg.readTime = rt is DateTime ? rt : DateTime.parse(rt);
    }

    await updateMessageFields(
      messageId: msg.messageId,
      fields: dataToMessageFields(data),
    );

    notifyMessagesChanged(conversationId: msg.conversationId);
    onDataChanged?.call();

    final recipientIds = await getConversationRecipientIds(conversationId: msg.conversationId);

    api.channel?.updateMessage(
      messageId: messageId,
      conversationId: msg.conversationId,
      data: data,
      recipientIds: recipientIds,
    ).catchError((Object e) {
      log('channel.updateMessage error', e, StackTrace.current);
      return null;
    });
  }

  Future<void> wipeAllData() async {
    try {
      await tblMessages.deleteRows(condition: '1=1');
      await tblConversations.deleteRows(condition: '1=1');
      await tblUsers.deleteRows(condition: '1=1');
      await tblConversationUsers.deleteRows(condition: '1=1');
      await tblUpdatesCache.deleteRows(condition: '1=1');
      await tblUserPrefs.deleteRows(condition: '1=1');
      await tblBlockedUsers.deleteRows(condition: '1=1');
      await tblMessagesFts.deleteRows(condition: '1=1');
    } catch (e, st) {
      log('wipeAllData error', e, st);
    }

    _usersCache.clear();
    _conversationsCache.clear();
    _conversationUsersCache.clear();
    _conversationPrefsCache.clear();
    _blockedUsersCache.clear();
    _messagesCache.clear();

    if (!_kIsWeb && api.dataDirectory.isNotEmpty) {
      try {
        final dir = io.Directory(api.dataDirectory);
        if (dir.existsSync()) {
          dir.deleteSync(recursive: true);
        }
      } catch (_) {}
    }

    notifyConversationsChanged();
    onDataChanged?.call();
  }

  // ─── Stream Notification Helpers ─────────────────────────────────────────

  void notifyConversationsChanged() {
    getConversations().then((list) {
      if (!conversationsStreamCtrl.isClosed) {
        conversationsStreamCtrl.add(List.unmodifiable(list));
      }
    }).catchError((_) {});
  }

  void notifyMessagesChanged({required String conversationId}) {
    getMessages(conversationId: conversationId).then((list) {
      final ctrl = messagesStreamCtrls[conversationId];
      if (ctrl != null && !ctrl.isClosed) {
        ctrl.add(List.unmodifiable(list));
      }
    }).catchError((_) {});
  }

  // ─── SQLite DB & CRUD (No Raw SQL) ──────────────────────────────────────

  Future<void> _openDatabase() async {
    // 1. Register data dictionary schema
    AcDataDictionary.registerDataDictionary(
      jsonData: kAcChatDataDictionaryJson,
      dataDictionaryName: dataDictionaryName,
    );

    // 2. Global settings
    AcSqlDatabase.databaseType = AcEnumSqlDatabaseType.sqlite;
    AcSqlDatabase.sqlConnection = AcSqlConnection(
      database: databasePath,
    );

    // 3. Build DAO and tables
    _dao = AcSqliteDao();
    await _dao.setSqlConnection(
      sqlConnection: AcSqlConnection(database: databasePath),
    );

    tblUsers = AcSqlDbTable(
      tableName: Tables.users,
      dataDictionaryName: dataDictionaryName,
      dao: _dao,
    );
    tblConversations = AcSqlDbTable(
      tableName: Tables.conversations,
      dataDictionaryName: dataDictionaryName,
      dao: _dao,
    );
    tblConversationUsers = AcSqlDbTable(
      tableName: Tables.conversationUsers,
      dataDictionaryName: dataDictionaryName,
      dao: _dao,
    );
    tblUserPrefs = AcSqlDbTable(
      tableName: Tables.userConversationPrefs,
      dataDictionaryName: dataDictionaryName,
      dao: _dao,
    );
    tblBlockedUsers = AcSqlDbTable(
      tableName: Tables.blockedUsers,
      dataDictionaryName: dataDictionaryName,
      dao: _dao,
    );
    tblMessages = AcSqlDbTable(
      tableName: Tables.messages,
      dataDictionaryName: dataDictionaryName,
      dao: _dao,
    );
    tblUpdatesCache = AcSqlDbTable(
      tableName: Tables.channelCache,
      dataDictionaryName: dataDictionaryName,
      dao: _dao,
    );
    tblMessagesFts = AcSqlDbTable(
      tableName: Tables.messagesFts,
      dataDictionaryName: dataDictionaryName,
      dao: _dao,
    );

    final schemaManager = AcSqlDbSchemaManager(
      dataDictionaryName: dataDictionaryName,
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

  void sortConversations() {
    if (cacheRows && _isCached) {
      _conversationsCache.sort((a, b) {
        final pinA = a.isPinned ? 0 : 1;
        final pinB = b.isPinned ? 0 : 1;
        if (pinA != pinB) return pinA - pinB;
        return b.lastTime.compareTo(a.lastTime);
      });
    }
  }

  Future<void> upsertUser({required AcChatUser user}) async {
    if (cacheRows && _isCached) {
      _usersCache.removeWhere((u) => u.userId == user.userId);
      _usersCache.add(user);
    }
    try {
      await tblUsers.saveRow(
        row: user.toJson(),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      log('upsertUser error', e, st);
    }
  }

  Future<void> upsertConversation({required AcChatConversation conversation}) async {
    if (cacheRows && _isCached) {
      _conversationsCache.removeWhere((c) => c.conversationId == conversation.conversationId);
      _conversationsCache.add(conversation);
      sortConversations();
    }
    try {
      await tblConversations.saveRow(
        row: conversation.toJson(),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      log('upsertConversation error', e, st);
    }
  }

  Future<void> insertUser({
    required String conversationId,
    required String userId,
    String role = 'user',
  }) async {
    if (cacheRows && _isCached) {
      if (!_conversationUsersCache.any((u) => u.conversationId == conversationId && u.userId == userId)) {
        _conversationUsersCache.add(
          AcChatConversationUser()
            ..conversationId = conversationId
            ..userId = userId
            ..role = role,
        );
      }
    }
    try {
      await tblConversationUsers.saveRow(
        row: {
          TblConversationUsers.conversationId: conversationId,
          TblConversationUsers.userId: userId,
          TblConversationUsers.role: role,
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      log('insertUser error', e, st);
    }
  }

  Future<void> upsertMessage({required AcChatMessage message}) async {
    if (cacheRows && _isCached) {
      _messagesCache.removeWhere((m) => m.messageId == message.messageId);
      _messagesCache.add(message);
    }
    try {
      await tblMessages.saveRow(
        row: message.toJson(),
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
      // Also update FTS table
      await tblMessagesFts.saveRow(
        row: {
          TblMessages.messageId: message.messageId,
          TblMessages.conversationId: message.conversationId,
          TblMessages.text: message.text,
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );
    } catch (e, st) {
      log('upsertMessage error', e, st);
    }
  }

  Future<void> updateConversationFields({
    required String conversationId,
    required Map<String, Object?> fields,
  }) async {
    if (fields.isEmpty) return;
    try {
      final conv = (await getConversationById(conversationId: conversationId));
      final row = conv != null
          ? conv.toJson()
          : <String, Object?>{TblConversations.conversationId: conversationId};
      row.addAll(fields);
      await tblConversations.saveRow(
        row: row,
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );

      if (cacheRows && _isCached && conv != null) {
        final updated = AcChatConversation.instanceFromJson(jsonData: row);
        final idx = _conversationsCache.indexWhere((c) => c.conversationId == conversationId);
        if (idx >= 0) {
          _conversationsCache[idx] = updated;
        }
        sortConversations();
      }
    } catch (e, st) {
      log('updateConversationFields error', e, st);
    }
  }

  Future<void> updateMessageFields({
    required String messageId,
    required Map<String, Object?> fields,
  }) async {
    if (fields.isEmpty) return;
    try {
      final msg = await getMessageById(messageId: messageId);
      final row = msg != null
          ? msg.toJson()
          : <String, Object?>{TblMessages.messageId: messageId};
      row.addAll(fields);
      await tblMessages.saveRow(
        row: row,
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );

      if (cacheRows && _isCached) {
        final idx = _messagesCache.indexWhere((m) => m.messageId == messageId);
        if (idx >= 0) {
          _messagesCache[idx] = _rowToMessage(row);
        }
      }
    } catch (e, st) {
      log('updateMessageFields error', e, st);
    }
  }

  void updateConversationLastMessage({required AcChatMessage message}) {
    if (cacheRows && _isCached) {
      final conv = _conversationsCache.where((c) => c.conversationId == message.conversationId).firstOrNull;
      if (conv != null) {
        conv.lastMessage = message.text;
        conv.lastMessageType = message.type;
        conv.lastTime = message.time;
        sortConversations();
      }
    }
  }

  Map<String, Object?> dataToMessageFields(Map<String, dynamic> data) {
    final fields = <String, Object?>{};
    if (data.containsKey(TblMessages.status)) fields[TblMessages.status] = data[TblMessages.status];
    if (data.containsKey(TblMessages.text)) fields[TblMessages.text] = data[TblMessages.text];
    if (data.containsKey(TblMessages.isDeleted)) {
      fields[TblMessages.isDeleted] = (data[TblMessages.isDeleted] == true || data[TblMessages.isDeleted] == 1) ? 1 : 0;
    }
    if (data.containsKey(TblMessages.isEdited)) {
      fields[TblMessages.isEdited] = (data[TblMessages.isEdited] == true || data[TblMessages.isEdited] == 1) ? 1 : 0;
    }
    if (data.containsKey(TblMessages.editedTime)) {
      final et = data[TblMessages.editedTime];
      fields[TblMessages.editedTime] = et is DateTime ? et.toIso8601String() : et;
    }
    if (data.containsKey('reactions')) {
      final r = data['reactions'];
      fields[TblMessages.reactionsJson] = r != null ? jsonEncode(r) : null;
    } else if (data.containsKey(TblMessages.reactionsJson)) {
      fields[TblMessages.reactionsJson] = data[TblMessages.reactionsJson];
    }
    if (data.containsKey(TblMessages.localPath) || data.containsKey('localPath')) {
      fields[TblMessages.localPath] = data[TblMessages.localPath] ?? data['localPath'];
    }
    if (data.containsKey(TblMessages.isDownloaded) || data.containsKey('isDownloaded')) {
      final val = data[TblMessages.isDownloaded] ?? data['isDownloaded'];
      fields[TblMessages.isDownloaded] = (val == true || val == 1) ? 1 : 0;
    }
    if (data.containsKey(TblMessages.deliveredTime)) {
      final dt = data[TblMessages.deliveredTime];
      fields[TblMessages.deliveredTime] = dt is DateTime ? dt.toIso8601String() : dt;
    }
    if (data.containsKey(TblMessages.readTime)) {
      final rt = data[TblMessages.readTime];
      fields[TblMessages.readTime] = rt is DateTime ? rt.toIso8601String() : rt;
    }
    return fields;
  }

  static AcChatMessage _rowToMessage(
    Map<String, dynamic> row, [
    AcChatMessage? Function(String replyToId)? replyResolver,
  ]) {
    final replyToIdVal = row[TblMessages.replyToId] as String?;
    final resolvedReply = (replyToIdVal != null && replyResolver != null) ? replyResolver(replyToIdVal) : null;

    Map<String, List<String>> reactions = {};
    if (row[TblMessages.reactionsJson] != null) {
      try {
        final decoded = jsonDecode(row[TblMessages.reactionsJson] as String) as Map;
        reactions = decoded.map((k, v) => MapEntry(k.toString(), (v as List).cast<String>()));
      } catch (_) {}
    }

    List<String> mentions = [];
    if (row[TblMessages.mentionsJson] != null) {
      try {
        final decoded = jsonDecode(row[TblMessages.mentionsJson] as String) as List;
        mentions = decoded.cast<String>();
      } catch (_) {}
    }

    return AcChatMessage.instanceFromJson(jsonData: row)
      ..replyTo = resolvedReply
      ..reactions = reactions
      ..mentions = mentions;
  }

  /// Cleans up any expired disappearing messages from SQLite, in-memory state, and disk media files.
  Future<void> cleanExpiredMessages() async {
    final nowMs = DateTime.now().toUtc().toIso8601String();
    try {
      final expiredResult = await tblMessages.getRows(
        condition: '${TblMessages.expiresAt} IS NOT NULL AND ${TblMessages.expiresAt} <= :now',
        parameters: {':now': nowMs},
      );

      if (expiredResult.isSuccess() && expiredResult.rows.isNotEmpty) {
        final expiredIds = <String>[];
        final affectedConvs = <String>{};
        for (final row in expiredResult.rows) {
          final id = row[TblMessages.messageId] as String?;
          final cid = row[TblMessages.conversationId] as String?;
          if (id != null) expiredIds.add(id);
          if (cid != null) affectedConvs.add(cid);

          final local = row[TblMessages.localPath] as String?;
          if (local != null && local.isNotEmpty && !_kIsWeb) {
            try {
              final f = io.File(local);
              if (f.existsSync()) {
                f.deleteSync();
              }
            } catch (_) {}
          }
        }

        await tblMessages.deleteRows(
          condition: '${TblMessages.expiresAt} IS NOT NULL AND ${TblMessages.expiresAt} <= :now',
          parameters: {':now': nowMs},
        );

        if (cacheRows && _isCached) {
          _messagesCache.removeWhere((m) => expiredIds.contains(m.messageId));
        }

        for (final convId in affectedConvs) {
          notifyMessagesChanged(conversationId: convId);
        }
      }
    } catch (e, st) {
      log('cleanExpiredMessages error', e, st);
    }
  }

  /// Downloads media file from [message.fileUrl] (or remote text url) and saves locally,
  /// updating the message record in SQLite and in-memory caches.
  Future<String?> downloadMedia({
    required AcChatMessage message,
    void Function({required double progress})? onProgress,
  }) async {
    final existingLocal = message.localPath;
    if (existingLocal != null && existingLocal.isNotEmpty && !_kIsWeb) {
      final f = io.File(existingLocal);
      if (f.existsSync()) {
        message.isDownloaded = true;
        onProgress?.call(progress: 1.0);
        return existingLocal;
      }
    }

    final url = ((message.fileUrl != null && message.fileUrl!.startsWith('http'))
        ? message.fileUrl!
        : ((message.text.startsWith('http://') || message.text.startsWith('https://'))
            ? message.text
            : null));
    Uint8List? bytes = message.byteData;
    if (bytes == null || bytes.isEmpty) {
      if (url != null) {
        if (api.mediaHandler != null) {
          try {
            bytes = await api.mediaHandler!.downloadMedia(
              url: url,
              onProgress: onProgress,
            );
          } catch (e, st) {
            log('downloadMedia mediaHandler error', e, st);
          }
        }

        if ((bytes == null || bytes.isEmpty) && !_kIsWeb) {
          try {
            final request = await io.HttpClient().getUrl(Uri.parse(url));
            final token = api.getAuthToken?.call();
            if (token != null && token.isNotEmpty) {
              request.headers.set('Authorization', 'Bearer $token');
            }
            final response = await request.close();
            if (response.statusCode >= 200 && response.statusCode < 300) {
              final contentLength = response.contentLength;
              final chunks = <Uint8List>[];
              var received = 0;
              await for (final chunk in response) {
                final c = chunk is Uint8List ? chunk : Uint8List.fromList(chunk);
                chunks.add(c);
                received += c.length;
                if (contentLength > 0 && onProgress != null) {
                  onProgress(progress: (received / contentLength).clamp(0.0, 1.0));
                }
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
            log('downloadMedia download error', e, st);
          }
        }
      }
    }

    if (bytes == null || bytes.isEmpty) return null;

    final fileName = message.fileName ??
        (url != null
            ? url.split('?').first.split('/').last
            : 'media_${message.messageId}.${AcChatApi.defaultExtensionForType(message.type)}');

    final savedPath = await api.saveMediaFile(
      type: message.type,
      fileName: fileName,
      bytes: bytes,
      messageId: message.messageId,
    );

    if (savedPath != null) {
      message.localPath = savedPath;
      message.isDownloaded = true;
      message.byteData = bytes;
      await updateMessageFields(
        messageId: message.messageId,
        fields: {
          TblMessages.localPath: savedPath,
          TblMessages.isDownloaded: 1,
        },
      );
      notifyMessagesChanged(conversationId: message.conversationId);
      onDataChanged?.call();
    }

    onProgress?.call(progress: 1.0);
    return savedPath;
  }

  void log(String message, Object error, StackTrace stackTrace) {
    developer.log(
      message,
      name: 'AcChatSqlite',
      error: error,
      stackTrace: stackTrace,
    );
  }

  _setHandlers() {
    api.getCurrentUser = () async => getCurrentUser();
    api.getUsers = () async => getUsers();
    api.getUserById = ({required String userId}) async => getUserById(userId: userId);
    api.saveUserProfile = ({required AcChatUser user}) async => saveUser(user: user);
    api.isUserBlocked = ({required String userId}) async => isUserBlocked(userId: userId);
    api.getBlockedUserIds = () async => getBlockedUserIds();
    api.blockUser = ({required String userId}) async => blockUser(userId: userId);
    api.unblockUser = ({required String userId}) async => unblockUser(userId: userId);
    api.reportUser = ({required String userId, required String reason}) async => reportUser(userId: userId, reason: reason);
    api.watchUserOnlineStatus = ({required String userId}) async => watchUserOnlineStatus(userId: userId);
    api.getConversations = () async => getConversations();
    api.watchConversations = () async => watchConversations();
    api.getConversationPrefs = ({required String conversationId}) async => getConversationPref(conversationId: conversationId);
    api.updateConversationPrefs = ({required AcChatConversationUser prefs}) async => updateConversationPrefs(prefs: prefs);
    api.getConversationUsers = ({required String conversationId}) async => getConversationUsers(conversationId: conversationId);
    api.insertConversation = ({AcChatConversation? newConversation, required String otherUserId}) async =>
        insertConversation(conversation: newConversation ?? AcChatConversation(), otherUserId: otherUserId);
    api.pinConversation = ({required String conversationId, required bool isPinned}) => pinConversation(conversationId: conversationId, isPinned: isPinned);
    api.archiveConversation = ({required String conversationId, required bool isArchived}) => archiveConversation(conversationId: conversationId, isArchived: isArchived);
    api.muteConversation = ({required String conversationId, Duration? muteDuration, bool? muted}) => muteConversation(conversationId: conversationId, muteDuration: muteDuration, muted: muted);
    api.deleteConversation = ({required String conversationId}) => deleteConversation(conversationId: conversationId);
    api.hideConversation = ({required String conversationId, required bool isHidden}) => hideConversation(conversationId: conversationId, isHidden: isHidden);
    api.addConversationUsers = ({required String conversationId, required List<String> userIds}) async => addConversationUsers(conversationId: conversationId, userIds: userIds);
    api.removeConversationUsers = ({required String conversationId, required String userId}) async => removeConversationUsers(conversationId: conversationId, userId: userId);

    api.getMessages = ({required String conversationId}) async => getMessages(conversationId: conversationId);
    api.watchMessages = ({required String conversationId}) async => watchMessages(conversationId: conversationId);
    api.sendMessage = ({required AcChatMessage message}) async => sendMessage(message: message);

    api.updateMessage = ({
      required String messageId,
      required Map<String, dynamic> data,
    }) async => updateMessage(messageId: messageId, data: data);

    api.editMessage = ({required String messageId, required String newText}) async =>
        editMessage(messageId: messageId, newText: newText);

    api.deleteMessageForMe = ({required String messageId}) async =>
        deleteMessageForMe(messageId: messageId);

    api.deleteMessageForEveryone = ({required String messageId}) async =>
        deleteMessageForEveryone(messageId: messageId);

    api.addReaction = ({required String messageId, required String emoji}) async =>
        addReaction(messageId: messageId, emoji: emoji);

    api.removeReaction = ({required String messageId, required String emoji}) async =>
        removeReaction(messageId: messageId, emoji: emoji);

    api.setStarred = ({required String messageId, required bool isStarred}) async =>
        setStarred(messageId: messageId, isStarred: isStarred);

    api.pinMessage = ({required String messageId, Duration? duration}) async =>
        pinMessage(messageId: messageId, duration: duration);

    api.unpinMessage = ({required String messageId}) async =>
        unpinMessage(messageId: messageId);

    api.notifyConversationRead = ({required String conversationId}) async =>
        notifyConversationRead(conversationId: conversationId);

    api.sendTypingIndicator = ({required String conversationId, required bool isTyping}) async =>
        sendTypingIndicator(conversationId: conversationId, isTyping: isTyping);

    api.watchTyping = ({required String conversationId}) async => watchTyping(conversationId: conversationId);

    api.forwardMessages = ({
      required List<String> messageIds,
      required String targetConversationId,
    }) async =>
        forwardMessages(
          messageIds: messageIds,
          targetConversationId: targetConversationId,
        );

    api.deleteMessagesBatch = ({
      required List<String> messageIds,
      required bool forEveryone,
    }) async =>
        deleteMessagesBatch(
          messageIds: messageIds,
          forEveryone: forEveryone,
        );

    api.searchMessages = ({
      required String query,
      String? conversationId,
      String? senderId,
      DateTime? startDateUtc,
      DateTime? endDateUtc,
      bool? hasAttachment,
    }) async =>
        searchMessages(
          query: query,
          conversationId: conversationId,
          senderId: senderId,
          startDateUtc: startDateUtc,
          endDateUtc: endDateUtc,
          hasAttachment: hasAttachment,
        );

    api.downloadMedia = ({required AcChatMessage message, void Function({required double progress})? onProgress}) async =>
        downloadMedia(message: message, onProgress: onProgress);
    api.exportChat = ({required String conversationId, required bool asJson}) async => exportConversation(conversationId: conversationId, asJson: asJson);
    api.wipeAllData = () async => wipeAllData();

    // ── Outbox cache ──────────────────────────────────────────────────────────
    api.storeUpdateInCache = ({required Map<String, dynamic> envelope}) async {
      try {
        print("[AcChatSqlite] Writing update in cache");
        await tblUpdatesCache.saveRow(
          row: {
            TblChannelCache.envelopeJson: jsonEncode(envelope),
            TblChannelCache.createdAt: DateTime.now().toIso8601String(),
          },
          executeBeforeEvent: false,
          executeAfterEvent: false,
        );
      } catch (e, st) {
        log('storeUpdateInCache error', e, st);
      }
    };

    api.getUpdatesFromCache = () async {
      try {
        final result = await tblUpdatesCache.getRows(
          orderBy: '${TblChannelCache.createdAt} ASC',
        );
        if (!result.isSuccess()) return [];
        return result.rows.map((r) {
          final envelope = jsonDecode(r[TblChannelCache.envelopeJson] as String) as Map<String, dynamic>;
          return <String, dynamic>{TblChannelCache.cacheId: r[TblChannelCache.cacheId] as int, ...envelope};
        }).toList();
      } catch (e, st) {
        log('getUpdatesFromCache error', e, st);
        return [];
      }
    };

    api.removeUpdateFromCache = ({required int updateId}) async {
      try {
        await tblUpdatesCache.deleteRows(
          condition: '${TblChannelCache.cacheId} = :id',
          parameters: {':id': updateId},
        );
      } catch (e, st) {
        log('removeUpdateFromCache error', e, st);
      }
    };
  }
}