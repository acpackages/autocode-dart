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
    if (jsonData.containsKey(keyRowsToDelete) && jsonData[keyRowsToDelete] != null) {
      var list = jsonData[keyRowsToDelete] as List;
      rowsToDelete = list.map((v) => AcSyncTableRowChange.instanceFromJson(jsonData: Map<String, dynamic>.from(v))).toList();
    }
    if (jsonData.containsKey(keyRowsToInsert) && jsonData[keyRowsToInsert] != null) {
      var list = jsonData[keyRowsToInsert] as List;
      rowsToInsert = list.map((v) => AcSyncTableRowChange.instanceFromJson(jsonData: Map<String, dynamic>.from(v))).toList();
    }
    if (jsonData.containsKey(keyRowsToUpdate) && jsonData[keyRowsToUpdate] != null) {
      var list = jsonData[keyRowsToUpdate] as List;
      rowsToUpdate = list.map((v) => AcSyncTableRowChange.instanceFromJson(jsonData: Map<String, dynamic>.from(v))).toList();
    }
    return this;
  }

  Map<String, dynamic> toJson() {
    var data = AcJsonUtils.getJsonDataFromInstance(instance: this);
    data[keyRowsToDelete] = rowsToDelete.map((v) => v.toJson()).toList();
    data[keyRowsToInsert] = rowsToInsert.map((v) => v.toJson()).toList();
    data[keyRowsToUpdate] = rowsToUpdate.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
