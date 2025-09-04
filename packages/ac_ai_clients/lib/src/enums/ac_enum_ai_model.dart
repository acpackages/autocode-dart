import 'package:ac_mirrors/ac_mirrors.dart';
/* AcDoc({
  "description": "Enumeration of all known AI models (mid‑2025), covering text, multimodal, image, audio, and video.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumAIModel {
  // ------------------------------- OpenAI -------------------------------
  /* AcDoc({"description": "OpenAI GPT-4 model."}) */
  openaiGpt4("gpt-4"),

  /* AcDoc({"description": "OpenAI GPT-4 Turbo model."}) */
  openaiGpt4Turbo("gpt-4-turbo"),

  /* AcDoc({"description": "OpenAI GPT-4o (omni) multimodal model."}) */
  openaiGpt4o("gpt-4o"),

  /* AcDoc({"description": "OpenAI GPT-4.5 (Orion) model."}) */
  openaiGpt45("gpt-4.5"),

  /* AcDoc({"description": "OpenAI GPT-3.5 Turbo model."}) */
  openaiGpt35Turbo("gpt-3.5-turbo"),

  /* AcDoc({"description": "OpenAI GPT‑3.5 Turbo 16k model."}) */
  openaiGpt35Turbo16k("gpt-3.5-turbo-16k"),

  /* AcDoc({"description": "OpenAI Codex model (o1)."}) */
  openaiCodexO1("code-davinci-o1"),

  /* AcDoc({"description": "OpenAI Whisper speech-to-text model."}) */
  openaiWhisper1("whisper-1"),

  /* AcDoc({"description": "OpenAI DALL·E 2 image model."}) */
  openaiDalle2("dall-e-2"),

  /* AcDoc({"description": "OpenAI DALL·E 3 image model."}) */
  openaiDalle3("dall-e-3"),

  // ------------------------------- Anthropic Claude -------------------------------
  /* AcDoc({"description": "Claude Instant 1.2 (fast, lightweight)."}) */
  claudeInstant12("claude-instant-1.2"),

  /* AcDoc({"description": "Claude 2.0 model."}) */
  claude20("claude-2.0"),

  /* AcDoc({"description": "Claude 2.1 model."}) */
  claude21("claude-2.1"),

  /* AcDoc({"description": "Claude 3 Haiku (fast)."}) */
  claude3Haiku("claude-3-haiku-20240307"),

  /* AcDoc({"description": "Claude 3 Sonnet (balanced)."}) */
  claude3Sonnet("claude-3-sonnet-20240229"),

  /* AcDoc({"description": "Claude 3 Opus (powerful)."}) */
  claude3Opus("claude-3-opus-20240229"),

  /* AcDoc({"description": "Claude 3.5 Sonnet v2."}) */
  claude35Sonnet("claude-3.5-sonnet-v2"),

  /* AcDoc({"description": "Claude 3.5 Haiku v2."}) */
  claude35Haiku("claude-3.5-haiku-v2"),

  /* AcDoc({"description": "Claude 3.7 Sonnet (hybrid model)."}) */
  claude37Sonnet("claude-3.7-sonnet"),

  /* AcDoc({"description": "Claude 4 Opus (latest)."}) */
  claude4Opus("claude-4-opus"),

  /* AcDoc({"description": "Claude 4 Sonnet (latest balanced)."}) */
  claude4Sonnet("claude-4-sonnet"),

  // ------------------------------- Google Gemini -------------------------------
  /* AcDoc({"description": "Gemini 1.0 Pro model."}) */
  geminiPro("gemini-pro"),

  /* AcDoc({"description": "Gemini 1.0 Ultra model."}) */
  geminiUltra("gemini-ultra"),

  /* AcDoc({"description": "Gemini 1.5 Pro model."}) */
  gemini15Pro("gemini-1.5-pro"),

  /* AcDoc({"description": "Gemini 1.5 Flash (lightweight)."}) */
  gemini15Flash("gemini-1.5-flash"),

  /* AcDoc({"description": "Gemini 2.5 Pro (latest as of Mar 2025)."}) */
  gemini25Pro("gemini-2.5-pro"),

  /* AcDoc({"description": "Gemini Pro Vision (multimodal)."}) */
  geminiProVision("gemini-pro-vision"),

  // ------------------------------- Meta LLaMA -------------------------------
  /* AcDoc({"description": "LLaMA3 8B Instruct model."}) */
  metaLlama38b("llama3-8b"),

  /* AcDoc({"description": "LLaMA3 70B Instruct model."}) */
  metaLlama370b("llama3-70b"),

  // ------------------------------- Mistral -------------------------------
  /* AcDoc({"description": "Mistral Tiny model."}) */
  mistralTiny("mistral-tiny"),

  /* AcDoc({"description": "Mistral Small model."}) */
  mistralSmall("mistral-small"),

  /* AcDoc({"description": "Mistral Medium model."}) */
  mistralMedium("mistral-medium"),

  /* AcDoc({"description": "Mistral 7B Instruct model."}) */
  mistral7bInstruct("mistral-7b-instruct-v0.2"),

  /* AcDoc({"description": "Mixtral 8x7B Instruct (Mixture of Experts)."}) */
  mixtral8x7bInstruct("mixtral-8x7b-instruct-v0.1"),

  // ------------------------------- Stability AI -------------------------------
  /* AcDoc({"description": "Stable Diffusion v1 base image model."}) */
  stabilitySdV1("stable-diffusion-1"),

  /* AcDoc({"description": "Stable Diffusion v2 base image model."}) */
  stabilitySdV2("stable-diffusion-2"),

  /* AcDoc({"description": "Stable Diffusion XL (SDXL) image model."}) */
  stabilitySdxl("stable-diffusion-xl-1024-v1-0"),

  /* AcDoc({"description": "SDXL Refiner model."}) */
  stabilitySdxlRefiner("stable-diffusion-xl-refiner-1024-v1-0"),

  /* AcDoc({"description": "Stable Cascade model."}) */
  stabilityCascade("stable-cascade"),

  /* AcDoc({"description": "Stable Cascade Refiner model."}) */
  stabilityCascadeRefiner("stable-cascade-refiner"),

  // ------------------------------- ElevenLabs -------------------------------
  /* AcDoc({"description": "ElevenLabs standard TTS model."}) */
  elevenlabsStandard("elevenlabs-standard"),

  /* AcDoc({"description": "ElevenLabs multilingual v1 TTS model."}) */
  elevenlabsMultilingualV1("elevenlabs-multilingual-v1"),

  /* AcDoc({"description": "ElevenLabs multilingual v2 TTS model."}) */
  elevenlabsMultilingualV2("elevenlabs-multilingual-v2"),

  // ------------------------------- RunwayML -------------------------------
  /* AcDoc({"description": "RunwayML Gen-2 video generation model."}) */
  runwaymlGen2("gen-2"),

  // ------------------------------- Pika Labs -------------------------------
  /* AcDoc({"description": "Pika Labs Gen-1 video generation model."}) */
  pikaGen1("pika-gen-1"),

  // ------------------------------- Midjourney (abstract) -------------------------------
  /* AcDoc({"description": "Midjourney v5 image generation model."}) */
  midjourneyV5("midjourney-v5"),

  /* AcDoc({"description": "Midjourney v6 image generation model."}) */
  midjourneyV6("midjourney-v6"),

  // ------------------------------- Unknown Fallback -------------------------------
  /* AcDoc({"description": "Fallback when model is not recognized."}) */
  unknown("unknown");

  /// The actual API model ID to use in requests
  final String value;

  const AcEnumAIModel(this.value);

  static AcEnumAIModel? fromValue(String value) {
    try {
      return AcEnumAIModel.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  bool equals(String other) => value == other;

  @override
  String toString() => value;
}
