import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:ac_web_socket/ac_web_socket.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:autocode/autocode.dart';

/// WebSocket transport for [AcChatApi].
///
/// Implements [AcChatSyncChannel] using [AcWsClient] from the `ac_web_socket`
/// package. Connects to the accountea-ws-server with a JWT query parameter,
/// delivers and receives messages in real-time, and auto-sends delivery ACKs
/// on every received message.
///
/// Usage:
/// ```dart
/// api.channel = AcChatOnAcWs(
///   wsUrl: 'ws://localhost:3002',
///   getJwtToken: () => authService.jwtToken,
/// );
/// ```
class AcChatOnAcWs implements AcChatSyncChannel {
  /// WebSocket server URL, e.g. `ws://192.168.1.10:3002`.
  String? wsUrl;

  /// Called fresh on each connect to obtain the current JWT.
  /// If the token changes (e.g. after a re-login), stop + restart listening.
  String Function()? getJwtToken;

  AcWsClient? client;
  AcWebSocket? socket;
  String? _currentUserId;
  final String eventKey;
  final String messageKey;
  final String deliveryAcknowledgementKey;
  final String readAcknowledgementKey;
  final String createConversationKey;
  final String updateConversationKey;
  final String updateConversationUserKey;
  final String editMessageKey;
  final String deleteMessageKey;
  final String typingKey;
  final String addConversationUserKey;
  final String removeConversationUserKey;
  final String readyKey;

  void Function({required String conversationId, required List<String> userIds})? _onConversationUsersRemoved;
  void Function({required String conversationId, required String receiverId, required List<String> messageIds})? _onConversationRead;
  void Function({required AcChatConversation conversation})? _onConversationUpdate;
  void Function({required AcChatConversationUser conversationUser})? _onConversationUserUpdate;
  void Function({required List<String> messageIds, required String conversationId, required String receiverId})? _onMessagesDelivered;
  void Function({required List<String> messageIds, required String conversationId, required String receiverId})? _onMessagesRead;
  void Function({required AcChatMessage message})? _onMessageReceived;
  void Function({required Map<String, dynamic> updateData, required String messageId, required String conversationId})? _onMessageUpdate;
  void Function({required AcChatConversation conversation, required List<String> userIds})? _onNewConversation;
  void Function({required String conversationId, required List<String> userIds})? _onNewConversationUsers;
  void Function({required String conversationId, required String userId, required bool isTyping})? _onTypingChanged;

  @override
  Future<void> Function({required String conversationId, required String messageId})? onMessageFlushed;

  void Function({
    required AcChatConversation conversation,
    required List<AcChatConversationUser> users,
  })? _onConversationChanged;
  void Function({
    required String messageId,
    required String conversationId,
    required String status,
  })? _onMessageStatusUpdated;

  /// Optional [AcChatApi] reference — used to access outbox cache functions
  /// when the socket is unavailable. Wire from ac_chat_sqlite.
  AcChatApi api;
  AcLogger get logger {
    return api.logger;
  }

  /// Called after a cached message envelope is successfully flushed to the
  /// socket. Used by ac_chat_sqlite to update the message status to 'sent'.

  AcChatOnAcWs({
    this.wsUrl,
    this.getJwtToken,
    this.client,
    this.socket,
    required this.api,
    this.eventKey = "ac_chat_user_update",
    this.messageKey  = "message",
    this.deliveryAcknowledgementKey = "delivery_acknowledgement",
    this.readAcknowledgementKey = "read_acknowledgement",
    this.createConversationKey = "conversation_create",
    this.updateConversationKey = "conversation_update",
    this.updateConversationUserKey = "conversation_user_update",
    this.editMessageKey = "message_edit",
    this.deleteMessageKey = "message_delete",
    this.typingKey = "typing",
    this.addConversationUserKey = "add_conversation_user",
    this.removeConversationUserKey = "delete_conversation_user",
    this.readyKey = "ready",
  });

