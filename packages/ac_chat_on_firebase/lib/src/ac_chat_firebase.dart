import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:uuid/uuid.dart';

import 'ac_chat_firebase_config.dart';
import 'firestore_extensions.dart';

/// Firebase backend adapter for `ac_chat`.
///
/// [AcChatFirebase] maintains an in-memory cache of users, conversations, and
/// messages that is kept up-to-date by Firestore real-time listeners.
///
/// Because [AcChatApi] callback signatures are synchronous, this class
/// pre-fetches and caches all data so that `getConversations()`,
/// `getMessages()`, etc. return instantly.
///
/// ## Standalone usage (no SQLite caching layer)
///
/// ```dart
/// final firebase = AcChatFirebase(currentUserId: 'uid');
/// firebase.onDataChanged = () => setState(() {});
/// await firebase.initialize();
/// final api = firebase.buildApi(AcChatTheme.dark());
/// ```
///
/// ## Channel usage (with `ac_chat_sqlite` or similar)
///
/// Call [startListening] with your own callbacks instead of relying on
/// [onDataChanged]. The [AcChatSyncChannel] implementation will forward
/// changes to the local SQLite cache.
class AcChatFirebase implements AcChatSyncChannel {
  // ─── Constructor ──────────────────────────────────────────────────────────

  /// Creates an [AcChatFirebase] instance.
  ///
  /// [currentUserId] is the user ID of the currently authenticated user.
  /// This value is supplied by the host application; this package has no
  /// dependency on Firebase Auth.
  ///
  /// [app] is an optional [FirebaseApp]. When omitted the default app is used.
  /// Pass a named app to target a specific Firebase project in multi-instance
  /// setups (e.g. `Firebase.app('chat')`).
  ///
  /// [config] allows customizing collection names, subcollection names, storage
  /// path, and pagination size. All fields have sensible defaults.
  AcChatFirebase({
    required String currentUserId,
    FirebaseApp? app,
    AcChatFirebaseConfig? config,
  })  : _currentUserId = currentUserId,
        _config = config ?? const AcChatFirebaseConfig() {
    // Derive Firestore and Storage from the supplied FirebaseApp rather than
    // accepting them directly — this keeps the coupling clean and testable.
    _firestore = app != null
        ? FirebaseFirestore.instanceFor(app: app)
        : FirebaseFirestore.instance;
    _storage = app != null
        ? FirebaseStorage.instanceFor(app: app)
        : FirebaseStorage.instance;
  }

  // ─── Private fields ────────────────────────────────────────────────────────

  final String _currentUserId;
  final AcChatFirebaseConfig _config;

  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;

  final _uuid = const Uuid();

  // ── In-memory state ────────────────────────────────────────────────────────

  final List<AcChatUser> _users = [];
  final List<AcChatConversation> _conversations = [];
  final Map<String, List<AcChatConversationUser>> _members = {};
  final Map<String, List<AcChatMessage>> _messages = {};

  /// O(1) user lookup by userId.
  final Map<String, AcChatUser> _userIndex = {};

  /// O(1) message lookup by messageId — used to resolve reply_to_id.
  final Map<String, AcChatMessage> _messageIndex = {};

  /// O(1) conversation lookup by conversationId.
  final Map<String, AcChatConversation> _conversationIndex = {};

  // ── Listener subscriptions ─────────────────────────────────────────────────

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  // ── Channel mode callbacks ─────────────────────────────────────────────────

  void Function(AcChatMessage message)? _onMessageReceived;
  void Function(
    AcChatConversation conversation,
    List<AcChatConversationUser> members,
  )? _onConversationChanged;
  void Function(List<AcChatUser> users)? _onUsersLoaded;

  bool get _isChannelMode => _onMessageReceived != null;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Called whenever Firestore data changes in **standalone mode**.
  ///
  /// Set this to `() => setState(() {})` in your [StatefulWidget] to trigger
  /// UI rebuilds when messages, conversations, or users arrive from Firestore.
  ///
  /// This callback is **not** invoked in channel mode (when [startListening]
  /// has been called), because the caching layer owns the local state.
  VoidCallback? onDataChanged;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  /// Initializes the Firebase adapter by loading all data from Firestore and
  /// setting up real-time listeners.
  ///
  /// Must be called once before [buildApi]. Awaiting this future guarantees
  /// that the first render has data available.
  Future<void> initialize() async {
    try {
      await _loadUsers();
      await _setupConversationListener();
    } catch (e, st) {
      _log('initialize error', e, st);
    }
  }

