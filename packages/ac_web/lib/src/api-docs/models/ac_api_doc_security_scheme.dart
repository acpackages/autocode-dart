import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Defines a security scheme that can be used by the API operations.",
  "description": "This class models the Security Scheme Object in an OpenAPI specification. It defines the mechanism for API authorization, such as API Key, HTTP Bearer authentication, OAuth2, or OpenID Connect.",
  "example": "// Defines a security scheme for an API Key passed in the header.\nfinal apiKeyAuth = AcApiDocSecurityScheme()\n  ..type = 'apiKey'\n  ..description = 'API Key to access private endpoints'\n  ..name = 'X-API-KEY'\n  ..in_ = 'header';"
}) */
@AcReflectable()
class AcApiDocSecurityScheme {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyType = 'type';
  static const String keyDescription = 'description';
  static const String keyName = 'name';
  static const String keyIn = 'in';
  static const String keyScheme = 'scheme';
  static const String keyBearerFormat = 'bearerFormat';
  static const String keyFlows = 'flows';
  static const String keyOpenIdConnectUrl = 'openIdConnectUrl';

  /* AcDoc({
    "summary": "The type of the security scheme.",
    "description": "Valid values are 'apiKey', 'http', 'oauth2', 'openIdConnect'."
  }) */
  @AcBindJsonProperty(key: keyType)
  String type = '';

  /* AcDoc({"summary": "A short description for the security scheme."}) */
  @AcBindJsonProperty(key: keyDescription)
  String description = '';

  /* AcDoc({
    "summary": "The name of the header, query, or cookie parameter to be used.",
    "description": "Required for `apiKey` security schemes."
  }) */
  @AcBindJsonProperty(key: keyName)
  String name = '';

  /* AcDoc({
    "summary": "The location of the API key.",
    "description": "Required for `apiKey` security schemes. Valid values are 'query', 'header', or 'cookie'. The field is named `in_` to avoid conflict with the 'in' keyword in Dart."
  }) */
  @AcBindJsonProperty(key: keyIn)
  String in_ = '';

  /* AcDoc({
    "summary": "The name of the HTTP Authorization scheme to be used.",
    "description": "Required for `http` security schemes (e.g., 'bearer')."
  }) */
  @AcBindJsonProperty(key: keyScheme)
  String scheme = '';

  /* AcDoc({
    "summary": "A hint to the client about the format of the bearer token.",
    "description": "Used with `http` security schemes (e.g., 'JWT')."
  }) */
  @AcBindJsonProperty(key: keyBearerFormat)
  String bearerFormat = '';

  /* AcDoc({
    "summary": "An object containing configuration information for the flow types supported by the `oauth2` scheme."
  }) */
  @AcBindJsonProperty(key: keyFlows)
  List<dynamic> flows = [];

  /* AcDoc({
    "summary": "The OpenID Connect discovery URL.",
    "description": "Required for `openIdConnect` security schemes."
  }) */
  @AcBindJsonProperty(key: keyOpenIdConnectUrl)
  String openIdConnectUrl = '';

  /* AcDoc({"summary": "Creates a new, empty instance of a security scheme."}) */
  AcApiDocSecurityScheme();

  /* AcDoc({
    "summary": "Creates a new AcApiDocSecurityScheme instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the security scheme."}
    ],
    "returns": "A new, populated AcApiDocSecurityScheme instance.",
    "returns_type": "AcApiDocSecurityScheme"
  }) */
  factory AcApiDocSecurityScheme.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocSecurityScheme();
    return instance.fromJson(jsonData:jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the scheme's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocSecurityScheme"
  }) */
  AcApiDocSecurityScheme fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current security scheme instance to a JSON map.",
    "returns": "A JSON map representation of the security scheme.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the security scheme.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}