import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';

class AcDDConditionGroup {
  static const String KEY_DATABASE_TYPE = "database_type";
  static const String KEY_CONDITIONS = "conditions";
  static const String KEY_OPERATOR = "operator";

  @AcBindJsonProperty(key: KEY_DATABASE_TYPE)
  String databaseType = "";

  List<dynamic> conditions = [];
  String operator = "";

  AcDDConditionGroup();

  factory AcDDConditionGroup.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDConditionGroup();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcDDConditionGroup addCondition({required String columnName, required String operator, required dynamic value}) {
    conditions.add(AcDDCondition.instanceFromJson(jsonData:{
      AcDDCondition.KEY_COLUMN_NAME: columnName,
      AcDDCondition.KEY_OPERATOR: operator,
      AcDDCondition.KEY_VALUE: value,
    }));
    return this;
  }

  AcDDConditionGroup addConditionGroup({required List<dynamic> conditions, String operator = 'AND'}) {
    this.conditions.add(AcDDConditionGroup.instanceFromJson(jsonData:{
      AcDDConditionGroup.KEY_CONDITIONS: conditions,
      AcDDConditionGroup.KEY_OPERATOR: operator,
    }));
    return this;
  }

  AcDDConditionGroup fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (json.containsKey(KEY_CONDITIONS)) {
      for (var condition in json[KEY_CONDITIONS]) {
        if (condition is Map<String, dynamic>) {
          if (condition.containsKey(KEY_CONDITIONS)) {
            conditions.add(AcDDConditionGroup.instanceFromJson(jsonData:condition));
          } else if (condition.containsKey(AcDDCondition.KEY_COLUMN_NAME)) {
            conditions.add(AcDDCondition.instanceFromJson(jsonData:condition));
          }
        } else {
          conditions.add(condition);
        }
      }
      json.remove(KEY_CONDITIONS);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(instance:this, jsonData:json);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance:this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
