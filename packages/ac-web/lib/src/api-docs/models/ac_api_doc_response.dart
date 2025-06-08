import 'dart:convert';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

class AcApiDocResponse {
  static const String KEY_CODE = 'code';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_HEADERS = 'headers';
  static const String KEY_CONTENT = 'content';
  static const String KEY_LINKS = 'links';

  int code = 0;
  String description = '';
  Map<String, AcApiDocHeader> headers = {};
  Map<String, AcApiDocContent> content = {};
  Map<String, AcApiDocLink> links = {};

  AcApiDocResponse();

  static AcApiDocResponse instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocResponse();
    return instance.fromJson(jsonData: jsonData);
  }

  void addContent({required AcApiDocContent content}) {
    if (content.encoding.isNotEmpty) {
      this.content[content.encoding] = content;
    } else {
      this.content[this.content.length.toString()] = content;
    }
  }

  AcApiDocResponse fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey(KEY_CONTENT)) {
      final contentMap = json[KEY_CONTENT] as Map<String, dynamic>;
      contentMap.forEach((mime, contentJson) {
        content[mime] = AcApiDocContent.instanceFromJson(jsonData: contentJson);
      });
      json.remove(KEY_CONTENT);
    }

    if (json.containsKey(KEY_HEADERS)) {
      final headersMap = json[KEY_HEADERS] as Map<String, dynamic>;
      headersMap.forEach((headerName, headerJson) {
        headers[headerName] = AcApiDocHeader.instanceFromJson(
          jsonData: headerJson,
        );
      });
      json.remove(KEY_HEADERS);
    }

    if (json.containsKey(KEY_LINKS)) {
      final linksMap = json[KEY_LINKS] as Map<String, dynamic>;
      linksMap.forEach((linkName, linkJson) {
        links[linkName] = AcApiDocLink.instanceFromJson(jsonData: linkJson);
      });
      json.remove(KEY_LINKS);
    }

    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    final result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    if (content.isNotEmpty) {
      final contentJson = <String, dynamic>{};
      content.forEach((encoding, contentItem) {
        contentJson[encoding] = contentItem.toJson();
      });
      result[KEY_CONTENT] = contentJson;
    }
    return result;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
