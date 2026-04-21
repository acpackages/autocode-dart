import 'package:ac_ws_server/ac_ws_server.dart';

void testAcWebSocketServer() async {
  final server = AcWsServer();
  const port = 3030;

  // Default namespace
  server.onConnection(handler:(socket) {
    print('Server: Client connected to /: ${socket.id}');

    socket.on(event:'hello', handler: (data, [ack]) {
      print('Server: Received "hello" from ${socket.id}: $data');
      if (ack != null) {
        ack('Hello from server! You said: $data');
      }
    });

    socket.on(event:'broadcast_request', handler: (data, [_]) {
      print('Server: Broadcasting message: $data');
      server.emit(event:'broadcast_event', data: 'Broadcast from ${socket.id}: $data');
    });

    socket.on(event:'disconnect', handler: (_, [__]) {
      print('Server: Client disconnected: ${socket.id}');
    });
  });

  // Chat namespace
  server.of(name:'/chat').onConnection(handler:(socket) {
    print('Server: Client connected to /chat: ${socket.id}');

    socket.on(event:'join',handler:  (room, [_]) {
      print('Server: Socket ${socket.id} joining room: $room');
      socket.join(room:room as String);
      socket.emit(event:'joined',data: room);
    });

    socket.on(event:'send_chat',handler:  (data, [_]) {
      final room = data['room'];
      final msg = data['msg'];
      print('Server: Chat in $room: $msg');
      server.of(name:'/chat').to(room: room).emit(event:'chat_msg',data:  {'from': socket.id, 'msg': msg});
    });
  });

  print('Server: Starting ac_ws demo server on port $port...');
  server.port = port;
  await server.start();
  print('Server: Listening on $port');
}
