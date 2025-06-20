import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcApiDocSecurityScheme {
  static const String KEY_TYPE = 'type';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_NAME = 'name';
  static const String KEY_IN = 'in';
  static const String KEY_SCHEME = 'scheme';
  static const String KEY_BEARER_FORMAT = 'bearerFormat';
  static const String KEY_FLOWS = 'flows';
  static const String KEY_OPENID_CONNECT_URL = 'openIdConnectUrl';

  String type = '';
  String description = '';
  String name = '';
  String in_ = '';  // `in` is a reserved word in Dart, so renamed to in_
  String scheme = '';
  String bearerFormat = '';
  List<dynamic> flows = [];
  String openIdConnectUrl = '';

  AcApiDocSecurityScheme();

  static AcApiDocSecurityScheme instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocSecurityScheme();
    return instance.fromJson(jsonData:jsonData);
  }

  AcApiDocSecurityScheme fromJson({required Map<String, dynamic> jsonData}) {
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
