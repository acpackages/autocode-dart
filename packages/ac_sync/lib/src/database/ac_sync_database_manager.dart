import 'dart:io';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_sync/src/database/data_dictionary.dart';
import 'package:ac_sync/src/models/ac_sync_table_definition.dart';
import 'package:autocode/autocode.dart';

class AcSyncDatabaseManager {
  static const String dataDictionaryName = "_ac_sync";
  AcBaseSqlDao? dao;
  AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown;
  AcLogger logger = AcLogger(logType: AcEnumLogType.console, logMessages: true);
  List<String> _buildMysqlTriggerSql(String table, String pk, String prefix, List<String> columns) {
    String insertPayload = "JSON_REMOVE(JSON_OBJECT(${columns.map((c) => "'$c', NEW.`$c`").join(', ')}), ${columns.map((c) => "IF(NEW.`$c` IS NULL, '\$.\"$c\"', '\$._dummy_')").join(', ')})";
    
    String updatePayload = "JSON_REMOVE(JSON_OBJECT(${columns.map((c) => "'$c', NEW.`$c`").join(', ')}), ${columns.map((c) => "IF(OLD.`$c` <=> NEW.`$c`, '\$.\"$c\"', '\$._dummy_')").join(', ')})";

    return [
      // INSERT Trigger
      """
      CREATE TRIGGER IF NOT EXISTS ${prefix}${table}_ins AFTER INSERT ON $table
      FOR EACH ROW
      BEGIN
        INSERT INTO ${AcSyncTables.acSyncChangeLogs} (
          ${TblAcSyncChangeLogs.tableName}, 
          ${TblAcSyncChangeLogs.rowId}, 
          ${TblAcSyncChangeLogs.rowOperation}, 
          ${TblAcSyncChangeLogs.operationTimestamp},
          ${TblAcSyncChangeLogs.rowPayload}
        ) VALUES (
          '$table', 
          NEW.`$pk`, 
          'INSERT', 
          NOW(),
          $insertPayload
        );
      END;
      """,
      // UPDATE Trigger
      """
      CREATE TRIGGER IF NOT EXISTS ${prefix}${table}_upd AFTER UPDATE ON $table
      FOR EACH ROW
      BEGIN
        INSERT INTO ${AcSyncTables.acSyncChangeLogs} (
          ${TblAcSyncChangeLogs.tableName}, 
          ${TblAcSyncChangeLogs.rowId}, 
          ${TblAcSyncChangeLogs.rowOperation}, 
          ${TblAcSyncChangeLogs.operationTimestamp},
          ${TblAcSyncChangeLogs.rowPayload}
        ) VALUES (
          '$table', 
          NEW.`$pk`, 
          'UPDATE', 
          NOW(),
          $updatePayload
        );
      END;
      """,
      // DELETE Trigger
      """
      CREATE TRIGGER IF NOT EXISTS ${prefix}${table}_del AFTER DELETE ON $table
      FOR EACH ROW
      BEGIN
        INSERT INTO ${AcSyncTables.acSyncChangeLogs} (
          ${TblAcSyncChangeLogs.tableName}, 
          ${TblAcSyncChangeLogs.rowId}, 
          ${TblAcSyncChangeLogs.rowOperation}, 
          ${TblAcSyncChangeLogs.operationTimestamp}
        ) VALUES (
          '$table', 
          OLD.`$pk`, 
          'DELETE', 
          NOW()
        );
      END;
      """
    ];
  }

