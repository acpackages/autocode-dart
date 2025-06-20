import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:autocode/autocode.dart';

class AcCodeEntityFunction extends AcCodeEntityMethod {
  AcCodeEntityFunction():super();

  factory AcCodeEntityFunction.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeEntityFunction();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeEntityFunction fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }
}
