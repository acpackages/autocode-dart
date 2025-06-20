import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcApiDocSchema {
  static const String KEY_TYPE = 'type';
  static const String KEY_FORMAT = 'format';
  static const String KEY_TITLE = 'title';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_PROPERTIES = 'properties';
  static const String KEY_REQUIRED = 'required';
  static const String KEY_ITEMS = 'items';
  static const String KEY_ENUM = 'enum';

  String? type;
  String? format;
  String? title;
  String? description;
  Map<String, dynamic>? properties;
  List<String>? required;
  dynamic items; // can be Map or List or other schema
  List<dynamic>? enumValues;

  AcApiDocSchema();

  static AcApiDocSchema instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocSchema();
    return instance.fromJson(jsonData:jsonData);
  }

  AcApiDocSchema fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
