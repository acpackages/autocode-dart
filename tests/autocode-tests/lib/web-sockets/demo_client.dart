import 'package:ac_ws_client/ac_ws_client.dart';
import 'dart:async';

void testAcWebSocketClient() async {
  const url = 'ws://localhost:3030';
  
  print('Client: Connecting to $url...');
  final client = AcWsClient(url: url);
  final chatClient = AcWsClient(url:url, nsp: '/chat');

  // Default client listeners
  client.on(event: 'connect', handler:(_, [__]) {
    print('Client [/]: Connected!');
    client.emit(event:'hello', data:'I am the Dart client').then((response) {
      print('Client [/]: Ack received: $response');
    });
    
    // Request a broadcast
    client.emit(event:'broadcast_request',data:'Hello everyone!');
  });

  client.on(event:'broadcast_event', handler:(data, [__]) {
    print('Client [/]: Received broadcast: $data');
  });

  // Chat client listeners
  chatClient.on(event:'connect',handler: (_, [__]) {
    print('Client [/chat]: Connected!');
    chatClient.emit(event:'join',data: 'lobby');
  });

  chatClient.on(event:'joined',handler: (room, [__]) {
    print('Client [/chat]: Joined room $room');
    chatClient.emit(event:'send_chat', data:{'room': 'lobby', 'msg': 'Hello chat room!'});
  });

  chatClient.on(event:'chat_msg', handler:(data, [__]) {
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
