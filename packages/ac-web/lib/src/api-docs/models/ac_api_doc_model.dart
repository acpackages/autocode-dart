import 'dart:convert';
import 'package:autocode/autocode.dart';

class AcApiDocModel {
  static const String KEY_NAME = 'name';
  static const String KEY_TYPE = 'type';
  static const String KEY_PROPERTIES = 'properties';

  String name = '';
  String type = 'object';
  Map<String, dynamic> properties = {};

  static AcApiDocModel instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocModel();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocModel fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
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
