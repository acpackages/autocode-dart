import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import '../../ac_sync.dart';

@AcReflectable()
class AcNotifyChangesCallbackArgs {
  static const String keySourceChanges = 'sourceChanges';
  static const String keyLastSyncChangeLogId = 'lastSyncChangeLogId';
  static const String keyDeviceId = 'deviceId';

  AcSyncChanges? sourceChanges;
  int? lastSyncChangeLogId;
  String? deviceId = "";

  AcNotifyChangesCallbackArgs({
    this.sourceChanges,
    this.lastSyncChangeLogId,
    this.deviceId
  });

  factory AcNotifyChangesCallbackArgs.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcNotifyChangesCallbackArgs();
    return instance.fromJson(jsonData: jsonData);
  }

  AcNotifyChangesCallbackArgs fromJson({Map<String, dynamic> jsonData = const {}}) {
    sourceChanges = AcJsonUtils.deserializeValue<AcSyncChanges>(
      jsonData[keySourceChanges] ?? jsonData['source_changes'],
      fromJson: (data) => AcSyncChanges.instanceFromJson(jsonData: data),
      defaultValue: sourceChanges,
    );
    lastSyncChangeLogId = AcJsonUtils.deserializeValue<int>(
      jsonData[keyLastSyncChangeLogId] ?? jsonData['last_sync_change_log_id'],
      defaultValue: lastSyncChangeLogId,
    );
    deviceId = AcJsonUtils.deserializeValue<String>(
      jsonData[keyDeviceId] ?? jsonData['device_id'],
      defaultValue: deviceId,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    if (sourceChanges != null) {
      data[keySourceChanges] = AcJsonUtils.serializeValue(sourceChanges);
    }
    if (lastSyncChangeLogId != null) {
      data[keyLastSyncChangeLogId] = lastSyncChangeLogId;
    }
    if (deviceId != null) {
      data[keyDeviceId] = deviceId;
    }
    return data;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
