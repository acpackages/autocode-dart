import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_extensions/ac_extensions.dart';

@AcReflectable()
class AcSyncSessionState {
  String syncIdentifier = "";
  String clientIdentifier = "";
  String protocolVersion = "1.0";
  String status = ""; // INITIALIZING, RUNNING, COMPLETED, CANCELLED, EXPIRED
  
  dynamic incomingCheckpoint;
  dynamic incomingTargetCheckpoint;
  bool incomingCompleted = false;

  dynamic outgoingCheckpoint;
  dynamic outgoingTargetCheckpoint;
  bool outgoingCompleted = false;

  Map<String, dynamic> metadata = {};
  String createdAt = "";
  String updatedAt = "";
  String lastActivityAt = "";
  String expiresAt = "";

  AcSyncSessionState({
    this.syncIdentifier = "",
    this.clientIdentifier = "",
    this.protocolVersion = "1.0",
    this.status = "INITIALIZING",
    this.incomingCheckpoint,
    this.incomingTargetCheckpoint,
    this.incomingCompleted = false,
    this.outgoingCheckpoint,
    this.outgoingTargetCheckpoint,
    this.outgoingCompleted = false,
    this.metadata = const {},
    this.createdAt = "",
    this.updatedAt = "",
    this.lastActivityAt = "",
    this.expiresAt = "",
  }) {
    var now = DateTime.now().toUtcIso8601String();
    if (this.createdAt.isEmpty) this.createdAt = now;
    if (this.updatedAt.isEmpty) this.updatedAt = now;
    if (this.lastActivityAt.isEmpty) this.lastActivityAt = now;
    if (this.expiresAt.isEmpty) {
      // Default to 24 hours expiry
      this.expiresAt = DateTime.now().add(Duration(hours: 24)).toUtcIso8601String();
    }
  }

  factory AcSyncSessionState.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncSessionState();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncSessionState fromJson({Map<String, dynamic> jsonData = const {}}) {
    syncIdentifier = AcJsonUtils.deserializeValue<String>(
      jsonData['syncIdentifier'] ?? jsonData['sync_identifier'],
      defaultValue: syncIdentifier,
    )!;
    clientIdentifier = AcJsonUtils.deserializeValue<String>(
      jsonData['clientIdentifier'] ?? jsonData['client_identifier'],
      defaultValue: clientIdentifier,
    )!;
    protocolVersion = AcJsonUtils.deserializeValue<String>(
      jsonData['protocolVersion'] ?? jsonData['protocol_version'],
      defaultValue: protocolVersion,
    )!;
    status = AcJsonUtils.deserializeValue<String>(
      jsonData['status'],
      defaultValue: status,
    )!;
    if (jsonData.containsKey('incomingCheckpoint') || jsonData.containsKey('incoming_checkpoint')) {
      incomingCheckpoint = jsonData['incomingCheckpoint'] ?? jsonData['incoming_checkpoint'];
    }
    if (jsonData.containsKey('incomingTargetCheckpoint') || jsonData.containsKey('incoming_target_checkpoint')) {
      incomingTargetCheckpoint = jsonData['incomingTargetCheckpoint'] ?? jsonData['incoming_target_checkpoint'];
    }
    incomingCompleted = AcJsonUtils.deserializeValue<bool>(
      jsonData['incomingCompleted'] ?? jsonData['incoming_completed'],
      defaultValue: incomingCompleted,
    )!;
    if (jsonData.containsKey('outgoingCheckpoint') || jsonData.containsKey('outgoing_checkpoint')) {
      outgoingCheckpoint = jsonData['outgoingCheckpoint'] ?? jsonData['outgoing_checkpoint'];
    }
    if (jsonData.containsKey('outgoingTargetCheckpoint') || jsonData.containsKey('outgoing_target_checkpoint')) {
      outgoingTargetCheckpoint = jsonData['outgoingTargetCheckpoint'] ?? jsonData['outgoing_target_checkpoint'];
    }
    outgoingCompleted = AcJsonUtils.deserializeValue<bool>(
      jsonData['outgoingCompleted'] ?? jsonData['outgoing_completed'],
      defaultValue: outgoingCompleted,
    )!;
    if (jsonData.containsKey('metadata') && jsonData['metadata'] is Map) {
      metadata = Map<String, dynamic>.from(jsonData['metadata'] as Map);
    }
    createdAt = AcJsonUtils.deserializeValue<String>(
      jsonData['createdAt'] ?? jsonData['created_at'],
      defaultValue: createdAt,
    )!;
    updatedAt = AcJsonUtils.deserializeValue<String>(
      jsonData['updatedAt'] ?? jsonData['updated_at'],
      defaultValue: updatedAt,
    )!;
    lastActivityAt = AcJsonUtils.deserializeValue<String>(
      jsonData['lastActivityAt'] ?? jsonData['last_activity_at'],
      defaultValue: lastActivityAt,
    )!;
    expiresAt = AcJsonUtils.deserializeValue<String>(
      jsonData['expiresAt'] ?? jsonData['expires_at'],
      defaultValue: expiresAt,
    )!;
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      'syncIdentifier': syncIdentifier,
      'clientIdentifier': clientIdentifier,
      'protocolVersion': protocolVersion,
      'status': status,
      'incomingCheckpoint': AcJsonUtils.serializeValue(incomingCheckpoint),
      'incomingTargetCheckpoint': AcJsonUtils.serializeValue(incomingTargetCheckpoint),
      'incomingCompleted': incomingCompleted,
      'outgoingCheckpoint': AcJsonUtils.serializeValue(outgoingCheckpoint),
      'outgoingTargetCheckpoint': AcJsonUtils.serializeValue(outgoingTargetCheckpoint),
      'outgoingCompleted': outgoingCompleted,
      'metadata': AcJsonUtils.serializeValue(metadata),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastActivityAt': lastActivityAt,
      'expiresAt': expiresAt,
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
