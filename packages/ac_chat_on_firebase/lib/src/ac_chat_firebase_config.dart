/// Configuration for the Firestore collection and subcollection names used
/// by [AcChatFirebase], as well as Storage path and pagination settings.
///
/// All fields have sensible defaults that match the schema documented in the
/// package README. Override only the fields that differ from your project.
class AcChatFirebaseConfig {
  /// Top-level Firestore collection that stores user documents.
  final String usersCollection;

  /// Top-level Firestore collection that stores conversation documents.
  final String conversationsCollection;

  /// Name of the subcollection inside each conversation document that holds
  /// message documents.
  final String messagesSubcollection;

  /// Name of the subcollection inside each conversation document that holds
  /// member/participant documents.
  final String conversationUsersSubcollection;

  /// Root path inside Firebase Storage where chat media files are uploaded.
  /// Files are stored under `{storagePath}/{conversationId}/{messageId}/{fileName}`.
  final String storagePath;

  /// Number of messages fetched per conversation on the initial load and
  /// subsequent real-time listener snapshots.
  final int messagesPageSize;

  /// Creates an [AcChatFirebaseConfig] with optional overrides.
  const AcChatFirebaseConfig({
    this.usersCollection = 'users',
    this.conversationsCollection = 'conversations',
    this.messagesSubcollection = 'messages',
    this.conversationUsersSubcollection = 'members',
    this.storagePath = 'chat',
    this.messagesPageSize = 50,
  });
}
