abstract class AcSyncProvider {
  /// Unique identifier of the provider or the target (e.g. database, a specific folder/file, etc.)
  String get targetId;

  /// Gets the current checkpoint/state of this provider.
  Future<dynamic> getCurrentCheckpoint();

  /// Gets changes from the provider since the given checkpoint up to a target checkpoint.
  /// Returns a batch payload and the next checkpoint.
  Future<AcSyncBatch> getChanges(dynamic fromCheckpoint, dynamic targetCheckpoint);

  /// Applies incoming changes (payload) to the provider.
  Future<void> applyChanges(dynamic payload);

  /// Called after successful sync of changes to commit transaction.
  Future<void> commitChanges();

  /// Called on failure to rollback transaction.
  Future<void> rollbackChanges();

  /// Deletes synced rows/data if applicable.
  Future<void> deleteSyncedData(dynamic payload);
}

class AcSyncBatch {
  final dynamic payload;
  final dynamic nextCheckpoint;
  final bool hasMore;

  AcSyncBatch({
    required this.payload,
    required this.nextCheckpoint,
    required this.hasMore,
  });

  Map<String, dynamic> toJson() {
    return {
      'payload': payload,
      'nextCheckpoint': nextCheckpoint,
      'hasMore': hasMore,
    };
  }
}
