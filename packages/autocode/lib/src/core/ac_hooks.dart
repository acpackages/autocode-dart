
import 'package:autocode/autocode.dart';

class AcHooks {
  static final Map<String, Map<String, Function>> _hooks = {};

  static AcHookExecutionResult execute({required String hookName, List<dynamic> args = const []}) {
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
    } catch (ex,stack) {
      result.setException(exception: ex,stackTrace: stack);
    }

    return result;
  }

  static String subscribe({required String hookName,required Function callback}) {
    _hooks[hookName] ??= {};
    final subscriptionId = Autocode.uniqueId();
    _hooks[hookName]![subscriptionId] = callback;
    return subscriptionId;
  }

  void unsubscribe({required String subscriptionId}) {
    for (final entry in _hooks.entries) {
      final hookFunctions = entry.value;

      if (hookFunctions.containsKey(subscriptionId)) {
        hookFunctions.remove(subscriptionId);
      }
    }
  }
}
