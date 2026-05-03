import 'package:ac_sql/ac_sql.dart';
import 'package:ac_sync/src/database/sync_database_manager.dart';
import 'package:ac_sync/src/models/ac_sync_definition.dart';
import 'package:autocode/autocode.dart';

class AcSync {

  Map<String,AcSyncDefinition> _syncDefinitions = {};

  AcSync({AcBaseSqlDao? dao}){

  }

  Future<AcResult> _initSchemaManager({AcBaseSqlDao? dao}) async {
    AcResult result = AcResult();
    var databaseManager = AcSyncDatabaseManager();
    await databaseManager.initAcSyncDatabase(dao: dao);
    result.setSuccess();
    return result;
  }

  void registerSyncDefinition({required AcSyncDefinition definition}){
    _syncDefinitions[definition.definitionName] = definition;
  }
}