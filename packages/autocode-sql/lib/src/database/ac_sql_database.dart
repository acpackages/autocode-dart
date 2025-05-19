import 'package:autocode/autocode.dart';
import 'package:autocode_sql/autocode_sql.dart';

class AcSqlDatabase {
  static String dataDictionaryName = "default";
  static String databaseType = AcEnumSqlDatabaseType.UNKNOWN;
  static AcSqlConnection? sqlConnection;
}