import 'dart:convert';
import 'package:autocode/autocode.dart';

class AcApiDocLink {
  static const String KEY_OPERATION_ID = 'operationId';
  static const String KEY_PARAMETERS = 'parameters';
  static const String KEY_DESCRIPTION = 'description';

  @AcBindJsonProperty(key: KEY_OPERATION_ID)
  String operationId = '';
  List<dynamic> parameters = [];
  String description = '';

  static AcApiDocLink instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocLink();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocLink fromJson({required Map<String, dynamic> jsonData}) {
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
