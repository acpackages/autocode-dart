/// Server-side Firebase adapter for ac_chat.
///
/// Uses the Firestore REST API (no Flutter SDK) to implement [AcChatSyncChannel].
/// Suitable for use in accountea-pro-cloud and other pure-Dart servers.
///
/// Usage:
/// ```dart
/// import 'package:ac_chat_on_firebase_server/ac_chat_on_firebase_server.dart';
///
/// final firestore = FirestoreRestClient(
///   projectId: 'my-firebase-project',
///   serviceAccountJson: jsonDecode(File('service_account.json').readAsStringSync()),
/// );
///
/// final chat = AcChatFirebaseServer(
///   firestore: firestore,
///   currentUserId: 'server-bot',
/// );
///
/// await chat.sendMessage(
///   message: myMessage,
///   recipientIds: ['user-123'],
/// );
/// ```
library;

export 'src/ac_chat_firebase_server.dart';
export 'src/ac_chat_firebase_server_config.dart';
export 'src/firestore_rest_client.dart';
export 'src/firestore_value_converter.dart';