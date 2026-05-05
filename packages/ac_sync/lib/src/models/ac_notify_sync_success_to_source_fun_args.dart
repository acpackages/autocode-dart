import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'ac_notify_success_callback_args.dart';

@AcReflectable()
class AcNotifySyncSuccessToSourceFunArgs {
  static const String keyLastSyncChangeLogId = 'lastSyncChangeLogId';
  static const String keyDeviceId = 'deviceId';

  int? lastSyncChangeLogId;
  String? deviceId = "";
  String? endTimestamp = "";

  @AcBindJsonProperty(skipInToJson: true,skipInFromJson: true)
  Future<void> Function(AcNotifySuccessCallbackArgs)? notifyCallback;

  AcNotifySyncSuccessToSourceFunArgs({
    this.lastSyncChangeLogId,
    this.deviceId,
    this.notifyCallback,
    this.endTimestamp
  });

  factory AcNotifySyncSuccessToSourceFunArgs.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcNotifySyncSuccessToSourceFunArgs();
    return instance.fromJson(jsonData: jsonData);
  }

  AcNotifySyncSuccessToSourceFunArgs fromJson({Map<String, dynamic> jsonData = const {}}) {
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
