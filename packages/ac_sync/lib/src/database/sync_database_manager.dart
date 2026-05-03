import 'package:ac_sql/ac_sql.dart';

class AcSyncDatabaseManager {
  static const String dataDictionaryName = "_ac_sync";

  initAcSyncDatabase({AcBaseSqlDao? dao}){
    AcSqlDbSchemaManager schemaManager = AcSqlDbSchemaManager(dao: dao,dataDictionaryName: dataDictionaryName);
    schemaManager.initDatabase();
  }
}