import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_sync/ac_sync.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:autocode/autocode.dart';

void main() {
  group('File and Directory Synchronization Tests', () {
    late Directory tempDir;
    late Directory srcDir;
    late Directory destDir;
    late AcSyncDestinationDatabase destDb;
    late AcSyncSourceDatabase sourceDb;

    setUp(() async {
      // Create temporary directories
      tempDir = Directory.systemTemp.createTempSync('ac_sync_test_');
      srcDir = Directory('${tempDir.path}/source')..createSync();
      destDir = Directory('${tempDir.path}/destination')..createSync();

      // Setup databases for session persistence
      AcSqliteDao destDao = AcSqliteDao();
      destDao.sqlConnection = AcSqlConnection(database: '${tempDir.path}/dest_db.db');
      destDb = AcSyncDestinationDatabase(dao: destDao, databaseType: AcEnumSqlDatabaseType.sqlite);

      AcSqliteDao sourceDao = AcSqliteDao();
      sourceDao.sqlConnection = AcSqlConnection(database: '${tempDir.path}/source_db.db');
      sourceDb = AcSyncSourceDatabase(dao: sourceDao, databaseType: AcEnumSqlDatabaseType.sqlite);

      await destDb.initialize();
      await sourceDb.initialize();
    });

    tearDown(() async {
      if (destDb.dao is AcSqliteDao) {
        await (destDb.dao as AcSqliteDao).close();
      }
      if (sourceDb.dao is AcSqliteDao) {
        await (sourceDb.dao as AcSqliteDao).close();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Single Large File Sync with Chunking', () async {
      // 1. Create a large source file
      final largeFile = File('${srcDir.path}/large.txt');
      final dataBuffer = StringBuffer();
      for (int i = 0; i < 5000; i++) {
        dataBuffer.write('Line $i: Hello world from the chunked file synchronization test!\n');
      }
      final fileContent = dataBuffer.toString();
      largeFile.writeAsStringSync(fileContent);

      // 2. Register file provider with small chunk size (16KB) to force multiple chunks
      final fileProviderSource = AcSyncFileProvider(
        targetId: 'large_file',
        files: [largeFile],
        destinationDirectory: destDir.path,
        baseDirectory: srcDir.path,
        chunkSize: 16 * 1024,
      );
      sourceDb.registerProvider(fileProviderSource);

      final fileProviderDest = AcSyncFileProvider(
        targetId: 'large_file',
        files: [],
        destinationDirectory: destDir.path,
        baseDirectory: destDir.path,
        chunkSize: 16 * 1024,
      );
      destDb.registerProvider(fileProviderDest);

      // 3. Routing helper
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

      // 4. Run synchronization
      final result = await destDb.sync();
      expect(result.isSuccess(), isTrue);

      // 5. Verify the destination file matches the source
      final copiedFile = File('${destDir.path}/${largeFile.path.substring(srcDir.path.length + 1)}');
      expect(copiedFile.existsSync(), isTrue);
      expect(copiedFile.readAsStringSync(), equals(fileContent));
    });

    test('Directory Sync with Recursion and Glob Filters', () async {
      // 1. Setup nested source folder hierarchy
      File('${srcDir.path}/main.dart').writeAsStringSync('void main() {}');
      File('${srcDir.path}/app.json').writeAsStringSync('{"name": "app"}');
      
      final subDir = Directory('${srcDir.path}/src')..createSync();
      File('${subDir.path}/helper.dart').writeAsStringSync('class Helper {}');
      File('${subDir.path}/debug.log').writeAsStringSync('some error log logs...');
      File('${subDir.path}/temp.tmp').writeAsStringSync('temp file content');

      // 2. Register Directory Provider with include/exclude glob filters
      // Include: src/**, *.dart, *.json
      // Exclude: **/*.tmp, **/*.log
      final dirProviderSrc = AcSyncDirectoryProvider(
        targetId: 'dir_sync',
        directoryPath: srcDir.path,
        destinationDirectory: destDir.path,
        recursive: true,
        includeFiles: ['src/**', '*.dart', '*.json'],
        excludeFiles: ['**/*.tmp', '**/*.log'],
        chunkSize: 4096,
      );
      sourceDb.registerProvider(dirProviderSrc);

      final dirProviderDest = AcSyncDirectoryProvider(
        targetId: 'dir_sync',
        directoryPath: destDir.path,
        destinationDirectory: destDir.path,
        recursive: true,
        includeFiles: ['src/**', '*.dart', '*.json'],
        excludeFiles: ['**/*.tmp', '**/*.log'],
        chunkSize: 4096,
      );
      destDb.registerProvider(dirProviderDest);

      // 3. Routing
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

      // 4. Run sync
      final result = await destDb.sync();
      expect(result.isSuccess(), isTrue);

      // 5. Verify synced files
      expect(File('${destDir.path}/main.dart').existsSync(), isTrue);
      expect(File('${destDir.path}/app.json').existsSync(), isTrue);
      expect(File('${destDir.path}/src/helper.dart').existsSync(), isTrue);
      
      // Verify excluded files
      expect(File('${destDir.path}/src/debug.log').existsSync(), isFalse);
      expect(File('${destDir.path}/src/temp.tmp').existsSync(), isFalse);
    });

    test('Resume Session', () async {
      // 1. Create a large source file
      final largeFile = File('${srcDir.path}/resume.txt');
      final fileContent = 'A' * 100 * 1024; // 100KB
      largeFile.writeAsStringSync(fileContent);

      final fileProviderSource = AcSyncFileProvider(
        targetId: 'resume_file',
        files: [largeFile],
        destinationDirectory: destDir.path,
        baseDirectory: srcDir.path,
        chunkSize: 10 * 1024, // 10 chunks
      );
      sourceDb.registerProvider(fileProviderSource);

      final fileProviderDest = AcSyncFileProvider(
        targetId: 'resume_file',
        files: [],
        destinationDirectory: destDir.path,
        baseDirectory: destDir.path,
        chunkSize: 10 * 1024,
      );
      destDb.registerProvider(fileProviderDest);

      // Limit routing to interrupt midway (after 3 messages)
      int messageCount = 0;
      bool interrupted = false;

      Future<void> routeMessage(AcSyncDatabase sender, AcSyncDatabase receiver, AcSyncMessage message) async {
        if (messageCount >= 6) {
          interrupted = true;
          return; // Stop transmitting/simulating network failure
        }
        messageCount++;
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

      // Start Sync (will get interrupted)
      final result1 = await destDb.sync();
      expect(result1.isSuccess(), isTrue);
      final String sessionId = result1.value;
      expect(interrupted, isTrue);

      // Verify destination file is NOT fully completed yet
      final copiedFile = File('${destDir.path}/${largeFile.path.substring(srcDir.path.length + 1)}');
      expect(copiedFile.existsSync(), isFalse); // Still in temp file format (.tmp)

      // Restore normal network routing
      Future<void> routeMessageNormal(AcSyncDatabase sender, AcSyncDatabase receiver, AcSyncMessage message) async {
        var responses = await receiver.receiveMessage(message);
        for (var resp in responses) {
          await routeMessageNormal(receiver, sender, resp);
        }
      }

      destDb.onSendMessage = (message) async {
        await routeMessageNormal(destDb, sourceDb, message);
      };
      sourceDb.onSendMessage = (message) async {
        await routeMessageNormal(sourceDb, destDb, message);
      };

      // Resume from last state using the same syncIdentifier
      final result2 = await destDb.sync(syncId: sessionId);
      expect(result2.isSuccess(), isTrue);

      // Verify copied file is fully complete and correct
      expect(copiedFile.existsSync(), isTrue);
      expect(copiedFile.readAsStringSync(), equals(fileContent));
    });
  });
}
