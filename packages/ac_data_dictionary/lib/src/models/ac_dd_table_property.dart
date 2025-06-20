import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcDDTableProperty {
  static const String KEY_PROPERTY_NAME = "property_name";
  static const String KEY_PROPERTY_VALUE = "property_value";

  @AcBindJsonProperty(key: AcDDTableProperty.KEY_PROPERTY_NAME)
  String propertyName = "";

  @AcBindJsonProperty(key: AcDDTableProperty.KEY_PROPERTY_VALUE)
  dynamic propertyValue = null;

  static AcDDTableProperty instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDTableProperty();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcDDTableProperty fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
