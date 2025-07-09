import 'dart:convert';
import 'package:ac_ai_clients/ac_ai_clients.dart';
import 'package:http/http.dart' as http;
/* AcDoc({
  "summary": "Client implementation for Anthropic Claude APIs.",
  "description": "Sends prompt requests to Claude API and returns structured responses using AcAIResponse.",
  "author": "Sanket Patel",
  "type": "client",
  "category": "AI",
  "group": "Claude"
}) */
class AcAIClaudeClient extends AcAIClient{

  /* AcDoc({
    "summary": "Initializes a new Claude client.",
    "params": [
      { "name": "config", "description": "The configuration including the API key and model." }
    ]
  }) */
  AcAIClaudeClient({required super.config});

  /* AcDoc({
    "summary": "Sends a prompt to Claude and returns a structured AI response.",
    "params": [
      { "name": "request", "description": "The AI input request including model and prompt." }
    ],
    "returns": "A structured response object containing generated text and metadata.",
    "returns_type": "AcAIResponse"
  }) */
  @override
  Future<AcAIResponse> send({required AcAIRequest request}) async {
    final result = AcAIResponse();

    try {
      final uri = Uri.parse('https://api.anthropic.com/v1/messages');

      final headers = {
        'Content-Type': 'application/json',
        'x-api-key': config.apiKey,
        'anthropic-version': '2023-06-01'
      };

      final body = {
        "model": config.model.name,
        "max_tokens": request.maxTokens ?? 1024,
        "temperature": request.creativityLevel ?? 0.7,
        "messages": [
          {
            "role": "user",
            "content": request.prompt
          }
        ]
      };

      final response = await http.post(uri, headers: headers, body: json.encode(body));
      final rawJson = json.decode(response.body);
      result.raw = rawJson;

      if (response.statusCode == 200) {
        final content = rawJson['content'];
        if (content != null && content is List && content.isNotEmpty) {
          final first = content.first;
          final text = first is Map && first.containsKey('text') ? first['text'] : null;

          if (text != null) {
            result.text = text;
            result.setSuccess(value: text);
          } else {
            result.setFailure(message: "No valid content.text in Claude response.");
          }
        } else {
          result.setFailure(message: "Claude returned empty content.");
        }
      } else {
        result.setFailure(
            message: rawJson['error']?['message'] ?? "Unknown Claude API error."
        );
      }
    } catch (e, stack) {
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }
}
