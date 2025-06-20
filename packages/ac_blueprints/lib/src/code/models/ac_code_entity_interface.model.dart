import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:autocode/autocode.dart';

class AcCodeEntityInterface extends AcCodeEntityBase {
  static const String KEY_EXTENDS = "extends";

  @AcBindJsonProperty(key: KEY_EXTENDS)
  List<String> extendsInterfaces = [];

  AcCodeEntityInterface();

  factory AcCodeEntityInterface.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeEntityInterface();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeEntityInterface fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }
}
