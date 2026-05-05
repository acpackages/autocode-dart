import 'dart:io';
import 'package:test/test.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_sync/ac_sync.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sync/src/database/data_dictionary.dart' as sync_dd;
import 'package:autocode/autocode.dart';
import 'package:ac_mirrors/ac_mirrors.dart';
import './data_dictionary.dart' as DD;

Future<void> main() async {
  print("Executing sync test 001...");
  AcSqliteDao dao = AcSqliteDao();
  AcDataDictionary.registerDataDictionary(dataDictionaryName: "default",jsonData: DD.DATA_DICTIONARY);
  dao.sqlConnection = AcSqlConnection(database: 'accountee.db');
  AcSyncDatabase syncDatabase = AcSyncDatabase(dao: dao,databaseType: AcEnumSqlDatabaseType.sqlite);
  await syncDatabase.registerDefinitionFromDataDictionary(dataDictionaryName: 'default',
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
  await syncDatabase.initialize();

  // Create Destination Database Test Start
  // await syncDatabase.createDatabaseFileForDestination(destinationPath: '_accountee_dest.db');
  // Create Destination Database Test End

  // print("File exists : ${File('accountee.db').existsSync()}");
  print("Executed sync test 001!");
}
