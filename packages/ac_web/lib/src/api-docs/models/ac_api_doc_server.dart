import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a server hosting the API.",
  "description": "This class models the Server Object in an OpenAPI specification. It provides connectivity information for a target server, including its base URL and a description. An API may be hosted on multiple servers (e.g., for production, staging, or development environments).",
  "example": "final productionServer = AcApiDocServer(\n  url: 'https://api.example.com/v1',\n  description: 'Production Server'\n);"
}) */
@AcReflectable()
class AcApiDocServer {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyDescription = "description";
  static const String keyTitle = "title";
  static const String keyUrl = "url";

  /* AcDoc({"summary": "An optional description for the server."}) */
  @AcBindJsonProperty(key: keyDescription)
  String description = "";

  /* AcDoc({"summary": "A title for the server, used for display purposes."}) */
  @AcBindJsonProperty(key: keyTitle)
  String title = "";

  /* AcDoc({
    "summary": "The base URL of the API server.",
    "description": "This URL is used as the base for all relative paths defined in the API's routes."
  }) */
  @AcBindJsonProperty(key: keyUrl)
  String url = "";

  /* AcDoc({
    "summary": "Creates a new instance of an API server definition.",
    "params": [
      {"name": "url", "description": "The base URL of the server."}
    ]
  }) */
  AcApiDocServer({this.url = ""});

  /* AcDoc({
    "summary": "Creates a new AcApiDocServer instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the server."}
    ],
    "returns": "A new, populated AcApiDocServer instance.",
    "returns_type": "AcApiDocServer"
  }) */
  factory AcApiDocServer.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocServer();
    return instance.fromJson(jsonData:jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the server's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocServer"
  }) */
  AcApiDocServer fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current server instance to a JSON map.",
    "returns": "A JSON map representation of the server.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the server.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}