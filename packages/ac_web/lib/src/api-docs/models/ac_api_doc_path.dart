import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';
@AcReflectable()
class AcApiDocPath {
  static const String KEY_URL = "url";
  static const String KEY_CONNECT = "connect";
  static const String KEY_GET = "get";
  static const String KEY_PUT = "put";
  static const String KEY_POST = "post";
  static const String KEY_DELETE = "delete";
  static const String KEY_OPTIONS = "options";
  static const String KEY_HEAD = "head";
  static const String KEY_PATCH = "patch";
  static const String KEY_TRACE = "trace";

  String url = "";
  AcApiDocRoute? connect;
  AcApiDocRoute? get;
  AcApiDocRoute? put;
  AcApiDocRoute? post;
  AcApiDocRoute? delete;
  AcApiDocRoute? options;
  AcApiDocRoute? head;
  AcApiDocRoute? patch;
  AcApiDocRoute? trace;

  AcApiDocPath();

  static AcApiDocPath instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocPath();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocPath fromJson({required Map<String, dynamic> jsonData}) {
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
