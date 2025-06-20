import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:autocode/autocode.dart';

class AcCodeEntityClass extends AcCodeEntityBase {
  static const String KEY_IS_ABSTRACT = "is_abstract";
  static const String KEY_EXTENDS = "extends";
  static const String KEY_IMPLEMENTS = "implements";

  @AcBindJsonProperty(key: KEY_IS_ABSTRACT)
  bool isAbstract = false;

  @AcBindJsonProperty(key: KEY_EXTENDS)
  String? extendsClass;

  @AcBindJsonProperty(key: KEY_IMPLEMENTS)
  List<String> implementsInterfaces = [];

  AcCodeEntityClass();

  factory AcCodeEntityClass.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeEntityClass();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeEntityClass fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }
}
