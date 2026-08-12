import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ac_sync/ac_sync.dart';
import 'package:autocode/autocode.dart';

import 'config/ac_sync_firebase_config.dart';
import 'models/ac_firebase_sync_message.dart';

/// Firestore field name constants for device registration documents.
class _DeviceFields {
  static const String deviceId       = 'deviceId';
  static const String isSourceDevice = 'isSourceDevice';
  static const String platform       = 'platform';
  static const String lastSeenAt     = 'lastSeenAt';
  _DeviceFields._();
}

/// Firebase Firestore transport adapter for `ac_sync`.
///
/// [AcSyncOnFirebase] uses Cloud Firestore as a message bus to carry
/// [AcSyncMessage] objects between devices. It is a **pure channel** —
/// all sync logic (definitions, sessions, checkpoints, conflict handling)
/// is owned entirely by `ac_sync`. This adapter adds no business logic.
///
/// ## Hub-spoke topology
///
/// One device acts as the permanent **source** (`syncSourceDatabase`).
/// All other devices are **destinations** (`syncDestinationDatabase`).
/// Any device may create or modify records; direction control is governed
/// by the [AcSyncDefinition] registered with `ac_sync`.
///
/// ## Source device
///
/// ```dart
/// final adapter = AcSyncOnFirebase(
///   config: AcSyncFirebaseConfig(groupId: 'my-group'),
///   syncSourceDatabase: sourceDb,
/// );
/// // Listens to its inbox and responds to sessions automatically.
/// ```
///
/// ## Destination device
///
/// ```dart
/// final adapter = AcSyncOnFirebase(
///   config: AcSyncFirebaseConfig(groupId: 'my-group'),
///   syncDestinationDatabase: destDb,
/// );
///
/// await adapter.sync();           // source discovered automatically
/// await adapter.sync(syncId: id); // resume an existing session
/// adapter.dispose();
/// ```
///
/// ## Multiple Firebase projects
///
/// Pass a named [FirebaseApp] via [AcSyncFirebaseConfig.app] to target a
/// specific Firebase project. Each adapter instance is fully isolated.
///
/// ## Prerequisites
///
/// Call `initialize()` on the [AcSyncSourceDatabase] or
/// [AcSyncDestinationDatabase] **before** constructing this adapter so
/// that `deviceId` is populated.
class AcSyncOnFirebase {
  // ─── Constructor ──────────────────────────────────────────────────────────

  /// Creates an [AcSyncOnFirebase] adapter and starts the Firestore inbox
  /// listener immediately.
  ///
  /// At least one of [syncSourceDatabase] or [syncDestinationDatabase] must
  /// be provided. Both databases must have `initialize()` called before this
  /// constructor is invoked.
  AcSyncOnFirebase({
    required this.config,
    this.syncSourceDatabase,
    this.syncDestinationDatabase,
  }) {
    assert(
      syncSourceDatabase != null || syncDestinationDatabase != null,
      '[AcSyncOnFirebase] At least one of syncSourceDatabase or '
      'syncDestinationDatabase must be provided.',
    );
    _firestore = config.app != null
        ? FirebaseFirestore.instanceFor(app: config.app!)
        : FirebaseFirestore.instance;
    _init();
  }

  // ─── Public fields ────────────────────────────────────────────────────────

  /// Configuration: groupId, collection names, FirebaseApp.
  final AcSyncFirebaseConfig config;

  /// The source database. Provide this on the device that acts as the
  /// permanent source of truth.
  final AcSyncSourceDatabase? syncSourceDatabase;

  /// The destination database. Provide this on devices that sync from
  /// the source.
  final AcSyncDestinationDatabase? syncDestinationDatabase;

  // ─── Private fields ────────────────────────────────────────────────────────

  late final FirebaseFirestore _firestore;

  /// Inbox listener subscription — cancelled in [dispose].
  StreamSubscription<QuerySnapshot>? _subscription;

  /// Maps sessionIdentifier → senderDeviceId.
  ///
  /// Populated on the **source** side when an [InitializeSession] message
  /// arrives. Used to route response messages back to the correct device
  /// inbox without requiring a second Firestore lookup.
  final Map<String, String> _sessionToSender = {};

  // ─── Firestore references ─────────────────────────────────────────────────

  /// The device ID of this device, taken from whichever database was
  /// provided. Requires `initialize()` to have been called first.
  String get _localDeviceId {
    final id = syncSourceDatabase?.deviceId ?? syncDestinationDatabase?.deviceId;
    assert(
      id != null && id.isNotEmpty,
      '[AcSyncOnFirebase] deviceId is null or empty. '
      'Call initialize() on the AcSyncDatabase before constructing AcSyncOnFirebase.',
    );
    return id!;
  }

  /// Reference to the `devices` subcollection under the group document.
  CollectionReference get _devicesRef => _firestore
      .collection(config.rootCollection)
      .doc(config.groupId)
      .collection(config.devicesCollection);

  /// Reference to this device's registration document.
  DocumentReference get _myDeviceRef => _devicesRef.doc(_localDeviceId);

