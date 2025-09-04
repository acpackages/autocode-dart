import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of AI response types supported by the ACAIApi package.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumAIResponseType {
  /* AcDoc({"description": "Textual response such as natural language or code generation."}) */
  text("text"),

  /* AcDoc({"description": "Generated image response (e.g., DALL·E output)."}) */
  image("image"),

  /* AcDoc({"description": "Audio response, including speech synthesis or audio data."}) */
  audio("audio"),

  /* AcDoc({"description": "Video response, typically generated via text-to-video models."}) */
  video("video"),

  /* AcDoc({"description": "General binary file response, used for document or raw data output."}) */
  file("file");

  /* AcDoc({"description": "The string representation of the response type."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns the string value to the enum."}) */
  const AcEnumAIResponseType(this.value);

  /* AcDoc({
    "description": "Parses a string and returns the corresponding enum value.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumAIResponseType? fromValue(String value) {
    try {
      return AcEnumAIResponseType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if the given string matches this enum's value.",
    "params": [{"name": "other", "description": "The string to compare with."}],
    "returns": "true if it matches, false otherwise."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the enum's string value."}) */
  @override
  String toString() => value;
}
