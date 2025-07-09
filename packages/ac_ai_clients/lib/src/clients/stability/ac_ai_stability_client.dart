import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ac_ai_clients/ac_ai_clients.dart';

/* AcDoc({
  "summary": "Client for Stability AI image generation (Stable Diffusion).",
  "description": "Generates images from text prompts using Stability AI's API. Supports creative control with guidance settings.",
  "author": "Sanket Patel",
  "type": "client",
  "category": "AI",
  "group": "StabilityAI"
}) */
class AcAIStabilityClient extends AcAIClient {
  /* AcDoc({
    "summary": "Initializes the Stability AI client.",
    "params": [
      {
        "name": "config",
        "description": "API key, base URL, and other configuration options."
      }
    ]
  }) */
  AcAIStabilityClient({required super.config});

  /* AcDoc({
    "summary": "Sends a prompt to Stability AI's image generation endpoint.",
    "params": [
      {
        "name": "request",
        "description": "AI input including text prompt and creative settings."
      }
    ],
    "returns": "Structured AI response containing generated image URLs or error information.",
    "returns_type": "AcAIResponse"
  }) */
  @override
  Future<AcAIResponse> send({required AcAIRequest request}) async {
    final result = AcAIResponse();

    try {
      final uri = Uri.parse('${config.apiUrl}/v1/generation/stable-diffusion-v1-5/text-to-image');
      final headers = {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = json.encode({
        'text_prompts': [
          {'text': request.prompt}
        ],
        'cfg_scale': request.creativityLevel ?? 7.0,
        'height': 512,
        'width': 512,
        'samples': 1,
        'steps': 30
      });

      final response = await http.post(uri, headers: headers, body: body);
      final rawJson = json.decode(response.body);
      result.raw = rawJson;

      if (response.statusCode == 200 && rawJson['artifacts'] != null) {
        final images = (rawJson['artifacts'] as List)
            .map((item) => item['base64'] as String?)
            .whereType<String>()
            .toList();

        result.imageUrls = images;
        result.setSuccess(message: 'Image(s) generated successfully');
      } else {
        result.setFailure(message: rawJson['error'] ?? 'Stability AI failed to generate image.');
      }
    } catch (e, stack) {
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }
}
