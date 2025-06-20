import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:autocode/autocode.dart';

class AcCodeEntityMixin extends AcCodeEntityBase {
  static const String KEY_IMPLEMENTS = "implements";

  @AcBindJsonProperty(key: KEY_IMPLEMENTS)
  List<String> implementsInterfaces = [];

  AcCodeEntityMixin();

  factory AcCodeEntityMixin.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeEntityMixin();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeEntityMixin fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }
}
