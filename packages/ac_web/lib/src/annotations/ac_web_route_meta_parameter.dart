import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "Represents the manual definition of a single parameter for an API route.",
  "description": "This class is used to explicitly define a parameter for an endpoint, typically within the `parameters` list of an `@AcWebRouteMeta` annotation. It allows for detailed documentation of parameters, which is then used to generate a precise OpenAPI/Swagger specification.",
  "example": "@AcWebRoute(path: '/users', method: 'GET')\n@AcWebRouteMeta(\n  summary: 'List all users',\n  parameters: [\n    AcWebRouteMetaParameter(\n      name: 'limit',\n      description: 'The maximum number of users to return.',\n      required: false,\n      schema: {'type': 'integer', 'format': 'int32'}\n    )\n  ]\n)\nvoid listUsers(AcWebRequest request) {\n  // ... handler logic ...\n}"
}) */
@AcReflectable()
class AcWebRouteMetaParameter {
  /* AcDoc({
    "summary": "A detailed description of the parameter."
  }) */
  final String description;

  /* AcDoc({
    "summary": "The name of the parameter."
  }) */
  final String name;

  /* AcDoc({
    "summary": "Whether the parameter is required for the request.",
    "description": "A boolean indicating if the parameter must be provided by the client."
  }) */
  final bool required;

  /* AcDoc({
    "summary": "Specifies how array/object parameters are serialized.",
    "description": "When true, array or object values generate separate parameters for each value/property. See the OpenAPI specification for more details."
  }) */
  final bool explode;

  /* AcDoc({
    "summary": "The schema definition for the parameter.",
    "description": "Defines the data type of the parameter according to the OpenAPI schema specification (e.g., {'type': 'string', 'format': 'date-time'})."
  }) */
  final List<dynamic> schema;

  /* AcDoc({
    "summary": "Creates a metadata definition for a single route parameter.",
    "params": [
      {"name": "description", "description": "A description of the parameter."},
      {"name": "name", "description": "The name of the parameter."},
      {"name": "required", "description": "Whether the parameter is required. Defaults to `false`."},
      {"name": "explode", "description": "How the parameter is serialized. Defaults to `false`."},
      {"name": "schema", "description": "The OpenAPI schema for the parameter."}
    ]
  }) */
  const AcWebRouteMetaParameter({
    this.description = '',
    this.name = '',
    this.required = false, // Changed to bool for correctness
    this.explode = false,  // Changed to bool for correctness
    this.schema = const [],
  });
}