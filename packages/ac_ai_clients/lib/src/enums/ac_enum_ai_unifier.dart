/* AcDoc({
  "description": "Enumeration of known AI API unifier platforms.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumAIUnifier {
  /* AcDoc({
    "description": "AIMLAPI - Unified OpenAI-compatible API to access Gemini, Claude, Mistral, etc.",
    "url": "https://aimlapi.com"
  }) */
  aimlapi("aimlapi"),

  /* AcDoc({
    "description": "PromptLayer - Unified API and logging layer for LLMs.",
    "url": "https://promptlayer.com"
  }) */
  promptlayer("promptlayer"),

  /* AcDoc({
    "description": "LangChain's LLM abstraction - Unified LLM interface in code.",
    "url": "https://www.langchain.com"
  }) */
  langchain("langchain"),

  /* AcDoc({
    "description": "BerriAI - Unified LLM gateway with routing, caching, and logging.",
    "url": "https://berri.ai"
  }) */
  berriai("berriai"),

  /* AcDoc({
    "description": "OpenRouter - API unifier for various LLMs with OpenAI-compatible format.",
    "url": "https://openrouter.ai"
  }) */
  openrouter("openrouter"),

  /* AcDoc({
    "description": "Unify.AI - General-purpose model routing/unification platform.",
    "url": "https://unify.ai"
  }) */
  unifyai("unifyai");

  /// The identifier string value.
  final String value;

  /// Constructor to associate string identifier.
  const AcEnumAIUnifier(this.value);

  /// Resolves from string value.
  static AcEnumAIUnifier? fromValue(String value) {
    try {
      return AcEnumAIUnifier.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /// Compares with another string.
  bool equals(String other) => value == other;

  @override
  String toString() => value;
}
