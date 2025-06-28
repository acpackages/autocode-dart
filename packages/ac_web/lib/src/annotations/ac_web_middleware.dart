import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to apply middleware to a route or controller.",
  "description": "This annotation is used to decorate a controller or a specific route method to specify a middleware class that should be executed before the main handler. The web framework uses the provided class name to look up and run the corresponding middleware logic.",
  "example": "// A simple logging middleware class (implementation not shown)\nclass LoggingMiddleware { ... }\n\n// Apply the middleware to a specific route\n@AcWebController()\nclass UserController {\n\n  @AcWebRoute(path: '/{id}', method: 'GET')\n  @AcWebMiddleware('LoggingMiddleware')\n  void getUserById(AcWebRequest request) {\n    // The LoggingMiddleware would run before this handler is executed.\n  }\n}"
}) */
@AcReflectable()
class AcWebMiddleware {
  /* AcDoc({
    "summary": "The name of the middleware class to be executed."
  }) */
  final String middlewareClass;

  /* AcDoc({
    "summary": "Creates the middleware annotation.",
    "params": [
      {"name": "middlewareClass", "description": "The string name of the middleware class to apply."}
    ]
  }) */
  const AcWebMiddleware(this.middlewareClass);
}