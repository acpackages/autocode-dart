import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcWebConfig {
  // 🔹 Singleton instance
  static final AcWebConfig _instance = AcWebConfig._internal();
  factory AcWebConfig() => _instance;

  AcWebConfig._internal();

  AcFilesControllerConfig _filesControllerConfig = AcFilesControllerConfig();
  AcFilesControllerConfig get filesControllerConfig => _filesControllerConfig;
  set filesControllerConfig(AcFilesControllerConfig value) {
    _filesControllerConfig = value;
  }

  bool _exposeFilesController = false;
  bool get exposeFilesController => _exposeFilesController;
  set exposeFilesController(bool value) {
    _exposeFilesController = value;
  }

  factory AcWebConfig.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcWebConfig();
    return instance.fromJson(jsonData: jsonData);
  }

  AcWebConfig fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() => AcJsonUtils.prettyEncode(toJson());
}

@AcReflectable()
class AcFilesControllerConfig {
  static final AcFilesControllerConfig _instance = AcFilesControllerConfig._internal();
  factory AcFilesControllerConfig() => _instance;
  AcFilesControllerConfig._internal();

  bool _generateDifferentSizeImages = true;
  int _imageXsPx = 35;
  int _imageSquareThumbPx = 70;
  int _imageThumbPx = 100;
  int _imageSmPx = 360;
  int _imageMdPx = 720;
  int _imageLgPx = 1080;
  String _uploadDirectory = "file-uploads";
  String _uploadFormKey = "medias";
  String _routePrefix = "/api/files";

  bool get generateDifferentSizeImages => _generateDifferentSizeImages;
  set generateDifferentSizeImages(bool v) => _generateDifferentSizeImages = v;

  int get imageXsPx => _imageXsPx;
  set imageXsPx(int v) => _imageXsPx = v;

  int get imageSquareThumbPx => _imageSquareThumbPx;
  set imageSquareThumbPx(int v) => _imageSquareThumbPx = v;

  int get imageThumbPx => _imageThumbPx;
  set imageThumbPx(int v) => _imageThumbPx = v;

  int get imageSmPx => _imageSmPx;
  set imageSmPx(int v) => _imageSmPx = v;

  int get imageMdPx => _imageMdPx;
  set imageMdPx(int v) => _imageMdPx = v;

  int get imageLgPx => _imageLgPx;
  set imageLgPx(int v) => _imageLgPx = v;

  String get uploadDirectory => _uploadDirectory;
  set uploadDirectory(String v) => _uploadDirectory = v;

  String get uploadFormKey => _uploadFormKey;
  set uploadFormKey(String v) => _uploadFormKey = v;

  String get routePrefix => _routePrefix;
  set routePrefix(String v) => _routePrefix = v;

  factory AcFilesControllerConfig.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcFilesControllerConfig();
    return instance.fromJson(jsonData: jsonData);
  }

  AcFilesControllerConfig fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() => AcJsonUtils.prettyEncode(toJson());
}
