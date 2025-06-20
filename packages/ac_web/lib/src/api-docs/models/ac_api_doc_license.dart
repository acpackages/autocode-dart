import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcApiDocLicense {
  static const String KEY_NAME = "name";
  static const String KEY_URL = "url";

  String name = "";
  String url = "";

  static AcApiDocLicense instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocLicense();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocLicense fromJson({required Map<String, dynamic> jsonData}) {
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
