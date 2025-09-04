import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of supported AI API providers.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumAIProvider {
  /* AcDoc({"description": "Amazon Bedrock platform for hosted AI services (e.g., Titan, Claude, Cohere)."}) */
  amazon("amazon"),

  /* AcDoc({"description": "Anyscale APIs for scalable open-source LLM inference."}) */
  anyscale("anyscale"),

  /* AcDoc({"description": "Anthropic Claude language model API."}) */
  claude("claude"),

  /* AcDoc({"description": "Cohere language and embedding API platform."}) */
  cohere("cohere"),

  /* AcDoc({"description": "DeepInfra model inference service for open-source models."}) */
  deepinfra("deepinfra"),

  /* AcDoc({"description": "ElevenLabs API for text-to-speech and voice cloning."}) */
  elevenlabs("elevenlabs"),

  /* AcDoc({"description": "Forefront AI multi-LLM chat platform (e.g., Claude, Mistral)."}) */
  forefront("forefront"),

  /* AcDoc({"description": "Google Gemini (formerly Bard) API platform."}) */
  gemini("gemini"),

  /* AcDoc({"description": "Groq LPU-accelerated API for LLaMA, Mixtral, and more."}) */
  groq("groq"),

  /* AcDoc({"description": "HuggingFace model hub and inference APIs for text, vision, audio, etc."}) */
  huggingface("huggingface"),

  /* AcDoc({"description": "Meta AI open-source model provider (e.g., LLaMA, MusicGen, SAM)."}) */
  meta("meta"),

  /* AcDoc({"description": "Midjourney image generation via Discord bot."}) */
  midjourney("midjourney"),

  /* AcDoc({"description": "Microsoft Azure AI services (OpenAI, Speech, Vision, etc.)."}) */
  microsoft("microsoft"),

  /* AcDoc({"description": "Mistral language model API (open-weight models like Mixtral)."}) */
  mistral("mistral"),

  /* AcDoc({"description": "OpenAI platform (ChatGPT, DALL·E, Whisper, etc.)."}) */
  openai("openai"),

  /* AcDoc({"description": "Perplexity AI conversational + retrieval API (in beta)."}) */
  perplexity("perplexity"),

  /* AcDoc({"description": "Pika Labs video generation via Discord (experimental)."}) */
  pika("pika"),

  /* AcDoc({"description": "Playground AI image generation tools."}) */
  playground("playground"),

  /* AcDoc({"description": "Replicate model hosting and multi-modal inference platform."}) */
  replicate("replicate"),

  /* AcDoc({"description": "RunwayML video generation and editing platform."}) */
  runwayml("runwayml"),

  /* AcDoc({"description": "Stability AI's image generation platform (Stable Diffusion)."}) */
  stability("stability"),

  /* AcDoc({"description": "Together.ai inference platform for open-source LLMs."}) */
  together("together"),

  /* AcDoc({"description": "Vocode conversational voice and TTS/STT framework."}) */
  vocode("vocode"),

  /* AcDoc({"description": "VoiceMod real-time TTS/voice transformation API."}) */
  voicemod("voicemod");

  /* AcDoc({"description": "The string identifier used for this AI provider."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns the string name to the enum value."}) */
  const AcEnumAIProvider(this.value);

  /* AcDoc({
    "description": "Resolves an enum value from its string representation.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "Matching enum instance or null if unmatched."
  }) */
  static AcEnumAIProvider? fromValue(String value) {
    try {
      return AcEnumAIProvider.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Compares this enum's string value to another.",
    "params": [{"name": "other", "description": "The string to compare against."}],
    "returns": "true if values match, false otherwise."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the provider value as a string."}) */
  @override
  String toString() => value;
}
