import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:autocode/autocode.dart';

class AcCodeEntityConstant extends AcCodeEntityBase {
  static const String KEY_DATA_TYPE = "data_type";
  static const String KEY_VALUE = "value";

  @AcBindJsonProperty(key: KEY_DATA_TYPE)
  String dataType = "";

  @AcBindJsonProperty(key: KEY_VALUE)
  String? value;

  AcCodeEntityConstant();

  factory AcCodeEntityConstant.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeEntityConstant();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeEntityConstant fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }
}
