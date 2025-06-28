import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents all available operations for a single API path.",
  "description": "This class models the Path Item Object in an OpenAPI specification. It holds a collection of Operation Objects, one for each HTTP method (GET, POST, PUT, etc.) supported by a specific URL path.",
  "example": "final userPath = AcApiDocPath()\n  ..url = '/users'\n  ..get = AcApiDocOperation(summary: 'List all users')\n  ..post = AcApiDocOperation(summary: 'Create a new user');"
}) */
@AcReflectable()
class AcApiDocPath {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyUrl = "url";
  static const String keyConnect = "connect";
  static const String keyGet = "get";
  static const String keyPut = "put";
  static const String keyPost = "post";
  static const String keyDelete = "delete";
  static const String keyOptions = "options";
  static const String keyHead = "head";
  static const String keyPatch = "patch";
  static const String keyTrace = "trace";

  /* AcDoc({"summary": "The URL path template (e.g., '/users/{id}')."}) */
  @AcBindJsonProperty(key: keyUrl)
  String url = "";

  /* AcDoc({"summary": "An operation definition for the CONNECT method on this path."}) */
  @AcBindJsonProperty(key: keyConnect)
  AcApiDocOperation? connect;

  /* AcDoc({"summary": "An operation definition for the GET method on this path."}) */
  @AcBindJsonProperty(key: keyGet)
  AcApiDocOperation? get;

  /* AcDoc({"summary": "An operation definition for the PUT method on this path."}) */
  @AcBindJsonProperty(key: keyPut)
  AcApiDocOperation? put;

  /* AcDoc({"summary": "An operation definition for the POST method on this path."}) */
  @AcBindJsonProperty(key: keyPost)
  AcApiDocOperation? post;

  /* AcDoc({"summary": "An operation definition for the DELETE method on this path."}) */
  @AcBindJsonProperty(key: keyDelete)
  AcApiDocOperation? delete;

  /* AcDoc({"summary": "An operation definition for the OPTIONS method on this path."}) */
  @AcBindJsonProperty(key: keyOptions)
  AcApiDocOperation? options;

  /* AcDoc({"summary": "An operation definition for the HEAD method on this path."}) */
  @AcBindJsonProperty(key: keyHead)
  AcApiDocOperation? head;

  /* AcDoc({"summary": "An operation definition for the PATCH method on this path."}) */
  @AcBindJsonProperty(key: keyPatch)
  AcApiDocOperation? patch;

  /* AcDoc({"summary": "An operation definition for the TRACE method on this path."}) */
  @AcBindJsonProperty(key: keyTrace)
  AcApiDocOperation? trace;

  /* AcDoc({"summary": "Creates a new, empty instance of an API path definition."}) */
  AcApiDocPath();

  /* AcDoc({
    "summary": "Creates a new AcApiDocPath instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the path item."}
    ],
    "returns": "A new, populated AcApiDocPath instance.",
    "returns_type": "AcApiDocPath"
  }) */
  factory AcApiDocPath.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocPath();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the path item's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocPath"
  }) */
  AcApiDocPath fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current path instance to a JSON map.",
    "returns": "A JSON map representation of the path item.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the path item.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}