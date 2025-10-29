import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_web/ac_web.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a deserialized incoming HTTP request.",
  "description": "This class encapsulates all the components of an HTTP request, including headers, path and query parameters, cookies, session data, and the request body. It is typically created by a web server framework from a raw request to provide a structured and easily accessible object.",
  "example": "// An AcWebRequest object is typically created by the server, not manually.\n// It might be used in a route handler like this:\n\nvoid handleUserRequest(AcWebRequest request) {\n  // Access path parameter: e.g., /users/{id}\n  final userId = request.pathParameters['id'];\n\n  // Access query parameter: e.g., /users?sort=asc\n  final sortBy = request.queryParameters['sort'];\n\n  // Access JSON body from a POST/PUT request\n  final userName = request.body['name'];\n\n  print('Fetching user \$userId, sorting by \$sortBy...');\n}"
}) */
@AcReflectable()
class AcWebRequest {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions and fixed typo.
  static const String keyCookies = 'cookies';
  static const String keyBody = 'body';
  static const String keyFiles = 'files';
  static const String keyQueryParameters = 'get'; // Renamed for clarity in docs
  static const String keyHeaders = 'headers';
  static const String keyMethod = 'method';
  static const String keyPathParameters = 'pathParameters';
  static const String keyFormFields = 'post'; // Renamed for clarity in docs
  static const String keySession = 'session';
  static const String keyUrl = 'url';

  /* AcDoc({
    "summary": "The parsed JSON body of the request.",
    "description": "Typically used for POST, PUT, and PATCH requests with a `Content-Type` of `application/json`."
  }) */
  @AcBindJsonProperty(key: keyBody)
  Map<String, dynamic> body = {};

  /* AcDoc({"summary": "A map of cookies sent with the request."}) */
  @AcBindJsonProperty(key: keyCookies)
  Map<String, dynamic> cookies = {};

  /* AcDoc({
    "summary": "A map of uploaded files.",
    "description": "Used for `multipart/form-data` requests to access file uploads."
  }) */
  @AcBindJsonProperty(key: keyFiles)
  Map<String, AcWebFile> files = {};

  /* AcDoc({
    "summary": "A map of URL query parameters.",
    "description": "Represents the key-value pairs in the query string of the URL (e.g., `?id=123&name=test`)."
  }) */
  @AcBindJsonProperty(key: keyQueryParameters)
  Map<String, dynamic> get queryParameters => get; // Keep original name for compatibility, use getter for clarity.
  Map<String, dynamic> get = {};

  /* AcDoc({"summary": "A map of HTTP headers sent with the request."}) */
  @AcBindJsonProperty(key: keyHeaders)
  Map<String, dynamic> headers = {};

  /* AcDoc({"summary": "The HTTP method of the request (e.g., 'GET', 'POST')."}) */
  @AcBindJsonProperty(key: keyMethod)
  String method = "";

  /* AcDoc({
    "summary": "A map of parameters extracted from the request's path.",
    "description": "For a route defined as `/users/{id}`, a request to `/users/123` would result in `{'id': '123'}`."
  }) */
  @AcBindJsonProperty(key: keyPathParameters)
  Map<String, dynamic> pathParameters = {};

  /* AcDoc({
    "summary": "A map of form fields from the request body.",
    "description": "Typically used for POST requests with a `Content-Type` of `application/x-www-form-urlencoded`."
  }) */
  @AcBindJsonProperty(key: keyFormFields)
  Map<String, dynamic> get formFields => post; // Keep original name for compatibility, use getter for clarity.
  Map<String, dynamic> post = {};

  /* AcDoc({
    "summary": "A map of session data associated with the request.",
    "description": "Contains server-side session variables for the requesting user."
  }) */
  @AcBindJsonProperty(key: keySession)
  Map<String, dynamic> session = {};

  /* AcDoc({"summary": "The full original URL of the request."}) */
  @AcBindJsonProperty(key: keyUrl)
  String url = "";

  /* AcDoc({"summary": "Creates a new, empty instance of a web request."}) */
  AcWebRequest();

  /* AcDoc({
    "summary": "Creates a new AcWebRequest instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the request."}
    ],
    "returns": "A new, populated AcWebRequest instance.",
    "returns_type": "AcWebRequest"
  }) */
  factory AcWebRequest.instanceFromJson(Map<String, dynamic> jsonData) {
    final instance = AcWebRequest();
    instance.fromJson(jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the request's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcWebRequest"
  }) */
  AcWebRequest fromJson(Map<String, dynamic> jsonData) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current request instance to a JSON map.",
    "returns": "A JSON map representation of the request.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the request.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }
}
