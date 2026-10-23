import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import '../../ac_sync.dart';

@AcReflectable()
class AcNotifyChangesToSourceFunArgs {
  static const String keyChanges = 'changes';
  static const String keyLastSyncChangeLogId = 'lastSyncChangeLogId';
  static const String keyDeviceId = 'deviceId';

  AcSyncChanges? changes;
  int? lastSyncChangeLogId;
  String? deviceId = "";
  String? startTimestamp = "";

  @AcBindJsonProperty(skipInToJson: true,skipInFromJson: true)
  Future<void> Function(AcNotifyChangesCallbackArgs)? notifyCallback;

  AcNotifyChangesToSourceFunArgs({
    this.changes,
    this.lastSyncChangeLogId,
    this.deviceId,
    this.notifyCallback,
    this.startTimestamp
  });

  factory AcNotifyChangesToSourceFunArgs.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcNotifyChangesToSourceFunArgs();
    return instance.fromJson(jsonData: jsonData);
  }

  AcNotifyChangesToSourceFunArgs fromJson({Map<String, dynamic> jsonData = const {}}) {
    changes = AcJsonUtils.deserializeValue<AcSyncChanges>(
      jsonData[keyChanges] ?? jsonData['changes'],
      fromJson: (data) => AcSyncChanges.instanceFromJson(jsonData: data),
      defaultValue: changes,
    );
    lastSyncChangeLogId = AcJsonUtils.deserializeValue<int>(
      jsonData[keyLastSyncChangeLogId] ?? jsonData['last_sync_change_log_id'],
      defaultValue: lastSyncChangeLogId,
    );
    deviceId = AcJsonUtils.deserializeValue<String>(
      jsonData[keyDeviceId] ?? jsonData['device_id'],
      defaultValue: deviceId,
    );
    startTimestamp = AcJsonUtils.deserializeValue<String>(
      jsonData['startTimestamp'] ?? jsonData['start_timestamp'],
      defaultValue: startTimestamp,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    if (changes != null) {
      data[keyChanges] = AcJsonUtils.serializeValue(changes);
    }
    if (lastSyncChangeLogId != null) {
      data[keyLastSyncChangeLogId] = lastSyncChangeLogId;
    }
    if (deviceId != null) {
      data[keyDeviceId] = deviceId;
    }
    if (startTimestamp != null) {
      data['startTimestamp'] = startTimestamp;
    }
    return data;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
