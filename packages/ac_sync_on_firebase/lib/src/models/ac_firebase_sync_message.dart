import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ac_sync/ac_sync.dart';

/// Firestore field name constants for inbox documents.
///
/// All Firestore field names are defined here as `static const` strings
/// to prevent typos and provide a single source of truth.
///
/// ```dart
/// data[AcFirebaseSyncMessageFields.messageType]
/// ```
class AcFirebaseSyncMessageFields {
  /// Field: the [AcSyncMessage.messageType] string.
  static const String messageType = 'messageType';

  /// Field: the [AcSyncMessage.sessionIdentifier] UUID.
  static const String sessionIdentifier = 'sessionIdentifier';

  /// Field: the [AcSyncMessage.stream] direction (`incoming` / `outgoing`).
  static const String stream = 'stream';

  /// Field: the [AcSyncMessage.payload] map.
  static const String payload = 'payload';

  /// Field: the [AcSyncMessage.metadata] map.
  static const String metadata = 'metadata';

  /// Field: the [AcSyncMessage.protocolVersion] string.
  static const String protocolVersion = 'protocolVersion';

  /// Field: the device ID of the sending device. Used for reply routing.
  static const String senderDeviceId = 'senderDeviceId';

  /// Field: server-side timestamp used for ordering inbox documents.
  ///
  /// Always written as `FieldValue.serverTimestamp()` — never a local
  /// `DateTime` — so ordering is consistent even with clock skew between
  /// devices.
  static const String timestamp = 'timestamp';

  // prevent instantiation — static helpers only
  AcFirebaseSyncMessageFields._();
}

/// Firestore ↔ [AcSyncMessage] conversion helper for `ac_sync_on_firebase`.
///
/// Wraps an [AcSyncMessage] with the additional [senderDeviceId] field
/// needed for peer-to-peer reply routing over Firestore inboxes.
///
/// ### Sending a message
/// ```dart
/// final fbMsg = AcFirebaseSyncMessage.fromSyncMessage(msg, senderDeviceId: myId);
/// await inboxRef.add(fbMsg.toFirestore());
/// ```
///
/// ### Receiving a message
/// ```dart
/// final fbMsg = AcFirebaseSyncMessage.fromFirestore(doc);
/// final syncMsg = fbMsg.toSyncMessage();
/// ```
class AcFirebaseSyncMessage {
  /// The [AcSyncMessage.messageType] value.
  final String messageType;

  /// The [AcSyncMessage.sessionIdentifier] value.
  final String sessionIdentifier;

  /// The [AcSyncMessage.stream] value.
  final String stream;

  /// The [AcSyncMessage.payload] value.
  final Map<String, dynamic> payload;

  /// The [AcSyncMessage.metadata] value.
  final Map<String, dynamic> metadata;

  /// The [AcSyncMessage.protocolVersion] value.
  final String protocolVersion;

  /// The device ID of the device that sent this message.
  ///
  /// Used by the recipient to route response messages back to the correct
  /// inbox without requiring a separate session lookup.
  final String senderDeviceId;

  const AcFirebaseSyncMessage({
    required this.messageType,
    required this.sessionIdentifier,
    required this.stream,
    required this.payload,
    required this.metadata,
    required this.protocolVersion,
    required this.senderDeviceId,
  });

  /// Creates an [AcFirebaseSyncMessage] from an [AcSyncMessage], adding
  /// the [senderDeviceId] for Firestore routing.
  factory AcFirebaseSyncMessage.fromSyncMessage(
    AcSyncMessage msg, {
    required String senderDeviceId,
  }) {
    return AcFirebaseSyncMessage(
      messageType: msg.messageType,
      sessionIdentifier: msg.sessionIdentifier,
      stream: msg.stream,
      payload: Map<String, dynamic>.from(msg.payload),
      metadata: Map<String, dynamic>.from(msg.metadata),
      protocolVersion: msg.protocolVersion,
      senderDeviceId: senderDeviceId,
    );
  }

  /// Parses an [AcFirebaseSyncMessage] from a Firestore [DocumentSnapshot].
  factory AcFirebaseSyncMessage.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return AcFirebaseSyncMessage(
      messageType:
          (data[AcFirebaseSyncMessageFields.messageType] as String?) ?? '',
      sessionIdentifier:
          (data[AcFirebaseSyncMessageFields.sessionIdentifier] as String?) ??
              '',
      stream: (data[AcFirebaseSyncMessageFields.stream] as String?) ?? '',
      payload: Map<String, dynamic>.from(
        (data[AcFirebaseSyncMessageFields.payload] as Map?) ?? {},
      ),
      metadata: Map<String, dynamic>.from(
        (data[AcFirebaseSyncMessageFields.metadata] as Map?) ?? {},
      ),
      protocolVersion:
          (data[AcFirebaseSyncMessageFields.protocolVersion] as String?) ??
              '1.0',
      senderDeviceId:
          (data[AcFirebaseSyncMessageFields.senderDeviceId] as String?) ?? '',
    );
  }

  /// Converts back to an [AcSyncMessage] for delivery to `ac_sync`.
  ///
  /// The [senderDeviceId] field is intentionally excluded — it is only
  /// meaningful as a Firestore routing annotation.
  AcSyncMessage toSyncMessage() {
    return AcSyncMessage(
      messageType: messageType,
      sessionIdentifier: sessionIdentifier,
      stream: stream,
      payload: payload,
      metadata: metadata,
      protocolVersion: protocolVersion,
    );
  }

  /// Serializes to a Firestore-compatible map.
  ///
  /// The [AcFirebaseSyncMessageFields.timestamp] field is always written as
  /// `FieldValue.serverTimestamp()` to guarantee consistent ordering even
  /// across devices with different local clocks.
  Map<String, dynamic> toFirestore() {
    return {
      AcFirebaseSyncMessageFields.messageType: messageType,
      AcFirebaseSyncMessageFields.sessionIdentifier: sessionIdentifier,
      AcFirebaseSyncMessageFields.stream: stream,
      AcFirebaseSyncMessageFields.payload: payload,
      AcFirebaseSyncMessageFields.metadata: metadata,
      AcFirebaseSyncMessageFields.protocolVersion: protocolVersion,
      AcFirebaseSyncMessageFields.senderDeviceId: senderDeviceId,
      AcFirebaseSyncMessageFields.timestamp: FieldValue.serverTimestamp(),
    };
  }
}
