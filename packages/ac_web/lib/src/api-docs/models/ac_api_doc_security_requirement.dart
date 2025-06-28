import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a security requirement for an API operation.",
  "description": "This class models the Security Requirement Object in an OpenAPI specification. It lists the security schemes (e.g., 'ApiKeyAuth', 'OAuth2') required to execute an operation. Each requirement in the list is a map where the key is the name of a security scheme and the value is a list of required scopes (for OAuth2/OpenID Connect).",
  "example": "// This defines a requirement for an API key passed in a header.\nfinal apiKeyRequirement = AcApiDocSecurityRequirement()\n  ..requirements = [{\n    'ApiKeyAuth': [] // The list is empty because this auth type doesn't use scopes.\n  }];\n\n// This would be added to a route's 'security' list."
}) */
@AcReflectable()
class AcApiDocSecurityRequirement {
  // Renamed static const to follow lowerCamelCase Dart naming conventions.
  static const String keyRequirements = 'requirements';

  /* AcDoc({
    "summary": "A list of security scheme requirements.",
    "description": "Each element in this list represents a security requirement. For a requirement to be met, all schemes within a single map element must be satisfied."
  }) */
  @AcBindJsonProperty(key: keyRequirements)
  List<dynamic> requirements = [];

  /* AcDoc({"summary": "Creates a new, empty instance of a security requirement."}) */
  AcApiDocSecurityRequirement();

  /* AcDoc({
    "summary": "Creates a new AcApiDocSecurityRequirement instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the security requirement."}
    ],
    "returns": "A new, populated AcApiDocSecurityRequirement instance.",
    "returns_type": "AcApiDocSecurityRequirement"
  }) */
  factory AcApiDocSecurityRequirement.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocSecurityRequirement();
    return instance.fromJson(jsonData:jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the requirement's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocSecurityRequirement"
  }) */
  AcApiDocSecurityRequirement fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current security requirement instance to a JSON map.",
    "returns": "A JSON map representation of the security requirement.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the security requirement.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}