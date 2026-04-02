import '../ac_web_internal.dart';
import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "Annotation to apply one or more interceptors to a controller class or route method.",
  "description": "Apply this annotation to a controller class to run the specified interceptors on every route in the controller, or apply it to a specific method to only affect that route.\n\nThe interceptor must be registered on the AcWeb instance via addInterceptor() before any requests arrive, so the framework can look it up by name.\n\nExample:\n```dart\n// Apply to all routes in the controller\n@AcWebController()\n@AcWebRoute(path: '/users', method: 'GET')\n@AcWebUseInterceptor('AcWebJwtInterceptor')\nclass UserController { ... }\n\n// Apply to a single route\n@AcWebRoute(path: '/{id}', method: 'DELETE')\n@AcWebUseInterceptor('AcWebJwtInterceptor', 'AdminOnlyInterceptor')\nFuture<AcWebResponse> deleteUser(...) { ... }\n```"
}) */
@AcReflectable()
class AcWebUseInterceptor {
  /* AcDoc({
    "summary": "Names of the interceptor classes to apply.",
    "description": "Each string must match the name property of a registered AcWebInterceptor."
  }) */
  final List<String> interceptorNames;

  /* AcDoc({
    "summary": "Creates the interceptor annotation.",
    "params": [
      {"name": "interceptorNames", "description": "One or more interceptor class names to apply."}
    ]
  }) */
  const AcWebUseInterceptor(this.interceptorNames);
}
