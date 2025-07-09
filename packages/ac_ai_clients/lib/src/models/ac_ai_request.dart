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
  static const String keyInputType = "input_type";
  static const String keyFiles = "files";
  static const String keyFileNames = "file_names";
  static const String keyMaxTokens = "max_tokens";
  static const String keyCreativityLevel = "creativity_level";

  /* AcDoc({
    "description": "Primary instruction or question for the AI model.",
    "example": "Describe the future of robotics in healthcare."
  }) */
  @AcBindJsonProperty(key: keyPrompt)
  String prompt;

  /* AcDoc({
    "description": "Type of non-text input being passed (e.g., image, audio, document).",
    "remarks": ["Used for multimodal models like GPT-4o, Gemini, etc."]
  }) */
  @AcBindJsonProperty(key: keyInputType)
  AcEnumAIInputType? inputType;

  /* AcDoc({
    "description": "Binary content of attached files such as images or audio.",
    "remarks": ["All files should correspond to the declared inputType."]
  }) */
  @AcBindJsonProperty(key: keyFiles)
  List<Uint8List>? files;

  /* AcDoc({
    "description": "Names of attached files, matching the order of `files`.",
    "remarks": ["Used to determine content type or provide filenames to APIs."]
  }) */
  @AcBindJsonProperty(key: keyFileNames)
  List<String>? fileNames;

  /* AcDoc({
    "description": "Maximum number of tokens allowed in the generated response.",
    "example": "512"
  }) */
  @AcBindJsonProperty(key: keyMaxTokens)
  int? maxTokens;

  /* AcDoc({
    "description": "Controls the creativity or randomness of the AI response (range 0.0–2.0).",
    "remarks": ["Higher values produce more diverse output, lower values are more factual."],
    "example": "0.7"
  }) */
  @AcBindJsonProperty(key: keyCreativityLevel)
  double? creativityLevel;

  /* AcDoc({
    "description": "Creates a request instance with optional named parameters.",
    "params": [
      {"name": "prompt", "description": "Instruction or content to prompt the AI."},
      {"name": "model", "description": "Target AI model to use."},
      {"name": "inputType", "description": "Multimodal input type like image, audio."},
      {"name": "files", "description": "List of file content as bytes."},
      {"name": "fileNames", "description": "Names corresponding to attached files."},
      {"name": "maxTokens", "description": "Maximum tokens allowed in response."},
      {"name": "creativityLevel", "description": "Controls output randomness."}
    ]
  }) */
  AcAIRequest({
    this.prompt = "",
    this.inputType,
    this.files,
    this.fileNames,
    this.maxTokens,
    this.creativityLevel,
  });

  /* AcDoc({
    "summary": "Creates an instance from JSON.",
    "params": [{"name": "jsonData", "description": "The JSON map to deserialize."}],
    "returns": "An AcAIRequest instance."
  }) */
  factory AcAIRequest.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcAIRequest();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Populates fields from a JSON object.",
    "params": [{"name": "jsonData", "description": "The map to parse."}],
    "returns": "The modified instance."
  }) */
  AcAIRequest fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the request to a map.",
    "returns": "A JSON-compatible map representation of this request."
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({"description": "Returns a pretty JSON string representation of the request."}) */
  @override
  String toString() => AcJsonUtils.prettyEncode(toJson());
}