  /// Reference to this device's inbox subcollection.
  CollectionReference get _myInboxRef =>
      _myDeviceRef.collection(config.inboxCollection);

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Initiates a sync session from this device to the source device.
  ///
  /// [syncId] resumes an existing session. When null a new session UUID is
  /// generated by `ac_sync`.
  ///
  /// [targetDeviceId] skips source discovery. When null the source device
  /// is discovered automatically by querying the `devices` collection for a
  /// document with `isSourceDevice == true`.
  ///
  /// Returns an [AcResult] that reflects the outcome of the
  /// `AcSyncDestinationDatabase.sync()` call.
  ///
  /// Only valid when [syncDestinationDatabase] is set.
  Future<AcResult> sync({String? syncId, String? targetDeviceId}) async {
    assert(
      syncDestinationDatabase != null,
      '[AcSyncOnFirebase] sync() requires syncDestinationDatabase.',
    );

    // Resolve the source device ID
    final sourceId = targetDeviceId ?? await _discoverSourceDeviceId();
    if (sourceId == null || sourceId.isEmpty) {
      final result = AcResult();
      result.setFailure(
        message: '[AcSyncOnFirebase] No source device found in group '
            '"${config.groupId}". Make sure a device with isSourceDevice = true '
            'is registered in Firestore.',
      );
      return result;
    }

    // Ensure the source is registered in _ac_sync_devices with is_source_of_truth = 1
    await _ensureSourceRegistered(sourceId);

    // Wire the send hook: destination → source's inbox
    syncDestinationDatabase!.onSendMessage = (AcSyncMessage message) async {
      _logMessage('Destination → Source', message);
      await _sendToInbox(recipientDeviceId: sourceId, msg: message);
    };

    // Delegate entirely to ac_sync — all session logic is handled there
    return syncDestinationDatabase!.sync(syncId: syncId);
  }

  /// Returns the Firestore [deviceId]s of all other devices registered in
  /// this group, excluding this device.
  Future<List<String>> discoverPeers() async {
    try {
      final snapshot = await _devicesRef.get();
      return snapshot.docs
          .map((doc) => doc.id)
          .where((id) => id != _localDeviceId)
          .toList();
    } catch (e, st) {
      _log('discoverPeers error: $e', error: e, stackTrace: st);
      return [];
    }
  }

  /// Cancels the Firestore inbox listener and releases all resources.
  ///
  /// Call this when the adapter is no longer needed (e.g., in `dispose()`
  /// of a Flutter widget or a service).
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  void _init() {
    // Wire onSendMessage for the source database (known immediately)
    if (syncSourceDatabase != null) {
      syncSourceDatabase!.onSendMessage = (AcSyncMessage message) async {
        final sender = _sessionToSender[message.sessionIdentifier];
        if (sender != null) {
          _logMessage('Source → Device[$sender]', message);
          await _sendToInbox(recipientDeviceId: sender, msg: message);
        } else {
          _log('Source has no sender recorded for session '
              '${message.sessionIdentifier}. Message dropped.');
        }
      };
    }

    // Register this device in Firestore (fire-and-forget; non-critical)
    _registerDevice().catchError((Object e, StackTrace st) {
      _log('Device registration error: $e', error: e, stackTrace: st);
    });

    // Start listening to this device's inbox
    _startInboxListener();
  }

