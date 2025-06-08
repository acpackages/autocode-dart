import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

class AcSqlDbBase {
  late AcDataDictionary acDataDictionary;
  AcBaseSqlDao? dao;
  String databaseType = AcEnumSqlDatabaseType.UNKNOWN;
  String dataDictionaryName = "default";
  late AcEvents events;
  late AcLogger logger;
  AcSqlConnection? sqlConnection;

  AcSqlDbBase({String dataDictionaryName = "default"}) {
    databaseType = AcSqlDatabase.databaseType;
    sqlConnection = AcSqlDatabase.sqlConnection;
    useDataDictionary(dataDictionaryName: dataDictionaryName);
    logger = AcLogger(logType: AcEnumLogType.PRINT, logMessages: true);
    if (databaseType == AcEnumSqlDatabaseType.MYSQL) {
      dao = AcMysqlDao();
      dao?.setSqlConnection(sqlConnection: sqlConnection!);
    }
  }

  void useDataDictionary({String dataDictionaryName = "default"}) {
    this.dataDictionaryName = dataDictionaryName;
    acDataDictionary = AcDataDictionary.getInstance(
      dataDictionaryName: dataDictionaryName,
    );
  }
}
