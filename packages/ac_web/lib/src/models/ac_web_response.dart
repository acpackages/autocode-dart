import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents an outgoing HTTP response to be sent to a client.",
  "description": "This class encapsulates all components of an HTTP response, including the status code, headers, cookies, session data, and the response body (content). It provides several static factory-like methods for easily creating common response types (e.g., JSON, redirects, errors).",
  "example": "// Inside a route handler, returning a JSON response.\nAcWebResponse handleRequest(AcWebRequest request) {\n  final user = {'id': 1, 'name': 'John Doe'};\n  return AcWebResponse.json(\n    data: user,\n    responseCode: AcEnumHttpResponseCode.ok\n  );\n}\n\n// Creating a redirect.\nfinal response = AcWebResponse.redirect(url: '/login');"
}) */
@AcReflectable()
class AcWebResponse {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyCookies = 'cookies';
  static const String keyContent = 'content';
  static const String keyHeaders = 'headers';
  static const String keyResponseCode = 'responseCode';
  static const String keyResponseType = 'responseType';
  static const String keySession = 'session';

  /* AcDoc({
    "summary": "A map of cookies to be set in the client's browser."
  }) */
  @AcBindJsonProperty(key: keyCookies)
  Map<String, dynamic> cookies = {};

  /* AcDoc({
    "summary": "The body content of the response.",
    "description": "The type of this value is dynamic. For a JSON response, it's typically a Map or List. For a raw response, it could be a String or bytes. For a redirect, it's the target URL."
  }) */
  @AcBindJsonProperty(key: keyContent)
  dynamic content;

  /* AcDoc({
    "summary": "A map of HTTP headers to be sent with the response."
  }) */
  @AcBindJsonProperty(key: keyHeaders)
  Map<String, dynamic> headers = {};

  /* AcDoc({"summary": "The HTTP status code for the response (e.g., 200 OK, 404 Not Found)."}) */
  @AcBindJsonProperty(key: keyResponseCode)
  AcEnumHttpResponseCode responseCode = AcEnumHttpResponseCode.notFound;

  /* AcDoc({
    "summary": "The type of response, which guides how the content is handled.",
    "description": "An enum value indicating if the response is JSON, raw text, a redirect, etc."
  }) */
  @AcBindJsonProperty(key: keyResponseType)
  AcEnumWebResponseType responseType = AcEnumWebResponseType.text;

  /* AcDoc({
    "summary": "A map of session data to be saved or updated for the client."
  }) */
  @AcBindJsonProperty(key: keySession)
  Map<String, dynamic> session = {};

  /* AcDoc({
    "summary": "Creates a new, empty instance of a web response."
  }) */
  AcWebResponse();

  /* AcDoc({
    "summary": "Creates a response for an internal server error (500).",
    "params": [
      {"name": "data", "description": "Optional data to include in the response body, often for debugging."},
      {"name": "responseCode", "description": "The specific error code. Defaults to 500."}
    ],
    "returns": "A configured `AcWebResponse` for an error.",
    "returns_type": "AcWebResponse"
  }) */
  static AcWebResponse internalError({
    dynamic data,
    AcEnumHttpResponseCode responseCode =
        AcEnumHttpResponseCode.internalServerError,
  }) {
    final response = AcWebResponse();
    response.responseCode = responseCode;
    response.content = data;
    return response;
  }

  /* AcDoc({
    "summary": "Creates a JSON response.",
    "description": "Configures the response to send JSON data with the appropriate `Content-Type` header.",
    "params": [
      {"name": "data", "description": "The data (typically a Map or List) to be JSON-encoded."},
      {"name": "responseCode", "description": "The HTTP status code. Defaults to 200 OK."}
    ],
    "returns": "A configured `AcWebResponse` for sending JSON.",
    "returns_type": "AcWebResponse"
  }) */
  static AcWebResponse json({
    required dynamic data,
    AcEnumHttpResponseCode responseCode = AcEnumHttpResponseCode.ok,
  }) {
    final response = AcWebResponse();
    response.responseCode = responseCode;
    response.responseType = AcEnumWebResponseType.json;
    response.content = data;
    response.headers['Content-Type'] = 'application/json';
    return response;
  }

  /* AcDoc({
    "summary": "Creates a standard Not Found (404) response.",
    "returns": "A configured `AcWebResponse` with a 404 status code.",
    "returns_type": "AcWebResponse"
  }) */
  static AcWebResponse notFound() {
    final response = AcWebResponse();
    response.responseCode = AcEnumHttpResponseCode.notFound;
    return response;
  }

  /* AcDoc({
    "summary": "Creates a response with raw content.",
    "description": "Used for sending content like HTML, plain text, or binary data with custom headers.",
    "params": [
      {"name": "content", "description": "The raw content to send (e.g., a String or Uint8List)."},
      {"name": "responseCode", "description": "The HTTP status code. Defaults to 200 OK."},
      {"name": "headers", "description": "A map of headers to send with the response."}
    ],
    "returns": "A configured `AcWebResponse` for sending raw data.",
    "returns_type": "AcWebResponse"
  }) */
  static AcWebResponse raw({
    required dynamic content,
    AcEnumHttpResponseCode responseCode = AcEnumHttpResponseCode.ok,
    Map<String, dynamic> headers = const {},
  }) {
    final response = AcWebResponse();
    response.responseCode = responseCode;
    response.responseType = AcEnumWebResponseType.raw;
    response.content = content;
    response.headers = headers;
    return response;
  }

  /* AcDoc({
    "summary": "Creates a redirect response.",
    "description": "Configures the response to redirect the client to a new URL.",
    "params": [
      {"name": "url", "description": "The target URL for the redirect."},
      {"name": "responseCode", "description": "The redirect status code (e.g., 302, 301). Defaults to 307 (Temporary Redirect)."}
    ],
    "returns": "A configured `AcWebResponse` for a redirect.",
    "returns_type": "AcWebResponse"
  }) */
  static AcWebResponse redirect({
    required String url,
    AcEnumHttpResponseCode responseCode =
        AcEnumHttpResponseCode.temporaryRedirect,
  }) {
    final response = AcWebResponse();
    response.responseCode = responseCode;
    response.responseType = AcEnumWebResponseType.redirect;
    response.content = url;
    return response;
  }

  /* AcDoc({
    "summary": "Creates a response by rendering a view template.",
    "description": "This is a placeholder for view rendering logic, which depends on the specific backend server and templating engine being used.",
    "params": [
      {"name": "template", "description": "The name or path of the view template to render."},
      {"name": "responseCode", "description": "The HTTP status code. Defaults to 200 OK."}
    ],
    "returns": "An empty `AcWebResponse`. The actual implementation would populate this with the rendered HTML.",
    "returns_type": "AcWebResponse"
  }) */
  static AcWebResponse view({
    required String template,
    AcEnumHttpResponseCode responseCode = AcEnumHttpResponseCode.ok,
  }) {
    // This is a placeholder for view rendering logic.
    // The actual implementation would use a templating engine.
    final response = AcWebResponse();
    response.responseCode = responseCode;
    response.responseType = AcEnumWebResponseType.view;
    response.content =
        '<html><body>View: $template</body></html>'; // Example content
    response.headers['Content-Type'] = 'text/html';
    return response;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the response properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcWebResponse"
  }) */
  AcWebResponse fromJson(Map<String, dynamic> jsonData) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current response instance to a JSON map.",
    "returns": "A JSON map representation of the response.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the response.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}
