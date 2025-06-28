import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to inject a cookie value into a handler parameter.",
  "description": "This annotation is used to decorate a parameter in a controller method, instructing the web framework to extract the value of a specific cookie from the incoming HTTP request and provide it as an argument for that parameter.",
  "example": "// Assume a request is sent with a cookie: 'session_id=abc123xyz'\n\n@AcWebRoute(path: '/profile', method: 'GET')\nvoid getUserProfile(\n  @AcWebValueFromCookie(key: 'session_id') String sessionId,\n) {\n  // The framework automatically injects the value:\n  // sessionId will be 'abc123xyz'\n  // ... handler logic to validate the session ...\n}"
}) */
@AcReflectable()
class AcWebValueFromCookie {
  /* AcDoc({
    "summary": "The name of the cookie whose value should be injected."
  }) */
  final String key;

  /* AcDoc({
    "summary": "Creates an annotation to bind a method parameter to a request cookie.",
    "params": [
      {"name": "key", "description": "The name of the cookie to extract the value from."}
    ]
  }) */
  const AcWebValueFromCookie({required this.key});
}