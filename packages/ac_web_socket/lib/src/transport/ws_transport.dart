import 'dart:async';

abstract class AcWebSocketTransport {
  void listen(void Function(dynamic data) onData, {void Function()? onDone, Function? onError});
  void add(dynamic data);
  Future<void> close();
  int get readyState;
  set pingInterval(Duration? interval);
}

const int wsReadyStateOpen = 1;
const int wsReadyStateClosed = 3;
