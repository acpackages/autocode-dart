/// Configuration for the SQLite database used by [AcChatSqlite].
///
/// All fields have sensible defaults. Override only what differs from your
/// project's requirements.
class AcChatSqliteConfig {
  /// Full filesystem path to the SQLite database file.
  ///
  /// **Must be an absolute path** — `ac_sql` uses the `sqlite3` package
  /// which requires a fully-qualified path rather than a simple file name.
  ///
  /// Example (Flutter):
  /// ```dart
  /// final dir = await getApplicationDocumentsDirectory();
  /// final config = AcChatSqliteConfig(
  ///   databasePath: '${dir.path}/ac_chat.db',
  /// );
  /// ```
  final String databasePath;

  /// The name registered in [AcDataDictionary] for the chat schema.
  ///
  /// Rarely needs to change unless you embed multiple chat databases in the
  /// same process.
  final String dataDictionaryName;

  /// Creates an [AcChatSqliteConfig] with optional overrides.
  const AcChatSqliteConfig({
    this.databasePath = 'ac_chat.db',
    this.dataDictionaryName = 'ac_chat',
  });
}
