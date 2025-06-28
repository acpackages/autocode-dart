/* AcDoc({
  "description": "Enumeration of select modes used in the data dictionary query system.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumDDSelectMode {
  /* AcDoc({"description": "Selects all rows that match the query conditions."}) */
  all("all"),

  /* AcDoc({"description": "Counts the number of rows that match the query conditions."}) */
  count("count"),

  /* AcDoc({"description": "Selects the first row that matches the query conditions."}) */
  first("first"),

  /* AcDoc({"description": "Selects a list of rows that match the query conditions."}) */
  list("list"),

  /* AcDoc({"description": "Selects a list of rows along with the total count of matched rows."}) */
  listWithCount("list_with_count");

  /* AcDoc({"description": "The string representation of the select mode."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string value to the enum."}) */
  const AcEnumDDSelectMode(this.value);

  /* AcDoc({
    "description": "Returns the enum constant that matches the provided string value.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum constant, or null if no match is found."
  }) */
  static AcEnumDDSelectMode? fromValue(String value) {
    try {
      return AcEnumDDSelectMode.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks whether this enum's value is equal to the provided string.",
    "params": [{"name": "other", "description": "The string to compare with."}],
    "returns": "true if the values are equal, otherwise false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the string representation of the select mode."}) */
  @override
  String toString() => value;
}
