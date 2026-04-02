import '../ac_web_internal.dart';
import '../models/ac_web_request.dart';
import '../models/ac_web_response.dart';

/* AcDoc({
  "summary": "Abstract base class for all AcWeb request/response interceptors.",
  "description": "An interceptor sits in the request pipeline around route handlers. Override [onRequest] to inspect or mutate the incoming request, or to short-circuit the pipeline by returning an [AcWebResponse] directly. Override [onResponse] to inspect or mutate the outgoing response.\n\nInterceptors are executed in registration order for requests and in reverse order for responses.\n\nExample:\n```dart\nclass LoggingInterceptor extends AcWebInterceptor {\n  @override\n  Future<AcWebResponse?> onRequest(AcWebRequest request) async {\n    print('→ ${request.method} ${request.url}');\n    return null; // continue pipeline\n  }\n\n  @override\n  Future<AcWebResponse> onResponse(AcWebRequest request, AcWebResponse response) async {\n    print('← ${response.responseCode}');\n    return response;\n  }\n}\n```"
}) */
abstract class AcWebInterceptor {
  /* AcDoc({
    "summary": "The unique name for this interceptor, used for annotation-based lookup.",
    "description": "Defaults to the runtime type name. Override to provide a stable name."
  }) */
  String get name => runtimeType.toString();

  /* AcDoc({
    "summary": "Called before the route handler executes.",
    "description": "Return null to continue the interceptor chain and eventually call the handler. Return an [AcWebResponse] to short-circuit: the handler and all subsequent interceptors' onRequest will be skipped, and the returned response will flow through the onResponse chain in reverse.",
    "params": [
      {"name": "request", "description": "The incoming web request."}
    ],
    "returns": "Null to continue, or an AcWebResponse to short-circuit.",
    "returns_type": "Future<AcWebResponse?>"
  }) */
  Future<AcWebResponse?> onRequest(AcWebRequest request) async => null;

  /* AcDoc({
    "summary": "Called after the route handler executes (or after a short-circuit).",
    "description": "Receives the final response (from the handler or from a short-circuit). May mutate and return a different response. Executed in reverse interceptor order.",
    "params": [
      {"name": "request", "description": "The original incoming request."},
      {"name": "response", "description": "The response produced by the handler or a prior short-circuit."}
    ],
    "returns": "The (potentially modified) response.",
    "returns_type": "Future<AcWebResponse>"
  }) */
  Future<AcWebResponse> onResponse(
    AcWebRequest request,
    AcWebResponse response,
  ) async =>
      response;
}
