import 'dart:typed_data';
import 'package:ac_ai_clients/ac_ai_clients.dart';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a unified, multimodal request to any AI model.",
  "description": "This model supports both simple text prompts and complex multimodal requests (such as image + text). It handles all necessary input configuration for supported AI providers.",
  "author": "Sanket Patel",
  "type": "model",
  "category": "AI",
  "group": "Request",
  "tags": ["ai", "prompt", "multimodal", "image", "text"]
}) */
@AcReflectable()
class AcAIRequest {
  static const String keyPrompt = "prompt";
  static const String keyInputType = "inputType";
  static const String keyFiles = "files";
  static const String keyFileNames = "fileNames";
  static const String keyFilePaths = "filePaths";
  static const String keyMaxTokens = "maxTokens";
  static const String keyCreativityLevel = "creativityLevel";

  @AcBindJsonProperty(key: keyPrompt)
  String prompt;

  @AcBindJsonProperty(key: keyInputType)
  AcEnumAIInputType? inputType;

  @AcBindJsonProperty(key: keyFiles)
  List<Uint8List>? files;

  @AcBindJsonProperty(key: keyFileNames)
  List<String>? fileNames;

  /* AcDoc({
    "description": "Paths of attached files, used as an alternative to `files` for lazy loading or deferred reading.",
    "remarks": ["Can be converted to bytes at runtime if needed."]
  }) */
  @AcBindJsonProperty(key: keyFilePaths)
  List<String>? filePaths;

  @AcBindJsonProperty(key: keyMaxTokens)
  int? maxTokens;

  @AcBindJsonProperty(key: keyCreativityLevel)
  double? creativityLevel;

  AcAIRequest({
    this.prompt = "",
    this.inputType,
    this.files,
    this.fileNames,
    this.filePaths,
    this.maxTokens,
    this.creativityLevel,
  });

  factory AcAIRequest.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcAIRequest();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcAIRequest fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() => AcJsonUtils.prettyEncode(toJson());
}
