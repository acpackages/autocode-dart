import 'dart:convert';
import 'package:autocode/autocode.dart';

class AcApiDocMediaType {
  static const String KEY_SCHEMA = 'schema';
  static const String KEY_EXAMPLES = 'examples';

  List<dynamic>? schema;
  List<dynamic>? examples;

  static AcApiDocMediaType instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocMediaType();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocMediaType fromJson({required Map<String, dynamic> jsonData}) {
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
