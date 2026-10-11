import 'dart:async';
import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:ac_web_socket/ac_web_socket.dart';
import 'package:autocode/autocode.dart';
import 'utils/chat_bridge_events.dart';

/// Client-side bridge that provides a fully wired, reactive [AcChatApi] instance
/// communicating over an active [AcWebSocket] connection to the cloud server.
///
/// Features:
/// 1. In-memory cache: Eliminates blank loading screens on screen transitions.
/// 2. Reactive streams: Powers `AcChat` UI widgets via broadcast StreamControllers.
/// 3. Reconnection catch-up: Automatically requests `chat:sync` upon socket reconnect.
/// 4. Direct Cloudflare R2 uploads: Uses the supplied [mediaHandler] so attachments
///    bypass the cloud server socket, keeping WebSocket bandwidth lean.
class AcChatOnWsClient {
  final AcWebSocket socket;
  final String userId;
  final AcChatMediaHandler? mediaHandler;
  final AcLogger logger = AcLogger(logMessages: true, logType: AcEnumLogType.console);

  late final AcChatApi api;

  /// External listener for data changes (e.g. to call setState in UI).
  void Function()? onDataChanged;

  /// External listener for inbound messages.
  void Function({required AcChatMessage message})? onMessageReceived;

  // In-Memory Caches (Suggestion 2)
  final List<AcChatConversation> _conversationsCache = [];
  final Map<String, List<AcChatMessage>> _messagesCache = {};

  // Reactive Stream Controllers for AcChat widget
  final StreamController<List<AcChatConversation>> _conversationsStreamCtrl =
      StreamController<List<AcChatConversation>>.broadcast();
  final Map<String, StreamController<List<AcChatMessage>>> _messagesStreamCtrls = {};
  final Map<String, StreamController<Map<String, bool>>> _typingStreamCtrls = {};

  DateTime? _lastSyncTimeUtc;
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  AcChatOnWsClient({
    required this.socket,
    required this.userId,
    this.mediaHandler,
    bool enableGroups = true,
  }) {
    api = AcChatApi(
      userId: userId,
      enableGroups: enableGroups,
      mediaHandler: mediaHandler,
    );

    _bindApiDelegates();
    _bindSocketEvents();
  }

