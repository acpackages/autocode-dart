import 'package:ac_mirrors/ac_mirrors.dart';
@AcReflectable()
class AcWebRouteConsumes {
  final String contentType;

  const AcWebRouteConsumes(this.contentType);
}