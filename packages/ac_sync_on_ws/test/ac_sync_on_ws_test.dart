import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_sync/ac_sync.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_web_socket/ac_web_socket.dart';
import 'package:ac_sync_on_ws/ac_sync_on_ws.dart';
import 'package:autocode/autocode.dart';
import '../../ac_sync/test/data_dictionary.dart' as DD;

void main() {
  group('AcSyncOnWs tests', () {
    late Directory tempDir;
    late AcWsServer server;
    late AcWsClient client;
    
    late AcSyncDestinationDatabase destDb;
    late AcSyncSourceDatabase sourceDb;
    
    late AcSyncOnWs clientSync;
    late AcSyncOnWs serverSync;

    setUpAll(() async {
      AcDataDictionary.registerDataDictionary(dataDictionaryName: "default", jsonData: DD.DATA_DICTIONARY);
    });

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('ac_sync_ws_test_');
      
      // Setup database files
      final sourceTemplate = File('../ac_sync/database/source/accountee.db');
      if (!sourceTemplate.existsSync()) {
        throw Exception("Source template database not found at ${sourceTemplate.absolute.path}");
      }
      
      sourceTemplate.copySync('${tempDir.path}/test_source.db');
      sourceTemplate.copySync('${tempDir.path}/test_dest.db');

      // Initialize databases
      AcSqliteDao destDao = AcSqliteDao();
      destDao.sqlConnection = AcSqlConnection(database: '${tempDir.path}/test_dest.db');
      destDb = AcSyncDestinationDatabase(dao: destDao, databaseType: AcEnumSqlDatabaseType.sqlite);
      
      AcSqliteDao sourceDao = AcSqliteDao();
      sourceDao.sqlConnection = AcSqlConnection(database: '${tempDir.path}/test_source.db');
      sourceDb = AcSyncSourceDatabase(dao: sourceDao, databaseType: AcEnumSqlDatabaseType.sqlite);

      await destDb.registerDefinitionFromDataDictionary(dataDictionaryName: 'default');
      await destDb.initialize(syncVersion: 2);

      await sourceDb.registerDefinitionFromDataDictionary(dataDictionaryName: 'default');
      await sourceDb.initialize(syncVersion: 2);

      // Start server
      server = AcWsServer()..port = 0;
      await server.start();
      final port = server.port;

      final connectionCompleter = Completer<void>();

      server.onConnection(handler: ({required socket}) {
        serverSync = AcSyncOnWs(
          socket: socket,
          syncSourceDatabase: sourceDb,
        );
        connectionCompleter.complete();
      });

      // Start client
      client = AcWsClient(url: 'ws://localhost:$port');
      final clientSocket = await client.connect();
      expect(clientSocket, isNotNull);

      clientSync = AcSyncOnWs(
        socket: clientSocket,
        syncDestinationDatabase: destDb,
      );

      await connectionCompleter.future.timeout(Duration(seconds: 5));
    });

    tearDown(() async {
      try {
        await client.disconnect();
      } catch (_) {}
      try {
        await server.stop();
      } catch (_) {}
      
      if (destDb.dao is AcSqliteDao) {
        try {
          await (destDb.dao as AcSqliteDao).close();
        } catch (_) {}
      }
      if (sourceDb.dao is AcSqliteDao) {
        try {
          await (sourceDb.dao as AcSqliteDao).close();
        } catch (_) {}
      }
      
      // Let OS release file handles before deleting
      await Future.delayed(Duration(milliseconds: 500));
      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    Future<void> waitForSessionCompletion(AcSyncDatabase db, String sessionId) async {
      for (int i = 0; i < 100; i++) {
        final session = await db.loadSessionState(sessionId);
        if (session != null && session.status == 'COMPLETED') {
          return;
        }
        await Future.delayed(Duration(milliseconds: 100));
      }
      throw TimeoutException("Sync session $sessionId did not complete in time");
    }

    test('Full Bidirectional Sync over WebSockets', () async {
      // 1. Insert local change in source
      await sourceDb.dao!.executeStatement(
        statement: "INSERT INTO act_products (product_id, product_name) VALUES ('ws_p1', 'WS Product 1');"
      );

      // 2. Perform sync
      final syncResult = await clientSync.sync();
      expect(syncResult.isSuccess(), isTrue);
      final String sessionId = syncResult.value;

      // 3. Wait for the sync to complete asynchronously
      await waitForSessionCompletion(destDb, sessionId);

      // 4. Verify changes propagated
      var productsResult = await destDb.dao!.getRows(statement: "SELECT * FROM act_products WHERE product_id = 'ws_p1';");
      expect(productsResult.rows, isNotEmpty);
      expect(productsResult.rows.first['product_name'], equals('WS Product 1'));
    });

    test('Database File Transfer (getDatabaseFileFromSource)', () async {
      final destFilePath = '${tempDir.path}/streamed_dest.db';
      final syncCompleteCompleter = Completer<void>();

      clientSync.onSyncComplete = () async {
        if (!syncCompleteCompleter.isCompleted) {
          syncCompleteCompleter.complete();
        }
      };

      final result = await clientSync.getDatabaseFileFromSource(destinationFilePath: destFilePath);
      expect(result.isSuccess(), isTrue);

      await syncCompleteCompleter.future.timeout(Duration(seconds: 15));

      final downloadedFile = File(destFilePath);
      expect(downloadedFile.existsSync(), isTrue);
      expect(downloadedFile.lengthSync(), greaterThan(0));
    });

    test('Interrupt and Resume Sync session', () async {
      // 1. Insert local changes in source
      await sourceDb.dao!.executeStatement(
        statement: "INSERT INTO act_products (product_id, product_name) VALUES ('ws_resume_p1', 'Resume Product 1');"
      );

      // 2. Intercept and disconnect mid-sync
      int messageCount = 0;
      final clientSocket = client.socket;
      
      clientSocket!.addOutgoingInterceptor(handler: ({required message, abort, callback}) async {
        final decoded = message as Map<String, dynamic>;
        final data = decoded['d'];
        if (data != null && data is Map && data['syncAction'] == 'sessionMessage') {
          messageCount++;
          if (messageCount >= 2) {
            // Disconnect socket to simulate network drop
            await client.disconnect();
            if (abort != null) abort();
          }
        }
      });

      // Start Sync (will get interrupted/disconnected)
      final syncResult1 = await clientSync.sync();
      expect(syncResult1.isSuccess(), isTrue);
      final String sessionId = syncResult1.value;

      // Wait for socket to disconnect (simulating interruption)
      for (int i = 0; i < 50; i++) {
        if (client.socket == null || !client.socket!.isConnected) break;
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Verify the changes did not propagate fully yet
      var productsResult1 = await destDb.dao!.getRows(statement: "SELECT * FROM act_products WHERE product_id = 'ws_resume_p1';");
      expect(productsResult1.rows, isEmpty);

      // Reconnect client to server
      final clientSocket2 = await client.connect();
      expect(clientSocket2, isNotNull);

      // Reset clientSync with the new socket
      clientSync = AcSyncOnWs(
        socket: clientSocket2,
        syncDestinationDatabase: destDb,
      );

      // Resume using the sessionId
      final syncResult2 = await clientSync.sync(syncId: sessionId);
      expect(syncResult2.isSuccess(), isTrue);

      // Wait for the resumed sync to complete
      await waitForSessionCompletion(destDb, sessionId);

      // Verify changes have now propagated
      var productsResult2 = await destDb.dao!.getRows(statement: "SELECT * FROM act_products WHERE product_id = 'ws_resume_p1';");
      expect(productsResult2.rows, isNotEmpty);
      expect(productsResult2.rows.first['product_name'], equals('Resume Product 1'));
    });
  });
}
