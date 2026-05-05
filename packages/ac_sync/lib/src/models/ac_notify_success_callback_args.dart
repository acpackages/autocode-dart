import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import '../../ac_sync.dart';
import 'ac_sync_table_changes.dart';

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
