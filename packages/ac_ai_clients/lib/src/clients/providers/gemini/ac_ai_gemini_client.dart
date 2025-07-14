import 'dart:convert';
import 'package:ac_ai_clients/ac_ai_clients.dart';
import 'package:http/http.dart' as http;

/* AcDoc({
  "summary": "Client implementation for Google Gemini APIs.",
  "description": "Handles requests to Gemini API and returns structured AI responses.",
  "author": "Sanket Patel",
  "type": "client",
  "category": "AI",
  "group": "Gemini"
}) */
class AcAIGeminiClient extends AcAIClient {

  /* AcDoc({
    "summary": "Creates a Gemini AI client.",
    "params": [
      { "name": "config", "description": "Client configuration containing the API key." }
    ]
  }) */
  AcAIGeminiClient({required super.config});

  /* AcDoc({
    "summary": "Sends an AI request to Gemini and receives a structured response.",
    "params": [
      { "name": "request", "description": "The request including prompt and model info." }
    ],
    "returns": "Structured AI response object.",
    "returns_type": "AcAIResponse"
  }) */
  @override
  Future<AcAIResponse> send({required AcAIRequest request}) async {
    final result = AcAIResponse();

    try {
      final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/${config.model.value}:generateContent?key=${config.apiKey}'
      );

      final headers = {
        'Content-Type': 'application/json',
      };

      final body = {
        "contents": [
          {
            "parts": [
              { "text": request.prompt }
            ]
          }
        ],
        "generationConfig": {
          "temperature": request.creativityLevel ?? 0.7,
        }
      };

      final response = await http.post(uri, headers: headers, body: json.encode(body));
      final rawJson = json.decode(response.body);
      result.raw = rawJson;

      if (response.statusCode == 200) {
        final text = rawJson['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null && text is String) {
          result.text = text;
          result.setSuccess(value: text);
        } else {
          result.setFailure(message: "No valid response text found.");
        }
      } else {
        result.setFailure(
            message: rawJson['error']?['message'] ?? "Unknown error from Gemini."
        );
      }
    } catch (e, stack) {
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }
}
