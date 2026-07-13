export 'sql/test_schema_manager.dart';
export 'web/web_on_jaguar/test_web_on_jaguar.dart';
import 'package:autocode_tests/web/web_on_jaguar/test_web_on_jaguar.dart';
import 'ai_clients/providers/gemini.dart';
import 'ai_clients/providers/openai.dart';
import 'ai_clients/unifiers/aimlapi.dart';
import 'data_dictionary/test_data_dcitionary.dart';
import 'sql/test_schema_manager.dart';

void main() {
  testDataDictionary();
  // testSchemaManager();
  // testWebOnJaguarAutoApi();
  // testAcWebSocketServer();
  // testAcWebSocketClient();
  // testAimlApi();
  // testOpenAI();
  // testGemini();
}


