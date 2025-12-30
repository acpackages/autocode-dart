import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

import '../../ac_printing.dart';

@AcReflectable()
class AcPrintSettings {
  static const String keyPageFormat = "pageFormat";
  static const String keyCopies = "copies";
  static const String keyColor = "color";
  static const String keyDuplex = "duplex";
  static const String keyOrientation = "orientation";

  @AcBindJsonProperty(key: keyPageFormat)
  AcPageFormat pageFormat = AcPageFormat();

  @AcBindJsonProperty(key: keyCopies)
  int copies = 1;

  @AcBindJsonProperty(key: keyColor)
  bool color = true;

  @AcBindJsonProperty(key: keyDuplex)
  bool duplex = false;

  @AcBindJsonProperty(key: keyOrientation)
  String orientation = "portrait"; // "portrait" or "landscape"

  AcPrintSettings();

  factory AcPrintSettings.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcPrintSettings();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcPrintSettings fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    var result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    result[keyPageFormat] = pageFormat.toJson();
    return result;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}