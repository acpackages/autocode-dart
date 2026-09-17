import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to inject a value from the request body into a handler parameter.",
  "description": "This annotation is used to decorate a parameter in a controller method, instructing the web framework to extract a specific value from the incoming JSON request body and provide it as an argument for that parameter.",
  "example": "// Assume a POST request with body: {'username': 'john_doe', 'notify': true}\n\n@AcWebRoute(path: '/register', method: 'POST')\nvoid registerUser(\n  @AcWebValueFromBody(key: 'username') String name,\n  @AcWebValueFromBody(key: 'notify') bool shouldNotify,\n) {\n  // The framework automatically injects the values:\n  // name will be 'john_doe'\n  // shouldNotify will be true\n  // ... handler logic ...\n}"
}) */
@AcReflectable()
class AcWebValueFromBody {
  /* AcDoc({
    "summary": "The key in the JSON request body whose value should be injected."
  }) */
  final String key;

  /* AcDoc({
    "summary": "Creates an annotation to bind a method parameter to a request body key.",
    "params": [
      {"name": "key", "description": "The key of the value to extract from the JSON body."}
    ]
  }) */
  const AcWebValueFromBody({required this.key});
}