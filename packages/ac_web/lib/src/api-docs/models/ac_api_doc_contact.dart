import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcApiDocContact {
  static const String KEY_EMAIL = "email";
  static const String KEY_NAME = "name";
  static const String KEY_URL = "url";

  String email = "";
  String name = "";
  String url = "";

  static AcApiDocContact instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocContact();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocContact fromJson({required Map<String, dynamic> jsonData}) {
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
