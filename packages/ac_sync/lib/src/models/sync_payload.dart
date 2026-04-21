/// Represents a single entry in the Global Sync Map.
class SyncMapChange {
  final int t; // The unique transaction ID (BigInt)
  final String tableName; // e.g., 'customers'
  final String recordUuid; // The primary key
  final int operation; // 1: Upsert, 2: Delete

  // The actual data payload (hydrated during the pull process)
  Map<String, dynamic>? data;

  SyncMapChange({
    required this.t,
    required this.tableName,
    required this.recordUuid,
    required this.operation,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    't': t,
    'tableName': tableName,
    'recordUuid': recordUuid,
    'operation': operation,
    'data': data,
  };

  factory SyncMapChange.fromJson(Map<String, dynamic> json) => SyncMapChange(
    t: json['t'],
    tableName: json['tableName'],
    recordUuid: json['recordUuid'],
    operation: json['operation'],
    data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
  );
}

/// The envelope sent between device and server for T-based sync.
class SyncPayload {
  final String sourceDeviceId;
  final List<SyncMapChange> changes;
  final int lastT; // The highest T in this payload

  SyncPayload({
    required this.sourceDeviceId,
    required this.changes,
    required this.lastT,
  });

  Map<String, dynamic> toJson() => {
    'sourceDeviceId': sourceDeviceId,
    'changes': changes.map((e) => e.toJson()).toList(),
    'lastT': lastT,
  };

  factory SyncPayload.fromJson(Map<String, dynamic> json) => SyncPayload(
    sourceDeviceId: json['sourceDeviceId'],
    changes: (json['changes'] as List).map((e) => SyncMapChange.fromJson(e)).toList(),
    lastT: json['lastT'],
  );
}
