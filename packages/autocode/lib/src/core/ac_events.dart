/* AcDoc({
  "description": "A simple event system for subscribing to, executing, and unsubscribing from named event callbacks.",
  "author": "Sanket Patel",
  "type": "utility"
}) */
import 'package:autocode/autocode.dart';

class AcEvents {
  /* AcDoc({
    "description": "Stores event subscriptions mapped by event name and subscription ID."
  }) */
  final Map<String, Map<String, Function>> _events = {};

  /* AcDoc({
    "description": "Executes all subscribed callbacks for the given event key and aggregates the results.",
    "params": [
      { "name": "key", "description": "The event name to execute callbacks for." },
      { "name": "args", "description": "Optional arguments to pass to each callback." }
    ],
    "returns": "An instance of [AcEventExecutionResult] containing execution status and results."
  }) */
  Future<AcEventExecutionResult> execute({
    required String key,
    List<dynamic> args = const [],
  }) async {
    final result = AcEventExecutionResult();

    try {
      final Map<String, dynamic> functionResults = {};

      if (_events.containsKey(key)) {
        final functionsToExecute = _events[key]!;

        for (final entry in functionsToExecute.entries) {
          final functionId = entry.key;
          final fun = entry.value;
          final functionResult = await Function.apply(fun, args);

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
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }

    return result;
  }

  /* AcDoc({
    "description": "Subscribes a callback function to a named event.",
    "params": [
      { "name": "event", "description": "The name of the event to subscribe to." },
      { "name": "callback", "description": "The callback function to invoke when the event is executed." }
    ],
    "returns": "A unique subscription ID for the registered callback."
  }) */
  String subscribe({
    required String event,
    required Function callback,
  }) {
    if(!_events.containsKey(event)){
      _events[event] = {};
    }
    final subscriptionId = Autocode.uniqueId();
    _events[event]![subscriptionId] = callback;
    return subscriptionId;
  }

  /* AcDoc({
    "description": "Unsubscribes a callback function using its subscription ID.",
    "params": [
      { "name": "subscriptionId", "description": "The unique ID of the subscription to remove." }
    ]
  }) */
  void unsubscribe({required String subscriptionId}) {
    for (final event in _events.keys) {
      final eventFunctions = _events[event]!;
      if (eventFunctions.containsKey(subscriptionId)) {
        eventFunctions.remove(subscriptionId);
      }
    }
  }
}