  /// Emits an event. Returns `true` if sent via socket, `false` if cached or dropped.
  Future<bool> _emitEvent({
    required String event,
    required Map<String, dynamic> data,
    List<String>? recipientIds,
    String? conversationId,
    bool writeToCache = true,
  }) async {
    logger.log(["Emitting event $event",data,recipientIds]);
    final Map<String, dynamic> envelope = {
      'event': event,
      'data': data,
    };
    if (recipientIds != null){
      List<String> receivers = [...recipientIds];
      if(receivers.contains(_currentUserId)){
        receivers.remove(_currentUserId);
      }
      envelope['recipientIds'] = receivers;
    }
    else if (conversationId != null) envelope['conversationId'] = conversationId;

    if (socket != null) {
      logger.log("Sending to server");
      await socket!.emit(event: eventKey, data: envelope);
      return true;  // actually sent via socket
    } else if (writeToCache) {
      logger.log("Writing to channel cache");
      await api.storeUpdateInCache(envelope: envelope);
      return false; // cached — will be sent on reconnect
    }
    return false; // silent drop (e.g. typing offline)
  }

  /// Fetches all envelopes stored while offline and emits them in order.
  /// Stops on first failed emit — remaining rows stay for the next reconnect.
  Future<void> _flushCache(AcWebSocket socket) async {
    final pending = await api.getUpdatesFromCache();
    logger.log("Flushing ${pending.length} cache items");
    for (final item in pending) {

      final updateId = item['cache_id'] as int;
      logger.log(["Flushing cash item with id $updateId",item]);
      final envelope = Map<String, dynamic>.from(item)..remove('cache_id');
      try {
        var response = await socket.emit(event: eventKey, data: envelope);
        logger.log(["Socket response",response]);
        await api.removeUpdateFromCache(updateId: updateId);
        // Notify sqlite to update message status to 'sent' if this was a message event
        final event = envelope['event'] as String?;
        if (event != null && event.toLowerCase() == messageKey.toLowerCase()) {
          final data = envelope['data'];
          if (data is Map) {
            final messageId = data['message_id']?.toString();
            final conversationId = data['conversation_id']?.toString();
            if (messageId != null && conversationId != null) {
              logger.log("Updating message status to sent for id  ${messageId}");
              onMessageFlushed?.call(
                messageId: messageId,
                conversationId: conversationId,
              );
            }
          }
        }
      } catch (e,stack) {
        logger.error([e,stack]);
        // Socket dropped mid-flush — remaining rows stay for next reconnect
        break;
      }
    }
  }

