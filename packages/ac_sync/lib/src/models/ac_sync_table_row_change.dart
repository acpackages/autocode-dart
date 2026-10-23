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
    operation = AcJsonUtils.deserializeValue<String>(
      jsonData[keyOperation] ?? jsonData['operation'],
      defaultValue: operation,
    )!;
    if (jsonData.containsKey(keyRowDetail) || jsonData.containsKey('row_detail') || jsonData.containsKey('row')) {
      final r = jsonData[keyRowDetail] ?? jsonData['row_detail'] ?? jsonData['row'];
      if (r is Map) {
        row = Map<String, dynamic>.from(r);
      }
    }
    rowId = AcJsonUtils.deserializeValue<String>(
      jsonData[keyRowId] ?? jsonData['row_id'],
      defaultValue: rowId,
    );
    timestamp = AcJsonUtils.deserializeValue<DateTime>(
      jsonData[keyTimestamp] ?? jsonData['timestamp'],
      defaultValue: timestamp,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{
      keyOperation: operation,
    };
    if (timestamp != null) {
      data[keyTimestamp] = AcJsonUtils.serializeValue(timestamp);
    }
    if (row != null) {
      data[keyRowDetail] = AcJsonUtils.serializeValue(row);
    }
    if (rowId != null) {
      data[keyRowId] = rowId;
    }
    return data;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
