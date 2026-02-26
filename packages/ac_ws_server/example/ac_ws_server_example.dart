import 'package:ac_ws_server/ac_ws_server.dart';

void main() async {
  final server = AcWsServer();
  final port = 3001;

  // Middleware example
  server.of('/chat').use((socket, next) {
    print('Middleware for /chat: checking handshake query...');
    if (socket.handshake['query']['token'] == 'secret') {
      next();
    } else {
      print('Middleware: Connection rejected (invalid token)');
      next('Authentication error');
    }
  });

  // Default namespace
  server.onConnection((socket) {
    print('Client connected to /: ${socket.id}');

    socket.on('message', (data, [ack]) {
      print('Received message from ${socket.id}: $data');
      if (ack != null) {
        ack('Server received: $data');
      }
    });

    socket.on('join_room', (room, [_]) {
      print('Socket ${socket.id} joining room: $room');
      socket.join(room as String);
    });
  });

  // Custom namespace
  server.of('/chat').onConnection((socket) {
    print('Client connected to /chat: ${socket.id}');

    socket.on('chat_message', (data, [_]) {
      print('Chat message in /chat from ${socket.id}: $data');
      // Broadcast to everything in the room using the adapter
      server.of('/chat').to('room1').emit('new_chat', {'from': socket.id, 'msg': data});
    });

    socket.on('join', (room, [_]) {
      socket.join(room as String);
      socket.emit('joined', room);
    });

    socket.on('binary_test', (data, [_]) {
      print('Received binary data of length: ${data.length}');
    });
  });

  print('Starting server on port $port...');
  await server.listen(port);
  print('Server listening on port $port');
}
