import 'package:ac_ws_server/ac_ws_server.dart';

void main() async {
  final server = AcWsServer();
  final port = 3001;

  // Middleware example
  server.of(name: '/chat').use(handler: (socket, next) {
    print('Middleware for /chat: checking handshake query...');
    if (socket.handshake['query']['token'] == 'secret') {
      next();
    } else {
      print('Middleware: Connection rejected (invalid token)');
      next('Authentication error');
    }
  });

  // Default namespace
  server.onConnection(handler: (socket) {
    print('Client connected to /: ${socket.id}');

    socket.on(event: 'message', handler: (data, [ack]) {
      print('Received message from ${socket.id}: $data');
      if (ack != null) {
        ack('Server received: $data');
      }
    });

    socket.on(event: 'join_room', handler: (room, [_]) {
      print('Socket ${socket.id} joining room: $room');
      socket.join(room: room as String);
    });
  });

  // Custom namespace
  server.of(name: '/chat').onConnection(handler: (socket) {
    print('Client connected to /chat: ${socket.id}');

    socket.on(event: 'chat_message', handler: (data, [_]) {
      print('Chat message in /chat from ${socket.id}: $data');
      // Broadcast to everything in the room using the adapter
      server.of(name: '/chat').to(room: 'room1').emit(event: 'new_chat', data: {'from': socket.id, 'msg': data});
    });

    socket.on(event: 'join', handler: (room, [_]) {
      socket.join(room: room as String);
      socket.emit(event: 'joined', data: room);
    });

    socket.on(event: 'binary_test', handler: (data, [_]) {
      print('Received binary data of length: ${data.length}');
    });
  });

  print('Starting server on port $port...');
  server.port = 8080;
  await server.start();
  print('Server listening on port $port');
}
