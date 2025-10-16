import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to define the path and method for an API route.",
  "description": "This annotation is used to decorate a controller class to set a base path, or a controller method to define a specific endpoint. The web framework reflects on these annotations to build its routing table.",
  "example": "@AcWebController()\n@AcWebRoute('/users') // Defines a base path for all methods in this controller\nclass UserController {\n\n  // This method will be available at GET /users/{id}\n  @AcWebRoute('/{id}', method: 'GET')\n  void getUserById(AcWebRequest request) {\n    // ... handler logic ...\n  }\n\n  // This method will be available at POST /users/\n  @AcWebRoute('/', method: 'POST')\n  void createUser(AcWebRequest request) {\n    // ... handler logic ...\n  }\n}"
}) */
@AcReflectable()
class AcWebRoute {
  /* AcDoc({
    "summary": "The URL path segment for the route.",
    "description": "This can be a static path (e.g., '/all') or contain path parameters (e.g., '/{id}'). When used on a class, it defines a prefix for all method routes within that class."
  }) */
  final String path;

  /* AcDoc({
    "summary": "The HTTP method for the route (e.g., 'GET', 'POST').",
    "description": "Defaults to 'GET' if not specified."
  }) */
  final String method;

  /* AcDoc({
    "summary": "Creates a route definition annotation.",
    "params": [
      {"name": "path", "description": "The URL path for the route."},
      {"name": "method", "description": "The HTTP method for the route. Defaults to 'GET'."}
    ]
  }) */
  const AcWebRoute({required this.path, this.method = 'GET'});
}