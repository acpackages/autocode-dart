import 'package:ac_web/ac_web.dart';
import 'package:ac_ws_server/ac_ws_server.dart';
import 'package:ac_ws_on_web/ac_ws_on_web.dart';
import 'package:autocode/autocode.dart';

void main() async {
  final wsServer = AcWsServer();
  final app = AcWeb();
  
  // Bridge them
  // AcWsOnWeb(wsServer, app);

  app.get(
    url: 'hello',
    handler: (AcWebRequest request, AcLogger logger) async {
      final name = request.get['name'] ?? 'World';
      return AcWebResponse.json(data: {'message': 'Hello, $name!'});
    },
  );

  await wsServer.listen(8080);
  print('WebSocket Server listening on port 8080');
  print('Send a "web_request" event with { "url": "hello", "method": "GET", "query": { "name": "User" } }');
}
