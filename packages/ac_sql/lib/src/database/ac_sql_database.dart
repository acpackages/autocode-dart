import 'package:autocode/autocode.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A static container for global database configuration.",
  "description": "This class holds shared, static properties for the default database connection, such as the data dictionary name to use, the SQL dialect, and the connection configuration object. It provides a central point of configuration for database operations throughout an application.",
  "example": "// During app initialization:\nAcSqlDatabase.databaseType = AcEnumSqlDatabaseType.mysql;\nAcSqlDatabase.dataDictionaryName = 'main_db';\nAcSqlDatabase.sqlConnection = AcSqlConnection(\n  hostname: 'localhost',\n  username: 'app_user',\n  password: 'password',\n  database: 'production_db'\n);"
}) */
class AcSqlDatabase {
  // Private constructor to prevent instantiation of this static class.
  AcSqlDatabase._();

  /* AcDoc({
    "summary": "The name of the default data dictionary to be used for schema operations."
  }) */
  static String dataDictionaryName = "default";

  /* AcDoc({
    "summary": "The type of SQL database, used to determine the correct SQL dialect.",
    "description": "This enum value (e.g., MySQL, SQLite) guides the generation of database-specific SQL statements."
  }) */
  static AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown;

  /* AcDoc({
    "summary": "The global connection configuration object.",
    "description": "Holds the details (hostname, port, credentials, etc.) for the primary database connection."
  }) */
  static AcSqlConnection? sqlConnection;
}