  List<String> _buildSqliteTriggerSql(
      String table,
      String pk,
      String prefix,
      List<String> columns,
      ) {

    String buildInsertPayload() {
      final selects = columns.map((column) {
        return """
SELECT '$column' AS key, NEW.`$column` AS value
""";
      }).join("\nUNION ALL\n");

      return """
(
  SELECT json_group_object(key, value)
  FROM (
    $selects
  )
  WHERE value IS NOT NULL
)
""";
    }

    String buildUpdatePayload() {
      final selects = columns.map((column) {
        return """
SELECT
  '$column' AS key,
  CASE
    WHEN NEW.`$column` IS NOT OLD.`$column`
    THEN NEW.`$column`
  END AS value
""";
      }).join("\nUNION ALL\n");

      return """
(
  SELECT json_group_object(key, value)
  FROM (
    $selects
  )
  WHERE value IS NOT NULL
)
""";
    }

    final insertPayload = buildInsertPayload();
    final updatePayload = buildUpdatePayload();

    final insertTrigger = """
CREATE TRIGGER IF NOT EXISTS ${prefix}${table}_ins
AFTER INSERT ON `$table`
BEGIN
  INSERT INTO `${AcSyncTables.acSyncChangeLogs}` (
    `${TblAcSyncChangeLogs.tableName}`,
    `${TblAcSyncChangeLogs.rowId}`,
    `${TblAcSyncChangeLogs.rowOperation}`,
    `${TblAcSyncChangeLogs.operationTimestamp}`,
    `${TblAcSyncChangeLogs.rowPayload}`
  ) VALUES (
    '$table',
    NEW.`$pk`,
    'INSERT',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    $insertPayload
  );
END;
""";

    final updateTrigger = """
    CREATE TRIGGER IF NOT EXISTS ${prefix}${table}_upd
    AFTER UPDATE ON `$table`
    BEGIN
      INSERT INTO `${AcSyncTables.acSyncChangeLogs}` (
        `${TblAcSyncChangeLogs.tableName}`,
        `${TblAcSyncChangeLogs.rowId}`,
        `${TblAcSyncChangeLogs.rowOperation}`,
        `${TblAcSyncChangeLogs.operationTimestamp}`,
        `${TblAcSyncChangeLogs.rowPayload}`
      ) VALUES (
        '$table',
        NEW.`$pk`,
        'UPDATE',
        strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
        $updatePayload
      );
    END;
    """;

    final deleteTrigger = """
CREATE TRIGGER IF NOT EXISTS ${prefix}${table}_del
AFTER DELETE ON `$table`
BEGIN
  INSERT INTO `${AcSyncTables.acSyncChangeLogs}` (
    `${TblAcSyncChangeLogs.tableName}`,
    `${TblAcSyncChangeLogs.rowId}`,
    `${TblAcSyncChangeLogs.rowOperation}`,
    `${TblAcSyncChangeLogs.operationTimestamp}`
  ) VALUES (
    '$table',
    OLD.`$pk`,
    'DELETE',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
  );
END;
""";

    return [
      insertTrigger,
      updateTrigger,
      deleteTrigger,
    ];
  }

  Future<void> _createTriggersForTable({
    required AcBaseSqlDao dao,
    required String tableName,
    required String primaryKey,
    required List<String> columns,
    required AcEnumSqlDatabaseType databaseType,
  }) async {
    List<String> triggerSqls = [];
    String triggerPrefix = "_ac_sync_trg_";

    if (databaseType == AcEnumSqlDatabaseType.sqlite) {
      triggerSqls.addAll(_buildSqliteTriggerSql(tableName, primaryKey, triggerPrefix, columns));
    } else if (databaseType == AcEnumSqlDatabaseType.mysql || databaseType == AcEnumSqlDatabaseType.mariadb) {
      triggerSqls.addAll(_buildMysqlTriggerSql(tableName, primaryKey, triggerPrefix, columns));
    }

    for (var sql in triggerSqls) {
      logger.log("[AcSyncDatabaseManager] Executing trigger SQL: ${sql.substring(0, sql.indexOf('AFTER')).trim()}...");
      await dao.executeStatement(statement: sql);
    }
  }

  Future<void> createSyncTriggers({
    AcBaseSqlDao? dao,
    required List<AcSyncTableDefinition> tableDefinitions,
    required AcEnumSqlDatabaseType databaseType,
  }) async {
    logger.log("[AcSyncDatabaseManager] Creating sync triggers for ${tableDefinitions.length} tables...");
    if (dao == null) {
      logger.error("[AcSyncDatabaseManager] DAO is null, cannot create triggers.");
      return;
    }

    for (var tableDef in tableDefinitions) {
      String table = tableDef.tableName;
      // Get columns to find all available columns and identify the primary key
      var columnsResult = await dao.getTableColumns(tableName: table);
      if (!columnsResult.isSuccess()) {
        logger.error("[AcSyncDatabaseManager] Failed to get columns for table '$table': ${columnsResult.message}");
        continue;
      }

      String? primaryKey = tableDef.primaryKeyField.isNotEmpty ? tableDef.primaryKeyField : null;
      List<String> allColumns = [];

      for (var row in columnsResult.rows) {
        String colName = row[AcDDTableColumn.keyColumnName];
        allColumns.add(colName);

        var properties = row[AcDDTableColumn.keyColumnProperties];
        if (properties != null) {
          if (properties[AcEnumDDColumnProperty.primaryKey.value] == true) {
            primaryKey ??= colName;
          }
        }
      }

      if (primaryKey == null) {
        logger.warn("[AcSyncDatabaseManager] Table '$table' - Primary key not found in definition or database metadata. Defaulting to 'id'.");
        primaryKey = "id";
      } else {
        logger.log("[AcSyncDatabaseManager] Table '$table' - Using primary key: $primaryKey");
      }
      
      // Filter columns based on columnsToSync
      List<String> columnsToUse = [];
      if (tableDef.columnsToSync.isNotEmpty) {
        // Always include Primary Key
        if (!tableDef.columnsToSync.contains(primaryKey)) {
          columnsToUse.add(primaryKey);
        }
        for (var col in tableDef.columnsToSync) {
          if (allColumns.contains(col)) {
            columnsToUse.add(col);
          }
        }
      } else {
        columnsToUse = allColumns;
      }

      await _createTriggersForTable(
        dao: dao,
        tableName: table,
        primaryKey: primaryKey,
        columns: columnsToUse,
        databaseType: databaseType,
      );
    }
    logger.log("[AcSyncDatabaseManager] Finished creating sync triggers.");
  }