  void _registerEventHandlers(AcWebSocket socket) {
    socket.on(
        event: eventKey,
        handler: ({dynamic data, void Function({dynamic response})? callback}) async {
          logger.log(["Received event from socket : ${eventKey}",data]);
          if(data is Map){
            Map<String,dynamic> args = Map.from(data);
            if(args.containsKey('event')){
              String event = args.getString("event");
              Map<String,dynamic> eventData = {};
              if(args.containsKey("data")){
                eventData = Map<String,dynamic>.from(args['data']);
              }
              if(event.equalsIgnoreCase(readyKey)){
                logger.log("Flushing existing cache" );
                await _flushCache(socket);
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(messageKey)){
                try {
                  logger.log("Received new message");
                  final msg = AcChatMessage.instanceFromJson(
                    jsonData: eventData,
                  );
                  _onMessageReceived?.call(message: msg);

                  // Auto-send delivery ACK for messages from other users
                  if (_currentUserId != null && msg.senderId != _currentUserId) {
                    logger.log("Notifying message delivered");
                    notifyMessagesDelivered(
                      messageIds: [msg.messageId],
                      conversationId: msg.conversationId,
                      senderId: msg.senderId,
                    );
                  }
                } catch (e,stack) {
                  logger.error([e,stack]);
                }
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(deliveryAcknowledgementKey)){
                logger.log("Received message delivery acknowledgement");
                final conversationId = eventData['conversationId']?.toString() ?? '';
                final receiverId = eventData['receiverId']?.toString() ?? '';
                final messageIds = (eventData['messageIds'] as List?)?.map((e) => e.toString()).toList() ??
                    (eventData['messageId'] != null ? [eventData['messageId'].toString()] : <String>[]);
                if (messageIds.isNotEmpty) {
                  logger.log("Updating ${messageIds.length} messages to delivered");
                  _onMessagesDelivered?.call(
                    messageIds: messageIds,
                    conversationId: conversationId,
                    receiverId: receiverId,
                  );
                }
                final status = eventData['status']?.toString() ?? 'DELIVERED';
                for (final id in messageIds) {
                  _onMessageStatusUpdated?.call(messageId: id, conversationId: conversationId, status: status);
                }
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(readAcknowledgementKey)){
                logger.log("Received message read acknowledgement");
                final conversationId = eventData['conversationId']?.toString() ?? '';
                final receiverId = eventData['receiverId']?.toString() ?? '';
                final messageIds = (eventData['messageIds'] as List?)?.map((e) => e.toString()).toList() ??
                    (eventData['messageId'] != null ? [eventData['messageId'].toString()] : <String>[]);
                if (messageIds.isNotEmpty) {
                  logger.log("Updating ${messageIds.length} messages to read");
                  _onMessagesRead?.call(
                    messageIds: messageIds,
                    conversationId: conversationId,
                    receiverId: receiverId,
                  );
                  _onConversationRead?.call(
                    conversationId: conversationId,
                    receiverId: receiverId,
                    messageIds: messageIds,
                  );
                }
                final status = eventData['status']?.toString() ?? 'READ';
                for (final id in messageIds) {
                  _onMessageStatusUpdated?.call(messageId: id, conversationId: conversationId, status: status);
                }
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(createConversationKey)){
                logger.log("Received new conversation event");
                if (eventData['conversation'] != null) {
                  final conv = AcChatConversation.instanceFromJson(
                    jsonData: eventData['conversation'],
                  );
                  logger.log(conv);
                  final userIds = (eventData['userIds'] as List?)?.map((e) => e.toString()).toList() ??
                      conv.userIds;
                  logger.log("Users : ${userIds.join(", ")}");
                  _onNewConversation?.call(conversation: conv, userIds: userIds);
                  if (_onConversationChanged != null) {
                    final users = userIds.map((uid) => AcChatConversationUser()..conversationId = conv.conversationId..userId = uid).toList();
                    _onConversationChanged?.call(conversation: conv, users: users);
                  }
                }
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(updateConversationKey)){
                logger.log("Updating conversation");
                if (eventData['conversation'] != null) {
                  final conv = AcChatConversation.instanceFromJson(
                    jsonData: eventData['conversation'],
                  );
                  logger.log(conv);
                  _onConversationUpdate?.call(conversation: conv);
                }
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(updateConversationUserKey)){
                logger.log("Updating conversation user");
                if (eventData['conversationUser'] != null) {
                  final convUser = AcChatConversationUser.instanceFromJson(
                    jsonData: eventData['conversationUser'],
                  );
                  logger.log(convUser);
                  _onConversationUserUpdate?.call(conversationUser: convUser);
                }
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(editMessageKey) || event.equalsIgnoreCase(deleteMessageKey)){
                logger.log("Edit/delete message");
                final messageId = eventData['messageId']?.toString() ?? '';
                final conversationId = eventData['conversationId']?.toString() ?? '';
                if (messageId.isNotEmpty && conversationId.isNotEmpty) {
                  _onMessageUpdate?.call(
                    updateData: eventData,
                    messageId: messageId,
                    conversationId: conversationId,
                  );
                }
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(addConversationUserKey)){
                logger.log("Adding conversation user");
                final conversationId = eventData['conversationId']?.toString() ?? '';
                final userIds = (eventData['userIds'] as List?)?.map((e) => e.toString()).toList()??[];
                if (conversationId.isNotEmpty && userIds.isNotEmpty) {
                  _onNewConversationUsers?.call(
                    conversationId: conversationId,
                    userIds: userIds,
                  );
                }
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(removeConversationUserKey)){
                logger.log("Removing conversation user");
                final conversationId = eventData['conversationId']?.toString() ?? '';
                final userIds = (eventData['userIds'] as List?)?.map((e) => e.toString()).toList()??<String>[];
                if (conversationId.isNotEmpty && userIds.isNotEmpty) {
                  _onConversationUsersRemoved?.call(
                    conversationId: conversationId,
                    userIds: userIds,
                  );
                }
                callback!(response: {'status':'success'});
              }
              else if(event.equalsIgnoreCase(typingKey)){
                logger.log("Received typing");
                final conversationId = eventData['conversationId']?.toString() ?? '';
                final userId = eventData['userId']?.toString() ?? '';
                final isTyping = eventData['isTyping'] == true;
                if (conversationId.isNotEmpty && userId.isNotEmpty) {
                  _onTypingChanged?.call(
                    conversationId: conversationId,
                    userId: userId,
                    isTyping: isTyping,
                  );
                }
                callback!(response: {'status':'success'});
              }
            }
          }
        });

    _emitEvent(event: readyKey, data: {});
  }

