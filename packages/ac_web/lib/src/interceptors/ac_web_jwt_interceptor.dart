import 'dart:typed_data';
import '../ac_web_internal.dart';
import 'dart:convert';
import 'package:autocode/autocode.dart';
import '../models/ac_web_request.dart';
import '../models/ac_web_response.dart';
import './ac_web_interceptor.dart';
import 'package:crypto/crypto.dart';

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
      claims = _verifyHs256(token, secretKey!);
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

  /* AcDoc({
    "summary": "Verifies an HS256-signed JWT using the supplied secret.",
    "description": "Validates the signature and checks exp/nbf claims. Returns the payload claims on success, null if the token is invalid or expired.",
    "returns_type": "Map<String, dynamic>?"
  }) */
  Map<String, dynamic>? _verifyHs256(String token, String secret) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Verify signature
      final signingInput = '${parts[0]}.${parts[1]}';
      final keyBytes = utf8.encode(secret);
      final hmac = Hmac(sha256, keyBytes);
      final digest = hmac.convert(utf8.encode(signingInput));
      final expectedSignature = _base64UrlEncode(Uint8List.fromList(digest.bytes));

      if (expectedSignature != parts[2]) return null;

      // Decode payload
      final payloadJson = utf8.decode(_base64UrlDecode(parts[1]));
      final claims = jsonDecode(payloadJson) as Map<String, dynamic>;

      // Validate time claims
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (claims.containsKey('exp') && (claims['exp'] as int) < now) return null;
      if (claims.containsKey('nbf') && (claims['nbf'] as int) > now) return null;

      return claims;
    } catch (_) {
      return null;
    }
  }

  String _base64UrlEncode(Uint8List bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  Uint8List _base64UrlDecode(String input) {
    // Pad to multiple of 4
    final padded = input.padRight((input.length + 3) ~/ 4 * 4, '=');
    return base64Url.decode(padded);
  }

  AcWebResponse _unauthorized(String message) {
    return AcWebResponse.json(
      data: {'error': 'Unauthorized', 'message': message},
      responseCode: AcEnumHttpResponseCode.unauthorized,
    );
  }
}