  Future<void> dropSyncTriggers({
    AcBaseSqlDao? dao,
    required List<AcSyncTableDefinition> tableDefinitions,
    required AcEnumSqlDatabaseType databaseType,
  }) async {
    logger.log("[AcSyncDatabaseManager] Dropping sync triggers for ${tableDefinitions.length} tables...");
    if (dao == null) {
      logger.error("[AcSyncDatabaseManager] DAO is null, cannot drop triggers.");
      return;
    }
    String triggerPrefix = "_ac_sync_trg_";

    for (var tableDef in tableDefinitions) {
      String table = tableDef.tableName;
      List<String> suffixes = ['_ins', '_upd', '_del'];
      for (var suffix in suffixes) {
        String triggerName = "$triggerPrefix$table$suffix";
        String dropSql = "";
        if (databaseType == AcEnumSqlDatabaseType.sqlite) {
          dropSql = "DROP TRIGGER IF EXISTS $triggerName;";
        } else if (databaseType == AcEnumSqlDatabaseType.mysql || databaseType == AcEnumSqlDatabaseType.mariadb) {
          dropSql = "DROP TRIGGER IF EXISTS `$triggerName`;";
        }
        if (dropSql.isNotEmpty) {
          logger.log("[AcSyncDatabaseManager] Dropping trigger: $triggerName");
          await dao.executeStatement(statement: dropSql);
        }
      }
    }
    logger.log("[AcSyncDatabaseManager] Finished dropping sync triggers.");
  }

  Future<AcResult> initAcSyncDatabase() async {
    AcSqlDbSchemaManager schemaManager = AcSqlDbSchemaManager(dataDictionaryName: dataDictionaryName);
    schemaManager.dao = dao;
    schemaManager.databaseType = databaseType;
    logger.log("[AcSyncDatabaseManager] Initializing AcSync database schema...");
    var result = await schemaManager.initDatabase();
    logger.log("[AcSyncDatabaseManager] Schema initialization ${result.isSuccess() ? 'successful' : 'failed: ' + result.message}");
    return result;
  }

  Future<void> createDatabaseFileForDestination({
    required String sourcePath,
    required String destinationPath,
    List<AcSyncTableDefinition>? tableDefinitions,
  }) async {
    // 1. Copy the file
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception("Source database file does not exist at $sourcePath");
    }
    // await sourceFile.copy(destinationPath);
    logger.log("[AcSyncDatabaseManager] Copying database file from '$sourcePath' to '$destinationPath'...");
    final bytes = await sourceFile.readAsBytes();
    File(destinationPath).writeAsBytesSync(bytes);
    logger.log("[AcSyncDatabaseManager] File copy complete (${bytes.length} bytes).");

    // 2. Open the destination database
    logger.log("[AcSyncDatabaseManager] Opening destination database...");
    final destDao = AcSqliteDao();
    destDao.sqlConnection = AcSqlConnection(database: destinationPath);

