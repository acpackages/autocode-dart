import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:ac_chat_sqlite/ac_chat_sqlite.dart';
import 'ac_chat_data_dictionary.dart';

class AcChatSqliteChannelSync {
  final Map<String, Map<String, bool>> _typingState = {};

  final AcChatSqlite chatSqlite;
  AcChatApi get api {
    return chatSqlite.api;
  }
  String get currentUserId {
    return api.userId;
  }

  Future<void> Function({required String messageId, required String conversationId}) get onMessageFlushed =>
      ({required String messageId, required String conversationId}) async {
        await chatSqlite.updateMessageFields(
          messageId: messageId,
          fields: {TblMessages.status: 'sent'},
        );
        chatSqlite.notifyMessagesChanged(conversationId: conversationId);
        chatSqlite.onDataChanged?.call();
      };

  AcChatSqliteChannelSync({required this.chatSqlite});

  Future<void> _handleIncomingMessage({required AcChatMessage message}) async {
    if (await chatSqlite.isUserBlocked(userId: message.senderId)) {
      _log('Incoming message suppressed from blocked user ${message.senderId}', '', StackTrace.current);
      return;
    }

    message.localPath = null;
    message.isDownloaded = false;

    final existing = await chatSqlite.getMessageById(messageId: message.messageId);
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
        await chatSqlite.updateMessageFields(
          messageId: message.messageId,
          fields: {
            TblMessages.status: existing.status,
            if (existing.deliveredTime != null)
              TblMessages.deliveredTime: existing.deliveredTime!.toIso8601String(),
            if (existing.readTime != null)
              TblMessages.readTime: existing.readTime!.toIso8601String(),
          },
        );
        chatSqlite.notifyMessagesChanged(conversationId: message.conversationId);
        chatSqlite.onDataChanged?.call();
      }
      return;
    }

    // Save received media into directories by type if dataDirectory is configured
    if (api.dataDirectory.isNotEmpty && message.type != 'text') {
      if (message.byteData != null && message.byteData!.isNotEmpty) {
        try {
          final fileName = message.fileName ??
              (message.text.isNotEmpty && !message.text.startsWith('http')
                  ? message.text.split(RegExp(r'[/\\]')).last
                  : '${message.messageId}.${AcChatApi.defaultExtensionForType(message.type)}');
          final savedPath = await api.saveMediaFile(
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

    await chatSqlite.upsertMessage(message: message);

    chatSqlite.updateConversationLastMessage(message: message);
    await chatSqlite.updateConversationFields(
      conversationId: message.conversationId,
      fields: {
        TblConversations.lastMessage: message.text,
        TblConversations.lastMessageType: message.type,
        TblConversations.lastTime: message.time.toIso8601String(),
      },
    );

    if (message.senderId != currentUserId) {
      final conv = await chatSqlite.getConversationById(conversationId: message.conversationId);
      if (conv != null) {
        conv.unread += 1;
        final pref = await chatSqlite.getConversationPref(conversationId: message.conversationId);
        if (pref != null) {
          pref.unreadCount += 1;
          await chatSqlite.updateConversationPrefs(prefs: pref);
        }
        await chatSqlite.updateConversationFields(
          conversationId: message.conversationId,
          fields: {TblConversations.unread: conv.unread},
        );
      }
      if (api.enableDeliveryReceipts) {
        api.channel?.notifyMessagesDelivered(
          messageIds: [message.messageId],
          conversationId: message.conversationId,
          senderId: message.senderId,
        );
      }
      chatSqlite.onMessageReceived?.call(message: message);
    }

    chatSqlite.notifyMessagesChanged(conversationId: message.conversationId);
    chatSqlite.notifyConversationsChanged();
    chatSqlite.onDataChanged?.call();
  }

  Future<void> _handleConversationUsersRemoved({
    required String conversationId,
    required List<String> userIds,
  }) async {
    for (final uid in userIds) {
      await chatSqlite.removeConversationUsers(
        conversationId: conversationId,
        userId: uid,
      );
    }
    chatSqlite.notifyConversationsChanged();
    chatSqlite.onDataChanged?.call();
  }

  Future<void> _handleConversationRead({
    required String conversationId,
    required String receiverId,
    required List<String> messageIds,
  }) async {
    final nowUtc = DateTime.now().toUtc();
    final nowIso = nowUtc.toIso8601String();

    if (receiverId == currentUserId) {
      final pref = await chatSqlite.getConversationPref(conversationId: conversationId);
      if (pref != null) {
        pref.unreadCount = 0;
        await chatSqlite.updateConversationPrefs(prefs: pref);
      }
      await chatSqlite.updateConversationFields(
        conversationId: conversationId,
        fields: {TblConversations.unread: 0},
      );
    }

    final msgs = await chatSqlite.getMessages(conversationId: conversationId);
    var changed = false;

    for (final m in msgs) {
      final matches = messageIds.isNotEmpty
          ? messageIds.contains(m.messageId)
          : (receiverId == currentUserId ? m.senderId != currentUserId : m.senderId == currentUserId);
      if (matches && m.status != 'read') {
        m.status = 'read';
        m.readTime = nowUtc;
        changed = true;
        await chatSqlite.updateMessageFields(
          messageId: m.messageId,
          fields: {
            TblMessages.status: 'read',
            TblMessages.readTime: nowIso,
          },
        );
      }
    }

    if (changed) {
      chatSqlite.notifyMessagesChanged(conversationId: conversationId);
    }
    chatSqlite.notifyConversationsChanged();
    chatSqlite.onDataChanged?.call();
  }

  Future<void> _handleConversationUpdate({
    required AcChatConversation conversation,
  }) async {
    await chatSqlite.upsertConversation(conversation: conversation);
    chatSqlite.sortConversations();
    chatSqlite.notifyConversationsChanged();
    chatSqlite.onDataChanged?.call();
  }

  Future<void> _handleConversationUserUpdate({
    required AcChatConversationUser conversationUser,
  }) async {
    if (conversationUser.userId == currentUserId) {
      await chatSqlite.updateConversationPrefs(prefs: conversationUser);
    } else {
      try {
        await chatSqlite.tblConversationUsers.saveRow(
          row: conversationUser.toJson(),
          executeBeforeEvent: false,
          executeAfterEvent: false,
        );
      } catch (e, st) {
        _log('_handleConversationUserUpdate error', e, st);
      }
      chatSqlite.notifyConversationsChanged();
      chatSqlite.onDataChanged?.call();
    }
  }

  Future<void> _handleMessagesDelivered({
    required List<String> messageIds,
    required String conversationId,
    required String receiverId,
  }) async {
    final nowUtc = DateTime.now().toUtc();
    for (final mid in messageIds) {
      await chatSqlite.updateMessageFields(
        messageId: mid,
        fields: {
          TblMessages.status: 'delivered',
          TblMessages.deliveredTime: nowUtc.toIso8601String(),
        },
      );
    }
    chatSqlite.notifyMessagesChanged(conversationId: conversationId);
    chatSqlite.onDataChanged?.call();
  }

  Future<void> _handleMessagesRead({
    required List<String> messageIds,
    required String conversationId,
    required String receiverId,
  }) async {
    final nowUtc = DateTime.now().toUtc();
    for (final mid in messageIds) {
      await chatSqlite.updateMessageFields(
        messageId: mid,
        fields: {
          TblMessages.status: 'read',
          TblMessages.readTime: nowUtc.toIso8601String(),
        },
      );
    }
    chatSqlite.notifyMessagesChanged(conversationId: conversationId);
    chatSqlite.onDataChanged?.call();
  }

  Future<void> _handleMessageUpdate({
    required Map<String, dynamic> updateData,
    required String messageId,
    required String conversationId,
  }) async {
    await chatSqlite.updateMessageFields(
      messageId: messageId,
      fields: chatSqlite.dataToMessageFields(updateData),
    );
    chatSqlite.notifyMessagesChanged(conversationId: conversationId);
    chatSqlite.onDataChanged?.call();
  }

  Future<void> _handleNewConversation({
    required AcChatConversation conversation,
    required List<String> userIds,
  }) async {
    print("[AcChatSqliteChannelSync] Creating new conversation with users : ${userIds.join(",")}");
    final allUsers = Set<String>.from(conversation.userIds)..addAll(userIds);
    if (currentUserId.isNotEmpty) allUsers.add(currentUserId);
    conversation.userIds = allUsers.toList();

    var existingUsers = await chatSqlite.tblUsers.getRows(
      condition: "${TblUsers.userId} IN (@userIds)",
      parameters: {"@userIds": [...allUsers]},
    );
    if (existingUsers.isSuccess()) {
      var notFoundUserIds = List<String>.from(allUsers);
      for (var row in existingUsers.rows) {
        notFoundUserIds.remove(row[TblUsers.userId]);
      }
      if (api.onGetRemoteUsers != null && notFoundUserIds.isNotEmpty) {
        List<AcChatUser> users = await api.onGetRemoteUsers!(userIds: notFoundUserIds);
        for (var user in users) {
          await chatSqlite.saveUser(user: user);
        }
      }
    }

    await chatSqlite.insertConversation(
      conversation: conversation,
      userIds: allUsers.toList(),
    );
  }

  Future<void> _handleNewConversationUsers({
    required String conversationId,
    required List<String> userIds,
  }) async {
    await chatSqlite.addConversationUsers(
      conversationId: conversationId,
      userIds: userIds,
    );
  }

  void _handleUserTyping({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) {
    final state = _typingState.putIfAbsent(conversationId, () => {});
    state[userId] = isTyping;
    chatSqlite.typingStreamCtrls[conversationId]?.add(Map.unmodifiable(state));
  }

  Future<void> initialize() async {
    if (api.channel != null) {
      try {
        final channel = api.channel!;
        channel.onMessageFlushed = onMessageFlushed;
        await channel.startListening(
          currentUserId: currentUserId,
          onConversationUsersRemoved: _handleConversationUsersRemoved,
          onConversationRead: _handleConversationRead,
          onConversationUpdate: _handleConversationUpdate,
          onConversationUserUpdate: _handleConversationUserUpdate,
          onMessagesDelivered: _handleMessagesDelivered,
          onMessagesRead: _handleMessagesRead,
          onMessageReceived: _handleIncomingMessage,
          onMessageUpdate: _handleMessageUpdate,
          onNewConversation: _handleNewConversation,
          onNewConversationUsers: _handleNewConversationUsers,
          onUserTyping: _handleUserTyping,
        );
      } catch (e, st) {
        _log('channel startListening error', e, st);
      }
    }
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    chatSqlite.log(message, error, stackTrace);
  }
}