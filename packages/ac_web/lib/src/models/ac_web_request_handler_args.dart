import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_web/ac_web.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a deserialized incoming HTTP request.",
  "description": "This class encapsulates all the components of an HTTP request, including headers, path and query parameters, cookies, session data, and the request body. It is typically created by a web server framework from a raw request to provide a structured and easily accessible object.",
  "example": "// An AcWebRequest object is typically created by the server, not manually.\n// It might be used in a route handler like this:\n\nvoid handleUserRequest(AcWebRequest request) {\n  // Access path parameter: e.g., /users/{id}\n  final userId = request.pathParameters['id'];\n\n  // Access query parameter: e.g., /users?sort=asc\n  final sortBy = request.queryParameters['sort'];\n\n  // Access JSON body from a POST/PUT request\n  final userName = request.body['name'];\n\n  print('Fetching user \$userId, sorting by \$sortBy...');\n}"
}) */
@AcReflectable()
class AcWebRequestHandlerArgs {
  late AcWebRequest request;
  late AcLogger logger;

  AcWebRequestHandlerArgs({AcWebRequest? request,AcLogger? logger}){
    if(request != null){
      this.request = request;
    }
    if(logger != null){
      this.logger = logger;
    }
  }
}
