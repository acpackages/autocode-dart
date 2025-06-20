import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:autocode/autocode.dart';

class AcCodeEntityEnum extends AcCodeEntityBase {
  static const String KEY_VALUES = "values";

  @AcBindJsonProperty(key: KEY_VALUES)
  List<String> values = [];

  AcCodeEntityEnum();

  factory AcCodeEntityEnum.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeEntityEnum();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeEntityEnum fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }
}
