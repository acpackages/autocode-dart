import 'dart:convert';

import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

class AcWebRouteDefinition {
  static const String KEY_CONTROLLER = 'controller';
  static const String KEY_HANDLER = 'handler';
  static const String KEY_DOCUMENTATION = 'documentation';
  static const String KEY_METHOD = 'method';
  static const String KEY_URL = 'url';

  dynamic controller;
  dynamic handler;
  late AcApiDocRoute documentation;
  String method = "POST";
  String url = "";

  static AcWebRouteDefinition instanceFromJson(Map<String, dynamic> jsonData) {
    final instance = AcWebRouteDefinition();
    instance.fromJson(jsonData);
    return instance;
  }

  AcWebRouteDefinition fromJson(Map<String, dynamic> jsonData) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
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
