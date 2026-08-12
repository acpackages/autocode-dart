import 'package:firebase_core/firebase_core.dart';

/// Configuration for the [AcSyncOnFirebase] adapter.
///
/// All fields except [groupId] have sensible defaults that match the
/// documented Firestore schema. Override only the fields that differ
/// from your project.
///
/// ### Multiple Firebase projects
///
/// Pass a named [FirebaseApp] to target a specific Firebase project:
///
/// ```dart
/// final secondary = await Firebase.initializeApp(
///   name: 'secondary',
///   options: const FirebaseOptions(...),
/// );
///
/// final config = AcSyncFirebaseConfig(
///   app: secondary,
///   groupId: 'my-group',
/// );
/// ```
///
/// When [app] is null the default `FirebaseFirestore.instance` is used.
class AcSyncFirebaseConfig {
  /// Optional [FirebaseApp]. When null, `FirebaseFirestore.instance` is used.
  ///
  /// Pass a named app to target a specific Firebase project in multi-instance
  /// setups (e.g. `Firebase.app('secondary')`).
  final FirebaseApp? app;

  /// Required. The sync group namespace in Firestore.
  ///
  /// All devices that share the same [groupId] can sync with each other.
  /// Acts as the top-level document key under [rootCollection].
  final String groupId;

  /// Top-level Firestore collection that contains group documents.
  ///
  /// Default: `'ac_sync'`
  final String rootCollection;

  /// Name of the subcollection that holds device registration documents
  /// inside each group document.
  ///
  /// Default: `'devices'`
  final String devicesCollection;

  /// Name of the subcollection inside each device document that holds
  /// inbound [AcSyncMessage] documents.
  ///
  /// Default: `'inbox'`
  final String inboxCollection;

  /// When `true`, every sent and received [AcSyncMessage] is logged via
  /// `dart:developer`. Useful for debugging. Default: `false`.
  final bool logMessages;

  /// Creates an [AcSyncFirebaseConfig] with optional overrides.
  const AcSyncFirebaseConfig({
    this.app,
    required this.groupId,
    this.rootCollection = 'ac_sync',
    this.devicesCollection = 'devices',
    this.inboxCollection = 'inbox',
    this.logMessages = false,
  });
}
