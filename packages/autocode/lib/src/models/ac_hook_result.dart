import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcHookResult extends AcResult {
  static const String KEY_CONTINUE_OPERATION = "continue_operation";
  static const String KEY_CHANGES = "changes";

  @AcBindJsonProperty(key: KEY_CONTINUE_OPERATION)
  bool continueOperation = true;

  List<dynamic> changes = [];

  AcHookResult({this.continueOperation = true, this.changes = const []});
}
