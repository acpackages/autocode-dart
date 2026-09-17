import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to inject an HTTP header value into a handler parameter.",
  "description": "This annotation is used to decorate a parameter in a controller method, instructing the web framework to extract the value of a specific HTTP header from the incoming request and provide it as an argument for that parameter.",
  "example": "// Assume a request is sent with a header: 'Authorization: Bearer my-secret-token'\n\n@AcWebRoute(path: '/secure-data', method: 'GET')\nvoid getSecureData(\n  @AcWebValueFromHeader(key: 'Authorization') String authToken,\n) {\n  // The framework automatically injects the header value:\n  // authToken will be 'Bearer my-secret-token'\n  // ... handler logic to validate the token ...\n}"
}) */
@AcReflectable()
class AcWebValueFromHeader {
  /* AcDoc({
    "summary": "The name of the HTTP header whose value should be injected.",
    "description": "The key is case-insensitive, as per HTTP header standards (e.g., 'Content-Type' is the same as 'content-type')."
  }) */
  final String key;

  /* AcDoc({
    "summary": "Creates an annotation to bind a method parameter to a request header.",
    "params": [
      {"name": "key", "description": "The name of the HTTP header to extract the value from."}
    ]
  }) */
  const AcWebValueFromHeader({required this.key});
}