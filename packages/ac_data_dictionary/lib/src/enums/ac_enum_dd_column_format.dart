import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of column format types used in a data dictionary schema.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumDDColumnFormat {
  /* AcDoc({"description": "Represents a date format (e.g., YYYY-MM-DD)."}) */
  date("DATE"),

  /* AcDoc({"description": "Indicates the column should be encrypted."}) */
  encrypt("ENCRYPT"),

  /* AcDoc({"description": "Hides the column from display or output."}) */
  hideColumn("HIDE_COLUMN"),

  /* AcDoc({"description": "Denotes that the column stores JSON-formatted data."}) */
  json("JSON"),

  /* AcDoc({"description": "Forces the value to be stored or displayed in lowercase."}) */
  lowercase("LOWERCASE"),

  /* AcDoc({"description": "Forces the value to be stored or displayed in uppercase."}) */
  uppercase("UPPERCASE");

  /* AcDoc({"description": "The string representation of the column format."}) */
  final String value;

  /* AcDoc({"description": "Constructor assigning a string value to the enum."}) */
  const AcEnumDDColumnFormat(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumDDColumnFormat? fromValue(String value) {
    try {
      return AcEnumDDColumnFormat.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if this enum's value matches the provided string.",
    "params": [{"name": "other", "description": "The string to compare with."}],
    "returns": "true if the string matches, otherwise false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the column format as a string."}) */
  @override
  String toString() => value;
}
