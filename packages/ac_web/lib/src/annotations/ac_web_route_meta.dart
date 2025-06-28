import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to provide rich documentation metadata for an API route.",
  "description": "This annotation is used to supplement a route's definition with detailed information for OpenAPI/Swagger documentation, such as a summary, a longer description, parameter details, and tags for grouping related endpoints.",
  "example": "@AcWebRoute(path: '/{id}', method: 'GET')\n@AcWebRouteMeta(\n  summary: 'Get User by ID',\n  description: 'Retrieves a single user object based on their unique numeric ID.',\n  tags: ['Users', 'Public']\n)\nvoid getUserById(AcWebRequest request) {\n  // ... handler logic ...\n}"
}) */
@AcReflectable()
class AcWebRouteMeta {
  /* AcDoc({
    "summary": "A short summary of what the route does.",
    "description": "This typically appears as the title or heading for the route in API documentation."
  }) */
  final String? summary;

  /* AcDoc({
    "summary": "A detailed explanation of the route's functionality.",
    "description": "This can be a longer, multi-line description providing details about the route's behavior, expected inputs, and possible outputs."
  }) */
  final String? description;

  /* AcDoc({
    "summary": "A list of parameter definitions for the route.",
    "description": "While many parameters can be inferred by the framework through reflection, this allows for manual overrides or additional parameter documentation."
  }) */
  final List<dynamic> parameters;

  /* AcDoc({
    "summary": "A list of tags for grouping the route in API documentation.",
    "description": "Routes with the same tag are typically grouped together in UIs like Swagger UI (e.g., 'Users', 'Authentication', 'Admin')."
  }) */
  final List<dynamic> tags;

  /* AcDoc({
    "summary": "Creates a metadata annotation for an API route.",
    "params": [
      {"name": "summary", "description": "A short summary of the route."},
      {"name": "description", "description": "A detailed description of the route."},
      {"name": "parameters", "description": "A list of manual parameter definitions."},
      {"name": "tags", "description": "A list of tags for grouping."}
    ]
  }) */
  const AcWebRouteMeta({
    this.summary = '',
    this.description = '',
    this.parameters = const [],
    this.tags = const [],
  });
}