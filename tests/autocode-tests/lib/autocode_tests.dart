export 'sql/test_schema_manager.dart';
export 'web/web_on_jaguar/test_web_on_jaguar.dart';
import 'package:autocode_tests/web-sockets/demo_client.dart';
import 'package:autocode_tests/web-sockets/demo_server.dart';
import 'package:autocode_tests/web/web_on_jaguar/test_web_on_jaguar.dart';
import 'ai_clients/providers/gemini.dart';
import 'ai_clients/providers/openai.dart';
import 'ai_clients/unifiers/aimlapi.dart';
import 'sql/test_schema_manager.dart';

void main() {
  // testSchemaManager();
  // testWebOnJaguarAutoApi();
  testAcWebSocketServer();
  testAcWebSocketClient();
  // testAimlApi();
  // testOpenAI();
  // testGemini();
}


