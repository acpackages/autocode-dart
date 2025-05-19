import 'dart:convert';
import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';

class AcDDViewColumn {
  static const String KEY_COLUMN_NAME = "column_name";
  static const String KEY_COLUMN_PROPERTIES = "column_properties";
  static const String KEY_COLUMN_TYPE = "column_type";
  static const String KEY_COLUMN_VALUE = "column_value";
  static const String KEY_COLUMN_SOURCE = "column_source";
  static const String KEY_COLUMN_SOURCE_NAME = "column_source_name";

  @AcBindJsonProperty(key: KEY_COLUMN_NAME)
  String columnName = "";

  @AcBindJsonProperty(key: KEY_COLUMN_PROPERTIES)
  Map<String, AcDDTableColumnProperty> columnProperties = {};

  @AcBindJsonProperty(key: KEY_COLUMN_TYPE)
  String columnType = "text";

  @AcBindJsonProperty(key: KEY_COLUMN_VALUE)
  dynamic columnValue;

  @AcBindJsonProperty(key: KEY_COLUMN_SOURCE)
  String columnSource = "";

  @AcBindJsonProperty(key: KEY_COLUMN_SOURCE_NAME)
  String columnSourceName = "";

  AcDDViewColumn();

  static AcDDViewColumn instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDViewColumn();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcDDViewColumn fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (json.containsKey(KEY_COLUMN_PROPERTIES)) {
      final props = json[KEY_COLUMN_PROPERTIES] as Map<String, dynamic>;
      for (final entry in props.entries) {
        columnProperties[entry.key] = AcDDTableColumnProperty.instanceFromJson(jsonData:entry.value);
      }
      json.remove(KEY_COLUMN_PROPERTIES);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: json);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }
}