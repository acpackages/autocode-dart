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
  print("Executing sync test 002...");

  AcDataDictionary.registerDataDictionary(dataDictionaryName: "default",jsonData: DD.DATA_DICTIONARY);

  await setDestinationSyncDatabase();
  await setSourceSyncDatabase();

  print("Test: Starting sync between destination and source...");
  await syncDestinationDatabase.sync();

  print("Executed sync test 002!");
}

Future<void> setDestinationSyncDatabase() async {
  AcSqliteDao destinationDao = AcSqliteDao();
  destinationDao.sqlConnection = AcSqlConnection(database: 'destination.db');
  syncDestinationDatabase = AcSyncDestinationDatabase(dao: destinationDao,databaseType: AcEnumSqlDatabaseType.sqlite);
  Future<void> Function(AcNotifyChangesToSourceFunArgs callbackArgs) notifyChangesCallback = (AcNotifyChangesToSourceFunArgs callbackArgs) async {
  AcResult result = await syncSourceDatabase.handleNotifyChangesFromDestination(destinationNotifyArgs: callbackArgs);
    if(result.isSuccess()){
      print("Test: Source processed destination changes successfully. Notifying callback...");
      callbackArgs.notifyCallback!(result.value);
    }
    else{
      print("Test: Source failed to process destination changes: ${result.message}");
    }
  };
  Future<void> Function(AcNotifySyncSuccessToSourceFunArgs callbackArgs) notifySuccessCallback = (AcNotifySyncSuccessToSourceFunArgs callbackArgs) async {
   print("Test: Destination notifying sync success to source...");
   AcResult result = await syncSourceDatabase.handleNotifySyncSuccessFromSource(destinationNotifyArgs: callbackArgs);
   if(result.isSuccess()){
     print("Test: Source processed sync success successfully. Notifying callback...");
     callbackArgs.notifyCallback!(result.value);
   }
   else{
     print("Test: Source failed to process sync success: ${result.message}");
   }
  };
  syncDestinationDatabase.notifyChangesToSourceFun = notifyChangesCallback;
  syncDestinationDatabase.notifySyncSuccessToSourceFun = notifySuccessCallback;
  print("Test: Registering sync definitions for destination...");
  await syncDestinationDatabase.registerDefinitionFromDataDictionary(dataDictionaryName: 'default',
      syncToDestinationTables: [
        DD.Tables.actProducts,
        DD.Tables.actProductUoms,
        DD.Tables.actProductBarcodes,
        DD.Tables.actProductSaleDetails,
        DD.Tables.actProductPrices,
      ],syncToSourceTables:[
        DD.Tables.actSaleInvoices,
        DD.Tables.actSaleInvoiceProducts,
        DD.Tables.actSaleInvoicePayments,
      ]
  );
  print("Test: Initializing destination database...");
  await syncDestinationDatabase.initialize();
}

Future<void> setSourceSyncDatabase() async {
  AcSqliteDao sourceDao = AcSqliteDao();
  sourceDao.sqlConnection = AcSqlConnection(database: 'source.db');
  syncSourceDatabase = AcSyncSourceDatabase(dao: sourceDao,databaseType: AcEnumSqlDatabaseType.sqlite);
  await syncSourceDatabase.registerDefinitionFromDataDictionary(dataDictionaryName: 'default',
      syncToDestinationTables: [
        DD.Tables.actProducts,
        DD.Tables.actProductUoms,
        DD.Tables.actProductBarcodes,
        DD.Tables.actProductSaleDetails,
        DD.Tables.actProductPrices,
      ],syncToSourceTables:[
        DD.Tables.actSaleInvoices,
        DD.Tables.actSaleInvoiceProducts,
        DD.Tables.actSaleInvoicePayments,
      ]
  );
  print("Test: Initializing source database...");
  await syncSourceDatabase.initialize();
}

