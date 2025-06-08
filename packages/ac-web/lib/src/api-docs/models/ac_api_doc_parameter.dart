import 'dart:convert';
import 'package:autocode/autocode.dart';

class AcApiDocParameter {
  static const String KEY_DESCRIPTION = "description";
  static const String KEY_EXPLODE = "explode";
  static const String KEY_IN = "in";
  static const String KEY_NAME = "name";
  static const String KEY_REQUIRED = "required";
  static const String KEY_SCHEMA = "schema";

  String? description;
  @AcBindJsonProperty(key: KEY_IN)
  String? inValue;
  String? name;
  bool required = false;
  bool explode = true;
  Map<String, dynamic>? schema;

  AcApiDocParameter();

  static AcApiDocParameter instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocParameter();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocParameter fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (json.containsKey(KEY_IN)) {
      inValue = json[KEY_IN] as String?;
      json.remove(KEY_IN);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: json);
    return this;
  }

  Map<String, dynamic> toJson() {
    final json = AcJsonUtils.getJsonDataFromInstance(instance: this);
    if (inValue != null) {
      json[KEY_IN] = inValue;
    }
    return json;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
