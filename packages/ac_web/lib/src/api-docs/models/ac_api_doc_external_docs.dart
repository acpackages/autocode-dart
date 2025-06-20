import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcApiDocExternalDocs {
  static const String KEY_DESCRIPTION = "description";
  static const String KEY_URL = "url";

  String description = "";
  String url = "";

  static AcApiDocExternalDocs instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocExternalDocs();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocExternalDocs fromJson({required Map<String, dynamic> jsonData}) {
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
