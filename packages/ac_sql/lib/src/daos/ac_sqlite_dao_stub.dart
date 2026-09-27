import 'package:autocode/autocode.dart';
import 'ac_base_sql_dao.dart';

/// Web stub for [AcSqliteDao] where native sqlite3 / dart:ffi is unavailable.
class AcSqliteDao extends AcBaseSqlDao {
  static bool autoCloseAfterExecution = false;

  @override
  AcEnumSqlDatabaseType get databaseType => AcEnumSqlDatabaseType.sqlite;

  @override
  String get uuidExpression =>
      "lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))";

  @override
  String get disableForeignKeyChecksSql => 'PRAGMA foreign_keys = OFF;';

  @override
  String get enableForeignKeyChecksSql => 'PRAGMA foreign_keys = ON;';

  Future<void> close() async {}
}
