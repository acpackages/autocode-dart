import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ac_ai_clients/ac_ai_clients.dart';
import 'package:autocode/autocode.dart';
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
  AcAIGeminiClient({required super.config});

  @override
  Future<AcAIResponse> send({required AcAIRequest request}) async {
    final result = AcAIResponse();

    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/${config.model.value}:generateContent?key=${config.apiKey}',
      );

      final headers = {
        'Content-Type': 'application/json',
      };

      final List<Map<String, dynamic>> parts = [];

      // Add prompt text
      if (request.prompt.trim().isNotEmpty) {
        parts.add({"text": request.prompt.trim()});
      }

      // Add multimodal files if provided
      final List<Uint8List> fileBytesList = [];

      // From Uint8List
      if (request.files != null && request.files!.isNotEmpty) {
        for (int i = 0; i < request.files!.length; i++) {
          final bytes = request.files![i];
          final filename = (request.fileNames != null && i < request.fileNames!.length)? request.fileNames![i]: 'file$i';
          final mimeType = AcFileUtils.getMimeTypeFromName(filename);
          parts.add({
            "inlineData": {
              "mimeType": mimeType,
              "data": base64Encode(bytes),
            }
          });
        }
      }

      // From file paths
      if (request.filePaths != null && request.filePaths!.isNotEmpty) {
        for (final path in request.filePaths!) {
          final file = File(path);
          if (await file.exists()) {
            final mimeType = AcFileUtils.getMimeTypeFromPath(file.path);
            parts.add({
              "inlineData": {
                "mimeType": mimeType,
                "data": base64Encode(await file.readAsBytes()),
              }
            });
          }
        }
      }



      final body = {
        "contents": [
          {
            "parts": parts,
          }
        ],
        "generationConfig": {
          "temperature": request.creativityLevel ?? 0.7,
          if (request.maxTokens != null) "maxOutputTokens": request.maxTokens,
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
        result.setFailure(message: rawJson['error']?['message'] ?? "Unknown error from Gemini.");
      }
    } catch (e, stack) {
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }
}
