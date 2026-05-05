import 'package:ac_web_socket/ac_web_socket.dart';

void main() async {
  // 1. Setup Server
  final server = AcWsServer()..port = 3000;
  
  // Use global middleware
  server.of(name: '/').use(handler: ({required socket, required next}) {
    print('Middleware: Connection to / from ${socket.handshake['address']}');
    next();
  });

  // Handle default namespace connections
  server.onConnection(handler: ({required socket}) {
    print('Server: Client connected to /: ${socket.id}');

    // Event handler with named parameters
    socket.on(event: 'chat', handler: ({data, callback}) {
      print('Server: Received chat: $data');
      // Broadcast to all clients in the default namespace
      server.emit(event: 'new_message', data: 'Broadcast: $data');
      // Acknowledge using named parameter
      callback?.call(response: 'Message delivered to server');
    });

    socket.on(event: 'join_room', handler: ({data, callback}) {
      final room = data as String;
      socket.join(room: room);
      callback?.call(response: 'Joined room: $room');
    });

    socket.on(event: 'room_msg', handler: ({data, callback}) {
      final map = data as Map;
      final room = map['room'];
      final msg = map['msg'];
      // Emit specifically to a room
      server.of(name: '/').to(room: room).emit(event: 'message', data: msg);
    });
  });

  await server.start();
  print('Server started on port 3000');

  // 2. Setup Client
  final client = AcWsClient(url: 'ws://localhost:3000');

  client.onConnection(handler: ({required socket}) async {
    print('Client: Connected to server!');

    // Intercept outgoing messages to add a prefix
    socket.addOutgoingInterceptor(({required message, callback, abort}) {
      if (message['e'] == 'chat') {
        message['d'] = '[Client-Prefixed] ${message['d']}';
      }
    });

    // Send chat message and wait for acknowledgment
    final response = await socket.emit(
      event: 'chat', 
      data: 'Hello Server!',
      callback: ({response}) {
        print('Client: Server acknowledged: $response');
      },
    );
    print('Client: Emit future resolved with: $response');

    // Join a room
    await socket.emit(event: 'join_room', data: 'lobby');

    // Handle broadcast messages
    socket.on(event: 'new_message', handler: ({data, callback}) {
      print('Client: Received broadcast: $data');
    });

    socket.on(event: 'message', handler: ({data, callback}) {
      print('Client: Received room message: $data');
    });

    // Send a room message
    socket.emit(event: 'room_msg', data: {'room': 'lobby', 'msg': 'Hi everyone in lobby!'});
  });

  await client.connect();

  // Keep alive for a bit to see logs
  await Future.delayed(Duration(seconds: 5));
  await client.disconnect();
  await server.stop();
  print('Example finished.');
}
