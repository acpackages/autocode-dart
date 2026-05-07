import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

import '../../ac_sync.dart';

@AcReflectable()
class AcSyncTableChanges {
  static const String keyTableName = 'tableName';
  static const String keyRowsToDelete = 'rowsToDelete';
  static const String keyRowsToInsert = 'rowsToInsert';
  static const String keyRowsToUpdate = 'rowsToUpdate';

  String tableName = "";
  List<AcSyncTableRowChange> rowsToDelete = List.empty(growable: true);
  List<AcSyncTableRowChange> rowsToInsert = List.empty(growable: true);
  List<AcSyncTableRowChange> rowsToUpdate = List.empty(growable: true);

  AcSyncTableChanges({
    this.tableName = "",
    List<AcSyncTableRowChange>? rowsToDelete,
    List<AcSyncTableRowChange>? rowsToInsert,
    List<AcSyncTableRowChange>? rowsToUpdate,
  }){
    if(rowsToDelete != null){
      this.rowsToDelete = rowsToDelete;
    }
    if(rowsToInsert != null){
      this.rowsToInsert = rowsToInsert;
    }
    if(rowsToUpdate != null){
      this.rowsToUpdate = rowsToUpdate;
    }
  }

  factory AcSyncTableChanges.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncTableChanges();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncTableChanges fromJson({Map<String, dynamic> jsonData = const {}}) {
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
