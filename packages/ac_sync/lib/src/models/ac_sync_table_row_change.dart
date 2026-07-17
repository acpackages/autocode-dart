import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_extensions/ac_extensions.dart';

@AcReflectable()
class AcSyncTableRowChange {
  static const String keyOperation = 'operation';
  static const String keyTimestamp = 'timestamp';
  static const String keyRowId = 'rowId';
  static const String keyRowDetail = 'row';

  String operation = "";
  DateTime? timestamp;
  Map<String, dynamic>? row;
  String? rowId;

  AcSyncTableRowChange({
    this.operation = "",
    this.timestamp,
    this.row,
    this.rowId
  });

  factory AcSyncTableRowChange.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncTableRowChange();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncTableRowChange fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    if (jsonData.containsKey(keyTimestamp) && jsonData[keyTimestamp] is String) {
      timestamp = DateTime.tryParse(jsonData[keyTimestamp] as String);
    }
    return this;
  }

  Map<String, dynamic> toJson() {
    var data = AcJsonUtils.getJsonDataFromInstance(instance: this);
    if (timestamp != null) {
      data[keyTimestamp] = timestamp!.toUtcIso8601String();
    }
    return data;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
