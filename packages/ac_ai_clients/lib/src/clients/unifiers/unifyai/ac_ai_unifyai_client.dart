import 'dart:convert';
import 'package:ac_ai_clients/ac_ai_clients.dart';
import 'package:http/http.dart' as http;

/* AcDoc({
  "summary": "Client implementation for UnifyAI Unified API.",
  "description": "Sends requests to UnifyAI (https://unifyai.dev), which offers unified access to multiple AI providers through a single API interface.",
  "author": "Sanket Patel",
  "type": "client",
  "category": "AI",
  "group": "UnifyAI"
}) */
class AcAIUnifyAIClient extends AcAIClient {
  static const _allowedModelPrefixes = [
    'openai.',
    'claude.',
    'gemini.',
    'mistral.',
    'llama3.',
    'llama2.',
    'mixtral.',
    'sdxl.',
    'dalle.',
    'whisper.',
    'elevenlabs.',
  ];

  /* AcDoc({
    "summary": "Creates a UnifyAI client.",
    "params": [
      { "name": "config", "description": "Configuration containing API key, model, and endpoint." }
    ]
  }) */
  AcAIUnifyAIClient({required super.config});

  /* AcDoc({
    "summary": "Sends a request using the UnifyAI unified endpoint.",
    "params": [
      { "name": "request", "description": "AI request containing prompt and parameters." }
    ],
    "returns": "Structured AI response object.",
    "returns_type": "AcAIResponse"
  }) */
  @override
  Future<AcAIResponse> send({required AcAIRequest request}) async {
    final result = AcAIResponse();

    try {
      final modelId = config.model.value;

      // ✅ Validate model prefix
      final isValidModel = _allowedModelPrefixes.any((prefix) => modelId.startsWith(prefix));
      if (!isValidModel) {
        result.setFailure(message: "Model '${modelId}' is not supported by UnifyAI.");
        return result;
      }

      final uri = Uri.parse(config.apiUrl.isNotEmpty
          ? config.apiUrl
          : 'https://api.unifyai.dev/v1/completion');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.apiKey}',
      };

      final body = {
        "model": modelId,
        "prompt": request.prompt,
        "temperature": request.creativityLevel ?? 0.7,
        "max_tokens": request.maxTokens ?? 1024,
      };

      final response = await http.post(uri, headers: headers, body: json.encode(body));
      final rawJson = json.decode(response.body);
      result.raw = rawJson;

      if (response.statusCode == 200) {
        final text = rawJson['text'] ?? rawJson['response'];
        if (text != null && text is String) {
          result.text = text;
          result.setSuccess(value: text);
        } else {
          result.setFailure(message: "No valid response text found.");
        }
      } else {
        result.setFailure(
          message: rawJson['error']?['message'] ?? "Unknown error from UnifyAI.",
        );
      }
    } catch (e, stack) {
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }
}
