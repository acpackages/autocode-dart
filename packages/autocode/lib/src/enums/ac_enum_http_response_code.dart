import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of standard HTTP response status codes and their meanings.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumHttpResponseCode {
  continue_(100),
  switchingProtocols(101),
  processing(102),
  ok(200),
  created(201),
  accepted(202),
  nonAuthoritativeInformation(203),
  noContent(204),
  resetContent(205),
  partialContent(206),
  multiStatus(207),
  alreadyReported(208),
  iAmUsed(226),
  multipleChoices(300),
  movedPermanently(301),
  found(302),
  movedTemporarily(302), // Duplicate value
  seeOther(303),
  notNotified(304),
  useProxy(305),
  temporaryRedirect(307),
  permanentRedirect(308),
  badRequest(400),
  unauthorized(401),
  paymentRequired(402),
  forbidden(403),
  notFound(404),
  methodNotAllowed(405),
  notAcceptable(406),
  proxyAuthenticationRequired(407),
  requestTimeout(408),
  conflict(409),
  gone(410),
  lengthRequired(411),
  preconditionFailed(412),
  requestEntityTooLarge(413),
  requestUriTooLong(414),
  unsupportedMediaType(415),
  requestRangeNotSatisfiable(416),
  expectationFailed(417),
  misdirectRequest(421),
  unprocessableEntity(422),
  locked(423),
  failedDependency(424),
  upgradeRequired(426),
  preconditionRequired(428),
  tooManyRequests(429),
  requestHeaderFieldsTooLarge(431),
  connectionClosedWithoutResponse(444),
  unavailableForLegalReasons(451),
  clientClosedRequest(499),
  internalServerError(500),
  notImplemented(501),
  badGateway(502),
  serviceUnavailable(503),
  gatewayTimeout(504),
  httpVersionNotSupported(505),
  variantAlsoNegotiates(506),
  insufficientStorage(507),
  loopDetected(508),
  notExtended(510),
  networkAuthenticationRequired(511),
  networkConnectionTimeoutError(599);

  /* AcDoc({"description": "The numeric HTTP response code."}) */
  final int value;

  /* AcDoc({"description": "Constructor that sets the HTTP response code."}) */
  const AcEnumHttpResponseCode(this.value);

  /* AcDoc({
    "description": "Finds the response code enum matching the given code.",
    "params": [{"name": "code", "description": "The numeric HTTP code to match."}],
    "returns": "The matching enum or null if no match."
  }) */
  static AcEnumHttpResponseCode? fromValue(int value) {
    try {
      return AcEnumHttpResponseCode.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if this enum's code equals another code.",
    "params": [{"name": "otherCode", "description": "The code to compare."}],
    "returns": "true if equal, false otherwise."
  }) */
  bool equals(int otherCode) => value == otherCode;

  /* AcDoc({"description": "Returns a formatted string representation of the enum."}) */
  @override
  String toString() => '\$name (\$code)';
}
