import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_web/ac_web.dart';
@AcReflectable()
class AcWebHookCreatedArgs {
  final AcWeb acWeb;

  AcWebHookCreatedArgs({required this.acWeb});
}
