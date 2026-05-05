import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

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
