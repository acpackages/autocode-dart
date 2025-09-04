import 'package:ac_mirrors/ac_mirrors.dart';
/* AcDoc({
  "description": "Enumerates the types of inputs that can be sent to an AI model.",
  "author": "Sanket Patel",
  "type": "enum",
  "category": "AI",
  "group": "Input Type",
  "tags": ["input", "enum", "media", "modality"]
}) */
@AcReflectable()
enum AcEnumAIInputType {
  /* AcDoc({"description": "Represents a plain text input prompt."}) */
  text("text"),

  /* AcDoc({"description": "Indicates the input is one or more image files."}) */
  image("image"),

  /* AcDoc({"description": "Specifies an audio input (e.g., voice prompt)."}) */
  audio("audio"),

  /* AcDoc({"description": "Indicates video input is being provided."}) */
  video("video"),

  /* AcDoc({"description": "Specifies a document input (e.g., PDF, DOCX)."}) */
  document("document"),

  /* AcDoc({"description": "Used when input type is unknown or not specified."}) */
  unknown("unknown");

  /* AcDoc({"description": "The string value representation of this enum type."}) */
  final String value;

  /* AcDoc({"description": "Constructor for assigning string value to enum type."}) */
  const AcEnumAIInputType(this.value);

  /* AcDoc({
    "description": "Gets the enum from its string value, if valid.",
    "params": [{"name": "value", "description": "The string to match."}],
    "returns": "The corresponding enum or null if not found."
  }) */
  static AcEnumAIInputType? fromValue(String value) {
    try {
      return AcEnumAIInputType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks whether this enum's string value equals the given string.",
    "params": [{"name": "other", "description": "The string to compare."}],
    "returns": "true if values match."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the enum as a string."}) */
  @override
  String toString() => value;
}
