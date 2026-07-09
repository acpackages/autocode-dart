import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'ac_sync_table_changes.dart';

@AcReflectable()
class AcSyncChanges {
  static const String keyTableChanges = 'tableChanges';
  static const String keyLastChangeLogId = 'lastChangeLogId';

  Map<String, AcSyncTableChanges> tableChanges = {};
  int lastChangeLogId = 0;

  AcSyncChanges({
    this.tableChanges = const {},
    this.lastChangeLogId = 0,
  });

  factory AcSyncChanges.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncChanges();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncChanges fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    // Handle manual mapping of tableChanges if reflection doesn't handle Map<String, CustomModel> automatically
    if (jsonData.containsKey(keyTableChanges)) {
      var map = jsonData[keyTableChanges] as Map<String, dynamic>;
      tableChanges = {};
      map.forEach((key, value) {
        tableChanges[key] = AcSyncTableChanges.instanceFromJson(jsonData: value);
      });
    }
    return this;
  }

  Map<String, dynamic> toJson() {
    var data = AcJsonUtils.getJsonDataFromInstance(instance: this);
    data[keyTableChanges] = tableChanges.map((k, v) => MapEntry(k, v.toJson()));
    return data;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
