import 'dart:convert';
import 'package:autocode/autocode.dart';
import 'package:autocode_web/autocode_web.dart';

class AcApiDocOperation {
  static const String KEY_DESCRIPTION = "description";
  static const String KEY_PARAMETERS = "parameters";
  static const String KEY_RESPONSES = "responses";
  static const String KEY_SUMMARY = "summary";

  String? summary;
  String? description;

  @AcBindJsonProperty(key: AcApiDocOperation.KEY_PARAMETERS, arrayType: AcApiDocParameter)
  List<AcApiDocParameter> parameters = [];

  Map<String, AcApiDocResponse> responses = {};

  AcApiDocOperation();

  static AcApiDocOperation instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocOperation();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocOperation fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (json.containsKey(KEY_RESPONSES)) {
      final responsesMap = <String, AcApiDocResponse>{};
      (json[KEY_RESPONSES] as Map<String, dynamic>).forEach((status, responseJson) {
        responsesMap[status] = AcApiDocResponse.instanceFromJson(jsonData:responseJson as Map<String, dynamic>);
      });
      responses = responsesMap;
      json.remove(KEY_RESPONSES);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: json);
    return this;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (summary != null) {
      json[KEY_SUMMARY] = summary;
    }
    if (description != null) {
      json[KEY_DESCRIPTION] = description;
    }

    if (parameters.isNotEmpty) {
      json[KEY_PARAMETERS] = parameters.map((param) => param.toJson()).toList();
    }

    if (responses.isNotEmpty) {
      final respJson = <String, dynamic>{};
      responses.forEach((status, response) {
        respJson[status] = response.toJson();
      });
      json[KEY_RESPONSES] = respJson;
    }

    return json;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
