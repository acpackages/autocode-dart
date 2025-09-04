import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
"author": "Sanket Patel",
"summary": "Represents the outcome of a hook's execution.",
"description": "A result class that encapsulates the outcome of a hook's operation. It includes a flag to determine if the main operation should proceed, whether the hook returned any data, and the data itself. It extends the base AcResult class.",
"example": "// Example of a hook result that stops the subsequent operation:\nfinal result = AcHookExecutionResult(\n  continueOperation: false, \n  hasResults: true, \n  results: {'validation_error': 'User not authorized'}\n);"
}) */
@AcReflectable()
class AcHookExecutionResult extends AcResult {
  /* AcDoc({ "description": "Key for the continueOperation flag during serialization." }) */
  static const String keyContinueOperation = "continueOperation";

  /* AcDoc({ "description": "Key for the hasResults flag during serialization." }) */
  static const String keyHasResults = "hasResults";

  /* AcDoc({ "description": "Key for the results object during serialization." }) */
  static const String keyResults = "results";

  /* AcDoc({
"summary": "A flag to control the continuation of the main operation.",
"description": "If true, the primary operation that triggered the hook will proceed. If false, it signals that the primary operation should be aborted."
}) */
  @AcBindJsonProperty(key: keyContinueOperation)
  bool continueOperation = true;

  /* AcDoc({
"summary": "Indicates if the hook's execution produced any data.",
"description": "A boolean flag that is true if the results map contains data returned by the hook, and false otherwise."
}) */
  @AcBindJsonProperty(key: keyHasResults)
  bool hasResults = false;

  /* AcDoc({
"summary": "A map containing the data payload from the hook's execution.",
"description": "Holds any key-value data returned by the hook, which might be used by subsequent steps if the operation continues."
}) */
  Map<String, dynamic> results = {};

  /* AcDoc({
"summary": "Creates an instance of a hook execution result.",
"description": "Initializes the result with optional values for controlling the flow of the primary operation and providing data.",
"params": [
{"name": "continueOperation", "description": "Whether the main operation should continue. Defaults to true."},
{"name": "hasResults", "description": "Whether any data is being returned by the hook. Defaults to false."},
{"name": "results", "description": "The map of data returned by the hook."}
]
}) */
  AcHookExecutionResult({
    this.continueOperation = true,
    this.hasResults = false,
    this.results = const <String, dynamic>{},
  });
}
