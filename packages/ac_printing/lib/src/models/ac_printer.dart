import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcPrinter {
  static const String keyName = "name";
  static const String keyUrl = "url";
  static const String keyLocation = "location";
  static const String keyComment = "comment";
  static const String keyIsDefault = "isDefault";
  static const String keyIsAvailable = "isAvailable";
  static const String keyDriverName = "driverName";
  static const String keyPpdName = "ppdName";

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