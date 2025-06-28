import 'package:autocode/autocode.dart';

/* AcDoc({
  "description": "Hook manager for subscribing to, executing, and managing custom logic hooks across the application.",
  "author": "Sanket Patel",
  "type": "utility"
}) */
class AcHooks {
  /* AcDoc({
    "description": "Stores registered hook callbacks by hook name and their unique subscription IDs."
  }) */
  static final Map<String, Map<String, Function>> _hooks = {};

  /* AcDoc({
    "description": "Executes all registered callbacks for a given hook name in order. Execution stops if any result fails.",
    "params": [
      { "name": "hookName", "description": "The name of the hook to trigger." },
      { "name": "args", "description": "Arguments passed to each callback function." }
    ],
    "returns": "An [AcHookExecutionResult] with aggregated results and control flow status."
  }) */
  static AcHookExecutionResult execute({
    required String hookName,
    List<dynamic> args = const [],
  }) {
    final result = AcHookExecutionResult();
    try {
      final Map<String, dynamic> functionResults = {};
      bool continueOperation = true;

      if (_hooks.containsKey(hookName)) {
        final functionsToExecute = _hooks[hookName]!;

        for (final entry in functionsToExecute.entries) {
          final functionId = entry.key;
          final fun = entry.value;

          if (continueOperation) {
            final functionResult = Function.apply(fun, args);

            if (functionResult != null) {
              functionResults[functionId] = functionResult;

              if (functionResult.isFailure()) {
                continueOperation = false;
              }

              if (functionResult.continueOperation != true) {
                result.continueOperation = false;
              }
            }
          }
        }
      }

      if (functionResults.isNotEmpty) {
        result.hasResults = true;
        result.results = functionResults;
      }

      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }

    return result;
  }

  /* AcDoc({
    "description": "Registers a new callback function under the specified hook name.",
    "params": [
      { "name": "hookName", "description": "The name of the hook to register the function under." },
      { "name": "callback", "description": "The callback function to execute when the hook is triggered." }
    ],
    "returns": "A unique subscription ID assigned to the registered function."
  }) */
  static String subscribe({
    required String hookName,
    required Function callback,
  }) {
    _hooks[hookName] ??= {};
    final subscriptionId = Autocode.uniqueId();
    _hooks[hookName]![subscriptionId] = callback;
    return subscriptionId;
  }

  /* AcDoc({
    "description": "Removes a registered function from any hook it was subscribed to using its subscription ID.",
    "params": [
      { "name": "subscriptionId", "description": "The unique subscription ID to identify the registered function." }
    ]
  }) */
  void unsubscribe({required String subscriptionId}) {
    for (final entry in _hooks.entries) {
      final hookFunctions = entry.value;

      if (hookFunctions.containsKey(subscriptionId)) {
        hookFunctions.remove(subscriptionId);
      }
    }
  }
}
