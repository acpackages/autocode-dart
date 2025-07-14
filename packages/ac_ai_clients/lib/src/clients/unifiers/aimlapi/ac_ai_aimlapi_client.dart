import 'dart:convert';
import 'package:ac_ai_clients/ac_ai_clients.dart';
import 'package:http/http.dart' as http;

/* AcDoc({
  "summary": "Client implementation for AIMLAPI Unified API.",
  "description": "Handles requests to AIMLAPI (https://aimlapi.com), which acts as a unified gateway to various AI model providers.",
  "author": "Sanket Patel",
  "type": "client",
  "category": "AI",
  "group": "AIMLAPI"
}) */
class AcAIAmlapiClient extends AcAIClient {
  static const _allowedModelPrefixes = [
    'openai.',
    'claude.',
    'gemini.',
    'mistral.',
    'llama3.',
    'llama2.',
    'mixtral.',
    'sdxl.',
    'whisper.',
    'dalle.',
    'elevenlabs.',
  ];

  /* AcDoc({
    "summary": "Creates an AIMLAPI client.",
    "params": [
      { "name": "config", "description": "Client configuration with API key, model, and options." }
    ]
  }) */
  AcAIAmlapiClient({required super.config});

  /* AcDoc({
    "summary": "Sends a request via AIMLAPI's unified endpoint.",
    "params": [
      { "name": "request", "description": "The AI request with prompt and model details." }
    ],
    "returns": "Structured AI response object.",
    "returns_type": "AcAIResponse"
  }) */
  @override
  Future<AcAIResponse> send({required AcAIRequest request}) async {
    final result = AcAIResponse();

    try {
      final modelId = config.model.value;

      // Validate allowed model prefixes
      bool isValidModel = _allowedModelPrefixes.any((prefix) => modelId.startsWith(prefix));
      isValidModel = true;
      if (!isValidModel) {
        result.setFailure(message: "Model '${modelId}' is not supported by AIMLAPI.");
        return result;
      }

      final uri = Uri.parse(config.apiUrl.isNotEmpty
          ? config.apiUrl
          : 'https://api.aimlapi.com/api/v1/prompt');

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
          result.setFailure(message: "No response text returned.");
        }
      } else {
        result.setFailure(
          message: rawJson['error']?['message'] ?? "Unknown error from AIMLAPI.",
        );
      }
    } catch (e, stack) {
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }
}
