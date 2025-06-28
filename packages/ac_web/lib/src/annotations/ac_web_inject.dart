import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to mark a class or dependency for injection.",
  "description": "This is a marker annotation used to identify a class (often a service or repository) that should be managed by a dependency injection (DI) container. The framework can then automatically create an instance of this class and inject it into other components, such as controllers.",
  "example": "// 1. Mark a service class for injection.\n@AcWebInject()\nclass UserService {\n  User getUser(int id) {\n    // ... logic to get user ...\n  }\n}\n\n// 2. In a controller, a constructor parameter can be used to receive the injected service.\n@AcWebController()\nclass UserController {\n  final UserService userService;\n\n  // The framework's DI container will automatically provide an instance of UserService.\n  UserController(this.userService);\n\n  @AcWebRoute(path: '/{id}', method: 'GET')\n  void getUserById(AcWebRequest request) {\n    final user = userService.getUser(request.pathParameters['id']);\n    // ...\n  }\n}"
}) */
@AcReflectable()
class AcWebInject {
  /* AcDoc({
    "summary": "Creates the marker annotation for dependency injection."
  }) */
  const AcWebInject();
}