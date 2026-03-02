import 'package:ac_ws_client/ac_ws_client.dart';
import 'dart:async';

void testAcWebSocketClient() async {
  const url = 'ws://localhost:3030';
  
  print('Client: Connecting to $url...');
  final client = AcWsClient(url);
  final chatClient = AcWsClient(url, nsp: '/chat');

  // Default client listeners
  client.on('connect', (_, [__]) {
    print('Client [/]: Connected!');
    client.emit('hello', 'I am the Dart client').then((response) {
      print('Client [/]: Ack received: $response');
    });
    
    // Request a broadcast
    client.emit('broadcast_request', 'Hello everyone!');
  });

  client.on('broadcast_event', (data, [__]) {
    print('Client [/]: Received broadcast: $data');
  });

  // Chat client listeners
  chatClient.on('connect', (_, [__]) {
    print('Client [/chat]: Connected!');
    chatClient.emit('join', 'lobby');
  });

  chatClient.on('joined', (room, [__]) {
    print('Client [/chat]: Joined room $room');
    chatClient.emit('send_chat', {'room': 'lobby', 'msg': 'Hello chat room!'});
  });

  chatClient.on('chat_msg', (data, [__]) {
    print('Client [/chat]: New message: ${data['from']} says "${data['msg']}"');
  });

  await client.connect();
  await chatClient.connect();

  // Keep alive for a bit to see events
  print('Client: Demo running for 10 seconds...');
  await Future.delayed(Duration(seconds: 10));
  
  print('Client: Shutting down...');
  client.disconnect();
  chatClient.disconnect();
}
