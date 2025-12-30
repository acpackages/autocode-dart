import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcPageFormat {
  static const String keyWidth = "width";
  static const String keyHeight = "height";
  static const String keyMarginLeft = "marginLeft";
  static const String keyMarginRight = "marginRight";
  static const String keyMarginTop = "marginTop";
  static const String keyMarginBottom = "marginBottom";

  @AcBindJsonProperty(key: keyWidth)
  double width = 0.0;

  @AcBindJsonProperty(key: keyHeight)
  double height = 0.0;

  @AcBindJsonProperty(key: keyMarginLeft)
  double marginLeft = 0.0;

  @AcBindJsonProperty(key: keyMarginRight)
  double marginRight = 0.0;

  @AcBindJsonProperty(key: keyMarginTop)
  double marginTop = 0.0;

  @AcBindJsonProperty(key: keyMarginBottom)
  double marginBottom = 0.0;

  // @AcBindJsonProperty(key: keyMarginBottom)
  // AcEnum marginBottom = 0.0;

  AcPageFormat();

  factory AcPageFormat.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcPageFormat();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcPageFormat fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    var result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    return result;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}