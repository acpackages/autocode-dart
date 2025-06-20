import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcDDTableColumnProperty {
  static const String KEY_PROPERTY_NAME = "property_name";
  static const String KEY_PROPERTY_VALUE = "property_value";

  @AcBindJsonProperty(key: AcDDTableColumnProperty.KEY_PROPERTY_NAME)
  String propertyName = "";

  @AcBindJsonProperty(key: AcDDTableColumnProperty.KEY_PROPERTY_VALUE)
  dynamic propertyValue;

  static AcDDTableColumnProperty instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDTableColumnProperty();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcDDTableColumnProperty fromJson({required Map<String, dynamic> jsonData}) {
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
