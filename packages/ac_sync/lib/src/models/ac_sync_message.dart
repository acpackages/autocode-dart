import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcSyncMessage {
  String protocolVersion = "1.0";
  String messageType = ""; // InitializeSession, SessionAccepted, RequestChanges, PushChanges, Acknowledge, ResumeSession, CompleteSession, CancelSession, Heartbeat, Error
  String sessionIdentifier = "";
  String stream = ""; // incoming, outgoing
  Map<String, dynamic> payload = {};
  Map<String, dynamic> metadata = {};
  String timestamp = "";

  AcSyncMessage({
    this.protocolVersion = "1.0",
    this.messageType = "",
    this.sessionIdentifier = "",
    this.stream = "",
    this.payload = const {},
    this.metadata = const {},
    this.timestamp = "",
  }) {
    if (this.timestamp.isEmpty) {
      this.timestamp = DateTime.now().toIso8601String();
    }
  }

  factory AcSyncMessage.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncMessage();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncMessage fromJson({Map<String, dynamic> jsonData = const {}}) {
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