  /// Returns a fully wired [AcChatApi] backed by in-memory state that is
  /// kept current by Firestore real-time listeners.
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
      markAsRead: _markAsReadStandalone,
      insertConversation: _insertConversation,
      getMessages: _getMessages,
      sendMessage: _sendMessageStandalone,
      enableGroupsAndStatuses: true,
      updateMessage: _updateMessageStandalone,
    );
  }

  /// Cancels all Firestore listeners and releases resources.
  ///
  /// Call this in `dispose()` of the owning [StatefulWidget].
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  // ─── AcChatSyncChannel implementation ─────────────────────────────────────

  /// Sends [message] to Firestore.
  ///
  /// In **channel mode** only Firestore is written — the local caching layer
  /// owns in-memory state. In **standalone mode** an optimistic local write
  /// is performed first and `onDataChanged` is called to refresh the UI.
  @override
  Future<void> sendMessage(AcChatMessage message) async {
    if (_isChannelMode) {
      await _writeMessageToFirestore(message);
    } else {
      await _sendMessageStandaloneAsync(message);
    }
  }

  /// Writes a new [conversation] and its two initial member documents
  /// to Firestore.
  @override
  Future<void> createConversation(
    AcChatConversation conversation,
    String otherUserId,
  ) async {
    try {
      final convRef = _firestore
          .collection(_config.conversationsCollection)
          .doc(conversation.conversationId);

      await convRef.set(FirestoreExtensions.conversationToFirestore(conversation));
      await _writeMemberDocs(
        conversationId: conversation.conversationId,
        userIds: [_currentUserId, otherUserId],
      );
    } catch (e, st) {
      _log('createConversation error', e, st);
      rethrow;
    }
  }

  /// Sets `unread = 0` for [currentUserId] in the [conversationId] members
  /// subcollection.
  @override
  Future<void> markAsRead(
    String conversationId,
    String currentUserId,
  ) async {
    try {
      await _firestore
          .collection(_config.conversationsCollection)
          .doc(conversationId)
          .collection(_config.conversationUsersSubcollection)
          .doc(currentUserId)
          .update({FirestoreExtensions.fUnread: 0});
    } catch (e, st) {
      _log('markAsRead error', e, st);
    }
  }

  /// Applies [data] as a partial update to the specified message document.
  @override
  Future<void> updateMessage(
    String messageId,
    String conversationId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(_config.conversationsCollection)
          .doc(conversationId)
          .collection(_config.messagesSubcollection)
          .doc(messageId)
          .update(data);
    } catch (e, st) {
      _log('updateMessage error', e, st);
    }
  }

  /// Starts listening for remote events in **channel mode**.
  ///
  /// After calling this method, Firestore listener events are forwarded
  /// through the supplied callbacks instead of updating in-memory state
  /// and calling [onDataChanged].
  @override
  Future<void> startListening({
    required String currentUserId,
    required void Function(AcChatMessage message) onMessageReceived,
    required void Function(
      AcChatConversation conversation,
      List<AcChatConversationUser> members,
    ) onConversationChanged,
    required void Function(List<AcChatUser> users) onUsersLoaded,
  }) async {
    _onMessageReceived = onMessageReceived;
    _onConversationChanged = onConversationChanged;
    _onUsersLoaded = onUsersLoaded;

    await initialize();
  }

  /// Cancels all listeners — alias for [dispose] to satisfy
  /// [AcChatSyncChannel].
  @override
  Future<void> stopListening() async {
    dispose();
  }

  // ─── Firestore data loading ────────────────────────────────────────────────

  /// Performs an initial fetch of all users and then subscribes to changes.
  Future<void> _loadUsers() async {
    final col = _firestore.collection(_config.usersCollection);

    // One-time initial fetch so that `getUsers()` returns data immediately.
    final snapshot = await col.get();
    _applyUsersSnapshot(snapshot.docs);

    // Real-time listener for subsequent changes.
    final sub = col.snapshots().listen(
      (snap) {
        _applyUsersSnapshot(snap.docs);
        if (_isChannelMode) {
          _onUsersLoaded?.call(List.unmodifiable(_users));
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

  /// Subscribes to the conversations collection filtered by membership and
  /// triggers per-conversation message and member listeners.
  Future<void> _setupConversationListener() async {
    final col = _firestore
        .collection(_config.conversationsCollection)
        .where(FirestoreExtensions.fMemberIds, arrayContains: _currentUserId)
        .orderBy(FirestoreExtensions.fLastTime, descending: true);

    final sub = col.snapshots().listen(
      (snap) async {
        for (final change in snap.docChanges) {
          if (change.type == DocumentChangeType.added ||
              change.type == DocumentChangeType.modified) {
            await _applyConversationDoc(
              change.doc as QueryDocumentSnapshot<Map<String, dynamic>>,
            );
          } else if (change.type == DocumentChangeType.removed) {
            _removeConversation(change.doc.id);
          }
        }

        if (!_isChannelMode) {
          _notifyDataChanged();
        }
      },
      onError: (Object e, StackTrace st) =>
          _log('conversations listener error', e, st),
    );
    _subscriptions.add(sub);
  }

  /// Processes a single conversation document: updates in-memory state,
  /// then ensures member and message listeners are active for it.
  Future<void> _applyConversationDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final convId = doc.id;
    final existingUnread = _conversationIndex[convId]?.unread ?? 0;
    final conv = FirestoreExtensions.conversationFromQueryDoc(
      doc,
      unread: existingUnread,
    );

    _conversationIndex[convId] = conv;

    // Rebuild ordered list.
    _conversations.removeWhere((c) => c.conversationId == convId);
    _conversations.add(conv);
    _conversations.sort((a, b) => b.lastTime.compareTo(a.lastTime));

    // Start sub-listeners if not already running for this conversation.
    if (!_messages.containsKey(convId)) {
      _messages[convId] = [];
      _setupMessageListener(convId);
    }
    if (!_members.containsKey(convId)) {
      _members[convId] = [];
      _setupMemberListener(convId);
    }

    if (_isChannelMode) {
      _onConversationChanged?.call(conv, _members[convId] ?? []);
    }
  }

  void _removeConversation(String convId) {
    _conversationIndex.remove(convId);
    _conversations.removeWhere((c) => c.conversationId == convId);
    _messages.remove(convId);
    _members.remove(convId);
  }

  /// Sets up a real-time listener on the messages subcollection of [convId].
  void _setupMessageListener(String convId) {
    final query = _firestore
        .collection(_config.conversationsCollection)
        .doc(convId)
        .collection(_config.messagesSubcollection)
        .orderBy(FirestoreExtensions.fTime, descending: false)
        .limitToLast(_config.messagesPageSize);

    final sub = query.snapshots().listen(
      (snap) {
        for (final change in snap.docChanges) {
          if (change.type == DocumentChangeType.added ||
              change.type == DocumentChangeType.modified) {
            final msg = _messageFromDoc(
              change.doc as QueryDocumentSnapshot<Map<String, dynamic>>,
            );
            _upsertMessage(convId, msg);

            if (_isChannelMode) {
              _onMessageReceived?.call(msg);
            }
          } else if (change.type == DocumentChangeType.removed) {
            _messages[convId]
                ?.removeWhere((m) => m.messageId == change.doc.id);
            _messageIndex.remove(change.doc.id);
          }
        }

        if (!_isChannelMode) {
          _notifyDataChanged();
        }
      },
      onError: (Object e, StackTrace st) =>
          _log('messages listener[$convId] error', e, st),
    );
    _subscriptions.add(sub);
  }

  /// Converts a message document to [AcChatMessage], resolving `reply_to_id`
  /// from [_messageIndex].
  AcChatMessage _messageFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final replyToId =
        doc.data()[FirestoreExtensions.fReplyToId] as String?;
    final resolvedReply =
        replyToId != null ? _messageIndex[replyToId] : null;
    return FirestoreExtensions.messageFromQueryDoc(
      doc,
      resolvedReplyTo: resolvedReply,
    );
  }

  /// Inserts or replaces [msg] in the per-conversation list and the index.
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

  /// Sets up a real-time listener on the members subcollection of [convId].
  void _setupMemberListener(String convId) {
    final col = _firestore
        .collection(_config.conversationsCollection)
        .doc(convId)
        .collection(_config.conversationUsersSubcollection);

    final sub = col.snapshots().listen(
      (snap) {
        final memberList = snap.docs
            .map((d) =>
                FirestoreExtensions.conversationUserFromQueryDoc(d, convId))
            .toList();
        _members[convId] = memberList;

        // Update unread counter from the current user's member doc.
        for (final doc in snap.docs) {
          if (doc.id == _currentUserId) {
            final unread = (doc.data()[FirestoreExtensions.fUnread] as int?) ?? 0;
            _conversationIndex[convId]?.unread = unread;
            final listIdx = _conversations
                .indexWhere((c) => c.conversationId == convId);
            if (listIdx >= 0) {
              _conversations[listIdx].unread = unread;
            }
            break;
          }
        }

        if (!_isChannelMode) {
          _notifyDataChanged();
        }
      },
      onError: (Object e, StackTrace st) =>
          _log('members listener[$convId] error', e, st),
    );
    _subscriptions.add(sub);
  }

  // ─── AcChatApi callback implementations ───────────────────────────────────

  AcChatUser _getCurrentUser() {
    return _userIndex[_currentUserId] ?? (AcChatUser()..userId = _currentUserId);
  }

  List<AcChatUser> _getUsers() => List.unmodifiable(_users);

  AcChatUser? _getUserById(String userId) {
    final user = _userIndex[userId];
    if (user == null) {
      // Trigger a background fetch so subsequent calls return the correct user.
      _fetchUserInBackground(userId);
    }
    return user;
  }

  List<AcChatConversation> _getConversations() =>
      List.unmodifiable(_conversations);

  List<AcChatConversationUser> _getConversationUsers(String conversationId) =>
      List.unmodifiable(_members[conversationId] ?? []);

  List<AcChatMessage> _getMessages(String conversationId) =>
      List.unmodifiable(_messages[conversationId] ?? []);

  void _markAsReadStandalone(String conversationId) {
    // Update local state immediately so the UI reflects zero unread.
    _conversationIndex[conversationId]?.unread = 0;
    final idx =
        _conversations.indexWhere((c) => c.conversationId == conversationId);
    if (idx >= 0) _conversations[idx].unread = 0;

    // Persist to Firestore in the background.
    markAsRead(conversationId, _currentUserId).catchError((Object e) {
      _log('markAsRead background error', e, StackTrace.current);
      return null;
    });
  }

  AcChatConversation _insertConversation(
    AcChatConversation newConv,
    String otherUserId,
  ) {
    // Assign an ID if the caller hasn't already.
    if (newConv.conversationId.isEmpty) {
      newConv.conversationId = _uuid.v4();
    }

    // Ensure the current user is in memberIds.
    if (!newConv.memberIds.contains(_currentUserId)) {
      newConv.memberIds.add(_currentUserId);
    }
    if (!newConv.memberIds.contains(otherUserId)) {
      newConv.memberIds.add(otherUserId);
    }

    // Optimistic local insert.
    _conversationIndex[newConv.conversationId] = newConv;
    _conversations.insert(0, newConv);
    _members[newConv.conversationId] = [
      AcChatConversationUser()
        ..conversationId = newConv.conversationId
        ..userId = _currentUserId,
      AcChatConversationUser()
        ..conversationId = newConv.conversationId
        ..userId = otherUserId,
    ];
    _messages[newConv.conversationId] = [];

    // Persist to Firestore in the background.
    createConversation(newConv, otherUserId).then((_) {
      _setupMessageListener(newConv.conversationId);
      _setupMemberListener(newConv.conversationId);
    }).catchError((Object e) {
      _log('insertConversation background error', e, StackTrace.current);
      return null;
    });

    _notifyDataChanged();
    return newConv;
  }

  /// Standalone send: optimistic write → Firestore → update status.
  Future<void> _sendMessageStandaloneAsync(AcChatMessage msg) async {
    if (msg.messageId.isEmpty) {
      msg.messageId = _uuid.v4();
    }
    msg.status = 'sending';

    // Optimistic local insert.
    _upsertMessage(msg.conversationId, msg);
    _notifyDataChanged();

    try {
      await _writeMessageToFirestore(msg);
      msg.status = 'sent';
    } catch (e, st) {
      _log('sendMessage error', e, st);
      msg.status = 'failed';
    }

    // Update local state with final status.
    _upsertMessage(msg.conversationId, msg);
    _notifyDataChanged();
  }

  /// Synchronous wrapper called by [AcChatApi.sendMessage].
  void _sendMessageStandalone(AcChatMessage msg) {
    _sendMessageStandaloneAsync(msg).catchError((Object e) {
      _log('sendMessage async error', e, StackTrace.current);
      return null;
    });
  }

  void _updateMessageStandalone(String messageId, Map<String, dynamic> data) {
    // Find the conversation that owns this message.
    final msg = _messageIndex[messageId];
    if (msg == null) return;

    updateMessage(messageId, msg.conversationId, data).catchError((Object e) {
      _log('updateMessage background error', e, StackTrace.current);
      return null;
    });
  }

  // ─── Firestore write helpers ───────────────────────────────────────────────

  /// Uploads media if present, writes the message document, and updates the
  /// conversation's last-message fields and unread counters.
  Future<void> _writeMessageToFirestore(AcChatMessage msg) async {
    // Upload media bytes to Storage first if present.
    if (msg.byteData != null &&
        (msg.type == 'image' ||
            msg.type == 'audio' ||
            msg.type == 'document')) {
      final fileName = msg.fileName ?? msg.messageId;
      final path =
          '${_config.storagePath}/${msg.conversationId}/${msg.messageId}/$fileName';
      final ref = _storage.ref().child(path);
      final task = await ref.putData(msg.byteData!);
      msg.text = await task.ref.getDownloadURL();
    }

    final convRef = _firestore
        .collection(_config.conversationsCollection)
        .doc(msg.conversationId);

    // Write message document.
    await convRef
        .collection(_config.messagesSubcollection)
        .doc(msg.messageId)
        .set(FirestoreExtensions.messageToFirestore(msg));

    // Update conversation's last-message metadata.
    await convRef.update({
      FirestoreExtensions.fLastMessage: msg.text,
      FirestoreExtensions.fLastMessageType: msg.type,
      FirestoreExtensions.fLastTime: Timestamp.fromDate(msg.time),
    });

    // Increment unread for all members except the sender.
    await _incrementUnreadForOtherMembers(
      conversationId: msg.conversationId,
      senderId: msg.senderId,
    );
  }

  /// Increments the `unread` counter for every conversation member except
  /// [senderId].
  Future<void> _incrementUnreadForOtherMembers({
    required String conversationId,
    required String senderId,
  }) async {
    final memberDocs = await _firestore
        .collection(_config.conversationsCollection)
        .doc(conversationId)
        .collection(_config.conversationUsersSubcollection)
        .get();

    final batch = _firestore.batch();
    for (final doc in memberDocs.docs) {
      if (doc.id != senderId) {
        batch.update(
          doc.reference,
          {FirestoreExtensions.fUnread: FieldValue.increment(1)},
        );
      }
    }
    await batch.commit();
  }

  /// Writes initial member documents for [userIds] under [conversationId].
  Future<void> _writeMemberDocs({
    required String conversationId,
    required List<String> userIds,
  }) async {
    final batch = _firestore.batch();
    final membersCol = _firestore
        .collection(_config.conversationsCollection)
        .doc(conversationId)
        .collection(_config.conversationUsersSubcollection);

    for (final uid in userIds) {
      batch.set(membersCol.doc(uid), {
        FirestoreExtensions.fUserId: uid,
        FirestoreExtensions.fConversationId: conversationId,
        FirestoreExtensions.fUnread: 0,
      });
    }
    await batch.commit();
  }

  // ─── Background helpers ────────────────────────────────────────────────────

  /// Fetches a single user document in the background and updates [_userIndex].
  void _fetchUserInBackground(String userId) {
    _firestore
        .collection(_config.usersCollection)
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final user = FirestoreExtensions.userFromDoc(doc);
        _userIndex[user.userId] = user;
        final existing = _users.indexWhere((u) => u.userId == userId);
        if (existing >= 0) {
          _users[existing] = user;
        } else {
          _users.add(user);
        }
        if (!_isChannelMode) {
          _notifyDataChanged();
        }
      }
    }).catchError((Object e) {
      _log('fetchUserInBackground error for $userId', e, StackTrace.current);
      return null;
    });
  }

  // ─── Utilities ─────────────────────────────────────────────────────────────

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
