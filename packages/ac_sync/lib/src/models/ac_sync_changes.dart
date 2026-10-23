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
    lastChangeLogId = AcJsonUtils.deserializeValue<int>(
      jsonData[keyLastChangeLogId] ?? jsonData['last_change_log_id'],
      defaultValue: lastChangeLogId,
    )!;
    tableChanges = AcJsonUtils.deserializeMap<AcSyncTableChanges>(
      jsonData[keyTableChanges] ?? jsonData['table_changes'],
      fromJson: (data) => AcSyncTableChanges.instanceFromJson(jsonData: data),
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      keyLastChangeLogId: lastChangeLogId,
      keyTableChanges: AcJsonUtils.serializeValue(tableChanges),
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
