import 'dart:io';
import 'package:test/test.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_sync/ac_sync.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:autocode/autocode.dart';
import './data_dictionary.dart' as DD;

void main() {
  group('Session-Based Synchronization Tests', () {
    late AcSyncDestinationDatabase destDb;
    late AcSyncSourceDatabase sourceDb;
    
    setUpAll(() async {
      AcDataDictionary.registerDataDictionary(dataDictionaryName: "default", jsonData: DD.DATA_DICTIONARY);
    });

    setUp(() async {
      // Copy pre-existing database/source/accountee.db containing application schema and tables
      final destFile = File('database/test_dest.db');
      if (destFile.existsSync()) destFile.deleteSync();
      File('database/source/accountee.db').copySync('database/test_dest.db');

      final sourceFile = File('database/test_source.db');
      if (sourceFile.existsSync()) sourceFile.deleteSync();
      File('database/source/accountee.db').copySync('database/test_source.db');

      AcSqliteDao destDao = AcSqliteDao();
      destDao.sqlConnection = AcSqlConnection(database: 'database/test_dest.db');
      destDb = AcSyncDestinationDatabase(dao: destDao, databaseType: AcEnumSqlDatabaseType.sqlite);
      
      AcSqliteDao sourceDao = AcSqliteDao();
      sourceDao.sqlConnection = AcSqlConnection(database: 'database/test_source.db');
      sourceDb = AcSyncSourceDatabase(dao: sourceDao, databaseType: AcEnumSqlDatabaseType.sqlite);

      await destDb.registerDefinitionFromDataDictionary(dataDictionaryName: 'default');
      await destDb.initialize(syncVersion: 2);

      await sourceDb.registerDefinitionFromDataDictionary(dataDictionaryName: 'default');
      await sourceDb.initialize(syncVersion: 2);
    });

    tearDown(() async {
      // Close connections
      if (destDb.dao is AcSqliteDao) {
        await (destDb.dao as AcSqliteDao).close();
      }
      if (sourceDb.dao is AcSqliteDao) {
        await (sourceDb.dao as AcSqliteDao).close();
      }
      
      final destFile = File('database/test_dest.db');
      if (destFile.existsSync()) destFile.deleteSync();

      final sourceFile = File('database/test_source.db');
      if (sourceFile.existsSync()) sourceFile.deleteSync();
    });

    test('Full Bidirectional Session-Based Sync', () async {
      // 1. Insert local changes in Source
      await sourceDb.dao!.executeStatement(
        statement: "INSERT INTO act_products (product_id, product_name) VALUES ('p1', 'Product 1');"
      );
      
      // 2. Setup bidirectional message routing helper
      Future<void> routeMessage(AcSyncDatabase sender, AcSyncDatabase receiver, AcSyncMessage message) async {
        var responses = await receiver.receiveMessage(message);
        for (var resp in responses) {
          await routeMessage(receiver, sender, resp);
        }
      }

      destDb.onSendMessage = (message) async {
        await routeMessage(destDb, sourceDb, message);
      };

      sourceDb.onSendMessage = (message) async {
        await routeMessage(sourceDb, destDb, message);
      };

      // 3. Initiate sync
      final syncResult = await destDb.sync();
      expect(syncResult.isSuccess(), isTrue);
      final String sessionId = syncResult.value;

      // 4. Verify session is complete and data applied
      var destSession = await destDb.loadSessionState(sessionId);
      print("DEST SESSION STATE: ${destSession?.toJson()}");
      var sourceSession = await sourceDb.loadSessionState(sessionId);
      print("SOURCE SESSION STATE: ${sourceSession?.toJson()}");
      
      expect(destSession, isNotNull);
      expect(destSession!.status, equals('COMPLETED'));

      var productsResult = await destDb.dao!.getRows(statement: "SELECT * FROM act_products WHERE product_id = 'p1';");
      expect(productsResult.rows, isNotEmpty);
      expect(productsResult.rows.first['product_name'], equals('Product 1'));
    });
  });
}
