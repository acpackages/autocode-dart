import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to specify the MIME type a route consumes.",
  "description": "This annotation is used to decorate a route handler to indicate the expected `Content-Type` of the incoming request body. This information can be used by the framework to correctly parse the body (e.g., as JSON or form data) and to generate accurate OpenAPI/Swagger documentation.",
  "example": "@AcWebRoute(path: '/', method: 'POST')\n@AcWebRouteConsumes('application/json')\nvoid createUser(AcWebRequest request) {\n  // The framework now knows to parse the request body as JSON.\n  final userName = request.body['name'];\n  // ... handler logic ...\n}"
}) */
@AcReflectable()
class AcWebRouteConsumes {
  /* AcDoc({
    "summary": "The expected content type of the request body.",
    "description": "A standard MIME type string, such as 'application/json', 'application/x-www-form-urlencoded', or 'multipart/form-data'."
  }) */
  final String contentType;

  /* AcDoc({
    "summary": "Creates a 'consumes' annotation for a route.",
    "params": [
      {"name": "contentType", "description": "The MIME type that the route's handler expects."}
    ]
  }) */
  const AcWebRouteConsumes(this.contentType);
}