import 'dart:convert';
import 'package:ac_ai_clients/ac_ai_clients.dart';
import 'package:http/http.dart' as http;

/* AcDoc({
  "summary": "Client implementation for OpenAI APIs.",
  "description": "Handles sending requests to OpenAI's API and returns structured AI responses.",
  "author": "Sanket Patel",
  "type": "client",
  "category": "AI",
  "group": "OpenAI"
}) */
class AcAIOpenAIClient extends AcAIClient {
  static final Set<AcEnumAIModel> _supportedModels = {
    AcEnumAIModel.openaiCodexO1,
    AcEnumAIModel.openaiDalle2,
    AcEnumAIModel.openaiDalle3,
    AcEnumAIModel.openaiGpt35Turbo,
    AcEnumAIModel.openaiGpt35Turbo16k,
    AcEnumAIModel.openaiGpt4,
    AcEnumAIModel.openaiGpt4o,
    AcEnumAIModel.openaiGpt4Turbo,
    AcEnumAIModel.openaiGpt45,
    AcEnumAIModel.openaiWhisper1,
  };

  /* AcDoc({
    "summary": "Creates a new OpenAI client instance.",
    "params": [
      { "name": "config", "description": "Client configuration with API key and other settings." }
    ]
  }) */
  AcAIOpenAIClient({required super.config});

  /* AcDoc({
    "summary": "Sends a prompt to OpenAI and returns the result.",
    "params": [
      { "name": "request", "description": "The AI request containing the prompt, model, and options." }
    ],
    "returns": "Structured AI response with text and raw metadata.",
    "returns_type": "AcAIResponse"
  }) */
  @override
  Future<AcAIResponse> send({required AcAIRequest request}) async {
    final result = AcAIResponse();

    try {
      if (_supportedModels.contains(config.model)) {
        final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.apiKey}',
        };

        final body = {
          "model": config.model.value,
          "messages": [
            { "role": "user", "content": request.prompt }
          ],
          "temperature": request.creativityLevel ?? 0.7,
        };

        final response = await http.post(uri, headers: headers, body: json.encode(body));
        final rawJson = json.decode(response.body);
        result.raw = rawJson;

        if (response.statusCode == 200) {
          final choices = rawJson['choices'];
          if (choices != null && choices.isNotEmpty) {
            result.text = choices[0]['message']['content'];
            result.setSuccess(value: result.text);
          } else {
            result.setFailure(message: "No choices returned.");
          }
        } else {
          result.setFailure(
            message: rawJson['error']?['message'] ?? "Unknown error from OpenAI.",
          );
        }
      }
      else{
        result.setFailure(message: "Model not supported");
      }

    } catch (e, stack) {
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }
}
