import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcPrinter {
  static const String keyName = "name";
  static const String keyUrl = "url";
  static const String keyLocation = "location";
  static const String keyComment = "comment";
  static const String keyIsDefault = "is_default";
  static const String keyIsAvailable = "is_available";
  static const String keyDriverName = "driver_name";
  static const String keyPpdName = "ppd_name";

  @AcBindJsonProperty(key: keyName)
  String name = "";

  @AcBindJsonProperty(key: keyUrl)
  String url = "";

  @AcBindJsonProperty(key: keyLocation)
  String location = "";

  @AcBindJsonProperty(key: keyComment)
  String comment = "";

  @AcBindJsonProperty(key: keyIsDefault)
  bool isDefault = false;

  @AcBindJsonProperty(key: keyIsAvailable)
  bool isAvailable = true;

  @AcBindJsonProperty(key: keyDriverName)
  String driverName = "";

  @AcBindJsonProperty(key: keyPpdName)
  String ppdName = "";

  AcPrinter();

  factory AcPrinter.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcPrinter();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcPrinter fromJson({required Map<String, dynamic> jsonData}) {
    if (jsonData.containsKey(keyName)) name = jsonData[keyName]?.toString() ?? '';
    if (jsonData.containsKey(keyUrl)) url = jsonData[keyUrl]?.toString() ?? '';
    if (jsonData.containsKey(keyLocation)) location = jsonData[keyLocation]?.toString() ?? '';
    if (jsonData.containsKey(keyComment)) comment = jsonData[keyComment]?.toString() ?? '';
    if (jsonData.containsKey(keyIsDefault)) isDefault = jsonData[keyIsDefault] == true;
    if (jsonData.containsKey(keyIsAvailable)) isAvailable = jsonData[keyIsAvailable] != false;
    if (jsonData.containsKey(keyDriverName)) driverName = jsonData[keyDriverName]?.toString() ?? '';
    if (jsonData.containsKey(keyPpdName)) ppdName = jsonData[keyPpdName]?.toString() ?? '';

    try {
      AcJsonUtils.setInstancePropertiesFromJsonData(
        instance: this,
        jsonData: jsonData,
      );
    } catch (_) {}
    return this;
  }

  Map<String, dynamic> toJson() {
    try {
      final res = AcJsonUtils.getJsonDataFromInstance(instance: this);
      if (res.isNotEmpty && res[keyName] != null) return res;
    } catch (_) {}

    return {
      keyName: name,
      keyUrl: url,
      keyLocation: location,
      keyComment: comment,
      keyIsDefault: isDefault,
      keyIsAvailable: isAvailable,
      keyDriverName: driverName,
      keyPpdName: ppdName,
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
