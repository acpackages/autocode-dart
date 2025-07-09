import 'package:ac_ai_clients/ac_ai_clients.dart';

void testOpenAI() async {
  // 1. Create the config
  final config = AcAIClientConfig(
    model: AcEnumAIModel.openaiGpt4o,
    apiKey: '',
    apiUrl: 'https://api.openai.com/v1/chat/completions',
    creativityLevel: 0.7,
    responseType: AcEnumAIResponseType.text,
  );
  print("Config : \n${config}");
  // 2. Create the client
  final client = AcAIOpenAIClient(config: config);

  // 3. Prepare the request
  final request = AcAIRequest(
    prompt: 'Explain the difference between Flutter and React Native.',
    inputType: AcEnumAIInputType.text,
  );

  // 4. Send the request
  final AcAIResponse response = await client.send(request: request);

  // 5. Handle the response
  if (response.isSuccess()) {
    print("✅ AI Response:\n${response.text}");
  } else {
    print("❌ Error: ${response.message}");
    if (response.raw != null) {
      print("Raw Response: ${response.raw}");
    }
  }
}