  void _bindApiDelegates() {
    // ── Conversations ─────────────────────────────────────────────────────────
    api.getConversations = () async {
      try {
        final res = await socket.emit(event: ChatBridgeEvents.getConversations);
        if (res is Map && res['status'] == 'ok' && res['data'] is List) {
          final list = (res['data'] as List)
              .map((e) => _deserializeConversation(Map<String, dynamic>.from(e as Map)))
              .toList();

          _conversationsCache
            ..clear()
            ..addAll(list);

          if (!_conversationsStreamCtrl.isClosed) {
            _conversationsStreamCtrl.add(List.unmodifiable(_conversationsCache));
          }
          return list;
        }
      } catch (e) {
        logger.log('[AcChatOnWsClient] getConversations error: $e');
      }
      return List.unmodifiable(_conversationsCache);
    };

    api.watchConversations = () async => _conversationsStreamCtrl.stream;

    api.insertConversation = ({AcChatConversation? newConversation, required String otherUserId}) async {
      final convToInsert = newConversation ?? AcChatConversation();
      final res = await socket.emit(event: ChatBridgeEvents.insertConversation, data: {
        'conversation': _serializeConversation(convToInsert),
        'otherUserId': otherUserId,
      });

      if (res is Map && res['status'] == 'ok' && res['data'] is Map) {
        final created = _deserializeConversation(Map<String, dynamic>.from(res['data'] as Map));
        _conversationsCache.removeWhere((c) => c.conversationId == created.conversationId);
        _conversationsCache.insert(0, created);
        if (!_conversationsStreamCtrl.isClosed) {
          _conversationsStreamCtrl.add(List.unmodifiable(_conversationsCache));
        }
        return created;
      }
      return convToInsert;
    };

    api.deleteConversation = ({required conversationId}) async {
      await socket.emit(event: ChatBridgeEvents.deleteConversation, data: {
        'conversationId': conversationId,
      });
      _conversationsCache.removeWhere((c) => c.conversationId == conversationId);
      if (!_conversationsStreamCtrl.isClosed) {
        _conversationsStreamCtrl.add(List.unmodifiable(_conversationsCache));
      }
    };

    api.getConversationUsers = ({required conversationId}) async {
      final res = await socket.emit(event: ChatBridgeEvents.getConversationUsers, data: {
        'conversationId': conversationId,
      });
      if (res is Map && res['status'] == 'ok' && res['data'] is List) {
        return (res['data'] as List)
            .map((e) => AcChatConversationUser.instanceFromJson(jsonData: Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    };

    // ── Messages ──────────────────────────────────────────────────────────────
    api.getMessages = ({required conversationId, limit, offset, orderBy}) async {
      try {
        final res = await socket.emit(event: ChatBridgeEvents.getMessages, data: {
          'conversationId': conversationId,
          'limit': limit ?? 50,
          'offset': offset ?? 0,
        });

        if (res is Map && res['status'] == 'ok' && res['data'] is List) {
          final msgs = (res['data'] as List)
              .map((e) => AcChatMessage.instanceFromJson(jsonData: Map<String, dynamic>.from(e as Map)))
              .toList();

          _messagesCache[conversationId] = msgs;
          _getOrCreateMessageStream(conversationId).add(List.unmodifiable(msgs));
          return msgs;
        }
      } catch (e) {
        logger.log('[AcChatOnWsClient] getMessages error: $e');
      }
      return _messagesCache[conversationId] ?? [];
    };

    api.watchMessages = ({required conversationId}) async {
      return _getOrCreateMessageStream(conversationId).stream;
    };

    api.sendMessage = ({required message}) async {
      // Optimistically add to local cache and stream with status 'sending'
      final list = _messagesCache.putIfAbsent(message.conversationId, () => []);
      list.add(message);
      _getOrCreateMessageStream(message.conversationId).add(List.unmodifiable(list));

      try {
        final res = await socket.emit(event: ChatBridgeEvents.sendMessage, data: {
          'message': message.toJson(),
        });

        if (res is Map && res['status'] == 'ok' && res['data'] is Map) {
          final confirmed = AcChatMessage.instanceFromJson(jsonData: Map<String, dynamic>.from(res['data'] as Map));
          final idx = list.indexWhere((m) => m.messageId == message.messageId);
          if (idx != -1) {
            list[idx] = confirmed;
          }
          _getOrCreateMessageStream(message.conversationId).add(List.unmodifiable(list));
        }
      } catch (e) {
        logger.log('[AcChatOnWsClient] sendMessage error: $e');
        message.status = 'failed';
        _getOrCreateMessageStream(message.conversationId).add(List.unmodifiable(list));
      }
    };

    api.editMessage = ({required messageId, required newText}) async {
      await socket.emit(event: ChatBridgeEvents.editMessage, data: {
        'messageId': messageId,
        'newText': newText,
      });

      for (final list in _messagesCache.values) {
        final msg = list.firstWhere((m) => m.messageId == messageId, orElse: () => AcChatMessage());
        if (msg.messageId.isNotEmpty) {
          msg.text = newText;
          msg.isEdited = true;
          _getOrCreateMessageStream(msg.conversationId).add(List.unmodifiable(list));
          break;
        }
      }
    };

    api.deleteMessageForMe = ({required messageId}) async {
      await socket.emit(event: ChatBridgeEvents.deleteMessageForMe, data: {
        'messageId': messageId,
      });
      for (final entry in _messagesCache.entries) {
        final list = entry.value;
        final idx = list.indexWhere((m) => m.messageId == messageId);
        if (idx != -1) {
          list.removeAt(idx);
          _getOrCreateMessageStream(entry.key).add(List.unmodifiable(list));
          break;
        }
      }
    };

    api.deleteMessageForEveryone = ({required messageId}) async {
      await socket.emit(event: ChatBridgeEvents.deleteMessageForEveryone, data: {
        'messageId': messageId,
      });
      for (final entry in _messagesCache.entries) {
        final list = entry.value;
        final msg = list.firstWhere((m) => m.messageId == messageId, orElse: () => AcChatMessage());
        if (msg.messageId.isNotEmpty) {
          msg.isDeleted = true;
          msg.text = 'This message was deleted';
          _getOrCreateMessageStream(entry.key).add(List.unmodifiable(list));
          break;
        }
      }
    };

    api.notifyConversationRead = ({required conversationId}) async {
      await socket.emit(event: ChatBridgeEvents.notifyConversationRead, data: {
        'conversationId': conversationId,
      });

      // Reset local unread count
      final conv = _conversationsCache.firstWhere(
        (c) => c.conversationId == conversationId,
        orElse: () => AcChatConversation(),
      );
      if (conv.conversationId.isNotEmpty) {
        conv.unread = 0;
        if (!_conversationsStreamCtrl.isClosed) {
          _conversationsStreamCtrl.add(List.unmodifiable(_conversationsCache));
        }
      }
    };

    api.sendTypingIndicator = ({required conversationId, required isTyping}) async {
      socket.emit(event: ChatBridgeEvents.sendTyping, data: {
        'conversationId': conversationId,
        'isTyping': isTyping,
      });
    };

    api.watchTyping = ({required conversationId}) async {
      return _getOrCreateTypingStream(conversationId).stream;
    };

    // ── Users & Contacts ───────────────────────────────────────────────────────
    api.getUserById = ({required userId}) async {
      final res = await socket.emit(event: ChatBridgeEvents.getUserById, data: {'userId': userId});
      if (res is Map && res['status'] == 'ok' && res['data'] is Map) {
        return AcChatUser.instanceFromJson(jsonData: Map<String, dynamic>.from(res['data'] as Map));
      }
      return null;
    };

    api.getUsers = () async {
      final res = await socket.emit(event: ChatBridgeEvents.getUsers);
      if (res is Map && res['status'] == 'ok' && res['data'] is List) {
        return (res['data'] as List)
            .map((e) => AcChatUser.instanceFromJson(jsonData: Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    };

    api.onGetRemoteUsers = ({query, userIds}) async {
      final res = await socket.emit(event: ChatBridgeEvents.getRemoteUsers, data: {
        'query': query,
        'userIds': userIds,
      });
      if (res is Map && res['status'] == 'ok' && res['data'] is List) {
        return (res['data'] as List)
            .map((e) => AcChatUser.instanceFromJson(jsonData: Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    };
  }

  void _bindSocketEvents() {
    socket.on(event: ChatBridgeEvents.messageReceived, handler: ({dynamic data, void Function({dynamic response})? callback}) {
      if (data is Map) {
        final msg = AcChatMessage.instanceFromJson(jsonData: Map<String, dynamic>.from(data));
        final list = _messagesCache.putIfAbsent(msg.conversationId, () => []);

        final idx = list.indexWhere((m) => m.messageId == msg.messageId);
        if (idx != -1) {
          list[idx] = msg;
        } else {
          list.add(msg);
        }

        _getOrCreateMessageStream(msg.conversationId).add(List.unmodifiable(list));

        final conv = _conversationsCache.firstWhere(
          (c) => c.conversationId == msg.conversationId,
          orElse: () => AcChatConversation(),
        );
        if (conv.conversationId.isNotEmpty) {
          conv.lastMessage = msg.text;
          conv.lastMessageType = msg.type;
          conv.lastTime = msg.time;
          if (msg.senderId != userId) {
            conv.unread += 1;
          }
          _conversationsCache.remove(conv);
          _conversationsCache.insert(0, conv);
          if (!_conversationsStreamCtrl.isClosed) {
            _conversationsStreamCtrl.add(List.unmodifiable(_conversationsCache));
          }
        } else {
          api.getConversations();
        }

        onMessageReceived?.call(message: msg);
        onDataChanged?.call();
      }
    });

    socket.on(event: ChatBridgeEvents.dataChanged, handler: ({dynamic data, void Function({dynamic response})? callback}) {
      api.getConversations();
      onDataChanged?.call();
    });

    socket.on(event: ChatBridgeEvents.typingChanged, handler: ({dynamic data, void Function({dynamic response})? callback}) {
      if (data is Map) {
        final convId = data['conversationId']?.toString() ?? '';
        final uid = data['userId']?.toString() ?? '';
        final isTyping = data['isTyping'] == true;
        _getOrCreateTypingStream(convId).add({uid: isTyping});
      }
    });

    socket.on(event: ChatBridgeEvents.messagesRead, handler: ({dynamic data, void Function({dynamic response})? callback}) {
      if (data is Map) {
        final convId = data['conversationId']?.toString() ?? '';
        final rawIds = data['messageIds'];
        final messageIds = rawIds is List ? rawIds.map((e) => e.toString()).toSet() : <String>{};

        final list = _messagesCache[convId];
        if (list != null) {
          for (final m in list) {
            if (messageIds.isEmpty || messageIds.contains(m.messageId)) {
              m.status = 'read';
              m.readTime = DateTime.now().toUtc();
            }
          }
          _getOrCreateMessageStream(convId).add(List.unmodifiable(list));
        }
      }
    });

    socket.on(event: ChatBridgeEvents.messagesDelivered, handler: ({dynamic data, void Function({dynamic response})? callback}) {
      if (data is Map) {
        final convId = data['conversationId']?.toString() ?? '';
        final rawIds = data['messageIds'];
        final messageIds = rawIds is List ? rawIds.map((e) => e.toString()).toSet() : <String>{};

        final list = _messagesCache[convId];
        if (list != null) {
          for (final m in list) {
            if ((messageIds.isEmpty || messageIds.contains(m.messageId)) && m.status != 'read') {
              m.status = 'delivered';
              m.deliveredTime = DateTime.now().toUtc();
            }
          }
          _getOrCreateMessageStream(convId).add(List.unmodifiable(list));
        }
      }
    });

    // Reconnection Catch-Up (Suggestion 3)
    socket.on(event: 'connect', handler: ({dynamic data, void Function({dynamic response})? callback}) {
      logger.log('[AcChatOnWsClient] Socket reconnected, performing catch-up sync...');
      sync();
    });
  }

  /// Performs a catch-up sync to retrieve updates missed while disconnected.
  Future<void> sync() async {
    if (_isDisposed) return;
    try {
      final res = await socket.emit(event: ChatBridgeEvents.sync, data: {
        'lastSyncTimeUtc': _lastSyncTimeUtc?.toIso8601String(),
      });

      if (res is Map && res['status'] == 'ok') {
        if (res['conversations'] is List) {
          final convs = (res['conversations'] as List)
              .map((e) => _deserializeConversation(Map<String, dynamic>.from(e as Map)))
              .toList();
          _conversationsCache
            ..clear()
            ..addAll(convs);
          if (!_conversationsStreamCtrl.isClosed) {
            _conversationsStreamCtrl.add(List.unmodifiable(_conversationsCache));
          }
        }

        if (res['recentMessages'] is List) {
          for (final raw in (res['recentMessages'] as List)) {
            final msg = AcChatMessage.instanceFromJson(jsonData: Map<String, dynamic>.from(raw as Map));
            final list = _messagesCache.putIfAbsent(msg.conversationId, () => []);
            final idx = list.indexWhere((m) => m.messageId == msg.messageId);
            if (idx != -1) {
              list[idx] = msg;
            } else {
              list.add(msg);
            }
            _getOrCreateMessageStream(msg.conversationId).add(List.unmodifiable(list));
          }
        }

        if (res['serverTimeUtc'] != null) {
          _lastSyncTimeUtc = DateTime.tryParse(res['serverTimeUtc'].toString());
        }
        onDataChanged?.call();
      }
    } catch (e) {
      logger.log('[AcChatOnWsClient] sync error: $e');
    }
  }

  StreamController<List<AcChatMessage>> _getOrCreateMessageStream(String conversationId) {
    return _messagesStreamCtrls.putIfAbsent(
      conversationId,
      () => StreamController<List<AcChatMessage>>.broadcast(),
    );
  }

  StreamController<Map<String, bool>> _getOrCreateTypingStream(String conversationId) {
    return _typingStreamCtrls.putIfAbsent(
      conversationId,
      () => StreamController<Map<String, bool>>.broadcast(),
    );
  }

  AcChatConversation _deserializeConversation(Map<String, dynamic> map) {
    final conv = AcChatConversation.instanceFromJson(jsonData: map);
    conv.unread = map['unread'] is int ? map['unread'] as int : 0;
    conv.isPinned = map['is_pinned'] == true;
    conv.isMuted = map['is_muted'] == true;
    conv.isArchived = map['is_archived'] == true;
    return conv;
  }

  Map<String, dynamic> _serializeConversation(AcChatConversation c) {
    final map = c.toJson();
    map['unread'] = c.unread;
    map['is_pinned'] = c.isPinned;
    map['is_muted'] = c.isMuted;
    map['is_archived'] = c.isArchived;
    return map;
  }

  void dispose() {
    _isDisposed = true;
    _conversationsStreamCtrl.close();
    for (final ctrl in _messagesStreamCtrls.values) {
      ctrl.close();
    }
    for (final ctrl in _typingStreamCtrls.values) {
      ctrl.close();
    }
    _messagesStreamCtrls.clear();
    _typingStreamCtrls.clear();
    _conversationsCache.clear();
    _messagesCache.clear();
  }
}
