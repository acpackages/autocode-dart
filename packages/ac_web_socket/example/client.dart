import 'package:ac_web_socket/ac_web_socket.dart';

Future<void> setupClient() async {
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
  await Future.delayed(Duration(seconds: 500000));
  await client.disconnect();
  print('Example finished.');
}
