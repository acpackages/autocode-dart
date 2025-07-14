import 'package:ac_ai_clients/ac_ai_clients.dart';

void testGemini() async {
  // 1. Create the config
  final config = AcAIClientConfig(
    model: AcEnumAIModel.gemini15Pro,
    apiKey: '', // Replace with your Gemini API key
    apiUrl: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent',
    creativityLevel: 0.7,
    responseType: AcEnumAIResponseType.text,
  );
  print("Config : \n${config}");

  // 2. Create the client
  final client = AcAIGeminiClient(config: config);

  // 3. Prepare the request
  final request = AcAIRequest(
    prompt: 'Summarize the latest trends in artificial intelligence.',
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
