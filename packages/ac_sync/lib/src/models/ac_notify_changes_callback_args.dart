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
