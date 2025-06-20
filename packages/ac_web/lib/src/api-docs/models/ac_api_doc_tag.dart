import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';
@AcReflectable()
class AcApiDocTag {
  static const String KEY_NAME = "name";
  static const String KEY_DESCRIPTION = "description";
  static const String KEY_EXTERNAL_DOCS = "externalDocs";

  String name = "";
  String description = "";

  @AcBindJsonProperty(key: AcApiDocTag.KEY_EXTERNAL_DOCS)
  late AcApiDocExternalDocs externalDocs;

  AcApiDocTag() {
    externalDocs = AcApiDocExternalDocs();
  }

  static AcApiDocTag instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocTag();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocTag fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
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
