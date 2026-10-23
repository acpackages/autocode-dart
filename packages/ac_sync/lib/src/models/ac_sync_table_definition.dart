import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcSyncTableDefinition {
  static const String keyTableName = 'tableName';
  static const String keyPrimaryKeyField = 'primaryKeyField';
  static const String keySyncToDestination = 'syncToDestination';
  static const String keySyncToSource = 'syncToSource';
  static const String keyColumnsToSync = 'columnsToSync';
  static const String keyDeleteAfterSyncFromDestination = 'deleteAfterSyncFromDestination';


  String tableName = "";
  String primaryKeyField = "";
  bool syncToSource = false;
  bool syncToDestination = false;
  List<String> columnsToSync = [];
  bool deleteAfterSyncFromDestination = false;

  AcSyncTableDefinition({
    this.tableName = "",
    this.primaryKeyField = "",
    this.syncToDestination = false,
    this.syncToSource = false,
    this.columnsToSync = const [],
    this.deleteAfterSyncFromDestination = false,
  });

  factory AcSyncTableDefinition.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncTableDefinition();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncTableDefinition fromJson({Map<String, dynamic> jsonData = const {}}) {
    tableName = AcJsonUtils.deserializeValue<String>(
      jsonData[keyTableName] ?? jsonData['table_name'],
      defaultValue: tableName,
    )!;
    primaryKeyField = AcJsonUtils.deserializeValue<String>(
      jsonData[keyPrimaryKeyField] ?? jsonData['primary_key_field'],
      defaultValue: primaryKeyField,
    )!;
    syncToDestination = AcJsonUtils.deserializeValue<bool>(
      jsonData[keySyncToDestination] ?? jsonData['sync_to_destination'],
      defaultValue: syncToDestination,
    )!;
    syncToSource = AcJsonUtils.deserializeValue<bool>(
      jsonData[keySyncToSource] ?? jsonData['sync_to_source'],
      defaultValue: syncToSource,
    )!;
    if (jsonData.containsKey(keyColumnsToSync) || jsonData.containsKey('columns_to_sync')) {
      columnsToSync = AcJsonUtils.deserializeList<String>(
        jsonData[keyColumnsToSync] ?? jsonData['columns_to_sync'],
      );
    }
    deleteAfterSyncFromDestination = AcJsonUtils.deserializeValue<bool>(
      jsonData[keyDeleteAfterSyncFromDestination] ?? jsonData['delete_after_sync_from_destination'],
      defaultValue: deleteAfterSyncFromDestination,
    )!;
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      keyTableName: tableName,
      keyPrimaryKeyField: primaryKeyField,
      keySyncToDestination: syncToDestination,
      keySyncToSource: syncToSource,
      keyColumnsToSync: AcJsonUtils.serializeValue(columnsToSync),
      keyDeleteAfterSyncFromDestination: deleteAfterSyncFromDestination,
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
