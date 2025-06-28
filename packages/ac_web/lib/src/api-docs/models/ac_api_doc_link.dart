import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a possible link between API responses and other operations.",
  "description": "This class models the Link Object in an OpenAPI specification. It is used to describe how values from one API response can be used as input for another API operation, effectively defining a relationship or workflow between endpoints.",
  "example": "// A link to get a user's repository after fetching the user.\nfinal userRepoLink = AcApiDocLink()\n  ..operationId = 'getUserRepositories'\n  ..parameters = [{\n    'userId': '\$response.body#/id' // Use the 'id' from the response body as the 'userId' parameter.\n  }];"
}) */
@AcReflectable()
class AcApiDocLink {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyOperationId = 'operationId';
  static const String keyParameters = 'parameters';
  static const String keyDescription = 'description';

  /* AcDoc({
    "summary": "The `operationId` of the target API operation.",
    "description": "This identifies the specific API endpoint that this link targets."
  }) */
  @AcBindJsonProperty(key: keyOperationId)
  String operationId = '';

  /* AcDoc({
    "summary": "A map of parameters to pass to the target operation.",
    "description": "This defines how to extract values from the original response to use as parameters for the linked operation. The key is the parameter name in the target operation, and the value is an expression that extracts the value from the source response."
  }) */
  @AcBindJsonProperty(key: keyParameters)
  List<dynamic> parameters = [];

  /* AcDoc({"summary": "A description of the link."}) */
  @AcBindJsonProperty(key: keyDescription)
  String description = '';

  /* AcDoc({"summary": "Creates a new, empty instance of an API link definition."}) */
  AcApiDocLink();

  /* AcDoc({
    "summary": "Creates a new AcApiDocLink instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the link."}
    ],
    "returns": "A new, populated AcApiDocLink instance.",
    "returns_type": "AcApiDocLink"
  }) */
  factory AcApiDocLink.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocLink();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the link's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocLink"
  }) */
  AcApiDocLink fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current link instance to a JSON map.",
    "returns": "A JSON map representation of the link.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the link.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}