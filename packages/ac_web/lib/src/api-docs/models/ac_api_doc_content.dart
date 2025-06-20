import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcApiDocContent {
  static const String KEY_SCHEMA = 'schema';
  static const String KEY_EXAMPLES = 'examples';
  static const String KEY_ENCODING = 'encoding';

  Map<String, dynamic> schema = {};
  Map<String, dynamic> examples = {};
  String encoding = "";

  AcApiDocContent({this.encoding = "",this.schema = const {},this.examples = const{}});

  static AcApiDocContent instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocContent();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocContent fromJson({Map<String, dynamic> jsonData = const {}}) {
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
