import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to specify authorization requirements for a route.",
  "description": "This annotation is used to decorate a controller method or a route handler to enforce role-based access control. The web framework can inspect this annotation to determine if a user has the required permissions before executing the handler.",
  "example": "@AcWebRoute(path: '/admin/dashboard', method: 'GET')\n@AcWebAuthorize(roles: ['admin', 'super_admin'])\nFuture<AcWebResponse> getAdminDashboard(AcWebRequest request) {\n  // This code will only execute if the user has the 'admin' or 'super_admin' role.\n  return AcWebResponse.json(data: {'message': 'Welcome to the admin dashboard!'});\n}"
}) */
@AcReflectable()
class AcWebAuthorize {
  /* AcDoc({
    "summary": "A list of roles that are permitted to access the route.",
    "description": "If a user's roles intersect with this list, they are granted access. If the list is empty or null, it may imply that any authenticated user is permitted, depending on the framework's implementation."
  }) */
  final List<String>? roles;

  /* AcDoc({
    "summary": "Creates an authorization requirement annotation.",
    "params": [
      {"name": "roles", "description": "An optional list of role names required for access."}
    ]
  }) */
  const AcWebAuthorize({this.roles});
}