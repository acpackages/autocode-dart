import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to mark a class as a service.",
  "description": "This is a marker annotation used to identify a class that contains business logic. Service classes are typically used to orchestrate operations between controllers and data repositories. The framework can use this annotation to manage the lifecycle of the service and handle its dependency injection into other components like controllers.",
  "example": "@AcWebService()\nclass UserRegistrationService {\n  final UserRepository _userRepo;\n  final EmailService _emailService;\n\n  // Dependencies are often injected into the service's constructor.\n  UserRegistrationService(this._userRepo, this._emailService);\n\n  Future<User> register(String name, String email, String password) async {\n    // ... business logic for registration ...\n    final newUser = await _userRepo.create(name, email, password);\n    await _emailService.sendWelcomeEmail(newUser);\n    return newUser;\n  }\n}\n\n// A controller can then depend on this service.\n@AcWebController()\nclass AuthController {\n  final UserRegistrationService _registrationService;\n\n  AuthController(this._registrationService);\n\n  // ... routes that use the service ...\n}"
}) */
@AcReflectable()
class AcWebService {
  /* AcDoc({
    "summary": "Creates the marker annotation for a service class."
  }) */
  const AcWebService();
}