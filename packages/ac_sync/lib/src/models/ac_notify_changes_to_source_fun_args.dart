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
