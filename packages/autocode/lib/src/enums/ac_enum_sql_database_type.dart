import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration representing various SQL database types supported by the system.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumSqlDatabaseType {
  /* AcDoc({"description": "MariaDB SQL database type."}) */
  mariadb('MARIADB'),

  /* AcDoc({"description": "Microsoft SQL Server database type."}) */
  mssql('MSSQL'),

  /* AcDoc({"description": "MySQL SQL database type."}) */
  mysql('MYSQL'),

  /* AcDoc({"description": "Oracle SQL database type."}) */
  oracle('ORACLE'),

  /* AcDoc({"description": "PostgreSQL SQL database type."}) */
  postgreSql('POSTGRE_SQL'),

  /* AcDoc({"description": "SQLite SQL database type."}) */
  sqlite('SQLITE'),

  /* AcDoc({"description": "Unknown or unsupported SQL database type."}) */
  unknown('UNKNOWN');

  /* AcDoc({"description": "The string representation of the SQL database type."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string value to the enum variant."}) */
  const AcEnumSqlDatabaseType(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumSqlDatabaseType? fromValue(String value) {
    try {
      return AcEnumSqlDatabaseType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if this enum's value matches the provided string.",
    "params": [{"name": "other", "description": "The string to compare with."}],
    "returns": "true if the string matches, otherwise false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the SQL database type as a string."}) */
  @override
  String toString() => value;
}
