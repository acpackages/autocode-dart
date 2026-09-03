import '../ac_web_internal.dart';
import 'package:autocode/autocode.dart';
import '../models/ac_web_request.dart';
import '../models/ac_web_response.dart';
import './ac_web_interceptor.dart';


/* AcDoc({
  "summary": "A built-in JWT (JSON Web Token) interceptor for AcWeb.",
  "description": "This interceptor validates a Bearer token from the Authorization header on every request. On success it stores the decoded JWT claims map inside request.internalParams['jwt_claims']. On failure it short-circuits with a 401 Unauthorized JSON response.\n\nUsage:\n```dart\nfinal app = AcWeb();\napp.addInterceptor(\n  AcWebJwtInterceptor(\n    secretKey: 'my-secret',\n    excludePaths: ['/auth/login', '/auth/register'],\n  )\n);\n```\n\nOr use a custom verifier:\n```dart\napp.addInterceptor(\n  AcWebJwtInterceptor.withVerifier(\n    verifyToken: (token) async {\n      // return claims map on success, null on failure\n      return await myJwtLibrary.verify(token);\n    },\n  )\n);\n```"
}) */
class AcWebJwtInterceptor extends AcWebInterceptor {
  /* AcDoc({"summary": "Paths that bypass JWT verification."}) */
  final List<String> excludePaths;

  /* AcDoc({"summary": "Optional HMAC-SHA256 secret key for built-in verification."}) */
  final String? secretKey;

  /* AcDoc({"summary": "Optional custom token verifier. Return claims on success, null on failure."}) */
  final Future<Map<String, dynamic>?> Function(String token)? verifyToken;

  /* AcDoc({"summary": "The header key to look up. Defaults to 'authorization'."}) */
  final String headerKey;

  /* AcDoc({"summary": "Key under request.internalParams where decoded claims are stored."}) */
  static const String claimsKey = 'jwt_claims';

  @override
  String get name => 'AcWebJwtInterceptor';

  /* AcDoc({
    "summary": "Creates a JWT interceptor using built-in HMAC-SHA256 verification.",
    "params": [
      {"name": "secretKey", "description": "The HMAC-SHA256 secret used to verify tokens."},
      {"name": "excludePaths", "description": "Paths that skip JWT verification."},
      {"name": "headerKey", "description": "HTTP header name to look for (default: 'authorization')."}
    ]
  }) */
  AcWebJwtInterceptor({
    required this.secretKey,
    this.excludePaths = const [],
    this.headerKey = 'authorization',
  }) : verifyToken = null;

  /* AcDoc({
    "summary": "Creates a JWT interceptor with a custom async token verifier.",
    "params": [
      {"name": "verifyToken", "description": "A function that validates the token and returns claims, or null on failure."},
      {"name": "excludePaths", "description": "Paths that skip JWT verification."},
      {"name": "headerKey", "description": "HTTP header name to look for."}
    ]
  }) */
  AcWebJwtInterceptor.withVerifier({
    required Future<Map<String, dynamic>?> Function(String token) this.verifyToken,
    this.excludePaths = const [],
    this.headerKey = 'authorization',
  }) : secretKey = null;

  @override
  Future<AcWebResponse?> onRequest(AcWebRequest request) async {
    // Skip excluded paths
    final path = '/${request.url.split('?').first}'.replaceAll('//', '/');
    for (final excluded in excludePaths) {
      final cleanExcluded = excluded.startsWith('/') ? excluded : '/$excluded';
      if (path == cleanExcluded || path.startsWith(cleanExcluded)) {
        return null;
      }
    }

    // Extract bearer token from header
    final authHeader = _getHeader(request, headerKey);
    if (authHeader == null || !authHeader.toLowerCase().startsWith('bearer ')) {
      return _unauthorized('Missing or invalid Authorization header');
    }

    final token = authHeader.substring(7).trim();
    if (token.isEmpty) {
      return _unauthorized('Empty token');
    }

    Map<String, dynamic>? claims;

    if (verifyToken != null) {
      claims = await verifyToken!(token);
    } else if (secretKey != null && secretKey!.isNotEmpty) {
      claims = AcEncryption.verifyToken(token: token, secret: secretKey!);
    }

    if (claims == null) {
      return _unauthorized('Token is invalid or expired');
    }

    request.internalParams[claimsKey] = claims;
    return null; // continue
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String? _getHeader(AcWebRequest request, String key) {
    final lower = key.toLowerCase();
    for (final entry in request.headers.entries) {
      if (entry.key.toLowerCase() == lower) {
        return entry.value?.toString();
      }
    }
    return null;
  }


  AcWebResponse _unauthorized(String message) {
    return AcWebResponse.json(
      data: {'error': 'Unauthorized', 'message': message},
      responseCode: AcEnumHttpResponseCode.unauthorized,
    );
  }
}
