import 'dart:convert';

import 'package:autocode/autocode.dart';
import 'package:autocode_web/autocode_web.dart';
class AcWebResponse {
  static const String KEY_COOKIES = 'cookies';
  static const String KEY_CONTENT = 'content';
  static const String KEY_HEADERS = 'headers';
  static const String KEY_RESPONSE_CODE = 'response_code';
  static const String KEY_RESPONSE_TYPE = 'response_type';
  static const String KEY_SESSION = 'session';

  Map<String, dynamic> cookies = {};
  dynamic content;
  Map<String, dynamic> headers = {};

  @AcBindJsonProperty(key: AcWebResponse.KEY_RESPONSE_CODE)
  int responseCode = 0;

  @AcBindJsonProperty(key: AcWebResponse.KEY_RESPONSE_TYPE)
  String responseType = AcEnumWebResponseType.TEXT;

  Map<String, dynamic> session = {};

  static AcWebResponse json({required dynamic data, int responseCode = AcEnumHttpResponseCode.OK}) {
    final response = AcWebResponse();
    response.responseCode = responseCode;
    response.responseType = AcEnumWebResponseType.JSON;
    response.content = data;
    response.headers['Content-Type'] = 'application/json';
    return response;
  }

  static AcWebResponse notFound() {
    final response = AcWebResponse();
    response.responseCode = AcEnumHttpResponseCode.NOT_FOUND;
    return response;
  }

  static AcWebResponse raw({required dynamic content, int responseCode = AcEnumHttpResponseCode.OK,Map<String,dynamic> headers = const {}}) {
    final response = AcWebResponse();
    response.responseCode = responseCode;
    response.responseType = AcEnumWebResponseType.RAW;
    response.content = content;
    for(var key in headers.keys){
      response.headers[key] = headers.keys;
    }
    return response;
  }

  static AcWebResponse redirect({required String url, int responseCode = AcEnumHttpResponseCode.TEMPORARY_REDIRECT}) {
    final response = AcWebResponse();
    response.responseCode = responseCode;
    response.responseType = AcEnumWebResponseType.REDIRECT;
    response.content = url;
    return response;
  }

  static AcWebResponse view({required String template, int responseCode = AcEnumHttpResponseCode.OK}) {
    // In Dart, view rendering depends on your backend server implementation
    // This is a placeholder for view rendering logic.
    // print("Render view: $template with $vars");
    return AcWebResponse();
  }

  AcWebResponse fromJson(Map<String, dynamic> jsonData) {
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
