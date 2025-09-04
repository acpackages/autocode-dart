import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
"author": "Sanket Patel",
"summary": "Represents the outcome of an event's execution.",
"description": "A result class that encapsulates the outcome of an operation, typically an event. It includes a flag to determine if subsequent operations should proceed, whether any data was returned, and the data itself. It extends the base AcResult class.",
"example": "// Example of a successful execution that should halt further processing:\nfinal result = AcEventExecutionResult(\n  continueOperation: false, \n  hasResults: true, \n  results: {'userId': 123}\n);"
}) */
@AcReflectable()
class AcEventExecutionResult extends AcResult {
  /* AcDoc({"description": "Key for the continuation status during serialization."}) */
  static const String keyContinueOperation = "continueOperation";

  /* AcDoc({"description": "Key for the result availability status during serialization."}) */
  static const String keyHasResults = "hasResults";

  /* AcDoc({"description": "Key for the result data during serialization."}) */
  static const String keyResults = "results";

  /* AcDoc({
"summary": "A flag to control the continuation of an operation chain.",
"description": "If true, the process or event chain will continue. If false, it signals that subsequent operations should be halted."
}) */
  @AcBindJsonProperty(key: keyContinueOperation)
  bool continueOperation = true;

  /* AcDoc({
"summary": "Indicates if the execution produced any data.",
"description": "A boolean flag that is true if the results map contains data, and false otherwise."
}) */
  @AcBindJsonProperty(key: keyHasResults)
  bool hasResults = false;

  /* AcDoc({
"summary": "A map containing the data payload from the execution.",
"description": "Holds the key-value pairs of any data returned by the event or operation."
}) */
  Map<String, dynamic> results = {};

  /* AcDoc({
"summary": "Creates an instance of an event execution result.",
"description": "Initializes the result with optional values for controlling operation flow and providing data.",
"params": [
{"name": "continueOperation", "description": "Whether the operation chain should continue. Defaults to true."},
{"name": "hasResults", "description": "Whether any data is being returned. Defaults to false."},
{"name": "results", "description": "The map of data returned by the operation."}
]
}) */
  AcEventExecutionResult({
    this.continueOperation = true,
    this.hasResults = false,
    this.results = const <String, dynamic>{},
  });
}
