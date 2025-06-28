import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to inject a URL path parameter into a handler parameter.",
  "description": "This annotation is used to decorate a parameter in a controller method, instructing the web framework to extract a value from a dynamic segment of the URL path and provide it as an argument for that parameter.",
  "example": "// For a route defined as: @AcWebRoute(path: '/users/{userId}')\n\nvoid getUserById(\n  @AcWebValueFromPath(key: 'userId') int id,\n) {\n  // If a request is made to '/users/123',\n  // the framework automatically injects the value:\n  // id will be 123 (with type casting).\n  // ... handler logic to fetch the user ...\n}"
}) */
@AcReflectable()
class AcWebValueFromPath {
  /* AcDoc({
    "summary": "The name of the path parameter whose value should be injected.",
    "description": "This must match the name of the dynamic segment defined in the route's URL template (e.g., the 'id' in '/users/{id}')."
  }) */
  final String key;

  /* AcDoc({
    "summary": "Creates an annotation to bind a method parameter to a URL path segment.",
    "params": [
      {"name": "key", "description": "The name of the path parameter to extract the value from."}
    ]
  }) */
  const AcWebValueFromPath({required this.key});
}