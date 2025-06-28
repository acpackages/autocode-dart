import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to inject a form field value into a handler parameter.",
  "description": "This annotation is used to decorate a parameter in a controller method, instructing the web framework to extract the value of a specific field from a submitted form (`application/x-www-form-urlencoded` or `multipart/form-data`) and provide it as an argument for that parameter.",
  "example": "// Assume a POST request from a form with fields 'email' and 'password'.\n\n@AcWebRoute(path: '/login', method: 'POST')\nvoid handleLogin(\n  @AcWebValueFromForm(key: 'email') String userEmail,\n  @AcWebValueFromForm(key: 'password') String userPassword,\n) {\n  // The framework automatically injects the form values:\n  // userEmail will contain the value of the 'email' form field.\n  // ... handler logic to authenticate the user ...\n}"
}) */
@AcReflectable()
class AcWebValueFromForm {
  /* AcDoc({
    "summary": "The name of the form field whose value should be injected."
  }) */
  final String key;

  /* AcDoc({
    "summary": "Creates an annotation to bind a method parameter to a form field.",
    "params": [
      {"name": "key", "description": "The name (key) of the form field to extract the value from."}
    ]
  }) */
  const AcWebValueFromForm({required this.key});
}