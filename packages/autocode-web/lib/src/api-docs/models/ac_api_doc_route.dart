import 'dart:convert';
import 'package:autocode/autocode.dart';
import 'package:autocode_web/autocode_web.dart';

class AcApiDocRoute {
  static const String KEY_TAGS = 'tags';
  static const String KEY_SUMMARY = 'summary';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_OPERATION_ID = 'operationId';
  static const String KEY_PARAMETERS = 'parameters';
  static const String KEY_REQUEST_BODY = 'requestBody';
  static const String KEY_RESPONSES = 'responses';
  static const String KEY_CONSUMES = 'consumes';
  static const String KEY_PRODUCES = 'produces';
  static const String KEY_DEPRECATED = 'deprecated';
  static const String KEY_SECURITY = 'security';

  List<String> tags = [];
  String summary = '';
  String description = '';

  String operationId = '';

  List<AcApiDocParameter> parameters = [];
  AcApiDocRequestBody? requestBody;

  /// Responses are not serialized by default, but included in toJson()
  List<AcApiDocResponse> responses = [];

  List<String> consumes = [];
  List<String> produces = [];
  bool deprecated = false;
  List<dynamic> security = [];

  AcApiDocRoute();

  static AcApiDocRoute instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocRoute();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocRoute fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  AcApiDocRoute addParameter({required AcApiDocParameter parameter}) {
    parameters.add(parameter);
    return this;
  }

  AcApiDocRoute addResponse({required AcApiDocResponse response}) {
    responses.add(response);
    return this;
  }

  AcApiDocRoute addTag({required String tag}) {
    tags.add(tag);
    return this;
  }

  Map<String, dynamic> toJson() {
    final result = AcJsonUtils.getJsonDataFromInstance(instance: this);

    if (responses.isNotEmpty) {
      result[KEY_RESPONSES] = <String, dynamic>{};
      for (final response in responses) {
        result[KEY_RESPONSES][response.code.toString()] = response.toJson();
      }
    }

    return result;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