  /// Writes or updates this device's registration document in Firestore.
  Future<void> _registerDevice() async {
    await _myDeviceRef.set(
      {
        _DeviceFields.deviceId: _localDeviceId,
        _DeviceFields.isSourceDevice:
            syncSourceDatabase != null && syncDestinationDatabase == null,
        _DeviceFields.platform: _platformString(),
        _DeviceFields.lastSeenAt: FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Attaches a Firestore snapshot listener to this device's inbox
  /// collection, ordered by [AcFirebaseSyncMessageFields.timestamp].
  void _startInboxListener() {
    _subscription = _myInboxRef
        .orderBy(AcFirebaseSyncMessageFields.timestamp)
        .snapshots()
        .listen(
      (snapshot) async {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            await _handleIncomingDocument(change.doc);
          }
        }
      },
      onError: (Object e, StackTrace st) {
        _log('Inbox listener error: $e', error: e, stackTrace: st);
      },
    );
  }

  // ─── Message handling ─────────────────────────────────────────────────────

  /// Processes a single inbox document:
  /// 1. Parses the [AcFirebaseSyncMessage].
  /// 2. Records session → sender routing (source side only).
  /// 3. **Deletes** the Firestore document immediately.
  /// 4. Delivers the [AcSyncMessage] to `ac_sync` via `receiveMessage()`.
  /// 5. Forwards every response via `sendMessage()`.
  Future<void> _handleIncomingDocument(
    DocumentSnapshot doc,
  ) async {
    try {
      final fbMsg = AcFirebaseSyncMessage.fromFirestore(doc);
      final syncMsg = fbMsg.toSyncMessage();

      _logMessage('Received [${fbMsg.senderDeviceId}]', syncMsg);

      // Track sessionId → senderDeviceId so the source knows where to reply
      if (syncMsg.messageType == 'InitializeSession' &&
          syncSourceDatabase != null) {
        _sessionToSender[syncMsg.sessionIdentifier] = fbMsg.senderDeviceId;
      }

      // Delete from Firestore before processing.
      // If the app crashes here, ac_sync session state in _ac_sync_sessions
      // allows the session to be resumed on the next sync() call.
      await doc.reference.delete();

      // Route to the correct database instance and let ac_sync handle it
      final db = _routeMessage(syncMsg);
      if (db == null) {
        _log('No database to handle message type ${syncMsg.messageType}');
        return;
      }

      final responses = await db.receiveMessage(syncMsg);
      for (final response in responses) {
        await db.sendMessage(response);
      }
    } catch (e, st) {
      // Do not rethrow — the listener must stay alive for future messages
      _log('Error handling inbox document: $e', error: e, stackTrace: st);
    }
  }

  /// Routes an incoming message to the correct [AcSyncDatabase] instance.
  ///
  /// - `InitializeSession` always goes to the source (only source handles it).
  /// - `SessionAccepted` always goes to the destination (only destination handles it).
  /// - Everything else goes to source if the session is tracked there,
  ///   otherwise to the destination.
  AcSyncDatabase? _routeMessage(AcSyncMessage msg) {
    switch (msg.messageType) {
      case 'InitializeSession':
        return syncSourceDatabase;
      case 'SessionAccepted':
        return syncDestinationDatabase;
      default:
        if (_sessionToSender.containsKey(msg.sessionIdentifier)) {
          return syncSourceDatabase;
        }
        return syncDestinationDatabase ?? syncSourceDatabase;
    }
  }

  // ─── Firestore helpers ────────────────────────────────────────────────────

  /// Writes [msg] to [recipientDeviceId]'s Firestore inbox.
  Future<void> _sendToInbox({
    required String recipientDeviceId,
    required AcSyncMessage msg,
  }) async {
    final fbMsg = AcFirebaseSyncMessage.fromSyncMessage(
      msg,
      senderDeviceId: _localDeviceId,
    );
    await _devicesRef
        .doc(recipientDeviceId)
        .collection(config.inboxCollection)
        .add(fbMsg.toFirestore());
  }

  /// Discovers the source device by querying for a device document with
  /// `isSourceDevice == true` in this group.
  ///
  /// Returns the first matching [deviceId], or `null` if none is found.
  Future<String?> _discoverSourceDeviceId() async {
    try {
      final snapshot = await _devicesRef
          .where(_DeviceFields.isSourceDevice, isEqualTo: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
    } catch (e, st) {
      _log('Source discovery error: $e', error: e, stackTrace: st);
    }
    return null;
  }

  /// Ensures the source device is registered in the destination's local
  /// `_ac_sync_devices` SQLite table with `is_source_of_truth = 1`.
  ///
  /// `AcSyncDestinationDatabase.sync()` reads this row to initialise the
  /// incoming checkpoint. If the row is absent the sync cannot start.
  ///
  /// This method is idempotent — calling it multiple times is safe.
  Future<void> _ensureSourceRegistered(String sourceDeviceId) async {
    final dao = syncDestinationDatabase?.dao;
    if (dao == null) return;

    // Check for an existing row
    final existing = await dao.getRows(
      statement:
          'SELECT sync_device_id FROM _ac_sync_devices WHERE sync_device_id = @id',
      parameters: {'@id': sourceDeviceId},
    );

    if (existing.isSuccess() && existing.rows.isNotEmpty) return;

    // Insert the source device as source of truth
    await dao.insertRow(
      tableName: '_ac_sync_devices',
      row: {
        'sync_device_id'         : sourceDeviceId,
        'is_source_of_truth'     : 1,
        'last_sync_change_log_id': 0,
        'last_synced_on'         : null,
      },
    );

    // Insert this device as a non-source entry if not already present
    final selfId = _localDeviceId;
    final selfCheck = await dao.getRows(
      statement:
          'SELECT sync_device_id FROM _ac_sync_devices WHERE sync_device_id = @id',
      parameters: {'@id': selfId},
    );
    if (!selfCheck.isSuccess() || selfCheck.rows.isEmpty) {
      await dao.insertRow(
        tableName: '_ac_sync_devices',
        row: {
          'sync_device_id'         : selfId,
          'is_source_of_truth'     : 0,
          'last_sync_change_log_id': 0,
          'last_synced_on'         : null,
        },
      );
    }
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  /// Returns a platform identifier string for device registration.
  String _platformString() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS)     return 'ios';
      if (Platform.isWindows) return 'windows';
      if (Platform.isMacOS)   return 'macos';
      if (Platform.isLinux)   return 'linux';
      if (Platform.isFuchsia) return 'fuchsia';
    } catch (_) {}
    return 'unknown';
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      '[AcSyncOnFirebase] $message',
      name: 'ac_sync_on_firebase',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _logMessage(String direction, AcSyncMessage msg) {
    if (!config.logMessages) return;
    _log('$direction  ${msg.messageType}  session=${msg.sessionIdentifier}');
  }
}
