import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "description": "Represents the result of a hook execution including continuation control and list of detected changes.",
  "author": "Sanket Patel"
}) */
@AcReflectable()
class AcHookResult extends AcResult {
  /* AcDoc({ "description": "Key used to map the continueOperation flag in JSON serialization." }) */
  static const String keyContinueOperation = "continue_operation";

  /* AcDoc({ "description": "Key used to map the changes list in JSON serialization." }) */
  static const String keyChanges = "changes";

  /* AcDoc({ "description": "Indicates whether the operation should continue after the hook." }) */
  @AcBindJsonProperty(key: keyContinueOperation)
  bool continueOperation = true;

  /* AcDoc({ "description": "List of changes detected or performed during the hook execution." }) */
  List<dynamic> changes = [];

  /* AcDoc({ "description": "Creates an instance of AcHookResult with optional continuation flag and change list." }) */
  AcHookResult({
    this.continueOperation = true,
    this.changes = const [],
  });
}
