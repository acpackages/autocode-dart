import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:ac_web_socket/ac_web_socket.dart';
import 'package:autocode/autocode.dart';
import 'utils/chat_bridge_events.dart';

/// Server-side bridge that exposes an authoritative [AcChatApi] instance to
/// connected WebSocket clients.
///
/// Features:
/// 1. Multi-client fan-out: Manages a pool of active client sockets and broadcasts
///    inbound messages and changes to all connected tabs/sessions.
/// 2. RPC dispatching: Executes chat queries and mutations against the authoritative
///    server [AcChatApi] instance.
/// 3. Reconnection sync: Provides `chat:sync` catch-up for clients reconnecting after
///    being offline.
class AcChatOnWsServer {
  final AcChatApi api;
  final List<AcWebSocket> _clients = [];
  final AcLogger logger = AcLogger(logMessages: true, logType: AcEnumLogType.console);

  AcChatOnWsServer({required this.api});

  /// Registers a newly connected client socket.
  void registerClient(AcWebSocket socket) {
    if (!_clients.contains(socket)) {
      _clients.add(socket);
      logger.log('[AcChatOnWsServer] Registered client socket: ${socket.id} (total: ${_clients.length})');
      _bindSocketHandlers(socket);
    }
  }

  /// Unregisters a disconnected client socket.
  void unregisterClient(AcWebSocket socket) {
    _clients.remove(socket);
    logger.log('[AcChatOnWsServer] Unregistered client socket: ${socket.id} (total: ${_clients.length})');
  }

  /// Broadcasts an event to all connected clients (optionally excluding a sender).
  void broadcast({required String event, required dynamic data, AcWebSocket? exclude}) {
    for (final client in _clients.toList()) {
      if (exclude != null && client == exclude) continue;
      try {
        client.emit(event: event, data: data);
      } catch (e) {
        logger.log('[AcChatOnWsServer] Error broadcasting $event to ${client.id}: $e');
      }
    }
  }

  /// Call this when a message is received from storage/relay to broadcast to all clients.
  void notifyMessageReceived(AcChatMessage message) {
    broadcast(
      event: ChatBridgeEvents.messageReceived,
      data: _serializeMessage(message),
    );
  }

  /// Call this when chat data changes to prompt clients to refresh.
  void notifyDataChanged() {
    broadcast(event: ChatBridgeEvents.dataChanged, data: {});
  }

