import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart'; // Assuming your Dart package imports

/* AcDoc({
  "summary": "Represents a standardized response from a web API.",
  "description": "This class extends `AcResult` to provide a standard structure for API responses. While it adds no new properties of its own, it serves as a specific type to encapsulate the success state, message, and data payload returned by an API endpoint. This ensures consistency across all web API calls.",
  "example": "Future<AcWebApiResponse> fetchUserData(int userId) async {\n  final response = AcWebApiResponse();\n  try {\n    // ... fetch user data from a service ...\n    final user = await userApiService.fetch(userId);\n    response.setSuccess(value: user.toJson(), message: 'User found.');\n  } catch (e) {\n    response.setFailure(message: 'User not found or an error occurred.');\n  }\n  return response;\n}"
}) */
@AcReflectable()
class AcWebApiResponse extends AcResult {
  /* AcDoc({
    "summary": "Creates a new instance of a web API response.",
    "description": "Initializes an empty response object, which can then be populated with success or failure details using methods inherited from `AcResult`."
  }) */
  AcWebApiResponse();
}