  @override
  Future<void> addConversationUsers({
    required String conversationId,
    required List<String> userIds,
  }) async {
    await _emitEvent(
      event: addConversationUserKey,
      data: {'conversationId': conversationId, 'userIds': userIds },
      recipientIds: userIds,
    );
  }

  @override
  Future<void> createConversation({
    required AcChatConversation conversation,
    required List<String> userIds,
    Map<String, dynamic>? notificationPayload,
  }) async {
    final payload = <String, dynamic>{
      'conversation': conversation.toJson(),
      'userIds': userIds,
    };
    if (notificationPayload != null) {
      payload['notification'] = notificationPayload;
    }
    await _emitEvent(event: createConversationKey, data: payload, recipientIds: userIds);
  }

  @override
  Future<void> notifyConversationRead({
    required String conversationId,
    List<String>? messageIds,
  }) async {
    if (messageIds == null || messageIds.isEmpty) return;
    await notifyMessagesRead(
      conversationId: conversationId,
      senderId: api.userId,
      messageIds: messageIds,
    );
  }

  @override
  Future<void> notifyMessagesDelivered({
    required List<String> messageIds,
    required String conversationId,
    required String senderId,
  }) async {
    await _emitEvent(
      event: deliveryAcknowledgementKey,
      data: {'messageIds': messageIds, 'conversationId': conversationId, 'status': 'DELIVERED','receiverId':_currentUserId},
      recipientIds: [senderId],
    );
  }

  @override
  Future<void> notifyMessagesRead({
    required String conversationId,
    required String senderId,
    required List<String> messageIds,
  }) async {
    await _emitEvent(
        event: readAcknowledgementKey,
        data:{'conversationId': conversationId, 'messageIds': messageIds,'status':'READ','receiverId':_currentUserId},
        recipientIds: [senderId]
    );
  }

  @override
  Future<void> removeConversationUsers({
    required String conversationId,
    required List<String> userIds,
  }) async {
    await _emitEvent(
      event: removeConversationUserKey,
      data: {'conversationId': conversationId, 'userIds': userIds},
      recipientIds: userIds,
    );
  }

  @override
  Future<void> updateConversation({
    required AcChatConversation conversation,
  }) async {
    await _emitEvent(
      event: updateConversationKey,
      data: {'conversation': conversation.toJson()},
      recipientIds: conversation.userIds,
    );
  }

  @override
  Future<void> updateConversationUser({
    required AcChatConversationUser conversationUser,
  }) async {
    await _emitEvent(
      event: updateConversationUserKey,
      data: {'conversationUser': conversationUser.toJson()},
      conversationId: conversationUser.conversationId,
    );
  }

