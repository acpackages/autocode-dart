import 'package:ac_chat/ac_chat.dart';

/// Configuration for the SQLite database used by [AcChatSqlite].
///
/// All fields have sensible defaults. Override only what differs from your
/// project's requirements.
class AcChatSqliteConfig {
  /// Full filesystem path to the SQLite database file.
  ///
  /// **Must be an absolute path** — `ac_sql` uses the `sqlite3` package
  /// which requires a fully-qualified path rather than a simple file name.
  final String databasePath;

  /// The name registered in [AcDataDictionary] for the chat schema.
  final String dataDictionaryName;

  /// Root directory for storing chat media files (e.g. `media`).
  final String? dataDirectory;

  /// Centralized chat configuration flags and limits.
  final AcChatConfig chatConfig;

  /// Creates an [AcChatSqliteConfig] with optional overrides.
  const AcChatSqliteConfig({
    this.databasePath = 'ac_chat.db',
    this.dataDictionaryName = 'ac_chat',
    this.dataDirectory,
    this.chatConfig = const AcChatConfig(),
  });

  /// Creates an [AcChatSqliteConfig] rooted inside [chatDataDirectory].
  factory AcChatSqliteConfig.fromDataDirectory({
    required String chatDataDirectory,
    String dataDictionaryName = 'ac_chat',
    AcChatConfig? chatConfig,
  }) {
    final cleanBase = chatDataDirectory.replaceAll(RegExp(r'[/\\]+$'), '');
    return AcChatSqliteConfig(
      databasePath: '$cleanBase/databases/chat.db',
      dataDictionaryName: dataDictionaryName,
      dataDirectory: '$cleanBase/media',
      chatConfig: chatConfig ?? const AcChatConfig(),
    );
  }
}
