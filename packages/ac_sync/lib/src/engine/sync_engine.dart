import 'package:ac_sql/ac_sql.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import '../models/sync_payload.dart';

/// The core engine responsible for orchestrating synchronization via a Single Map Table.
class SyncEngine {
  final AcBaseSqlDao dao;
  final AcDataDictionary dictionary;
  final String deviceId;

  SyncEngine({
    required this.dao,
    required this.dictionary,
    required this.deviceId,
  });

  /// Pulls changes from the global map and hydrates them with data.
  Future<SyncPayload> pullChanges({int? lastT, int limit = 500, int offset = 0}) async {
    final List<SyncMapChange> changes = [];
    
    // 1. Query the Central Map Table
    String condition = "";
    Map<String, dynamic> params = {};
    if (lastT != null) {
      condition = "WHERE sync_t > :lastT";
      params['lastT'] = lastT;
    }

    final mapResult = await dao.getRows(
      statement: "SELECT * FROM ac_sync_map $condition ORDER BY sync_t ASC LIMIT $limit OFFSET $offset",
      parameters: params,
    );

    if (mapResult.isSuccess) {
      for (var row in mapResult.rows) {
        final change = SyncMapChange(
          t: row['sync_t'],
          tableName: row['table_name'],
          recordUuid: row['record_uuid'],
          operation: row['operation'],
        );

        // 2. Hydrate data if it's an Upsert (operation == 1)
        if (change.operation == 1) {
          change.data = await _fetchRecordData(change.tableName, change.recordUuid);
        }
        
        changes.add(change);
      }
    }

    final newLastT = changes.isNotEmpty ? changes.last.t : (lastT ?? 0);

    return SyncPayload(
      sourceDeviceId: deviceId,
      changes: changes,
      lastT: newLastT,
    );
  }

  /// Appies a received payload to the local database.
  Future<void> applyPayload(SyncPayload payload) async {
    // Process in the exact order received to maintain T-based integrity
    for (var change in payload.changes) {
      if (change.operation == 1 && change.data != null) {
        await _applyUpsert(change);
      } else if (change.operation == 2) {
        await _applyDelete(change);
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchRecordData(String tableName, String uuid) async {
    // We assume the column name for the UUID primary key is 'id' 
    // This can be fetched from Data Dictionary in a real implementation
    final result = await dao.getRows(
      statement: "SELECT * FROM $tableName WHERE id = :uuid",
      parameters: {'uuid': uuid},
    );
    return result.isSuccess && result.rows.isNotEmpty ? result.rows.first : null;
  }

  Future<void> _applyUpsert(SyncMapChange change) async {
    // Perform a standard SQL UPSERT using the UUID as the key
    print('Upserting ${change.tableName} record ${change.recordUuid} (T=${change.t})');
    if (change.data != null) {
      await dao.insertRow(tableName: change.tableName, row: change.data!);
      // Note: In real scenarios, use a dedicated upsert method to handle existing records
    }
  }

  Future<void> _applyDelete(SyncMapChange change) async {
    print('Deleting ${change.tableName} record ${change.recordUuid} (T=${change.t})');
    await dao.deleteRows(
      tableName: change.tableName,
      condition: "id = :uuid",
      parameters: {'uuid': change.recordUuid},
    );
  }
}