    try {
      await destDao.executeStatement(statement: "PRAGMA journal_mode = OFF;");

      if(tableDefinitions != null){
        logger.log("[AcSyncDatabaseManager] Cleaning up destination database tables...");
        await destDao.executeStatement(statement: "PRAGMA foreign_keys = OFF;");
        // 3. Empty tables where syncToDestination is false
        for (var tableDef in tableDefinitions) {
          if (!tableDef.syncToDestination) {
            logger.log("[AcSyncDatabaseManager] Emptying table '${tableDef.tableName}' (syncToDestination is false)");
            await destDao.executeStatement(statement: "DELETE FROM ${tableDef.tableName}");
          }
        }

        logger.log("[AcSyncDatabaseManager] Clearing sync metadata tables...");
        await destDao.executeStatement(statement: "DELETE FROM ${AcSyncTables.acSyncDetails}");
        await destDao.executeStatement(statement: "DELETE FROM ${AcSyncTables.acSyncChangeLogs}");
        await destDao.executeStatement(statement: "DELETE FROM ${AcSyncTables.acSyncDeviceLogs}");
        await destDao.executeStatement(statement: "DELETE FROM ${AcSyncTables.acSyncDevices}");

        await destDao.executeStatement(statement: "PRAGMA foreign_keys = ON;");
        // 4. Perform Vacuum
        logger.log("[AcSyncDatabaseManager] Performing VACUUM on destination database...");
        await destDao.executeStatement(statement: "VACUUM");
      }

    } catch (e) {
      logger.error("[AcSyncDatabaseManager] Error during database file preparation: $e");
      rethrow;
    } finally {
      try {
        await destDao.close();
      } catch (_) {}
      logger.log("[AcSyncDatabaseManager] Finished preparing destination database file.");
    }
  }

  Future<void> provisionClientDatabase({
    required String destinationPath,
    required String clientDeviceId,
    required String serverDeviceId,
    required int serverLastLogId,
    required Map<String, dynamic> serverDeviceDetails,
  }) async {
    logger.log("[AcSyncDatabaseManager] Provisioning client database at '$destinationPath'...");
    final destDao = AcSqliteDao();
    destDao.sqlConnection = AcSqlConnection(database: destinationPath);

    try {
      // 1. Set current device ID for the client copy
      logger.log("[AcSyncDatabaseManager] Setting current device ID to '$clientDeviceId'...");
      await destDao.executeStatement(
          statement: "DELETE FROM ${AcSyncTables.acSyncDetails} WHERE ${TblAcSyncDetails.syncDetailKey} = 'current_device_id'"
      );
      await destDao.insertRow(
          tableName: AcSyncTables.acSyncDetails,
          row: {
            TblAcSyncDetails.syncDetailKey: 'current_device_id',
            TblAcSyncDetails.syncDetailStringValue: clientDeviceId
          }
      );

      // 2. Set sync mode to client
      logger.log("[AcSyncDatabaseManager] Setting sync mode to 'client'...");
      await destDao.executeStatement(
          statement: "DELETE FROM ${AcSyncTables.acSyncDetails} WHERE ${TblAcSyncDetails.syncDetailKey} = 'sync_mode'"
      );
      await destDao.insertRow(
          tableName: AcSyncTables.acSyncDetails,
          row: {
            TblAcSyncDetails.syncDetailKey: 'sync_mode',
            TblAcSyncDetails.syncDetailStringValue: 'client'
          }
      );

      // 3. Clear all device records and keep only Client and Server
      logger.log("[AcSyncDatabaseManager] Clearing devices and adding Client/Server records...");
      await destDao.executeStatement(statement: "DELETE FROM ${AcSyncTables.acSyncDevices}");

      // Add Client Device entry (as itself)
      await destDao.insertRow(
          tableName: AcSyncTables.acSyncDevices,
          row: {
            TblAcSyncDevices.syncDeviceId: clientDeviceId,
            TblAcSyncDevices.isSourceOfTruth: 0,
            TblAcSyncDevices.lastSyncChangeLogId: 0
          }
      );

      // Add Server Device entry (as remote source)
      // This allows the client to know where it stands relative to the server's logs
      await destDao.insertRow(
          tableName: AcSyncTables.acSyncDevices,
          row: {
            ...serverDeviceDetails,
            TblAcSyncDevices.syncDeviceId: serverDeviceId,
            TblAcSyncDevices.isSourceOfTruth: 1,
            TblAcSyncDevices.lastSyncChangeLogId: 0 // Client's progress on Server's logs (start at 0)
          }
      );
      
      // Update the "Server has processed our logs up to X" (which is everything since it's a fresh clone)
      // Actually, the clone has 0 logs usually if it was a fresh setup, or it has all the server's current data.
      // We set the lastSyncChangeLogId for the server device to the server's current log ID.
      logger.log("[AcSyncDatabaseManager] Setting server's last log ID to $serverLastLogId...");
      await destDao.updateRow(
        tableName: AcSyncTables.acSyncDevices,
        row: {TblAcSyncDevices.lastSyncChangeLogId: serverLastLogId},
        condition: "${TblAcSyncDevices.syncDeviceId} = '$serverDeviceId'"
      );
      logger.log("[AcSyncDatabaseManager] Client database provisioning complete.");

    } catch (e) {
      logger.error("[AcSyncDatabaseManager] Error during client provisioning: $e");
      rethrow;
    } finally {
      try {
        await destDao.close();
      } catch (_) {}
    }
  }
}