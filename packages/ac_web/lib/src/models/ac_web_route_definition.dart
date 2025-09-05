import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents the definition of a single web API route.",
  "description": "This class encapsulates all the necessary information to define an API endpoint, including its URL path, HTTP method, the controller and handler function that process requests, and its associated API documentation.",
  "example": "final userRoute = AcWebRouteDefinition()\n  ..url = '/api/users/{id}'\n  ..method = 'GET'\n  ..controller = UserController()\n  ..handler = (UserController c, AcWebRequest r) => c.getUserById(r)\n  ..documentation = AcApiDocRoute(summary: 'Gets a single user by their ID.');"
}) */
@AcReflectable()
class AcWebRouteDefinition {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyController = 'controller';
  static const String keyHandler = 'handler';
  static const String keyDocumentation = 'documentation';
  static const String keyMethod = 'method';
  static const String keyUrl = 'url';

  /* AcDoc({
    "summary": "The controller instance that contains the handler logic.",
    "description": "This is typically an instance of a class that groups related route handlers. It is dynamic to accommodate various controller classes."
  }) */
  @AcBindJsonProperty(key: keyController)
  dynamic controller;

  /* AcDoc({
    "summary": "A reference to the function that will handle the request.",
    "description": "This is the function that gets executed when a request matches the route's URL and method. It is dynamic to allow for different function signatures."
  }) */
  @AcBindJsonProperty(key: keyHandler)
  dynamic handler;

  /* AcDoc({
    "summary": "The API documentation for this specific route."
  }) */
  @AcBindJsonProperty(key: keyDocumentation)
  AcApiDocOperation documentation = AcApiDocOperation();

  /* AcDoc({
    "summary": "The HTTP method for this route (e.g., 'GET', 'POST', 'PUT', 'DELETE')."
  }) */
  @AcBindJsonProperty(key: keyMethod)
  String method = "POST";

  /* AcDoc({
    "summary": "The URL path for this route (e.g., '/api/users/{id}')."
  }) */
  @AcBindJsonProperty(key: keyUrl)
  String url = "";

  /* AcDoc({
    "summary": "Creates a new, empty instance of a web route definition."
  }) */
  AcWebRouteDefinition();

  /* AcDoc({
    "summary": "Creates a new AcWebRouteDefinition instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the route definition."}
    ],
    "returns": "A new, populated AcWebRouteDefinition instance.",
    "returns_type": "AcWebRouteDefinition"
  }) */
  factory AcWebRouteDefinition.instanceFromJson(Map<String, dynamic> jsonData) {
    final instance = AcWebRouteDefinition();
    instance.fromJson(jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the route's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcWebRouteDefinition"
  }) */
  AcWebRouteDefinition fromJson(Map<String, dynamic> jsonData) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current route definition instance to a JSON map.",
    "returns": "A JSON map representation of the route definition.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
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