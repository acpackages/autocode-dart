import 'dart:io';
import 'package:ac_sync/src/core/ac_sync_destination_database.dart';
import 'package:ac_sync/src/core/ac_sync_source_database.dart';
import 'package:ac_sync/src/models/ac_notify_changes_callback_args.dart';
import 'package:ac_sync/src/models/ac_notify_changes_to_source_fun_args.dart';
import 'package:ac_sync/src/models/ac_notify_sync_success_to_source_fun_args.dart';
import 'package:test/test.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_sync/ac_sync.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sync/src/database/data_dictionary.dart' as sync_dd;
import 'package:autocode/autocode.dart';
import 'package:ac_mirrors/ac_mirrors.dart';
import './data_dictionary.dart' as DD;

late AcSyncDestinationDatabase syncDestinationDatabase;
late AcSyncSourceDatabase syncSourceDatabase;

Future<void> main() async {
  print("[Test002] Executing sync test 002...");

  print("[Test002] Registering data dictionary.");
  AcDataDictionary.registerDataDictionary(dataDictionaryName: "default",jsonData: DD.DATA_DICTIONARY);

  print("[Test002] Setting destination sync database");
  await setDestinationSyncDatabase();
  print("[Test002] Setting source sync database");
  await setSourceSyncDatabase();

  print("[Test002] Creating destination changes json file...");
  File destinationChanges = File("database/destination_changes.json");
  if(destinationChanges.existsSync()){
    destinationChanges.deleteSync();
  }
  destinationChanges.createSync(recursive: true);
  destinationChanges.writeAsStringSync((await syncDestinationDatabase.getSyncChanges(lastSyncId: 11)).value.toString());
  print("[Test002] Destination changes json file created.");
  print("[Test002] Creating source changes json file...");
  File sourceChanges = File("database/source_changes.json");
  if(sourceChanges.existsSync()){
    sourceChanges.deleteSync();
  }
  sourceChanges.createSync(recursive: true);
  sourceChanges.writeAsStringSync((await syncSourceDatabase.getSyncChanges(lastSyncId: 11)).value.toString());

  print("[Test002] Source changes json file created.");

  print("[Test002] Starting sync between destination and source...");
  
  await syncDestinationDatabase.sync();

  print("[Test002] Sync completed between destination and source.");
  
  print("[Test002] Executed sync test 002!");
}

Future<void> setDestinationSyncDatabase() async {
  AcSqliteDao destinationDao = AcSqliteDao();
  destinationDao.sqlConnection = AcSqlConnection(database: 'database/destination/accountee.db');
  syncDestinationDatabase = AcSyncDestinationDatabase(dao: destinationDao,databaseType: AcEnumSqlDatabaseType.sqlite);
  Future<void> Function(AcNotifyChangesToSourceFunArgs callbackArgs) notifyChangesCallback = (AcNotifyChangesToSourceFunArgs callbackArgs) async {
    print("[Test002] Tables with changes : ${callbackArgs.changes!.tableChanges.length}");
  AcResult result = await syncSourceDatabase.handleNotifyChangesFromDestination(destinationNotifyArgs: callbackArgs);
    if(result.isSuccess()){
      print("[Test002] Source processed destination changes successfully. Notifying callback...");
      callbackArgs.notifyCallback!(result.value);
    }
    else{
      print("[Test002] Source failed to process destination changes: ${result.message}");
    }
  };
  Future<void> Function(AcNotifySyncSuccessToSourceFunArgs callbackArgs) notifySuccessCallback = (AcNotifySyncSuccessToSourceFunArgs callbackArgs) async {
   print("[Test002] Destination notifying sync success to source...");
   AcResult result = await syncSourceDatabase.handleNotifySyncSuccessFromSource(destinationNotifyArgs: callbackArgs);
   if(result.isSuccess()){
     print("[Test002] Source processed sync success successfully. Notifying callback...");
     callbackArgs.notifyCallback!(result.value);
   }
   else{
     print("[Test002] Source failed to process sync success: ${result.message}");
   }
  };
  syncDestinationDatabase.notifyChangesToSourceFun = notifyChangesCallback;
  syncDestinationDatabase.notifySyncSuccessToSourceFun = notifySuccessCallback;
  print("[Test002] Registering sync definitions for destination...");
  await syncDestinationDatabase.registerDefinitionFromDataDictionary(dataDictionaryName: 'default');
  print("[Test002] Initializing destination database...");
  await syncDestinationDatabase.initialize(syncVersion: 1);
}

Future<void> setSourceSyncDatabase() async {
  AcSqliteDao sourceDao = AcSqliteDao();
  sourceDao.sqlConnection = AcSqlConnection(database: 'database/source/accountee.db');
  syncSourceDatabase = AcSyncSourceDatabase(dao: sourceDao,databaseType: AcEnumSqlDatabaseType.sqlite);
  await syncSourceDatabase.registerDefinitionFromDataDictionary(dataDictionaryName: 'default');
  print("[Test002] Initializing source database...");
  await syncSourceDatabase.initialize(syncVersion: 1);
}

