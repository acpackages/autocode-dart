import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcApiDocHeader {
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_REQUIRED = 'required';
  static const String KEY_DEPRECATED = 'deprecated';
  static const String KEY_SCHEMA = 'schema';

  String description = '';
  bool required = false;
  bool deprecated = false;
  Map<String, dynamic> schema = {};

  static AcApiDocHeader instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocHeader();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocHeader fromJson({required Map<String, dynamic> jsonData}) {
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
