import '../../ac_sync.dart';
import './ac_sync_provider.dart';

class AcSyncDatabaseProvider implements AcSyncProvider {
  final AcSyncDatabase database;
  
  AcSyncDatabaseProvider(this.database);

  @override
  String get targetId => "database";

  @override
  Future<dynamic> getCurrentCheckpoint() async {
    final result = await database.getLastChangeLogId();
    if (result.isSuccess()) {
      return result.value ?? 0;
    }
    return 0;
  }

  @override
  Future<AcSyncBatch> getChanges(dynamic fromCheckpoint, dynamic targetCheckpoint) async {
    int from = _toInt(fromCheckpoint);
    int target = _toInt(targetCheckpoint);
    
    final result = await database.getSyncChanges(lastSyncId: from);
    if (result.isSuccess()) {
      final changes = result.value as AcSyncChanges;
      final nextCheckpoint = changes.lastChangeLogId;
      final hasMore = nextCheckpoint < target;
      return AcSyncBatch(
        payload: changes.toJson(),
        nextCheckpoint: nextCheckpoint,
        hasMore: hasMore,
      );
    }
    throw Exception("Failed to get database changes: ${result.message}");
  }

  @override
  Future<void> applyChanges(dynamic payload) async {
    if (database.dao != null) {
      await database.dao!.executeStatement(statement: "BEGIN TRANSACTION;");
    }
    try {
      final changesMap = Map<String, dynamic>.from(payload as Map);
      final changes = AcSyncChanges.instanceFromJson(jsonData: changesMap);
      final result = await database.applySyncChanges(changes: changes);
      if (result.isFailure()) {
        throw Exception(result.message);
      }
    } catch (e) {
      await rollbackChanges();
      rethrow;
    }
  }

  @override
  Future<void> commitChanges() async {
    if (database.dao != null) {
      await database.dao!.executeStatement(statement: "COMMIT;");
    }
  }

  @override
  Future<void> rollbackChanges() async {
    if (database.dao != null) {
      try {
        await database.dao!.executeStatement(statement: "ROLLBACK;");
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteSyncedData(dynamic payload) async {
    final changesMap = Map<String, dynamic>.from(payload as Map);
    final changes = AcSyncChanges.instanceFromJson(jsonData: changesMap);
    await database.deleteSyncedRows(changes: changes);
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
