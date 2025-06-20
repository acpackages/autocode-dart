import 'package:ac_mirrors/ac_mirrors.dart';
@AcReflectable()
class AcWebRoute {
  final String path;
  final String method;

  const AcWebRoute(this.path, {this.method = 'GET'});
}