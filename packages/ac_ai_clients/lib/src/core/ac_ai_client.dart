import 'package:ac_ai_clients/ac_ai_clients.dart';


/* AcDoc({
  "summary": "Abstract base class for all AI clients.",
  "description": "Defines a unified contract and holds the configuration for AI providers like OpenAI, Gemini, Claude, etc. Subclasses must implement `sendRequest` and may use the provided configuration.",
  "author": "Sanket Patel",
  "type": "abstract",
  "category": "AI",
  "group": "Client"
}) */
abstract class AcAIClient {
  /* AcDoc({
    "summary": "The client configuration object.",
    "description": "Holds provider-specific configuration such as model, API key, endpoint, and options like creativity level.",
    "readonly": true
  }) */
  final AcAIClientConfig config;

  /* AcDoc({
    "summary": "Creates an AI client with the given configuration.",
    "params": [
      { "name": "config", "description": "The configuration to use for this client." }
    ]
  }) */
  AcAIClient({required this.config});

  /* AcDoc({
    "summary": "Sends an AI request to the underlying provider and returns a structured response.",
    "description": "Each implementation should map the unified request to provider-specific formats and return a parsed response.",
    "params": [
      { "name": "request", "description": "The AI input request containing model, content, input type, and configuration." }
    ],
    "returns": "A structured response object representing the result of the operation.",
    "returns_type": "AcAIClientResponse"
  }) */
  Future<AcAIResponse> send({required AcAIRequest request});
}
