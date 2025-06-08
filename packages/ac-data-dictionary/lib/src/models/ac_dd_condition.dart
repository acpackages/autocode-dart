
import 'package:autocode/autocode.dart';

class AcDDCondition {
  static const String KEY_DATABASE_TYPE = "database_type";
  static const String KEY_COLUMN_NAME = "column_name";
  static const String KEY_OPERATOR = "operator";
  static const String KEY_VALUE = "value";

  @AcBindJsonProperty(key: KEY_DATABASE_TYPE)
  String databaseType = "";

  @AcBindJsonProperty(key: KEY_COLUMN_NAME)
  String columnName = "";

  String operator = "";
  dynamic value;

  AcDDCondition();

  factory AcDDCondition.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDCondition();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcDDCondition fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
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
