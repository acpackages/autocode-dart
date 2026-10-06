import 'dart:io';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';
import 'package:ac_web_on_jaguar/ac_web_on_jaguar.dart';
import 'controllers/ac_patch_domain_controller.dart';
import 'database/ac_patches_data_dictionary.dart';
import 'storage/ac_patch_storage_provider.dart';

class AcPatchesServerApp {
  final int port;
  final String dbPath;
  final Directory storageDir;
  final String dataDictionaryName;

  late AcWebOnJaguar server;
  late AcBaseSqlDao dao;
  late IAcPatchStorageProvider storage;
  late AcPatchDomainController domainController;

  AcPatchesServerApp({
    this.port = 8080,
    required this.dbPath,
    required this.storageDir,
    this.dataDictionaryName = 'ac_patches',
  });

  Future<void> initialize() async {
    // 1. Register Data Dictionary
    AcDataDictionary.registerDataDictionary(
      jsonData: kAcPatchesDataDictionaryJson,
      dataDictionaryName: dataDictionaryName,
    );

    // 2. Initialize SQLite DAO
    AcSqlDatabase.databaseType = AcEnumSqlDatabaseType.sqlite;
    AcSqlDatabase.sqlConnection = AcSqlConnection(database: dbPath);

    dao = AcSqliteDao();
    await dao.setSqlConnection(
      sqlConnection: AcSqlConnection(database: dbPath),
    );

    // 3. Run Schema Manager to ensure tables exist
    final schemaManager = AcSqlDbSchemaManager(
      dataDictionaryName: dataDictionaryName,
      dao: dao,
    );
    schemaManager.ignoreViews = true;
    schemaManager.ignoreFunctions = true;
    schemaManager.ignoreStoredProcedures = true;

    final schemaResult = await schemaManager.initDatabase();
    if (!schemaResult.isSuccess()) {
      throw StateError('Database initialization failed: ${schemaResult.message}');
    }

    // 4. Setup Storage
    storage = AcPatchLocalStorageProvider(rootDir: storageDir);

    // 5. Setup Web Server
    server = AcWebOnJaguar();
    server.port = port;

    // 6. Register AutoApi for CRUD on metadata tables
    final autoApi = AcDataDictionaryAutoApi(
      acWeb: server,
      dataDictionaryName: dataDictionaryName,
    );
    autoApi.urlPrefix = '/api/v1';
    autoApi.getAcSqlDbTable = ({
      required AcWebRequest request,
      required AcDDTable acDDTable,
    }) async {
      final res = AcResult();
      res.setSuccess(
        value: AcSqlDbTable(
          tableName: acDDTable.tableName,
          dataDictionaryName: dataDictionaryName,
          dao: dao,
        ),
      );
      return res;
    };
    autoApi.generate();

    // 7. Register Domain Controller
    domainController = AcPatchDomainController(
      web: server,
      storage: storage,
      dao: dao,
      dataDictionaryName: dataDictionaryName,
    );
  }

  Future<void> start() async {
    await server.start();
  }

  Future<void> stop() async {
    await server.stop();
    if (dao is AcSqliteDao) {
      await (dao as AcSqliteDao).close();
    }
  }
}
