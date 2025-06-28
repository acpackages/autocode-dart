import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents a single API operation on a specific path.",
  "description": "This class models the Operation Object in an OpenAPI specification. It provides a detailed definition of a single endpoint (e.g., a GET request on `/users/{id}`), including its summary, description, parameters, and possible responses.",
  "example": "final getUserOperation = AcApiDocOperation()\n  ..summary = 'Get a user by ID'\n  ..description = 'Retrieves a single user object.'\n  ..parameters = [\n    AcApiDocParameter(name: 'id', inValue: 'path', required: true)\n  ]\n  ..responses = {\n    '200': AcApiDocResponse(description: 'Successful operation'),\n    '404': AcApiDocResponse(description: 'User not found')\n  };"
}) */
@AcReflectable()
class AcApiDocOperation {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyDescription = "description";
  static const String keyParameters = "parameters";
  static const String keyResponses = "responses";
  static const String keySummary = "summary";

  /* AcDoc({"summary": "A short summary of what the operation does."}) */
  @AcBindJsonProperty(key: keySummary)
  String? summary;

  /* AcDoc({"summary": "A verbose explanation of the operation behavior."}) */
  @AcBindJsonProperty(key: keyDescription)
  String? description;

  /* AcDoc({
    "summary": "A list of parameters that are applicable for this operation.",
    "description": "If a parameter is defined in both the Path Item and the Operation, the Operation's definition overrides the Path Item's."
  }) */
  @AcBindJsonProperty(
    key: keyParameters,
    arrayType: AcApiDocParameter,
  )
  List<AcApiDocParameter> parameters = [];

  /* AcDoc({
    "summary": "The list of possible responses as they are returned from executing this operation.",
    "description": "A map where the key is the HTTP status code (e.g., '200', '404') and the value is an `AcApiDocResponse` object describing the response."
  }) */
  @AcBindJsonProperty(key: keyResponses)
  Map<String, AcApiDocResponse> responses = {};

  /* AcDoc({"summary": "Creates a new, empty instance of an API operation definition."}) */
  AcApiDocOperation();

  /* AcDoc({
    "summary": "Creates a new AcApiDocOperation instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the operation."}
    ],
    "returns": "A new, populated AcApiDocOperation instance.",
    "returns_type": "AcApiDocOperation"
  }) */
  factory AcApiDocOperation.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocOperation();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "This method manually deserializes the nested `responses` map before using a reflection utility for the remaining properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the operation's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocOperation"
  }) */
  AcApiDocOperation fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey(keyResponses)) {
      final responsesMap = <String, AcApiDocResponse>{};
      (json[keyResponses] as Map<String, dynamic>).forEach((
          status,
          responseJson,
          ) {
        responsesMap[status] = AcApiDocResponse.instanceFromJson(
          jsonData: responseJson as Map<String, dynamic>,
        );
      });
      responses = responsesMap;
      json.remove(keyResponses);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current operation instance to a JSON map.",
    "description": "This method manually serializes its properties into the correct structure for an OpenAPI Operation Object.",
    "returns": "A JSON map representation of the operation.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (summary != null) {
      json[keySummary] = summary;
    }
    if (description != null) {
      json[keyDescription] = description;
    }

    if (parameters.isNotEmpty) {
      json[keyParameters] = parameters.map((param) => param.toJson()).toList();
    }

    if (responses.isNotEmpty) {
      final respJson = <String, dynamic>{};
      responses.forEach((status, response) {
        respJson[status] = response.toJson();
      });
      json[keyResponses] = respJson;
    }

    return json;
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the operation.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}