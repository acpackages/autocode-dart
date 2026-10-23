import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_extensions/ac_extensions.dart';

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
      this.timestamp = DateTime.now().toUtcIso8601String();
    }
  }

  factory AcSyncMessage.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncMessage();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncMessage fromJson({Map<String, dynamic> jsonData = const {}}) {
    protocolVersion = AcJsonUtils.deserializeValue<String>(
      jsonData['protocolVersion'] ?? jsonData['protocol_version'],
      defaultValue: protocolVersion,
    )!;
    messageType = AcJsonUtils.deserializeValue<String>(
      jsonData['messageType'] ?? jsonData['message_type'],
      defaultValue: messageType,
    )!;
    sessionIdentifier = AcJsonUtils.deserializeValue<String>(
      jsonData['sessionIdentifier'] ?? jsonData['session_identifier'],
      defaultValue: sessionIdentifier,
    )!;
    stream = AcJsonUtils.deserializeValue<String>(jsonData['stream'], defaultValue: stream)!;
    if (jsonData['payload'] is Map) {
      payload = Map<String, dynamic>.from(jsonData['payload'] as Map);
    }
    if (jsonData['metadata'] is Map) {
      metadata = Map<String, dynamic>.from(jsonData['metadata'] as Map);
    }
    timestamp = AcJsonUtils.deserializeValue<String>(jsonData['timestamp'], defaultValue: timestamp)!;
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      'protocolVersion': protocolVersion,
      'messageType': messageType,
      'sessionIdentifier': sessionIdentifier,
      'stream': stream,
      'payload': AcJsonUtils.serializeValue(payload),
      'metadata': AcJsonUtils.serializeValue(metadata),
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
