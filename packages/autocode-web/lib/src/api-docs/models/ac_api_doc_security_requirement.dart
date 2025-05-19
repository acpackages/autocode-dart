import 'dart:convert';
import 'package:autocode/autocode.dart';

class AcApiDocSecurityRequirement {
  static const String KEY_REQUIREMENTS = 'requirements';

  List<dynamic> requirements = [];

  AcApiDocSecurityRequirement();

  static AcApiDocSecurityRequirement instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocSecurityRequirement();
    return instance.fromJson(jsonData:jsonData);
  }

  AcApiDocSecurityRequirement fromJson({required Map<String, dynamic> jsonData}) {
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
