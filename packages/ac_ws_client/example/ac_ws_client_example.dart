import 'package:ac_ws_client/ac_ws_client.dart';
import 'dart:typed_data';

void main() async {
  // Connect to default namespace
  final client = AcWsClient(url: 'ws://localhost:3001');

  // Connect to /chat namespace with token
  final chatClient = AcWsClient(url: 'ws://localhost:3001', nsp: '/chat', query: {'token': 'secret'});

  client.on(event: 'connect', handler: (_, [__]) {
    print('Default Client: Connected!');
    
    // Test Acknowledgement
    client.emit(event: 'message', data: 'Hello server with ack!').then((response) {
      print('Default Client: Ack received: $response');
    });
  });

  chatClient.on(event: 'connect', handler: (_, [__]) {
    print('Chat Client: Connected to /chat!');
    chatClient.emit(event: 'join', data: 'room1');
  });

  chatClient.on(event: 'joined', handler: (room, [__]) {
    print('Chat Client: Joined room: $room');
    chatClient.emit(event: 'chat_message', data: 'Hello everyone in room1!');
    
    // Test Binary
    print('Chat Client: Sending binary data...');
    chatClient.sendBinary(bytes: Uint8List.fromList([1, 2, 3, 4, 5]));
  });

  chatClient.on(event: 'new_chat', handler: (data, [__]) {
    print('Chat Client: New chat in room: $data');
  });

  print('Connecting clients...');
  await client.connect();
  await chatClient.connect();

  await Future.delayed(Duration(seconds: 10));
  print('Disconnecting...');
  client.disconnect();
  chatClient.disconnect();
}
