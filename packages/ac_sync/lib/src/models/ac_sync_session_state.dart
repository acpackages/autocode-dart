import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

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
    var now = DateTime.now().toIso8601String();
    if (this.createdAt.isEmpty) this.createdAt = now;
    if (this.updatedAt.isEmpty) this.updatedAt = now;
    if (this.lastActivityAt.isEmpty) this.lastActivityAt = now;
    if (this.expiresAt.isEmpty) {
      // Default to 24 hours expiry
      this.expiresAt = DateTime.now().add(Duration(hours: 24)).toIso8601String();
    }
  }

  factory AcSyncSessionState.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncSessionState();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncSessionState fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
