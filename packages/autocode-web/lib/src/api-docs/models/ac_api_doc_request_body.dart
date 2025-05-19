import 'dart:convert';
import 'package:autocode/autocode.dart';
import 'package:autocode_web/autocode_web.dart';

class AcApiDocRequestBody {
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_CONTENT = 'content';
  static const String KEY_REQUIRED = 'required';

  String? description = "";
  Map<String, AcApiDocContent> content = {};
  bool required = false;

  AcApiDocRequestBody();

  static AcApiDocRequestBody instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocRequestBody();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocRequestBody fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (json.containsKey(KEY_CONTENT)) {
      final contentMap = json[KEY_CONTENT] as Map<String, dynamic>;
      contentMap.forEach((mime, contentJson) {
        content[mime] = AcApiDocContent.instanceFromJson(jsonData: contentJson);
      });
      json.remove(KEY_CONTENT);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: json);
    return this;
  }

  void addContent({required AcApiDocContent content}) {
    // Using encoding as key if available, fallback to numeric keys if needed.
    if (content.encoding.isNotEmpty) {
      this.content[content.encoding] = content;
    } else {
      this.content[this.content.length.toString()] = content;
    }
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    if (description != null && description!.isNotEmpty) {
      result[KEY_DESCRIPTION] = description;
    }
    if (required) {
      result[KEY_REQUIRED] = required;
    }
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
