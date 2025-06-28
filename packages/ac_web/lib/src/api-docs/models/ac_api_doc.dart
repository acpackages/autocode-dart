import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents the root document of an OpenAPI specification.",
  "description": "This class models the entire API documentation structure, corresponding to the OpenAPI/Swagger document object. It includes metadata like title and version, server information, paths (endpoints), components (reusable schemas/models), and tags.",
  "example": "final apiDoc = AcApiDoc()\n  ..title = 'My Awesome API'\n  ..version = '1.0.0'\n  ..description = 'This API provides services for my awesome application.'\n  ..addServer(server: AcApiDocServer(url: 'https://api.example.com/v1'));"
}) */
@AcReflectable()
class AcApiDoc {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyContact = "contact";
  static const String keyComponents = "components";
  static const String keyDescription = "description";
  static const String keyLicense = "license";
  static const String keyModels = "models";
  static const String keyPaths = "paths";
  static const String keyServers = "servers";
  static const String keyTags = "tags";
  static const String keyTermsOfService = "termsOfService";
  static const String keyTitle = "title";
  static const String keyVersion = "version";

  /* AcDoc({"summary": "Contact information for the exposed API."}) */
  @AcBindJsonProperty(key: keyContact)
  AcApiDocContact? contact;

  /* AcDoc({
    "summary": "An object to hold reusable components for the API specification.",
    "description": "This corresponds to the OpenAPI 'Components Object' and can hold schemas, responses, parameters, etc."
  }) */
  @AcBindJsonProperty(key: keyComponents)
  List<dynamic> components = [];

  /* AcDoc({"summary": "A detailed description of the API."}) */
  @AcBindJsonProperty(key: keyDescription)
  String description = "";

  /* AcDoc({"summary": "License information for the exposed API."}) */
  @AcBindJsonProperty(key: keyLicense)
  AcApiDocLicense? license;

  /* AcDoc({
    "summary": "A map of reusable data models (schemas).",
    "description": "Corresponds to the 'schemas' section within the OpenAPI Components Object."
  }) */
  @AcBindJsonProperty(key: keyModels, arrayType: AcApiDocModel)
  Map<String, AcApiDocModel> models = {};

  /* AcDoc({
    "summary": "The available paths and operations for the API.",
    "description": "A list of all the API endpoints (routes)."
  }) */
  @AcBindJsonProperty(key: keyPaths, arrayType: AcApiDocPath)
  List<AcApiDocPath> paths = [];

  /* AcDoc({
    "summary": "A list of server URLs for the API.",
    "description": "Can include multiple servers, such as for production and staging environments."
  }) */
  @AcBindJsonProperty(key: keyServers, arrayType: AcApiDocServer)
  List<AcApiDocServer> servers = [];

  /* AcDoc({
    "summary": "A list of tags used by the specification with additional metadata.",
    "description": "Tags are used for logical grouping of operations."
  }) */
  @AcBindJsonProperty(key: keyTags, arrayType: AcApiDocTag)
  List<AcApiDocTag> tags = [];

  /* AcDoc({"summary": "A URL to the Terms of Service for the API."}) */
  @AcBindJsonProperty(key: keyTermsOfService)
  String termsOfService = "";

  /* AcDoc({"summary": "The title of the API."}) */
  @AcBindJsonProperty(key: keyTitle)
  String title = "";

  /* AcDoc({"summary": "The version of the API documentation."}) */
  @AcBindJsonProperty(key: keyVersion)
  String version = "";

  /* AcDoc({"summary": "Creates a new, empty instance of an API documentation object."}) */
  AcApiDoc();

  /* AcDoc({
    "summary": "Creates a new AcApiDoc instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the API documentation."}
    ],
    "returns": "A new, populated AcApiDoc instance.",
    "returns_type": "AcApiDoc"
  }) */
  factory AcApiDoc.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDoc();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Adds a reusable data model (schema) to the documentation.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcApiDoc"
  }) */
  AcApiDoc addModel({required AcApiDocModel model}) {
    models[model.name] = model;
    return this;
  }

  /* AcDoc({
    "summary": "Adds an API path (endpoint) to the documentation.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcApiDoc"
  }) */
  AcApiDoc addPath({required AcApiDocPath path}) {
    paths.add(path);
    return this;
  }

  /* AcDoc({
    "summary": "Adds a server URL to the documentation.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcApiDoc"
  }) */
  AcApiDoc addServer({required AcApiDocServer server}) {
    servers.add(server);
    return this;
  }

  /* AcDoc({
    "summary": "Adds a tag used for grouping operations.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcApiDoc"
  }) */
  AcApiDoc addTag({required AcApiDocTag tag}) {
    tags.add(tag);
    return this;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the API documentation properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDoc"
  }) */
  AcApiDoc fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current API documentation instance to a JSON map.",
    "returns": "A JSON map representation of the API documentation.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the API documentation.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}