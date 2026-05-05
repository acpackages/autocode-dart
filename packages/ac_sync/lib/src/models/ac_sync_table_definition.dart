import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcSyncTableDefinition {
  static const String keyTableName = 'tableName';
  static const String keyPrimaryKeyField = 'primaryKeyField';
  static const String keySyncToDestination = 'syncToDestination';
  static const String keySyncToSource = 'syncToSource';


  String tableName = "";
  String primaryKeyField = "";
  bool syncToSource = false;
  bool syncToDestination = false;

  AcSyncTableDefinition({
    this.tableName = "",
    this.primaryKeyField = "",
    this.syncToDestination = false,
    this.syncToSource = false
  });

  factory AcSyncTableDefinition.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncTableDefinition();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncTableDefinition fromJson({Map<String, dynamic> jsonData = const {}}) {
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
