import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:autocode/autocode.dart';

class AcCodeEntityMethod extends AcCodeEntityBase {
  static const String KEY_RETURN_TYPE = "return_type";
  static const String KEY_PARAMETERS = "parameters";
  static const String KEY_ACCESS = "access";

  @AcBindJsonProperty(key: KEY_RETURN_TYPE)
  String returnType = "";

  @AcBindJsonProperty(key: KEY_PARAMETERS)
  List<String> parameters = [];

  @AcBindJsonProperty(key: KEY_ACCESS)
  String accessModifier = "public";

  AcCodeEntityMethod();

  factory AcCodeEntityMethod.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeEntityMethod();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeEntityMethod fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }
}
