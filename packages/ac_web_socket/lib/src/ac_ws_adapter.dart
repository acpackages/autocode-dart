import './ac_web_socket.dart';
import './ac_ws_server.dart';

abstract class AcWsAdapter {
  final AcWsNamespace nsp;
  AcWsAdapter(this.nsp);

  void broadcast({required String event, dynamic data, String? room, Set<String>? except});
  void add({required String id, required String room});
  void del({required String id, required String room});
  void delAll({required String id});
}

class AcWsDefaultAdapter extends AcWsAdapter {
  AcWsDefaultAdapter(super.nsp);

  @override
  void broadcast({required String event, dynamic data, String? room, Set<String>? except}) {
    Set<AcWebSocket>? sockets;
    if (room != null) {
      sockets = nsp.rooms[room];
    } else {
      sockets = nsp.sockets;
    }

    if (sockets != null) {
      for (final socket in sockets) {
        if (except != null && except.contains(socket.id)) continue;
        if (data is List<int>) {
          socket.emitBinary(event: event, data: data);
        } else {
          socket.emit(event: event, data: data);
        }
      }
    }
  }

  @override
  void add({required String id, required String room}) {
    // Basic implementation stores rooms in the namespace itself for now
  }

  @override
  void del({required String id, required String room}) {
    // Basic implementation stores rooms in the namespace itself for now
  }

  @override
  void delAll({required String id}) {
    // Basic implementation stores rooms in the namespace itself for now
  }
}
