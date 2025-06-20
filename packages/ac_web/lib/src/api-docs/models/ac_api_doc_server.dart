import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcApiDocServer {
  static const String KEY_DESCRIPTION = "description";
  static const String KEY_TITLE = "title";
  static const String KEY_URL = "url";

  String description = "";
  String title = "";
  String url = "";

  AcApiDocServer({this.url = ""});

  static AcApiDocServer instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocServer();
    return instance.fromJson(jsonData:jsonData);
  }

  AcApiDocServer fromJson({required Map<String, dynamic> jsonData}) {
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
