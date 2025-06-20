import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcWebRequest {
  static const String KEY_COOKIES = 'cookies';
  static const String KEY_BODY = 'body';
  static const String KEY_FILES = 'files';
  static const String KEY_GET = 'get';
  static const String KEY_HEADERS = 'headers';
  static const String KEY_METHOD = 'method';
  static const String KEY_PATH_PAREMETERS = 'path_parameters';
  static const String KEY_POST = 'post';
  static const String KEY_SESSION = 'session';
  static const String KEY_URL = 'url';

  Map<String, dynamic> body = {};
  Map<String, dynamic> cookies = {};
  Map<String, dynamic> files = {};
  Map<String, dynamic> get = {};
  Map<String, dynamic> headers = {};
  String method = "";
  Map<String, dynamic> pathParameters = {};
  Map<String, dynamic> post = {};
  Map<String, dynamic> session = {};
  String url = "";

  static AcWebRequest instanceFromJson(Map<String, dynamic> jsonData) {
    final instance = AcWebRequest();
    instance.fromJson(jsonData);
    return instance;
  }

  AcWebRequest fromJson(Map<String, dynamic> jsonData) {
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
