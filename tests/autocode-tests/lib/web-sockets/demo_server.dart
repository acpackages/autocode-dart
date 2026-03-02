import 'package:ac_ws_server/ac_ws_server.dart';

void testAcWebSocketServer() async {
  final server = AcWsServer();
  const port = 3030;

  // Default namespace
  server.onConnection((socket) {
    print('Server: Client connected to /: ${socket.id}');

    socket.on('hello', (data, [ack]) {
      print('Server: Received "hello" from ${socket.id}: $data');
      if (ack != null) {
        ack('Hello from server! You said: $data');
      }
    });

    socket.on('broadcast_request', (data, [_]) {
      print('Server: Broadcasting message: $data');
      server.emit('broadcast_event', 'Broadcast from ${socket.id}: $data');
    });

    socket.on('disconnect', (_, [__]) {
      print('Server: Client disconnected: ${socket.id}');
    });
  });

  // Chat namespace
  server.of('/chat').onConnection((socket) {
    print('Server: Client connected to /chat: ${socket.id}');

    socket.on('join', (room, [_]) {
      print('Server: Socket ${socket.id} joining room: $room');
      socket.join(room as String);
      socket.emit('joined', room);
    });

    socket.on('send_chat', (data, [_]) {
      final room = data['room'];
      final msg = data['msg'];
      print('Server: Chat in $room: $msg');
      server.of('/chat').to(room).emit('chat_msg', {'from': socket.id, 'msg': msg});
    });
  });

  print('Server: Starting ac_ws demo server on port $port...');
  await server.listen(port);
  print('Server: Listening on $port');
}
