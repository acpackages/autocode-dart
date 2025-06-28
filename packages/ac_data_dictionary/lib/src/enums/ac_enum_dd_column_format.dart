/* AcDoc({
  "description": "Enumeration of column format types used in a data dictionary schema.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumDDColumnFormat {
  /* AcDoc({"description": "Represents a date format (e.g., YYYY-MM-DD)."}) */
  date("date"),

  /* AcDoc({"description": "Indicates the column should be encrypted."}) */
  encrypt("encrypt"),

  /* AcDoc({"description": "Hides the column from display or output."}) */
  hideColumn("hide_column"),

  /* AcDoc({"description": "Denotes that the column stores JSON-formatted data."}) */
  json("json"),

  /* AcDoc({"description": "Forces the value to be stored or displayed in lowercase."}) */
  lowercase("lowercase"),

  /* AcDoc({"description": "Forces the value to be stored or displayed in uppercase."}) */
  uppercase("uppercase");

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
