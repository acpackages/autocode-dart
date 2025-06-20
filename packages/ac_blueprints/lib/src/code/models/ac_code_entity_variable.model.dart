import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:autocode/autocode.dart';

class AcCodeEntityVariable extends AcCodeEntityBase {
  static const String KEY_DATA_TYPE = "data_type";
  static const String KEY_IS_STATIC = "is_static";
  static const String KEY_ACCESS = "access";

  @AcBindJsonProperty(key: KEY_DATA_TYPE)
  String dataType = "";

  @AcBindJsonProperty(key: KEY_IS_STATIC)
  bool isStatic = false;

  @AcBindJsonProperty(key: KEY_ACCESS)
  String accessModifier = "public";

  AcCodeEntityVariable();

  factory AcCodeEntityVariable.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeEntityVariable();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeEntityVariable fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }
}
