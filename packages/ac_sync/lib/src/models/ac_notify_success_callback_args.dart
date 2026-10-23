import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcNotifySuccessCallbackArgs {
  static const String keyLastSyncChangeLogId = 'lastSyncChangeLogId';
  static const String keyDeviceId = 'deviceId';

  int? lastSyncChangeLogId;
  String? deviceId = "";

  AcNotifySuccessCallbackArgs({
    this.lastSyncChangeLogId,
    this.deviceId
  });

  factory AcNotifySuccessCallbackArgs.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcNotifySuccessCallbackArgs();
    return instance.fromJson(jsonData: jsonData);
  }

  AcNotifySuccessCallbackArgs fromJson({Map<String, dynamic> jsonData = const {}}) {
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
