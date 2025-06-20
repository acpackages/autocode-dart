import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
@AcReflectable()
class AcEventExecutionResult extends AcResult {
  static const String KEY_CONTINUE_OPERATION = "continue_operation";
  static const String KEY_HAS_RESULTS = "has_results";
  static const String KEY_RESULTS = "results";

  @AcBindJsonProperty(key: KEY_CONTINUE_OPERATION)
  bool continueOperation = true;

  @AcBindJsonProperty(key: KEY_HAS_RESULTS)
  bool hasResults = false;

  Map<String,dynamic> results = {};

  AcEventExecutionResult({
    this.continueOperation = true,
    this.hasResults = false,
    this.results = const <String,dynamic>{},
  });
}
