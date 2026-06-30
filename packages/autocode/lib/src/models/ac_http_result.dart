import 'package:ac_mirrors/ac_mirrors.dart';
import '../../autocode.dart';

@AcReflectable()
class AcHttpResult extends AcResult{
  dynamic data;
  AcEnumHttpResponseCode responseCode = AcEnumHttpResponseCode.unknown;
}