  /// Call this when typing status changes.
  void notifyTypingChanged({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) {
    broadcast(
      event: ChatBridgeEvents.typingChanged,
      data: {
        'conversationId': conversationId,
        'userId': userId,
        'isTyping': isTyping,
      },
    );
  }

  /// Call this when read receipts arrive.
  void notifyMessagesRead({
    required String conversationId,
    required List<String> messageIds,
    required String receiverId,
  }) {
    broadcast(
      event: ChatBridgeEvents.messagesRead,
      data: {
        'conversationId': conversationId,
        'messageIds': messageIds,
        'receiverId': receiverId,
      },
    );
  }

  /// Call this when delivery receipts arrive.
  void notifyMessagesDelivered({
    required String conversationId,
    required List<String> messageIds,
    required String receiverId,
  }) {
    broadcast(
      event: ChatBridgeEvents.messagesDelivered,
      data: {
        'conversationId': conversationId,
        'messageIds': messageIds,
        'receiverId': receiverId,
      },
    );
  }

  void _bindSocketHandlers(AcWebSocket socket) {
    // ── 1. Conversations ───────────────────────────────────────────────────────
    socket.on(event: ChatBridgeEvents.getConversations, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final convs = await api.getConversations();
        final serialized = convs.map(_serializeConversation).toList();
        callback?.call(response: {'status': 'ok', 'data': serialized});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.insertConversation, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final rawConv = Map<String, dynamic>.from(payload['conversation'] as Map? ?? {});
        final otherUserId = payload['otherUserId']?.toString() ?? '';
        final conv = AcChatConversation.instanceFromJson(jsonData: rawConv);
        final result = await api.insertConversation(newConversation: conv, otherUserId: otherUserId);
        notifyDataChanged();
        callback?.call(response: {'status': 'ok', 'data': _serializeConversation(result)});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.deleteConversation, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final conversationId = payload['conversationId']?.toString() ?? '';
        await api.deleteConversation(conversationId: conversationId);
        notifyDataChanged();
        callback?.call(response: {'status': 'ok'});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.getConversationUsers, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final conversationId = payload['conversationId']?.toString() ?? '';
        final users = await api.getConversationUsers(conversationId: conversationId);
        callback?.call(response: {'status': 'ok', 'data': users.map((u) => u.toJson()).toList()});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    // ── 2. Messages ────────────────────────────────────────────────────────────
    socket.on(event: ChatBridgeEvents.getMessages, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final conversationId = payload['conversationId']?.toString() ?? '';
        final limit = payload['limit'] is int ? payload['limit'] as int : int.tryParse(payload['limit']?.toString() ?? '50') ?? 50;
        final offset = payload['offset'] is int ? payload['offset'] as int : int.tryParse(payload['offset']?.toString() ?? '0') ?? 0;

        final messages = await api.getMessages(
          conversationId: conversationId,
          limit: limit,
          offset: offset,
        );

        final serialized = messages.map(_serializeMessage).toList();
        callback?.call(response: {'status': 'ok', 'data': serialized});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.sendMessage, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final rawMsg = Map<String, dynamic>.from(payload['message'] as Map? ?? {});
        final msg = AcChatMessage.instanceFromJson(jsonData: rawMsg);

        await api.sendMessage(message: msg);

        // Broadcast to other tabs
        broadcast(
          event: ChatBridgeEvents.messageReceived,
          data: _serializeMessage(msg),
          exclude: socket,
        );

        callback?.call(response: {'status': 'ok', 'data': _serializeMessage(msg)});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.editMessage, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final messageId = payload['messageId']?.toString() ?? '';
        final newText = payload['newText']?.toString() ?? '';
        await api.editMessage(messageId: messageId, newText: newText);
        notifyDataChanged();
        callback?.call(response: {'status': 'ok'});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.deleteMessageForMe, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final messageId = payload['messageId']?.toString() ?? '';
        await api.deleteMessageForMe(messageId: messageId);
        callback?.call(response: {'status': 'ok'});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.deleteMessageForEveryone, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final messageId = payload['messageId']?.toString() ?? '';
        await api.deleteMessageForEveryone(messageId: messageId);
        notifyDataChanged();
        callback?.call(response: {'status': 'ok'});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.notifyConversationRead, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final conversationId = payload['conversationId']?.toString() ?? '';

        await api.notifyConversationRead(conversationId: conversationId);

        callback?.call(response: {'status': 'ok'});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.sendTyping, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final conversationId = payload['conversationId']?.toString() ?? '';
        final isTyping = payload['isTyping'] == true;
        await api.sendTypingIndicator(conversationId: conversationId, isTyping: isTyping);
        callback?.call(response: {'status': 'ok'});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    // ── 3. Users & Contacts ────────────────────────────────────────────────────
    socket.on(event: ChatBridgeEvents.getUserById, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final userId = payload['userId']?.toString() ?? '';
        final user = await api.getUserById(userId: userId);
        callback?.call(response: {'status': 'ok', 'data': user?.toJson()});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.getUsers, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final users = await api.getUsers();
        callback?.call(response: {'status': 'ok', 'data': users.map((u) => u.toJson()).toList()});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    socket.on(event: ChatBridgeEvents.getRemoteUsers, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final payload = Map<String, dynamic>.from(data as Map? ?? {});
        final query = payload['query']?.toString();
        final rawIds = payload['userIds'];
        final userIds = rawIds is List ? rawIds.map((e) => e.toString()).toList() : null;

        final users = await api.onGetRemoteUsers?.call(query: query, userIds: userIds) ?? [];
        callback?.call(response: {'status': 'ok', 'data': users.map((u) => u.toJson()).toList()});
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });

    // ── 4. Catch-Up Sync (Suggestion 3) ────────────────────────────────────────
    socket.on(event: ChatBridgeEvents.sync, handler: ({dynamic data, void Function({dynamic response})? callback}) async {
      try {
        final convs = await api.getConversations();
        List<Map<String, dynamic>> recentMessages = [];

        for (final c in convs) {
          final msgs = await api.getMessages(
            conversationId: c.conversationId,
            limit: 20,
          );
          recentMessages.addAll(msgs.map(_serializeMessage));
        }

        callback?.call(response: {
          'status': 'ok',
          'conversations': convs.map(_serializeConversation).toList(),
          'recentMessages': recentMessages,
          'serverTimeUtc': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (e) {
        callback?.call(response: {'status': 'error', 'error': e.toString()});
      }
    });
  }

  Map<String, dynamic> _serializeConversation(AcChatConversation c) {
    final map = c.toJson();
    map['unread'] = c.unread;
    map['is_pinned'] = c.isPinned;
    map['is_muted'] = c.isMuted;
    map['is_archived'] = c.isArchived;
    return map;
  }

  Map<String, dynamic> _serializeMessage(AcChatMessage m) {
    return m.toJson();
  }
}
