import 'dart:convert';
import 'package:autocode/autocode.dart';
import 'package:autocode_web/autocode_web.dart';

class AcApiDoc {
  static const String KEY_CONTACT = "contact";
  static const String KEY_COMPONENTS = "components";
  static const String KEY_DESCRIPTION = "description";
  static const String KEY_LICENSE = "license";
  static const String KEY_MODELS = "models";
  static const String KEY_PATHS = "paths";
  static const String KEY_SERVERS = "servers";
  static const String KEY_TAGS = "tags";
  static const String KEY_TERMS_OF_SERVICE = "termsOfService";
  static const String KEY_TITLE = "title";
  static const String KEY_VERSION = "version";

  AcApiDocContact? contact;
  List<dynamic> components = [];
  String description = "";
  AcApiDocLicense? license;

  @AcBindJsonProperty(key: AcApiDoc.KEY_MODELS, arrayType: AcApiDocModel)
  Map<String, AcApiDocModel> models = {};

  @AcBindJsonProperty(key: AcApiDoc.KEY_PATHS, arrayType: AcApiDocPath)
  List<AcApiDocPath> paths = [];

  @AcBindJsonProperty(key: AcApiDoc.KEY_SERVERS, arrayType: AcApiDocServer)
  List<AcApiDocServer> servers = [];

  @AcBindJsonProperty(key: AcApiDoc.KEY_TAGS, arrayType: AcApiDocTag)
  List<AcApiDocTag> tags = [];

  @AcBindJsonProperty(key: AcApiDoc.KEY_TERMS_OF_SERVICE)
  String termsOfService = "";

  String title = "";
  String version = "";

  static AcApiDoc instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDoc();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDoc addModel({required AcApiDocModel model}) {
    models[model.name] = model;
    return this;
  }

  AcApiDoc addPath({required AcApiDocPath path}) {
    paths.add(path);
    return this;
  }

  AcApiDoc addServer({required AcApiDocServer server}) {
    servers.add(server);
    return this;
  }

  AcApiDoc addTag({required AcApiDocTag tag}) {
    tags.add(tag);
    return this;
  }

  AcApiDoc fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }
}