  @override
  Future<void> updateMessage({
    required String messageId,
    required String conversationId,
    required Map<String, dynamic> data,
    required List<String> recipientIds,
  }) async {
    final isDelete = data['isDeleted'] == true;
    await _emitEvent(
        event:isDelete ? deleteMessageKey : editMessageKey,
        data: {
          'messageId': messageId,
          'conversationId': conversationId,
          ...data,
        },
        recipientIds:recipientIds
    );
  }

  @override
  Future<bool> sendMessage({
    required AcChatMessage message,
    required List<String> recipientIds,
    Map<String, dynamic>? notificationPayload,
  }) async {
    final payload = message.toJson();
    if (notificationPayload != null) {
      payload['notification'] = notificationPayload;
    }
    return await _emitEvent(
      event: messageKey,
      data: payload,
      recipientIds: recipientIds,
    );
  }

  @override
  Future<void> sendTypingIndicator({
    required String conversationId,
    required List<String> recipientIds,
    required bool isTyping,
  }) async {
    // Ephemeral signal — drop silently if offline, never cache
    _emitEvent(
      event: typingKey,
      data: {'conversationId': conversationId, 'isTyping': isTyping},
      recipientIds: recipientIds,
      writeToCache: false,
    );
  }

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
    void Function({required AcChatConversation conversation, required List<AcChatConversationUser> users})? onConversationChanged,
    void Function({required List<AcChatUser> users})? onUsersLoaded,
    void Function({required String messageId, required String conversationId, required String status})? onMessageStatusUpdated,
    void Function({required String conversationId, required String userId, required bool isTyping})? onTypingChanged,
    void Function({required String userId, required bool isOnline})? onUserPresenceChanged,
  }) async {
    _currentUserId = currentUserId;
    _onConversationUsersRemoved = onConversationUsersRemoved;
    _onConversationRead = onConversationRead;
    _onConversationUpdate = onConversationUpdate;
    _onConversationUserUpdate = onConversationUserUpdate;
    _onMessagesDelivered = onMessagesDelivered;
    _onMessagesRead = onMessagesRead;
    _onMessageReceived = onMessageReceived;
    _onMessageUpdate = onMessageUpdate;
    _onNewConversation = onNewConversation;
    _onNewConversationUsers = onNewConversationUsers;
    _onTypingChanged = onUserTyping ?? onTypingChanged;
    _onConversationChanged = onConversationChanged;
    _onMessageStatusUpdated = onMessageStatusUpdated;

    if (client == null && socket == null && wsUrl != null) {
      client = AcWsClient(
        url: wsUrl!,
        // Pass both the JWT (for auth) and chat_user_id (the conversation_entity_identifier)
        query: {
          'token': getJwtToken != null ? getJwtToken!() : '',
          'chat_user_id': currentUserId,
        },
      );
    }

    client!.onConnection(handler: ({required AcWebSocket socket}) {
      this.socket = socket; // fix: assign to field, not local shadow
      _registerEventHandlers(socket);
    });

    client!.onDisconnect(handler: ({dynamic data}) {
      socket = null;
      // AcWsClient will auto-reconnect in 2s — _registerEventHandlers will run again.
    });

    // if (client != null && socket == null) {
    //   await client!.connect();
    // }

    if(socket != null){
      _registerEventHandlers(socket!);
    }

    print("[AcChatOnAcWs] started listening web socket for chat messages");
  }

  @override
  Future<void> stopListening() async {
    socket?.disconnect();
    socket = null;
    client = null;
    _currentUserId = null;
    _onConversationUsersRemoved = null;
    _onConversationRead = null;
    _onConversationUpdate = null;
    _onConversationUserUpdate = null;
    _onMessagesDelivered = null;
    _onMessagesRead = null;
    _onMessageReceived = null;
    _onMessageUpdate = null;
    _onNewConversation = null;
    _onNewConversationUsers = null;
    _onTypingChanged = null;
    _onConversationChanged = null;
    _onMessageStatusUpdated = null;
  }

}
