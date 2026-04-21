import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'engine/sync_engine.dart';

/// Base class for synchronization configuration and state.
class AcSync {
  final AcDataDictionary dictionary;
  final AcBaseSqlDao dao;
  final String deviceId;
  late final SyncEngine engine;

  AcSync({
    required this.dictionary,
    required this.dao,
    required this.deviceId,
  }) {
    engine = SyncEngine(
      dao: dao,
      dictionary: dictionary,
      deviceId: deviceId,
    );
  }

  /// Initialize synchronization for the current database context.
  Future<void> initialize() async {
    // Logic to ensure tracking columns exist in syncable tables.
    print('Initializing ac_sync with dictionary: ${dictionary.name}');
    
    // 1. Identify syncable tables from dictionary
    final syncableTables = _getSyncableTables();
    
    // 2. TODO: Ensure tracking columns (ac_sync_id, ac_last_modified) exist in DB
    // This would use ac_sql to alter tables if needed.
  }

  List<AcDDTable> _getSyncableTables() {
    // For now, assume all tables are syncable if they have a primary key
    // In future, check for a 'SYNCABLE' property in AcDDTable
    return dictionary.tables;
  }
}
