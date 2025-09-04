import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

import '../enums/ac_enum_ai_model.dart';
import '../enums/ac_enum_ai_response_type.dart';

/* AcDoc({
  "summary": "Configuration for an AI client.",
  "description": "Encapsulates all necessary config for calling a specific AI model from a provider, such as API key, endpoint, model type, output format, and creativity level.",
  "author": "Sanket Patel",
  "type": "model",
  "category": "AI",
  "group": "Config",
  "tags": ["ai", "config", "model", "api"]
}) */
@AcReflectable()
class AcAIClientConfig {
  static const String keyModel = "model";
  static const String keyApiKey = "apiKey";
  static const String keyApiUrl = "apiUrl";
  static const String keyResponseType = "responseType";
  static const String keyLanguage = "language";
  static const String keyTone = "tone";
  static const String keyCreativityLevel = "creativityLevel";
  static const String keyOrganization = "organization";
  static const String keyProject = "project";

  /* AcDoc({"description": "The AI model to be used, such as GPT-4o or Gemini-1.5."}) */
  @AcBindJsonProperty(key: keyModel)
  AcEnumAIModel model;

  /* AcDoc({"description": "The API key required to authenticate with the provider."}) */
  @AcBindJsonProperty(key: keyApiKey)
  String apiKey;

  /* AcDoc({"description": "The base URL of the AI provider's API."}) */
  @AcBindJsonProperty(key: keyApiUrl)
  String apiUrl;

  /* AcDoc({"description": "The expected type of output from the AI response (text, image, etc)."}) */
  @AcBindJsonProperty(key: keyResponseType)
  AcEnumAIResponseType responseType;

  /* AcDoc({"description": "Optional setting to influence the output language."}) */
  @AcBindJsonProperty(key: keyLanguage)
  String? language;

  /* AcDoc({"description": "Optional tone (e.g., formal, casual, instructional)."}) */
  @AcBindJsonProperty(key: keyTone)
  String? tone;

  /* AcDoc({
    "description": "Controls creativity or randomness of the output. Maps to 'temperature'. Range: 0.0–2.0.",
    "example": "0.7"
  }) */
  @AcBindJsonProperty(key: keyCreativityLevel)
  double? creativityLevel;

  /* AcDoc({"description": "Optional organization ID (for OpenAI orgs or similar)."}) */
  @AcBindJsonProperty(key: keyOrganization)
  String? organization;

  /* AcDoc({"description": "Optional project ID (for tracking purposes)."}) */
  @AcBindJsonProperty(key: keyProject)
  String? project;

  /* AcDoc({
    "description": "Constructor with named parameters to create a configuration object.",
    "params": [
      {"name": "model", "description": "AI model to use."},
      {"name": "apiKey", "description": "API key for authentication."},
      {"name": "apiUrl", "description": "Base API endpoint."},
      {"name": "responseType", "description": "Expected output type (text, image, etc)."},
      {"name": "language", "description": "Optional output language."},
      {"name": "tone", "description": "Optional tone setting."},
      {"name": "creativityLevel", "description": "Controls output randomness/creativity."},
      {"name": "organization", "description": "Optional organization ID."},
      {"name": "project", "description": "Optional project ID."}
    ]
  }) */
  AcAIClientConfig({
    this.model = AcEnumAIModel.unknown,
    this.apiKey = "",
    this.apiUrl = "",
    this.responseType = AcEnumAIResponseType.text,
    this.language,
    this.tone,
    this.creativityLevel,
    this.organization,
    this.project,
  });

  /* AcDoc({
    "summary": "Creates an instance from JSON data.",
    "params": [{"name": "jsonData", "description": "The JSON map containing configuration values."}],
    "returns": "A configured AcAIClientConfig instance."
  }) */
  factory AcAIClientConfig.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcAIClientConfig();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Loads values from a JSON map into the config.",
    "params": [{"name": "jsonData", "description": "A map containing key-value pairs."}],
    "returns": "The current instance with values populated."
  }) */
  AcAIClientConfig fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Converts the config into a serializable map.",
    "returns": "A JSON-compatible map of this configuration."
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({"description": "Returns a pretty-printed string representation of the config."}) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
