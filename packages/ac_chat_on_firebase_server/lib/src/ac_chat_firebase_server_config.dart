/// Configuration for [AcChatFirebaseServer].
class AcChatFirebaseServerConfig {
  /// Firestore collection that holds per-user mailbox documents.
  /// Default: `users`
  final String usersCollection;

  /// Subcollection inside each user document that holds incoming update docs.
  /// Default: `updates`
  final String updatesSubcollection;

  const AcChatFirebaseServerConfig({
    this.usersCollection = 'users',
    this.updatesSubcollection = 'updates',
  });
}