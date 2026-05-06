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
  List<String> _buildMysqlTriggerSql(String table, String pk, String prefix, List<String> columns) {
    String insertPayload = "JSON_REMOVE(JSON_OBJECT(${columns.map((c) => "'$c', NEW.`$c`").join(', ')}), ${columns.map((c) => "IF(NEW.`$c` IS NULL, '\$.$c', '\$._dummy_')").join(', ')})";
    
    String updatePayload = "JSON_REMOVE(JSON_OBJECT(${columns.map((c) => "'$c', NEW.`$c`").join(', ')}), ${columns.map((c) => "IF(OLD.`$c` <=> NEW.`$c`, '\$.$c', '\$._dummy_')").join(', ')})";

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
          NEW.$pk, 
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
          NEW.$pk, 
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
          OLD.$pk, 
          'DELETE', 
          NOW()
        );
      END;
      """
    ];
  }

  List<String> _buildSqliteTriggerSql(String table, String pk, String prefix, List<String> columns) {
    String insertPayload = "json_remove(json_object(${columns.map((c) => "'$c', NEW.\"$c\"").join(', ')}), ${columns.map((c) => "CASE WHEN NEW.\"$c\" IS NULL THEN '\$.$c' ELSE NULL END").join(', ')})";
    
    String updatePayload = "json_remove(json_object(${columns.map((c) => "'$c', NEW.\"$c\"").join(', ')}), ${columns.map((c) => "CASE WHEN OLD.\"$c\" IS NEW.\"$c\" THEN '\$.$c' ELSE NULL END").join(', ')})";

    return [
      // INSERT Trigger
      """
      CREATE TRIGGER IF NOT EXISTS ${prefix}${table}_ins AFTER INSERT ON $table
      BEGIN
        INSERT INTO ${AcSyncTables.acSyncChangeLogs} (
          ${TblAcSyncChangeLogs.tableName}, 
          ${TblAcSyncChangeLogs.rowId}, 
          ${TblAcSyncChangeLogs.rowOperation}, 
          ${TblAcSyncChangeLogs.operationTimestamp},
          ${TblAcSyncChangeLogs.rowPayload}
        ) VALUES (
          '$table', 
          NEW.$pk, 
          'INSERT', 
          CURRENT_TIMESTAMP,
          $insertPayload
        );
      END;
      """,
      // UPDATE Trigger
      """
      CREATE TRIGGER IF NOT EXISTS ${prefix}${table}_upd AFTER UPDATE ON $table
      BEGIN
        INSERT INTO ${AcSyncTables.acSyncChangeLogs} (
          ${TblAcSyncChangeLogs.tableName}, 
          ${TblAcSyncChangeLogs.rowId}, 
          ${TblAcSyncChangeLogs.rowOperation}, 
          ${TblAcSyncChangeLogs.operationTimestamp},
          ${TblAcSyncChangeLogs.rowPayload}
        ) VALUES (
          '$table', 
          NEW.$pk, 
          'UPDATE', 
          CURRENT_TIMESTAMP,
          $updatePayload
        );
      END;
      """,
      // DELETE Trigger
      """
      CREATE TRIGGER IF NOT EXISTS ${prefix}${table}_del AFTER DELETE ON $table
      BEGIN
        INSERT INTO ${AcSyncTables.acSyncChangeLogs} (
          ${TblAcSyncChangeLogs.tableName}, 
          ${TblAcSyncChangeLogs.rowId}, 
          ${TblAcSyncChangeLogs.rowOperation}, 
          ${TblAcSyncChangeLogs.operationTimestamp}
        ) VALUES (
          '$table', 
          OLD.$pk, 
          'DELETE', 
          CURRENT_TIMESTAMP
        );
      END;
      """
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
      await dao.executeStatement(statement: sql);
    }
  }

  Future<void> createSyncTriggers({
    AcBaseSqlDao? dao,
    required List<AcSyncTableDefinition> tableDefinitions,
    required AcEnumSqlDatabaseType databaseType,
  }) async {
    if (dao == null) return;

    for (var tableDef in tableDefinitions) {
      String table = tableDef.tableName;
      // Get columns to find all available columns and identify the primary key
      var columnsResult = await dao.getTableColumns(tableName: table);
      if (!columnsResult.isSuccess()) continue;

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

      primaryKey ??= "id";
      
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
  }

  Future<AcResult> initAcSyncDatabase() async {
    AcSqlDbSchemaManager schemaManager = AcSqlDbSchemaManager(dataDictionaryName: dataDictionaryName);
    schemaManager.dao = dao;
    schemaManager.databaseType = databaseType;
    return await schemaManager.initDatabase();
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
    final bytes = await sourceFile.readAsBytes();
    File(destinationPath).writeAsBytesSync(bytes);

    // 2. Open the destination database
    final destDao = AcSqliteDao();
    destDao.sqlConnection = AcSqlConnection(database: destinationPath);

    try {
      if(tableDefinitions != null){
        await destDao.executeStatement(statement: "PRAGMA foreign_keys = OFF;");
        // 3. Empty tables where syncToDestination is false
        for (var tableDef in tableDefinitions) {
          if (!tableDef.syncToDestination) {
            print("Deleting from database : ${tableDef.tableName}");
            await destDao.executeStatement(statement: "DELETE FROM ${tableDef.tableName}");
          }
        }

        await destDao.executeStatement(statement: "DELETE FROM ${AcSyncTables.acSyncDetails}");
        await destDao.executeStatement(statement: "DELETE FROM ${AcSyncTables.acSyncChangeLogs}");
        await destDao.executeStatement(statement: "DELETE FROM ${AcSyncTables.acSyncDeviceLogs}");
        await destDao.executeStatement(statement: "DELETE FROM ${AcSyncTables.acSyncDevices}");

        await destDao.executeStatement(statement: "PRAGMA foreign_keys = ON;");
        // 4. Perform Vacuum
        await destDao.executeStatement(statement: "VACUUM");
      }

    } finally {
    }
  }

  Future<void> provisionClientDatabase({
    required String destinationPath,
    required String clientDeviceId,
    required String serverDeviceId,
    required int serverLastLogId,
    required Map<String, dynamic> serverDeviceDetails,
  }) async {
    final destDao = AcSqliteDao();
    destDao.sqlConnection = AcSqlConnection(database: destinationPath);

    try {
      // 1. Set current device ID for the client copy
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
      await destDao.updateRow(
        tableName: AcSyncTables.acSyncDevices,
        row: {TblAcSyncDevices.lastSyncChangeLogId: serverLastLogId},
        condition: "${TblAcSyncDevices.syncDeviceId} = '$serverDeviceId'"
      );

    } finally {
    }
  }
}