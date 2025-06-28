import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents the detailed documentation for a single API route.",
  "description": "This class models the comprehensive definition of an API endpoint, equivalent to an Operation Object in an OpenAPI specification. It includes metadata like tags, a summary, parameters, a request body, and a full set of possible responses.",
  "example": "final createUserRoute = AcApiDocRoute()\n  ..tags = ['Users']\n  ..summary = 'Create a new user'\n  ..operationId = 'createUser'\n  ..requestBody = AcApiDocRequestBody(description: 'User object to create')\n  ..addResponse(response: AcApiDocResponse(code: AcEnumHttpResponseCode.created, description: 'User created successfully'))\n  ..addResponse(response: AcApiDocResponse(code: AcEnumHttpResponseCode.badRequest, description: 'Invalid input'));"
}) */
@AcReflectable()
class AcApiDocRoute {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyTags = 'tags';
  static const String keySummary = 'summary';
  static const String keyDescription = 'description';
  static const String keyOperationId = 'operationId';
  static const String keyParameters = 'parameters';
  static const String keyRequestBody = 'requestBody';
  static const String keyResponses = 'responses';
  static const String keyConsumes = 'consumes';
  static const String keyProduces = 'produces';
  static const String keyDeprecated = 'deprecated';
  static const String keySecurity = 'security';

  /* AcDoc({"summary": "A list of tags for API documentation control."}) */
  @AcBindJsonProperty(key: keyTags)
  List<String> tags = [];

  /* AcDoc({"summary": "A short summary of what the route does."}) */
  @AcBindJsonProperty(key: keySummary)
  String summary = '';

  /* AcDoc({"summary": "A verbose explanation of the operation behavior."}) */
  @AcBindJsonProperty(key: keyDescription)
  String description = '';

  /* AcDoc({"summary": "A unique string used to identify the operation."}) */
  @AcBindJsonProperty(key: keyOperationId)
  String operationId = '';

  /* AcDoc({"summary": "A list of parameters that are applicable for this route."}) */
  @AcBindJsonProperty(key: keyParameters)
  List<AcApiDocParameter> parameters = [];

  /* AcDoc({"summary": "The request body applicable for this route."}) */
  @AcBindJsonProperty(key: keyRequestBody)
  AcApiDocRequestBody? requestBody;

  /* AcDoc({
    "summary": "A list of possible responses for this operation.",
    "description": "This list is not serialized directly but is converted by `toJson` into a map keyed by HTTP status codes."
  }) */
  List<AcApiDocResponse> responses = [];

  /* AcDoc({"summary": "A list of MIME types the operation can consume."}) */
  @AcBindJsonProperty(key: keyConsumes)
  List<String> consumes = [];

  /* AcDoc({"summary": "A list of MIME types the operation can produce."}) */
  @AcBindJsonProperty(key: keyProduces)
  List<String> produces = [];

  /* AcDoc({"summary": "Declares this operation to be deprecated."}) */
  @AcBindJsonProperty(key: keyDeprecated)
  bool deprecated = false;

  /* AcDoc({"summary": "A declaration of which security mechanisms are used for this operation."}) */
  @AcBindJsonProperty(key: keySecurity)
  List<dynamic> security = [];

  /* AcDoc({"summary": "Creates a new, empty instance of an API route definition."}) */
  AcApiDocRoute();

  /* AcDoc({
    "summary": "Creates a new AcApiDocRoute instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the route definition."}
    ],
    "returns": "A new, populated AcApiDocRoute instance.",
    "returns_type": "AcApiDocRoute"
  }) */
  factory AcApiDocRoute.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocRoute();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the route's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Adds a parameter definition to this route.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute addParameter({required AcApiDocParameter parameter}) {
    parameters.add(parameter);
    return this;
  }

  /* AcDoc({
    "summary": "Adds a possible response definition to this route.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute addResponse({required AcApiDocResponse response}) {
    responses.add(response);
    return this;
  }

  /* AcDoc({
    "summary": "Adds a tag to this route for documentation grouping.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute addTag({required String tag}) {
    tags.add(tag);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current route definition to a JSON map.",
    "description": "This method uses reflection for most properties but manually serializes the `responses` list into a map keyed by status code to conform to the OpenAPI specification.",
    "returns": "A JSON map representation of the route definition.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    final result = AcJsonUtils.getJsonDataFromInstance(instance: this);

    if (responses.isNotEmpty) {
      final responsesMap = <String, dynamic>{};
      for (final response in responses) {
        // Use the integer value of the enum for the status code key.
        responsesMap[response.code.value.toString()] = response.toJson();
      }
      result[keyResponses] = responsesMap;
    }

    return result;
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the route definition.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}