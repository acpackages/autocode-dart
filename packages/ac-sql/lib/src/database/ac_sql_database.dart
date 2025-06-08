import 'package:autocode/autocode.dart';
import 'package:ac_sql/ac_sql.dart';

class AcSqlDatabase {
  static String dataDictionaryName = "default";
  static String databaseType = AcEnumSqlDatabaseType.UNKNOWN;
  static AcSqlConnection? sqlConnection;
}
