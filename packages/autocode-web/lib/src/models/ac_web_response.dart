import 'dart:convert';

import 'package:autocode/autocode.dart';
import 'package:autocode_web/autocode_web.dart';
class AcWebResponse {
  static const String KEY_COOKIES = 'cookies';
  static const String KEY_DATA = 'data';
  static const String KEY_HEADERS = 'headers';
  static const String KEY_RESPONSE_CODE = 'response_code';
  static const String KEY_RESPONSE_TYPE = 'response_type';
  static const String KEY_SESSION = 'session';

  Map<String, dynamic> cookies = {};
  dynamic data;
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
    response.data = data;
    response.headers['Content-Type'] = 'application/json';

    // In a Dart web server environment, you'd return or send the response differently
    print(jsonEncode(data)); // simulate sending response
    return response;
  }

  static AcWebResponse view(String template, [Map<String, dynamic> vars = const {}]) {
    // In Dart, view rendering depends on your backend server implementation
    // This is a placeholder for view rendering logic.
    print("Render view: $template with $vars");
    return AcWebResponse();
  }

  static AcWebResponse redirect(String url, [int responseCode = AcEnumHttpResponseCode.TEMPORARY_REDIRECT]) {
    // In a real web server, you'd set a redirect header
    print("Redirect to: $url");
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
