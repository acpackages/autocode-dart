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
  static const String keyDpi = "dpi";

  @AcBindJsonProperty(key: keyPageFormat)
  AcPageFormat pageFormat = AcPageFormat();

  @AcBindJsonProperty(key: keyCopies)
  int copies = 1;

  @AcBindJsonProperty(key: keyColor)
  bool color = true;

  @AcBindJsonProperty(key: keyDuplex)
  bool duplex = false;

  @AcBindJsonProperty(key: keyOrientation)
  String orientation = "auto"; // "auto", "portrait", or "landscape"

  @AcBindJsonProperty(key: keyDpi)
  int dpi = 200; // 150 (Fast/Draft), 200 (Standard - 55% less RAM), 300 (High Quality)

  AcPrintSettings();

  factory AcPrintSettings.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcPrintSettings();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcPrintSettings fromJson({required Map<String, dynamic> jsonData}) {
    if (jsonData.containsKey(keyCopies)) {
      copies = int.tryParse(jsonData[keyCopies].toString()) ?? 1;
    }
    if (jsonData.containsKey(keyColor)) {
      color = jsonData[keyColor] != false;
    }
    if (jsonData.containsKey(keyDuplex)) {
      duplex = jsonData[keyDuplex] == true;
    }
    if (jsonData.containsKey(keyOrientation)) {
      orientation = jsonData[keyOrientation]?.toString() ?? 'auto';
    }
    if (jsonData.containsKey(keyDpi)) {
      dpi = int.tryParse(jsonData[keyDpi].toString()) ?? 200;
      if (dpi < 72) dpi = 72;
      if (dpi > 600) dpi = 600;
    }
    if (jsonData.containsKey(keyPageFormat) && jsonData[keyPageFormat] is Map<String, dynamic>) {
      pageFormat = AcPageFormat.instanceFromJson(jsonData: jsonData[keyPageFormat] as Map<String, dynamic>);
    }

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
      if (res.isNotEmpty && res[keyCopies] != null) {
        res[keyPageFormat] = pageFormat.toJson();
        res[keyDpi] = dpi;
        return res;
      }
    } catch (_) {}

    return {
      keyPageFormat: pageFormat.toJson(),
      keyCopies: copies,
      keyColor: color,
      keyDuplex: duplex,
      keyOrientation: orientation,
      keyDpi: dpi,
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
