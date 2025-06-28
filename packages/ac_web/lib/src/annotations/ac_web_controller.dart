import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to mark a class as a web controller.",
  "description": "This is a marker annotation used to identify a class as a web controller. The web framework's `registerController` method will reflect on classes marked with `@AcWebController` to find and register their methods as API routes.",
  "example": "@AcWebController()\n@AcWebRoute(path: '/users')\nclass UserController {\n\n  @AcWebRoute(path: '/{id}', method: 'GET')\n  void getUserById(AcWebRequest request) {\n    // handler logic\n  }\n\n}"
}) */
@AcReflectable()
class AcWebController {
  /* AcDoc({
    "summary": "Creates the marker annotation for a web controller."
  }) */
  const AcWebController();
}