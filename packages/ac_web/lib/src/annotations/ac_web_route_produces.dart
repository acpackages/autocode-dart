import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to specify the MIME type a route produces.",
  "description": "This annotation is used to decorate a route handler to declare the `Content-Type` of the response it will generate. This information is crucial for clients to correctly interpret the response body and for generating accurate OpenAPI/Swagger documentation.",
  "example": "@AcWebRoute(path: '/user/profile', method: 'GET')\n@AcWebRouteProduces('application/json')\nvoid getUserProfile(AcWebRequest request) {\n  // The framework now knows this endpoint returns JSON.\n  final userProfile = {'name': 'John', 'email': 'john.doe@example.com'};\n  return AcWebResponse.json(data: userProfile);\n}"
}) */
@AcReflectable()
class AcWebRouteProduces {
  /* AcDoc({
    "summary": "The content type of the response body.",
    "description": "A standard MIME type string, such as 'application/json', 'text/html', or 'application/xml'."
  }) */
  final String contentType;

  /* AcDoc({
    "summary": "Creates a 'produces' annotation for a route.",
    "params": [
      {"name": "contentType", "description": "The MIME type that the route's handler will return."}
    ]
  }) */
  const AcWebRouteProduces({required this.contentType});
}