import 'package:autocode/autocode.dart';

class AcEvents {
  final Map<String, Map<String, Function>> _events = {};

  AcEventExecutionResult execute({required String key,List<dynamic> args = const []}) {
    final result = AcEventExecutionResult();

    try {
      final Map<String, dynamic> functionResults = {};

      if (_events.containsKey(key)) {
        final functionsToExecute = _events[key]!;

        for (final entry in functionsToExecute.entries) {
          final functionId = entry.key;
          final fun = entry.value;
          final functionResult = Function.apply(fun, args);

          if (functionResult != null &&
              functionResult is AcEventExecutionResult &&
              functionResult.status == "success") {
            functionResults[functionId] = functionResult;
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

  String subscribe({required String eventName,required Function callback}) {
    _events[eventName] ??= {};
    final subscriptionId = Autocode.uniqueId();
    _events[eventName]![subscriptionId] = callback;
    return subscriptionId;
  }

  void unsubscribe({required String subscriptionId}) {
    for (final eventName in _events.keys) {
      final eventFunctions = _events[eventName]!;
      if (eventFunctions.containsKey(subscriptionId)) {
        eventFunctions.remove(subscriptionId);
      }
    }
  }
}
